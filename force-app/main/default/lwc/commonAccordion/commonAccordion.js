import { LightningElement, api } from 'lwc';

export default class AccordionSection extends LightningElement {
    @api title;
    @api isCollapsedByDefault = false;
    @api variant = 'standard'; // 'standard' or 'activity-item'

    isExpanded = false;

    connectedCallback() {
        // Set initial expanded state based on isCollapsedByDefault
        this.isExpanded = !this.isCollapsedByDefault;
    }

    handleToggle(event) {
        // For activity-item variant, only toggle if clicking on an anchor element
        if (this.isActivityItemVariant && event) {
            const target = event.target;
            const anchor = target.closest('a');
            
            if (anchor) {
                event.preventDefault();
                this.isExpanded = !this.isExpanded;
            }
        } else {
            // For standard variant or when called without event (e.g., from handleKeyDown)
            this.isExpanded = !this.isExpanded;
        }
    }

    handleKeyDown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            this.handleToggle();
        }
    }

    get iconName() {
        return this.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get isStandardVariant() {
        return this.variant === 'standard';
    }

    get isActivityItemVariant() {
        return this.variant === 'activity-item';
    }

    get wrapperClass() {
        const baseClass = 'slds-m-bottom_medium';
        if (this.isActivityItemVariant) {
            return `${baseClass} accordion-wrapper-activity`;
        }
        return `${baseClass} accordion-wrapper`;
    }

    get contentClass() {
        const baseClass = 'slds-box slds-box_x-small accordion-content';
        if (this.isActivityItemVariant) {
            return `${baseClass} accordion-content-activity`;
        }
        return baseClass;
    }
}
