import { LightningElement, api } from 'lwc';

export default class BaseFormInputPhone extends LightningElement {
  @api label;
  @api placeholder;
  @api isRequired = false;
  @api value = '';
  @api requiredMessage = 'This field is required';

  get displayValue() {
    return this.value || '';
  }

  handleChange(event) {
    const newValue = event.target.value;
    this.dispatchValueChange(newValue);
  }

  handleBlur(event) {
    // Add null checks to prevent errors
    if (!event || !event.target) {
      console.warn('Invalid blur event in baseFormInputPhone');
      return;
    }

    // Dispatch blur event for validation
    const value = event.target.value || '';
    this.dispatchEvent(
      new CustomEvent('fieldblur', {
        detail: {
          value: value
        }
      })
    );
  }

  dispatchValueChange(value) {
    this.dispatchEvent(
      new CustomEvent('valuechange', {
        detail: {
          value: value,
          field: this.field
        }
      })
    );
  }

  @api
  get field() {
    return this._field;
  }

  set field(value) {
    this._field = value;
  }

  _field;
}

