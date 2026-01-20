import { LightningElement, api } from 'lwc';
import { 
  toLightningDateFormat, 
  toLightningDateTimeFormat,
  parseDateFromDisplay, 
  parseDateTimeFromDisplay,
  formatDateForDisplay, 
  formatDateTimeForDisplay,
  validateDateConstraints 
} from 'c/utilityDateUtils';

export default class BaseFormInputDate extends LightningElement {
  @api label;
  @api isRequired = false;
  @api type = 'date'; // 'date' or 'datetime'
  @api value = ''; // ISO format (YYYY-MM-DD) for date, YYYY-MM-DD HH:MM:SS for datetime
  @api dateFormat = 'DD/MM/YYYY'; // For date: DD/MM/YYYY, MM/DD/YYYY. For datetime: YYYY-MM-DD HH:MM:SS, DD/MM/YYYY HH:MM:SS
  @api excludeDates = [];
  @api requiredMessage = 'This field is required';
  @api errorMessage = '';
  
  _minDate = '';
  _maxDate = '';

  get lightningDateValue() {
    // Convert ISO date to format expected by lightning-input (YYYY-MM-DD)
    return toLightningDateFormat(this.value);
  }

  get lightningDateTimeValue() {
    // Convert datetime to format expected by lightning-input type="datetime" (ISO format)
    return toLightningDateTimeFormat(this.value);
  }

  get inputValue() {
    // Return appropriate value based on type
    return this.type === 'datetime' ? this.lightningDateTimeValue : this.lightningDateValue;
  }

  get minDateFormatted() {
    if (!this._minDate) return '';
    if (this.type === 'datetime') {
      // For datetime, parse and format for datetime input (ISO format)
      // Salesforce datetime handles timezone automatically
      const isoDateTime = parseDateTimeFromDisplay(this._minDate, this.dateFormat);
      return toLightningDateTimeFormat(isoDateTime);
    } else {
      // For date, convert display format to ISO for lightning-input
      const isoDate = parseDateFromDisplay(this._minDate, this.dateFormat);
      return toLightningDateFormat(isoDate);
    }
  }

  get maxDateFormatted() {
    if (!this._maxDate) return '';
    if (this.type === 'datetime') {
      // For datetime, parse and format for datetime input (ISO format)
      // Salesforce datetime handles timezone automatically
      const isoDateTime = parseDateTimeFromDisplay(this._maxDate, this.dateFormat);
      return toLightningDateTimeFormat(isoDateTime);
    } else {
      // For date, convert display format to ISO for lightning-input
      const isoDate = parseDateFromDisplay(this._maxDate, this.dateFormat);
      return toLightningDateFormat(isoDate);
    }
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
    let newValue = event.target.value;

    if (this.type === 'datetime') {
      if (newValue) {
        // 1. Create a Date object to handle the Timezone conversion automatically
        const dateObj = new Date(newValue);

        // 2. Extract the parts in Local Time (IST)
        const year = dateObj.getFullYear();
        const month = String(dateObj.getMonth() + 1).padStart(2, '0');
        const day = String(dateObj.getDate()).padStart(2, '0');
        const hours = String(dateObj.getHours()).padStart(2, '0');
        const minutes = String(dateObj.getMinutes()).padStart(2, '0');
        const seconds = String(dateObj.getSeconds()).padStart(2, '0');

        // 3. Construct the string in Local Time format
        newValue = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      }
    }
    // No else needed for date type as it is already correct

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