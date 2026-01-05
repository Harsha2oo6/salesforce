import { LightningElement, api } from 'lwc';

export default class AccordionSection extends LightningElement {
    @api title;
    @api isCollapsedByDefault = false;

    isExpanded = false;

    connectedCallback() {
        // Set initial expanded state based on isCollapsedByDefault
        this.isExpanded = !this.isCollapsedByDefault;
    }

    handleToggle() {
        this.isExpanded = !this.isExpanded;
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
}
