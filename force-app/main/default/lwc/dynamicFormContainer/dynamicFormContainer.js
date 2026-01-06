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
import { validateField } from 'c/utilityValidators';

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

    const fieldErrors = validateField(
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
    console.log('validateAllFields: Starting validation');
    console.log('validateAllFields: visibleFields count:', this.visibleFields?.length || 0);
    
    const newErrors = {};
    let hasErrors = false;

    if (!this.visibleFields || !Array.isArray(this.visibleFields)) {
      console.warn('validateAllFields: visibleFields is not an array:', this.visibleFields);
      return true; // No fields to validate, consider it valid
    }

    if (this.visibleFields.length === 0) {
      console.log('validateAllFields: No visible fields to validate');
      return true;
    }

    console.log('validateAllFields: Iterating over', this.visibleFields.length, 'fields');
    
    this.visibleFields.forEach((field, index) => {
      try {
        const fieldName = field.field;
        const fieldValue = this.values[fieldName];
        const isRequired = field.isRequired || false;
        const validationRules = field.validation_regexs || [];
        
        console.log(`validateAllFields: [${index + 1}/${this.visibleFields.length}] Validating "${fieldName}"`);
        console.log(`  - Value:`, fieldValue);
        console.log(`  - Required:`, isRequired);
        console.log(`  - Validation rules:`, validationRules);
        
        const fieldErrors = validateField(
          fieldValue,
          isRequired,
          validationRules
        );

        console.log(`  - Errors:`, fieldErrors);

        if (fieldErrors && Array.isArray(fieldErrors) && fieldErrors.length > 0) {
          newErrors[fieldName] = fieldErrors;
          hasErrors = true;
          console.log(`  - ❌ Field "${fieldName}" FAILED validation`);
        } else {
          console.log(`  - ✅ Field "${fieldName}" passed validation`);
        }
      } catch (fieldError) {
        console.error(`validateAllFields: Error validating field ${field?.field}:`, fieldError);
        console.error('Error details:', fieldError.message, fieldError.stack);
        // Mark field as having errors if validation throws
        newErrors[field?.field] = ['Validation error occurred'];
        hasErrors = true;
      }
    });

    console.log('validateAllFields: Validation complete');
    console.log('validateAllFields: Total errors found:', Object.keys(newErrors).length);
    console.log('validateAllFields: Errors object:', JSON.stringify(newErrors, null, 2));
    console.log('validateAllFields: hasErrors:', hasErrors);
    
    this.errors = newErrors;
    const result = !hasErrors;
    console.log('validateAllFields: Returning validation result:', result);
    return result;
  }

  async handleSubmit() {
    console.log('handleSubmit: Starting form submission');
    
    // Validate all fields
    console.log('handleSubmit: Validating all fields...');
    const validationResult = this.validateAllFields();
    console.log('handleSubmit: Validation result:', validationResult);
    
    if (!validationResult) {
      console.log('handleSubmit: Validation failed. Errors:', JSON.stringify(this.errors));
      this.showToast('Error', 'Please fix the errors before submitting', 'error');
      return;
    }

    console.log('handleSubmit: Validation passed. Proceeding with submission...');

    try {
      this.isSubmitting = true;
      console.log('handleSubmit: isSubmitting set to true');
      
      // Prepare form data
      const formData = {
        formName: this.formName,
        values: this.values,
        timestamp: new Date().toISOString()
      };
      console.log('handleSubmit: Form data prepared:', JSON.stringify(formData, null, 2));
      
      console.log('handleSubmit: Calling Apex submitForm...');
      const result = await submitForm({ formValuesJson: JSON.stringify(formData) });
      console.log('handleSubmit: Apex call completed. Result type:', typeof result);
      console.log('handleSubmit: Raw result:', result);
      
      this.isSubmitting = false;
      console.log('handleSubmit: isSubmitting set to false');

      // Parse result with error handling
      let resultObj;
      try {
        if (!result || typeof result !== 'string') {
          throw new Error('Invalid response from server: ' + typeof result);
        }
        resultObj = JSON.parse(result);
        console.log('handleSubmit: Parsed result object:', JSON.stringify(resultObj, null, 2));
      } catch (parseError) {
        console.error('handleSubmit: Error parsing result:', parseError);
        console.error('handleSubmit: Raw result that failed to parse:', result);
        this.showToast(
          'Error',
          'Invalid response from server. Please try again.',
          'error'
        );
        return;
      }

      if (resultObj.success) {
        console.log('handleSubmit: Submission successful');
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
        console.log('handleSubmit: formsubmit event dispatched');
      } else {
        console.log('handleSubmit: Submission failed (success: false)');
        this.showToast('Error', resultObj.message || 'Failed to submit form', 'error');
      }
    } catch (error) {
      this.isSubmitting = false;
      console.error('handleSubmit: Exception caught:', error);
      console.error('handleSubmit: Error details:', {
        message: error.message,
        body: error.body,
        stack: error.stack
      });
      
      const errorMessage = 
        error.body?.message || 
        error.body?.pageErrors?.[0]?.message ||
        error.message || 
        'Failed to submit form';
      
      console.error('handleSubmit: Showing error toast with message:', errorMessage);
      this.showToast('Error', errorMessage, 'error');
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

