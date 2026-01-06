import { LightningElement, api, track } from 'lwc';
import { fetchFormConfig } from 'c/serviceFormConfig';
import {
  initializeFormValues,
  resetDependentFields,
  computeVisibleFields,
  getFilteredOptions
} from 'c/serviceFormState';
import submitForm from '@salesforce/apex/DynamicFormController.submitForm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DynamicFormContainer extends LightningElement {
  @api formName = 'default';
  @api formTitle = 'Dynamic Form';

  @track config = null;
  @track values = {};
  @track visibleFields = [];
  @track errors = {};
  @track isLoading = true;
  @track hasError = false;
  @track errorMessage = '';
  @track isSubmitting = false;

  connectedCallback() {
    this.loadFormConfig();
  }

  async loadFormConfig() {
    try {
      this.isLoading = true;
      this.hasError = false;
      this.errorMessage = '';

      const config = await fetchFormConfig(this, this.formName);
      this.config = config;

      // Initialize form values
      this.values = initializeFormValues(config.fields);

      // Compute visible fields
      this.visibleFields = computeVisibleFields(config.fields, this.values);

      this.isLoading = false;
    } catch (error) {
      this.isLoading = false;
      this.hasError = true;
      this.errorMessage = 'Failed to load form configuration. Please try again.';
      console.error('Error loading form config:', error);
    }
  }

  get isFormReady() {
    return !this.isLoading && !this.hasError && this.config !== null;
  }

  handleFieldValueChange(event) {
    const { field, value } = event.detail;

    // Update the value
    this.values = {
      ...this.values,
      [field]: value
    };

    // Reset dependent fields
    this.values = resetDependentFields(this.values, field, this.config.fields);

    // Recompute visible fields
    this.visibleFields = computeVisibleFields(this.config.fields, this.values);

    // Clear error for this field
    if (this.errors[field]) {
      this.errors = {
        ...this.errors,
        [field]: []
      };
    }

    // Check if selected value is still valid (for select/multi-select/radio/checkbox)
    this.validateSelectedValue(field, value);
  }

  validateSelectedValue(fieldName, value) {
    const fieldConfig = this.config.fields.find((f) => f.field === fieldName);
    if (!fieldConfig) return;

    // For fields with options, check if selected value is still in filtered options
    if (
      fieldConfig.options &&
      Array.isArray(fieldConfig.options) &&
      (fieldConfig.type === 'select' ||
        fieldConfig.type === 'multi_select' ||
        fieldConfig.type === 'radio_group' ||
        fieldConfig.type === 'checkbox')
    ) {
      const filteredOptions = this.getFilteredOptions(fieldConfig);
      const optionValues = filteredOptions.map((opt) => opt.value);

      if (fieldConfig.type === 'select' || fieldConfig.type === 'radio_group') {
        // Single value - check if it's in filtered options
        if (value && !optionValues.includes(value)) {
          // Reset to default value
          this.values = {
            ...this.values,
            [fieldName]: fieldConfig.defaultValue !== undefined
              ? fieldConfig.defaultValue
              : ''
          };
        }
      } else {
        // Multi-select or checkbox - filter out invalid values
        if (Array.isArray(value)) {
          const validValues = value.filter((v) => optionValues.includes(v));
          if (validValues.length !== value.length) {
            this.values = {
              ...this.values,
              [fieldName]: validValues
            };
          }
        }
      }
    }
  }

  getFilteredOptions(fieldConfig) {
    return getFilteredOptions(fieldConfig.options, this.values);
  }

  handleFieldBlur(event) {
    try {
      // Add comprehensive null checks to prevent errors
      if (!event) {
        console.warn('Event is null in handleFieldBlur');
        return;
      }

      if (!event.detail) {
        console.warn('Event detail is missing in handleFieldBlur');
        return;
      }

      // Safely extract field and value
      const field = event.detail.field;
      const value = event.detail.value;
      
      // Validate that field exists and is a string
      if (!field || typeof field !== 'string') {
        console.warn('Field name is missing or invalid in blur event:', field);
        return;
      }

      // Validate field value (can be empty string, that's OK)
      const fieldValue = value !== undefined && value !== null ? value : '';

      this.validateFieldValue(field, fieldValue);
    } catch (error) {
      // Catch and log errors instead of showing error dialog
      console.error('Error in handleFieldBlur:', error);
      console.error('Event:', event);
    }
  }

  validateFieldValue(fieldName, value) {
    const fieldConfig = this.config.fields.find((f) => f.field === fieldName);
    if (!fieldConfig) return;

    const { validateField: validateFieldUtil } = require('c/utilityValidators');
    const fieldErrors = validateFieldUtil(
      value,
      fieldConfig.isRequired,
      fieldConfig.validation_regexs || []
    );

    this.errors = {
      ...this.errors,
      [fieldName]: fieldErrors
    };
  }

  validateAllFields() {
    const { validateField: validateFieldUtil } = require('c/utilityValidators');
    const newErrors = {};
    let hasErrors = false;

    this.visibleFields.forEach((field) => {
      const fieldErrors = validateFieldUtil(
        this.values[field.field],
        field.isRequired,
        field.validation_regexs || []
      );

      if (fieldErrors.length > 0) {
        newErrors[field.field] = fieldErrors;
        hasErrors = true;
      }
    });

    this.errors = newErrors;
    return !hasErrors;
  }

  async handleSubmit() {
    // Validate all fields
    if (!this.validateAllFields()) {
      this.showToast('Error', 'Please fix the errors before submitting', 'error');
      return;
    }

    try {
      this.isSubmitting = true;

      // Prepare form data
      const formData = {
        formName: this.formName,
        values: this.values,
        timestamp: new Date().toISOString()
      };

      const result = await submitForm({ formValuesJson: JSON.stringify(formData) });

      this.isSubmitting = false;

      // Parse result
      const resultObj = JSON.parse(result);

      if (resultObj.success) {
        this.showToast('Success', resultObj.message || 'Form submitted successfully', 'success');
        // Optionally reset form or emit event
        this.dispatchEvent(
          new CustomEvent('formsubmit', {
            detail: {
              values: this.values,
              result: resultObj
            }
          })
        );
      } else {
        this.showToast('Error', resultObj.message || 'Failed to submit form', 'error');
      }
    } catch (error) {
      this.isSubmitting = false;
      console.error('Error submitting form:', error);
      this.showToast(
        'Error',
        error.body?.message || error.message || 'Failed to submit form',
        'error'
      );
    }
  }

  handleReset() {
    // Reset to initial values
    this.values = initializeFormValues(this.config.fields);
    this.errors = {};
    this.visibleFields = computeVisibleFields(this.config.fields, this.values);
  }

  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }
}

