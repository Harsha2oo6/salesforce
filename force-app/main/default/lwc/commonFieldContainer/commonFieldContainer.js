import { LightningElement, api } from 'lwc';

export default class CommonFieldContainer extends LightningElement {
    @api item;
    @api align = 'row'; // 'row' or 'column', default is 'row'
    connectedCallback() {
        this.item = {
            ...this.item,
            formattedLabel: this.formatFieldLabel(this.item.name),
            formattedValue: this.formatFieldValue(this.item)
        };
    }
    get isBoolean() {
        return this.item.isBoolean;
    }
    get formattedLabel() {
        return this.formatFieldLabel(this.item.name);
    }

    get formattedValue() {
        return this.formatFieldValue(this.item);
    }

    get isRowLayout() {
        return this.align === 'row';
    }

    get isColumnLayout() {
        return this.align === 'column';
    }

    get containerClass() {
        const baseClass = 'responsive-field';
        if (this.isRowLayout) {
            return `${baseClass} slds-grid slds-grid_vertical-align-center field-row`;
        } else {
            return `${baseClass} field-column`;
        }
    }

    get labelClass() {
        if (this.isRowLayout) {
            return 'slds-m-right_small label';
        } else {
            return 'label label-column';
        }
    }

    formatFieldLabel(fieldName) {
        if (!fieldName) return '';
        return fieldName
            .split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
            .join(' ');
    }

    // Format field value based on type
    formatFieldValue(field) {
        if (field.value === null || field.value === undefined || field.value === '') {
            return '—';
        }

        if (field.type === 'boolean') {
            return field.value ? 'Yes' : 'No';
        }

        if (field.type === 'date') {
            // Format date string from YYYY-MM-DD to DD/MM/YYYY
            if (typeof field.value === 'string' && field.value.includes('-')) {
                const dateParts = field.value.split('-');
                if (dateParts.length === 3) {
                    return `${dateParts[2]}/${dateParts[1]}/${dateParts[0]}`;
                }
            }
            return field.value;
        }

        return field.value;
    }
}