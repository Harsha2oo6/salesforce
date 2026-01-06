import { LightningElement, api } from 'lwc';
import { getFilteredOptions } from 'c/serviceFormState';

export default class DynamicFormField extends LightningElement {
  @api fieldConfig;
  @api fieldValue;
  @api formValues = {};
  @api errorMessage = '';

  get isText() {
    return this.fieldConfig?.type === 'text';
  }

  get isPhone() {
    return this.fieldConfig?.type === 'phone_number';
  }

  get isTextArea() {
    return this.fieldConfig?.type === 'text_area';
  }

  get isSelect() {
    return this.fieldConfig?.type === 'select';
  }

  get isMultiSelect() {
    return this.fieldConfig?.type === 'multi_select';
  }

  get isRadio() {
    return this.fieldConfig?.type === 'radio_group';
  }

  get isCheckbox() {
    return this.fieldConfig?.type === 'checkbox';
  }

  get isDatePicker() {
    return this.fieldConfig?.type === 'date_picker';
  }

  get filteredOptions() {
    if (!this.fieldConfig?.options || !Array.isArray(this.fieldConfig.options)) {
      return [];
    }

    return getFilteredOptions(this.fieldConfig.options, this.formValues);
  }

  handleValueChange(event) {
    // Add null checks to prevent errors
    if (!event || !event.detail) {
      console.warn('Invalid value change event in dynamicFormField');
      return;
    }

    const detail = event.detail;
    const field = detail.field || (this.fieldConfig && this.fieldConfig.field) || '';
    const value = detail.value !== undefined ? detail.value : '';

    if (!field) {
      console.warn('Field name is missing in value change event');
      return;
    }

    this.dispatchEvent(
      new CustomEvent('fieldvaluechange', {
        detail: {
          field: field,
          value: value
        },
        bubbles: true,
        composed: true
      })
    );
  }

  handleFieldBlur(event) {
    try {
      // Add null checks to prevent errors
      if (!this.fieldConfig || !this.fieldConfig.field) {
        console.warn('Field config is not available for blur event');
        return;
      }

      // Safely get the value from event detail or use current field value
      let value = '';
      if (event && event.detail && event.detail.value !== undefined) {
        value = event.detail.value;
      } else if (this.fieldValue !== undefined && this.fieldValue !== null) {
        value = this.fieldValue;
      }

      // Ensure field name is a string
      const fieldName = String(this.fieldConfig.field || '');

      if (!fieldName) {
        console.warn('Field name is empty, cannot dispatch blur event');
        return;
      }

      // Create event detail object with only primitive values
      const eventDetail = {
        field: fieldName,
        value: String(value || '')
      };

      // Dispatch event with error handling
      this.dispatchEvent(
        new CustomEvent('fieldblur', {
          detail: eventDetail,
          bubbles: true,
          composed: true
        })
      );
    } catch (error) {
      // Catch any errors and log them instead of throwing
      console.error('Error in handleFieldBlur:', error);
      console.error('Event:', event);
      console.error('FieldConfig:', this.fieldConfig);
      console.error('FieldValue:', this.fieldValue);
    }
  }
}

