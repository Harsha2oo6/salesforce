import { LightningElement, api } from 'lwc';

export default class BaseFormInputRadio extends LightningElement {
  @api label;
  @api isRequired = false;
  @api value = '';
  @api options = [];
  @api requiredMessage = 'This field is required';

  get displayValue() {
    return this.value || '';
  }

  get formattedOptions() {
    if (!Array.isArray(this.options)) {
      return [];
    }

    return this.options.map((option) => {
      return {
        label: option.label || option.value || '',
        value: option.value || ''
      };
    });
  }

  get hasOptions() {
    return Array.isArray(this.options) && this.options.length > 0;
  }

  handleChange(event) {
    const newValue = event.detail.value;
    this.dispatchValueChange(newValue);
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

