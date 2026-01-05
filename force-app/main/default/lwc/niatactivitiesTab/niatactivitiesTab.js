import { LightningElement, wire, track } from 'lwc';
import getActivities from '@salesforce/apex/ActivitiesController.getActivities';

export default class ActivitiesTab extends LightningElement {
    // ===== CONFIGURATION: Change this value to set number of records per page =====
    RECORDS_PER_PAGE = 5;
    
    // Tab values are now the category enums directly (lead_activity, agent_task, etc.)
    // This eliminates conditional logic and makes it easy to add new tabs
    @track tabData = {
        'lead_activity': {
            allActivities: [],
            displayedActivities: [],
            currentPage: 1,
            filters: {
                fromDate: null,
                toDate: null,
                offset: 0,
                limit: 10
            }
        },
        'agent_task': {
            allActivities: [],
            displayedActivities: [],
            currentPage: 1,
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
    @track currentTab = 'lead_activity'; // Tab value is now the category enum
    @track previousTab = 'lead_activity';
    
    @track totalRecords = 0;
    @track showFilterModal = false;

    get tabs() {
        return [
            { label: 'Activities', value: 'lead_activity' },
            { label: 'Tasks', value: 'agent_task' },
        ];
    }

    get activeTabValue() {
        return 'lead_activity';
    }
    
    // Helper getter to get current tab's data
    get currentTabData() {
        return this.tabData[this.currentTab] || this.tabData['lead_activity'];
    }
    
    get filters() {
        return this.currentTabData.filters;
    }

    connectedCallback() {
        // Initialize limit for all tabs from configurable RECORDS_PER_PAGE
        Object.keys(this.tabData).forEach(tabKey => {
            this.tabData[tabKey].filters.limit = this.RECORDS_PER_PAGE;
        });
    }

    // Computed properties for wire service reactivity
    // Tab value is now the category enum directly, so we can use it as-is
    get currentActivityCategory() {
        return this.currentTab; // Tab value is the category enum
    }
    
    get currentFromDate() {
        return this.currentTabData.filters.fromDate || null;
    }
    
    get currentToDate() {
        return this.currentTabData.filters.toDate || null;
    }
    
    get currentOffset() {
        return this.currentTabData.filters.offset;
    }
    
    get currentLimit() {
        return this.currentTabData.filters.limit;
    }

    @wire(getActivities, {
        activityCategory: '$currentActivityCategory',
        fromDate: '$currentFromDate',
        toDate: '$currentToDate',
        offset: '$currentOffset',
        limitRecords: '$currentLimit'
    })
    wiredActivities({ error, data }) {
        // Always set loading to false when wire completes (with data or error)
        this.isLoading = false;
        
        if (data) {
            try {
                // Parse JSON string response (Salesforce wire service may auto-parse)
                let parsedData;
                if (typeof data === 'string') {
                    parsedData = JSON.parse(data);
                } else {
                    parsedData = data;
                }
                // Deep clone to convert Proxy objects to plain objects
                const newActivities = JSON.parse(JSON.stringify(parsedData.activities || []));
                
                // Store total records for pagination display
                this.totalRecords = parsedData.total_records || 0;
                
                // Get existing data for current tab before updating
                const existingData = this.currentTabData.allActivities;
                
                // Check if this is a tab switch (tab changed) vs filter change
                const isTabSwitch = this.currentTab !== this.previousTab;
                
                // Check if data actually changed (filters changed)
                const dataChanged = existingData.length === 0 || 
                    JSON.stringify(existingData.map(a => a.id).sort()) !== 
                    JSON.stringify(newActivities.map(a => a.id).sort());
                
                // Store new activities for current tab
                this.currentTabData.allActivities = newActivities;
                
                // Only reset pagination if filters changed or first load
                // Preserve page number when just switching tabs
                if (!(isTabSwitch && existingData.length > 0 && !dataChanged)) {
                    if (dataChanged || existingData.length === 0) {
                        this.resetPaginationForCurrentTab();
                    }
                }
                
                // Update previousTab to currentTab after processing
                // This ensures next wire execution knows we're not switching tabs anymore
                this.previousTab = this.currentTab;
                
                // Update displayed activities (accumulating style)
                this.updateDisplayedActivities();
                
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

    updateDisplayedActivities() {
        const recordsToShow = this.currentTabData.currentPage * this.RECORDS_PER_PAGE;
        this.currentTabData.displayedActivities = this.currentTabData.allActivities.slice(0, recordsToShow);
    }

    handleTabChange(event) {
        const { value } = event.detail;
        this.previousTab = this.currentTab; // Store previous tab
        this.currentTab = value; // Tab value is the category enum
        
        // Check if the new tab already has data loaded
        const newTabData = this.tabData[value];
        if (newTabData && newTabData.allActivities.length > 0) {
            // Tab already has data, restore the displayed activities immediately
            this.updateDisplayedActivities();
        }
        // Wire will automatically re-execute with new category based on current tab
    }

    handleFilterChange(event) {
        const filterName = event.currentTarget.dataset.filter;
        const filterValue = event.target.value || null; // Convert empty string to null
        
        this.currentTabData.filters = { 
            ...this.currentTabData.filters, 
            [filterName]: filterValue, 
            offset: 0 
        };
        this.currentTabData.currentPage = 1;
        this.currentTabData.displayedActivities = [];
    }
    
    resetPaginationForCurrentTab() {
        this.currentTabData.currentPage = 1;
        this.currentTabData.displayedActivities = [];
    }

    openFilterModal() {
        this.showFilterModal = true;
    }

    closeFilterModal() {
        this.showFilterModal = false;
    }

    applyFilters() {
        this.currentTabData.filters = { ...this.currentTabData.filters, offset: 0 };
        this.resetPaginationForCurrentTab();
        this.closeFilterModal();
    }

    clearFilters() {
        // Reset filters to empty state (no filters applied)
        this.currentTabData.filters = { 
            ...this.currentTabData.filters, 
            fromDate: null, 
            toDate: null, 
            offset: 0 
        };
        this.resetPaginationForCurrentTab();
    }

    handleModalBackdropClick(event) {
        // Close modal when clicking on backdrop
        if (event.target === event.currentTarget) {
            this.closeFilterModal();
        }
    }

    handlePrevious() {
        if (this.currentTabData.currentPage > 1) {
            this.currentTabData.currentPage--;
            this.updateDisplayedActivities();
        }
    }

    handleLoadMore() {
        if (this.currentTabData.displayedActivities.length < this.currentTabData.allActivities.length) {
            this.currentTabData.currentPage++;
            this.updateDisplayedActivities();
        }
    }

    formatDate(dateString) {
        if (!dateString) return '—';
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString();
        } catch (e) {
            return dateString;
        }
    }

    get showPreviousButton() {
        return this.currentTabData.currentPage > 1;
    }

    get showLoadMoreButton() {
        return this.currentTabData.displayedActivities.length < this.currentTabData.allActivities.length;
    }

    get loadMoreButtonClass() {
        return this.showPreviousButton ? "slds-m-left_x-small" : "";
    }

    get errorMessage() {
        if (!this.error) return 'Unknown error';
        return this.error.body?.message || this.error.message || 'Unknown error';
    }

    // Generic getter for current tab's activities (works for any tab)
    get currentTabActivities() {
        return this.currentTabData.displayedActivities.map(activity => ({
            ...activity,
            formattedDueDate: this.formatDate(activity.due_date),
            formattedCompletedAt: this.formatDate(activity.completed_at)
        }));
    }
    
    // Keep these for backward compatibility with HTML template
    get activitiesTabActivities() {
        // If on lead_activity tab, return current tab activities, otherwise return empty
        return this.currentTab === 'lead_activity' ? this.currentTabActivities : [];
    }

    get tasksTabActivities() {
        // If on agent_task tab, return current tab activities, otherwise return empty
        return this.currentTab === 'agent_task' ? this.currentTabActivities : [];
    }

    get currentTabPaginationDisplay() {
        const count = this.currentTabActivities.length;
        return {
            start: count > 0 ? 1 : 0,
            end: count,
            total: this.totalRecords || this.currentTabData.allActivities.length
        };
    }
    
    // Keep these for backward compatibility with HTML template
    get activitiesTabPaginationDisplay() {
        return this.currentTab === 'lead_activity' ? this.currentTabPaginationDisplay : { start: 0, end: 0, total: 0 };
    }

    get tasksTabPaginationDisplay() {
        return this.currentTab === 'agent_task' ? this.currentTabPaginationDisplay : { start: 0, end: 0, total: 0 };
    }


}
