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
      // For datetime, Salesforce returns ISO format (YYYY-MM-DDTHH:mm:ss or YYYY-MM-DDTHH:mm:ssZ)
      // Convert to YYYY-MM-DD HH:MM:SS format for storage (without timezone, as it's handled by Salesforce)
      if (newValue && newValue.includes('T')) {
        // Remove timezone if present (Z or +HH:mm)
        newValue = newValue.replace(/Z$/, '').replace(/[+-]\d{2}:\d{2}$/, '');
        // Convert T to space and ensure seconds are present
        const [datePart, timePart] = newValue.split('T');
        if (timePart) {
          const timeParts = timePart.split(':');
          const hours = timeParts[0] || '00';
          const minutes = timeParts[1] || '00';
          const seconds = timeParts[2] || '00';
          newValue = `${datePart} ${hours}:${minutes}:${seconds}`;
        }
      }
    } else {
      // For date, value is already in YYYY-MM-DD format (ISO)
      // Store as-is
    }
    
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