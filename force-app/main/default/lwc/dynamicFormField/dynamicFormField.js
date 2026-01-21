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
    return this.fieldConfig?.type === 'Multi_select';
  }

  get isRadio() {
    return this.fieldConfig?.type === 'radio_group';
  }

  get isCheckbox() {
    return this.fieldConfig?.type === 'checkbox';
  }

  get isDate() {
    return this.fieldConfig?.type === 'date';
  }

  get isDateTime() {
    return this.fieldConfig?.type === 'datetime';
  }

  get filteredOptions() {
    if (!this.fieldConfig?.options || !Array.isArray(this.fieldConfig.options)) {
      return [];
    }

    return getFilteredOptions(this.fieldConfig.options, this.formValues);
  }

  handleValueChange(event) {
    // Forward the event with the same detail (no re-deriving field)
    if (!event || !event.detail) {
      console.warn('Invalid value change event in dynamicFormField');
      return;
    }

    // Forward the event as-is, assuming it already has { field, value }
    this.dispatchEvent(
      new CustomEvent('fieldvaluechange', {
        detail: event.detail,
        bubbles: true,
        composed: true
      })
    );
  }

  handleFieldBlur(event) {
    // Forward the event with the same detail (no re-deriving field)
    if (!event || !event.detail) {
      console.warn('Invalid blur event in dynamicFormField');
      return;
    }

    // Forward the event as-is, assuming it already has { field, value }
    this.dispatchEvent(
      new CustomEvent('fieldblur', {
        detail: event.detail,
        bubbles: true,
        composed: true
      })
    );
  }
}