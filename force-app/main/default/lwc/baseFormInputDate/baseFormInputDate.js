import { LightningElement, api } from 'lwc';
import { toLightningDateFormat, parseDateFromDisplay, formatDateForDisplay, validateDateConstraints } from 'c/utilityDateUtils';

export default class BaseFormInputDate extends LightningElement {
  @api label;
  @api isRequired = false;
  @api value = ''; // ISO format (YYYY-MM-DD)
  @api dateFormat = 'DD/MM/YYYY';
  @api excludeDates = [];
  @api requiredMessage = 'This field is required';
  @api errorMessage = '';
  
  _minDate = '';
  _maxDate = '';

  get lightningDateValue() {
    // Convert ISO date to format expected by lightning-input (YYYY-MM-DD)
    return toLightningDateFormat(this.value);
  }

  get minDateFormatted() {
    if (!this._minDate) return '';
    // Convert display format to ISO for lightning-input
    const isoDate = parseDateFromDisplay(this._minDate, this.dateFormat);
    return toLightningDateFormat(isoDate);
  }

  get maxDateFormatted() {
    if (!this._maxDate) return '';
    // Convert display format to ISO for lightning-input
    const isoDate = parseDateFromDisplay(this._maxDate, this.dateFormat);
    return toLightningDateFormat(isoDate);
  }

  @api
  get minDate() {
    return this._minDate;
  }

  set minDate(value) {
    this._minDate = value;
  }

  @api
  get maxDate() {
    return this._maxDate;
  }

  set maxDate(value) {
    this._maxDate = value;
  }

  get hasError() {
    return this.errorMessage && this.errorMessage.length > 0;
  }

  handleChange(event) {
    const newValue = event.target.value; // This is in YYYY-MM-DD format from lightning-input
    // Store in ISO format (already correct)
    this.dispatchValueChange(newValue);
  }

  handleBlur(event) {
    // Dispatch blur event for centralized validation in container
    const dateValue = event.target.value || '';
    this.dispatchEvent(
      new CustomEvent('fieldblur', {
        detail: {
          field: this.field,
          value: dateValue
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

