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
    // Assume event already has { field, value } and just re-dispatch
    if (!event || !event.detail) {
      console.warn('Invalid value change event in dynamicFormRenderer');
      return;
    }

    // Re-dispatch to container with same detail
    this.dispatchEvent(
      new CustomEvent('fieldvaluechange', {
        detail: event.detail,
        bubbles: true,
        composed: true
      })
    );
  }

  handleFieldBlur(event) {
    // Assume event already has { field, value } and just re-dispatch
    if (!event || !event.detail) {
      console.warn('Invalid blur event in dynamicFormRenderer');
      return;
    }

    // Re-dispatch to container with same detail
    this.dispatchEvent(
      new CustomEvent('fieldblur', {
        detail: event.detail,
        bubbles: true,
        composed: true
      })
    );
  }
}

