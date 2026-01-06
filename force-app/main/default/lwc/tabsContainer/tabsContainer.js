import { LightningElement, api } from 'lwc';

export default class TabsContainer extends LightningElement {
    @api tabs = []; // Array of {label, value}
    @api activeTabValue;
    @api variant = 'standard'; // 'standard' or 'scoped'

    // Check if tabs are available
    get hasTabs() {
        return Array.isArray(this.tabs) && this.tabs.length > 0;
    }

    // Check if specific tabs exist in the tabs array

    get hasDetailsTab() {
        return this.tabs.some(tab => tab && tab.value === 'details');
    }

    get hasRelatedTab() {
        return this.tabs.some(tab => tab && tab.value === 'related');
    }

    get hasCallLogsTab() {
        return this.tabs.some(tab => tab && tab.value === 'callLogs');
    }

    get hasRemarksTab() {
        return this.tabs.some(tab => tab && tab.value === 'remarks');
    }

    get hasActivitiesTab() {
        return this.tabs.some(tab => tab && tab.value === 'LEAD_ACTIVITY');
    }

    get hasTasksTab() {
        return this.tabs.some(tab => tab && tab.value === 'TASK');
    }

    get hasEventsTab() {
        return this.tabs.some(tab => tab && tab.value === 'events');
    }

    handleTabActive(event) {
        // lightning-tab onactive event provides the tab value
        const selectedValue = event.target.value || event.detail?.value;
        const selectedTab = Array.isArray(this.tabs) 
            ? this.tabs.find(tab => tab && tab.value === selectedValue)
            : null;
        
        // Dispatch event to parent
        this.dispatchEvent(new CustomEvent('tabchange', {
            detail: { 
                value: selectedValue,
                label: selectedTab?.label || ''
            }
        }));
    }
}

