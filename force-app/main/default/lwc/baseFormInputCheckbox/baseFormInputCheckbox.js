import { LightningElement, api } from 'lwc';

export default class BaseFormInputCheckbox extends LightningElement {
  @api label;
  @api isRequired = false;
  @api value = [];
  @api options = [];
  @api requiredMessage = 'This field is required';
  @api errorMessage = '';

  get displayValue() {
    return Array.isArray(this.value) ? this.value : [];
  }

  get formattedOptions() {
    if (!Array.isArray(this.options)) {
      return [];
    }

    const selectedValues = this.displayValue;

    return this.options.map((option) => {
      return {
        label: option.label || option.value || '',
        value: option.value || '',
        checked: selectedValues.includes(option.value)
      };
    });
  }

  get hasOptions() {
    return Array.isArray(this.options) && this.options.length > 0;
  }

  get hasError() {
    return this.errorMessage && this.errorMessage.length > 0;
  }

  handleOptionChange(event) {
    const optionValue = event.target.dataset.value;
    const isChecked = event.target.checked;
    const currentValues = [...this.displayValue];

    if (isChecked) {
      if (!currentValues.includes(optionValue)) {
        currentValues.push(optionValue);
      }
    } else {
      const index = currentValues.indexOf(optionValue);
      if (index > -1) {
        currentValues.splice(index, 1);
      }
    }

    this.dispatchValueChange(currentValues);
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

