import { LightningElement, api, track } from 'lwc';

export default class CustomForm extends LightningElement {
    @api formFields = [];
    @api showSubmitButton = false;
    @api submitButtonLabel = 'Submit';
    
    @track formData = {};

    /**
     * Process form fields config and add type flags for template rendering
     * Each field gets boolean flags like isText, isEmail, etc. for conditional rendering
     */
    get processedFields() {
        if (!this.formFields || !Array.isArray(this.formFields)) {
            return [];
        }

        return this.formFields.map((field, index) => {
            const processedField = {
                ...field,
                key: field.field || `field-${index}`,
                // Type flags for conditional rendering in template
                isText: field.type === 'text',
                isEmail: field.type === 'email',
                isPhone: field.type === 'phone',
                isSelect: field.type === 'select',
                isDate: field.type === 'date',
                isTextarea: field.type === 'textarea',
                isNumber: field.type === 'number',
                isCheckbox: field.type === 'checkbox',
                // Current value from formData
                currentValue: this.formData[field.field] || '',
                // Format options for lightning-combobox (select type)
                comboboxOptions: this.formatOptionsForCombobox(field),
                // Phone display with country code prefix
                phonePrefix: field.countryCode || '',
                // Label variant - computed here since LWC doesn't support ternary in templates
                labelVariant: field.shouldShowLabel ? 'standard' : 'label-hidden',
                // Phone input CSS class
                phoneCssClass: field.countryCode ? 'has-prefix' : ''
            };

            return processedField;
        });
    }

    /**
     * Convert options array to lightning-combobox format
     * @param {Object} field - Field configuration object
     * @returns {Array|null} - Formatted options array or null
     */
    formatOptionsForCombobox(field) {
        if (field.type !== 'select' || !field.options || !Array.isArray(field.options)) {
            return null;
        }

        return field.options.map(option => {
            // Handle both string options and object options
            if (typeof option === 'string') {
                return { label: option, value: option };
            }
            return { label: option.label || option, value: option.value || option };
        });
    }

    /**
     * Check if form has any fields to render
     */
    get hasFields() {
        return this.processedFields && this.processedFields.length > 0;
    }

    /**
     * Handle input change for text, email, date, number fields
     */
    handleInputChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        this.updateFormData(fieldName, value);
    }

    /**
     * Handle combobox (select) change
     */
    handleComboboxChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.detail.value;
        this.updateFormData(fieldName, value);
    }

    /**
     * Handle checkbox change
     */
    handleCheckboxChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.checked;
        this.updateFormData(fieldName, value);
    }

    /**
     * Update form data and dispatch change event
     */
    updateFormData(fieldName, value) {
        this.formData = {
            ...this.formData,
            [fieldName]: value
        };

        // Dispatch formchange event to parent
        this.dispatchEvent(new CustomEvent('formchange', {
            detail: {
                field: fieldName,
                value: value,
                formData: { ...this.formData }
            }
        }));
    }

    /**
     * Handle form submission
     */
    handleSubmit() {
        // Validate required fields if needed
        if (this.validateForm()) {
            this.dispatchEvent(new CustomEvent('formsubmit', {
                detail: {
                    formData: { ...this.formData }
                }
            }));
        }
    }

    /**
     * Basic form validation
     * @returns {Boolean} - True if form is valid
     */
    validateForm() {
        const allInputs = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea');
        let isValid = true;

        allInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    /**
     * Public method to get current form data
     * @returns {Object} - Current form data
     */
    @api
    getFormData() {
        return { ...this.formData };
    }

    /**
     * Public method to set form data programmatically
     * @param {Object} data - Form data to set
     */
    @api
    setFormData(data) {
        if (data && typeof data === 'object') {
            this.formData = { ...data };
        }
    }

    /**
     * Public method to reset form
     */
    @api
    resetForm() {
        this.formData = {};
        
        // Clear all input values
        const allInputs = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea');
        allInputs.forEach(input => {
            if (input.type === 'checkbox') {
                input.checked = false;
            } else {
                input.value = '';
            }
        });
    }

    /**
     * Public method to validate form
     * @returns {Boolean} - True if form is valid
     */
    @api
    validate() {
        return this.validateForm();
    }
}
