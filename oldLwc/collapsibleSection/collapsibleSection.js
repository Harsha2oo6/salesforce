import { LightningElement, api } from 'lwc';

export default class CollapsibleSection extends LightningElement {
    @api title;
    @api titleClass = '';
    @api isCollapsedByDefault = false;
    
    // Key-value list props
    @api items; // Array of {label, value, isEditable, isLink, linkUrl, fieldName}
    @api emptyMessage = 'No data available.';
    
    // Legacy datatable props (for backward compatibility)
    @api tableData;
    @api tableColumns;
    @api keyField;
    @api hideCheckboxColumn = false;
    @api showRowNumberColumn = false;
    
    isExpanded = true;
    
    connectedCallback() {
        // If collapsed by default is true, start collapsed; otherwise start expanded
        this.isExpanded = !this.isCollapsedByDefault;
    }
    
    handleToggle() {
        this.isExpanded = !this.isExpanded;
    }
    
    get iconName() {
        return this.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get computedTitleClass() {
        return `section-title ${this.titleClass || ''}`.trim();
    }
    
    // Check if key-value list mode
    get isListMode() {
        return this.items !== undefined && Array.isArray(this.items);
    }
    
    // Check if datatable mode (has data and columns)
    get isDatatableMode() {
        return !this.isListMode && this.tableData !== undefined && this.tableColumns !== undefined;
    }
    
    // Check if data exists
    get hasData() {
        if (this.isListMode) {
            return this.items && this.items.length > 0;
        }
        return this.tableData && Array.isArray(this.tableData) && this.tableData.length > 0;
    }
    
    // Check if slot mode (neither list nor datatable)
    get isSlotMode() {
        return !this.isListMode && !this.isDatatableMode;
    }
    
    handleEdit(event) {
        const fieldName = event.currentTarget.dataset.field;
        // Dispatch custom event for parent to handle
        this.dispatchEvent(new CustomEvent('edit', {
            detail: { fieldName }
        }));
    }
}

