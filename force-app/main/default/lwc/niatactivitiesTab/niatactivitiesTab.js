import { LightningElement, wire, track } from 'lwc';
import getActivities from '@salesforce/apex/ActivitiesController.getActivities';

export default class ActivitiesTab extends LightningElement {
    // ===== CONFIGURATION =====
    PAGE_SIZE = 10; // Records displayed per page (also used as API limit)
    
    // Activity filter enum values
    static LEAD_ACTIVITY_ENUM = 'LEAD_ACTIVITY';
    static TASK_ENUM = 'TASK';
    
    @track tabData = {
        'LEAD_ACTIVITY': {
            allActivities: [],    // Accumulated activities from all API calls
            currentPage: 1,       // Current page for client-side pagination
            totalRecords: 0,      // Total records available on server
            hasMore: false,       // Whether server has more records
            nextOffset: 0,        // Next offset for Load More
            filters: {
                fromDate: null,
                toDate: null,
                offset: 0,
                limit: 10
            }
        },
        'TASK': {
            allActivities: [],
            currentPage: 1,
            totalRecords: 0,
            hasMore: false,
            nextOffset: 0,
            filters: {
                fromDate: null,
                toDate: null,
                offset: 0,
                limit: 10
            }
        }
    };
    
    @track isLoading = true;
    @track error;
    @track currentTab = 'LEAD_ACTIVITY';
    @track showFilterModal = false;
    @track opportunityId = null; // Can be set from parent component or URL params

    // Tab configuration
    get tabs() {
        return [
            { label: 'Activities', value: 'LEAD_ACTIVITY' },
            { label: 'Tasks', value: 'TASK' },
        ];
    }

    get activeTabValue() {
        return 'LEAD_ACTIVITY';
    }
    
    // Current tab's data helper
    get currentTabData() {
        return this.tabData[this.currentTab];
    }
    
    get filters() {
        return this.currentTabData.filters;
    }

    // Wire service reactive getters
    get currentOpportunityId() {
        return this.opportunityId;
    }
    
    get currentActivityFilter() {
        // Return array with current tab's enum value
        return [this.currentTab];
    }
    
    get currentDateFilter() {
        // Return date_filter object with from_date and to_date
        const fromDate = this.currentTabData.filters.fromDate || '';
        const toDate = this.currentTabData.filters.toDate || '';
        return {
            from_date: fromDate,
            to_date: toDate
        };
    }
    
    get currentOffset() {
        return this.currentTabData.filters.offset;
    }
    
    get currentLimit() {
        return this.currentTabData.filters.limit;
    }

    @wire(getActivities, {
        opportunityId: '$currentOpportunityId',
        activityFilter: '$currentActivityFilter',
        dateFilter: '$currentDateFilter',
        offset: '$currentOffset',
        limitRecords: '$currentLimit'
    })
    wiredActivities({ error, data }) {
        this.isLoading = false;
        
        if (data) {
            try {
                // Parse response
                const parsedData = typeof data === 'string' ? JSON.parse(data) : data;
                const newActivities = JSON.parse(JSON.stringify(parsedData.activities || []));
                const currentOffset = this.currentTabData.filters.offset;
                
                if (currentOffset === 0) {
                    // First load or filter change: REPLACE all activities
                    this.currentTabData.allActivities = newActivities;
                    this.currentTabData.currentPage = 1; // Reset to page 1
                } else {
                    // Load More: APPEND to existing activities
                    const existingIds = new Set(this.currentTabData.allActivities.map(a => a.id));
                    const uniqueNewActivities = newActivities.filter(a => !existingIds.has(a.id));
                    this.currentTabData.allActivities = [...this.currentTabData.allActivities, ...uniqueNewActivities];
                    // Increment page to show the newly loaded data in accumulating view
                    this.currentTabData.currentPage++;
                }
                
                // Update pagination metadata from API response (new format uses 'total' instead of 'total_records')
                this.currentTabData.totalRecords = parsedData.total || 0;
                // Calculate hasMore based on total and current loaded count
                const totalLoaded = this.currentTabData.allActivities.length;
                this.currentTabData.hasMore = totalLoaded < this.currentTabData.totalRecords;
                this.currentTabData.nextOffset = currentOffset + this.PAGE_SIZE;
                
                this.error = undefined;
            } catch (parseError) {
                this.error = { message: 'Failed to parse response: ' + parseError.message };
                console.error('Error parsing activities:', parseError, 'Raw data:', data);
            }
        } else if (error) {
            this.error = error;
            console.error('Error loading activities:', error);
        }
    }

    // ===== EVENT HANDLERS =====
    
    handleTabChange(event) {
        const { value } = event.detail;
        this.currentTab = value;
        // Wire service will re-execute with new category
        // Each tab's data is preserved in tabData object
    }


