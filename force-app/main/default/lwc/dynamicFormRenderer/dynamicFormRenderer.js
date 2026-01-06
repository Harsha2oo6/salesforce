import { LightningElement, api } from 'lwc';

export default class DynamicFormRenderer extends LightningElement {
  @api visibleFields = [];
  @api formValues = {};
  @api errors = {};

  get hasFields() {
    return this.visibleFields && this.visibleFields.length > 0;
  }

  get fieldsWithData() {
    if (!this.visibleFields || !Array.isArray(this.visibleFields)) {
      return [];
    }

    return this.visibleFields.map((field) => {
      const fieldName = field.field;
      const fieldValue = this.formValues && fieldName ? (this.formValues[fieldName] || '') : '';
      
      let fieldError = '';
      if (this.errors && this.errors[fieldName]) {
        const fieldErrors = this.errors[fieldName];
        if (Array.isArray(fieldErrors) && fieldErrors.length > 0) {
          fieldError = fieldErrors[0];
        }
      }

      return {
        ...field,
        _fieldValue: fieldValue,
        _fieldError: fieldError
      };
    });
  }

  handleFieldValueChange(event) {
    try {
      // Add null checks
      if (!event) {
        console.warn('Event is null in handleFieldValueChange');
        return;
      }

      // Safely extract detail or create empty object
      let detail = {};
      if (event.detail) {
        detail = {
          field: String(event.detail.field || ''),
          value: event.detail.value !== undefined ? event.detail.value : ''
        };
      }

      // Only dispatch if we have a valid field
      if (!detail.field) {
        console.warn('Field name is missing in value change event');
        return;
      }

      // Bubble up the event to parent
      this.dispatchEvent(
        new CustomEvent('fieldvaluechange', {
          detail: detail,
          bubbles: true,
          composed: true
        })
      );
    } catch (error) {
      console.error('Error in dynamicFormRenderer handleFieldValueChange:', error);
    }
  }

  handleFieldBlur(event) {
    try {
      // Add comprehensive null checks
      if (!event) {
        console.warn('Event is null in handleFieldBlur');
        return;
      }

      // Check if detail exists
      if (!event.detail) {
        console.warn('Event detail is missing in handleFieldBlur');
        return;
      }

      // Safely extract values with defaults
      const field = event.detail.field;
      const value = event.detail.value;

      // Validate field name exists
      if (!field || typeof field !== 'string') {
        console.warn('Invalid or missing field name in blur event:', field);
        return;
      }

      // Create a clean detail object with only primitive values
      const detail = {
        field: String(field),
        value: value !== undefined && value !== null ? String(value) : ''
      };

      // Bubble up the event to parent
      this.dispatchEvent(
        new CustomEvent('fieldblur', {
          detail: detail,
          bubbles: true,
          composed: true
        })
      );
    } catch (error) {
      // Catch and log any errors instead of letting them propagate
      console.error('Error in dynamicFormRenderer handleFieldBlur:', error);
      console.error('Event object:', event);
      // Don't rethrow - prevent error dialog from showing
    }
  }
}