    handlePrevious() {
        if (this.currentTabData.currentPage > 1) {
            this.currentTabData.currentPage--;
        }
    }

    handleLoadMore() {
        const tabData = this.currentTabData;
        const currentlyDisplayed = tabData.currentPage * this.PAGE_SIZE;
        
        if (currentlyDisplayed < tabData.allActivities.length) {
            // We have more records in already loaded data - show next batch
            tabData.currentPage++;
        } else if (tabData.hasMore) {
            // Need to fetch more from server
            this.isLoading = true;
            tabData.filters = {
                ...tabData.filters,
                offset: tabData.nextOffset
            };
            // Wire service will auto re-execute and append results
        }
    }

    // ===== FILTER MODAL HANDLERS =====
    
    openFilterModal() {
        this.showFilterModal = true;
    }

    closeFilterModal() {
        this.showFilterModal = false;
    }

    applyFilters() {
        // Read current values from the lightning-input elements in the modal
        const fromDateInput = this.template.querySelector('lightning-input[data-filter="fromDate"]');
        const toDateInput = this.template.querySelector('lightning-input[data-filter="toDate"]');
        
        const fromDate = fromDateInput?.value || null;
        const toDate = toDateInput?.value || null;
        
        // Reset offset to 0 and clear existing data when applying new filters
        this.currentTabData.filters = { 
            ...this.currentTabData.filters, 
            fromDate: fromDate,
            toDate: toDate,
            offset: 0 
        };
        this.currentTabData.allActivities = [];
        this.currentTabData.currentPage = 1;
        this.isLoading = true;
        this.closeFilterModal();
        // Wire service will re-execute with new filters
    }

    clearFilters() {
        // Reset all filters and offset
        this.currentTabData.filters = { 
            ...this.currentTabData.filters, 
            fromDate: null, 
            toDate: null, 
            offset: 0 
        };
        this.currentTabData.allActivities = [];
        this.currentTabData.currentPage = 1;
        this.isLoading = true;
        // Wire service will re-execute
    }

    handleModalBackdropClick(event) {
        if (event.target === event.currentTarget) {
            this.closeFilterModal();
        }
    }

    handleTitleClick(event) {
        event.preventDefault();
    }

    // ===== COMPUTED PROPERTIES =====

    formatDate(dateString) {
        if (!dateString) return '—';
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString();
        } catch (e) {
            return dateString;
        }
    }

    // Get activities up to current page (accumulating display)
    // Page 1: records 0-9, Page 2: records 0-19, Page 3: records 0-29
    get displayedActivities() {
        const tabData = this.currentTabData;
        const endIndex = tabData.currentPage * this.PAGE_SIZE;
        return tabData.allActivities.slice(0, endIndex);
    }

    get showPreviousButton() {
        // Show Previous when we're displaying more than first page worth of records
        return this.currentTabData.currentPage > 1;
    }

    get showLoadMoreButton() {
        const tabData = this.currentTabData;
        const currentlyDisplayed = tabData.currentPage * this.PAGE_SIZE;
        // Show if we have more local data to display OR server has more data
        return (currentlyDisplayed < tabData.allActivities.length) || tabData.hasMore;
    }

    get loadMoreButtonClass() {
        return this.showPreviousButton ? 'slds-m-left_x-small' : '';
    }

    get errorMessage() {
        if (!this.error) return 'Unknown error';
        return this.error.body?.message || this.error.message || 'Unknown error';
    }

    // Activities for current page with formatted dates
    get currentTabActivities() {
        return this.displayedActivities.map(activity => ({
            ...activity,
            formattedActivityDateTime: this.formatDate(activity.activity_datetime)
        }));
    }
    
    // Tab-specific getters for HTML template compatibility
    get activitiesTabActivities() {
        return this.currentTab === 'LEAD_ACTIVITY' ? this.currentTabActivities : [];
    }

    get tasksTabActivities() {
        return this.currentTab === 'TASK' ? this.currentTabActivities : [];
    }

    // Pagination display for current tab (accumulating display)
    get currentTabPaginationDisplay() {
        const tabData = this.currentTabData;
        const displayed = this.displayedActivities.length;
        const total = tabData.totalRecords || tabData.allActivities.length;
        
        if (displayed === 0) {
            return { start: 0, end: 0, total: total };
        }
        
        // Always starts from 1 since we're accumulating
        return {
            start: 1,
            end: displayed,
            total: total
        };
    }
    
    // Tab-specific pagination getters for HTML template compatibility
    get activitiesTabPaginationDisplay() {
        return this.currentTab === 'LEAD_ACTIVITY' ? this.currentTabPaginationDisplay : { start: 0, end: 0, total: 0 };
    }

    get tasksTabPaginationDisplay() {
        return this.currentTab === 'TASK' ? this.currentTabPaginationDisplay : { start: 0, end: 0, total: 0 };
    }
}
