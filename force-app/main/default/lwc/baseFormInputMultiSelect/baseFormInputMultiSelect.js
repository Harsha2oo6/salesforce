import { LightningElement, api, track } from 'lwc';

export default class BaseFormInputMultiSelect extends LightningElement {
  @api label;
  @api placeholder;
  @api isRequired = false;
  @api value = [];
  @api options = [];
  @api requiredMessage = 'This field is required';
  @api errorMessage = '';

  @track isOpen = false;
  @track focusedIndex = -1;

  get displayValue() {
    return Array.isArray(this.value) ? this.value : [];
  }

  get formattedOptions() {
    if (!Array.isArray(this.options)) {
      return [];
    }

    const selectedValues = this.displayValue;

    return this.options.map((option, index) => {
      return {
        label: option.label || option.value || '',
        value: option.value || '',
        checked: selectedValues.includes(option.value),
        tabindex: this.focusedIndex === index ? '0' : '-1'
      };
    });
  }

  get hasOptions() {
    return Array.isArray(this.options) && this.options.length > 0;
  }

  get hasError() {
    return this.errorMessage && this.errorMessage.length > 0;
  }

  get displayText() {
    const selectedValues = this.displayValue;
    if (selectedValues.length === 0) {
      return this.placeholder || 'Select options...';
    }

    // Get labels for selected values
    const selectedLabels = selectedValues
      .map((val) => {
        const option = this.options.find((opt) => opt.value === val);
        return option ? option.label || option.value : val;
      })
      .filter(Boolean);

    return selectedLabels.join(', ');
  }

  get comboboxClass() {
    let classes = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    if (this.isOpen) {
      classes += ' slds-is-open';
    }
    if (this.hasError) {
      classes += ' slds-has-error';
    }
    return classes;
  }

  get inputClass() {
    let classes = 'slds-input slds-combobox__input';
    if (this.hasError) {
      classes += ' slds-has-error';
    }
    return classes;
  }

  get ariaDescribedBy() {
    return this.hasError ? 'multiselect-error' : '';
  }

  handleComboboxClick(event) {
    // Prevent event from bubbling to document click handler
    event.stopPropagation();
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.focusedIndex = -1;
    }
  }

  handleOptionClick(event) {
    // Prevent event from bubbling to document click handler
    event.stopPropagation();
    const optionValue = event.currentTarget.dataset.value;
    this.toggleOption(optionValue);
  }

  handleOptionKeyDown(event) {
    const key = event.key;
    const optionValue = event.currentTarget.dataset.value;
    const options = this.formattedOptions;

    if (key === 'Enter' || key === ' ') {
      event.preventDefault();
      this.toggleOption(optionValue);
    } else if (key === 'ArrowDown') {
      event.preventDefault();
      const currentIndex = options.findIndex((opt) => opt.value === optionValue);
      if (currentIndex < options.length - 1) {
        this.focusedIndex = currentIndex + 1;
        this.focusOption();
      }
    } else if (key === 'ArrowUp') {
      event.preventDefault();
      const currentIndex = options.findIndex((opt) => opt.value === optionValue);
      if (currentIndex > 0) {
        this.focusedIndex = currentIndex - 1;
        this.focusOption();
      }
    } else if (key === 'Escape') {
      event.preventDefault();
      this.closeDropdown();
    }
  }

  handleInputKeyDown(event) {
    const key = event.key;
    if (key === 'Enter' || key === ' ') {
      event.preventDefault();
      this.isOpen = !this.isOpen;
      if (this.isOpen && this.formattedOptions.length > 0) {
        this.focusedIndex = 0;
        this.focusOption();
      }
    } else if (key === 'ArrowDown' && !this.isOpen) {
      event.preventDefault();
      this.isOpen = true;
      if (this.formattedOptions.length > 0) {
        this.focusedIndex = 0;
        this.focusOption();
      }
    } else if (key === 'Escape' && this.isOpen) {
      event.preventDefault();
      this.closeDropdown();
    }
  }

  toggleOption(optionValue) {
    const currentValues = [...this.displayValue];
    const index = currentValues.indexOf(optionValue);

    if (index > -1) {
      currentValues.splice(index, 1);
    } else {
      currentValues.push(optionValue);
    }

    this.dispatchValueChange(currentValues);
  }

  focusOption() {
    // Focus the option at focusedIndex
    const optionElement = this.template.querySelector(
      `[data-value-index="${this.focusedIndex}"]`
    );
    if (optionElement) {
      optionElement.focus();
    }
  }

  closeDropdown() {
    this.isOpen = false;
    this.focusedIndex = -1;
  }

  handleClickOutside(event) {
    const combobox = this.template.querySelector('.slds-combobox');
    if (combobox && !combobox.contains(event.target)) {
      this.closeDropdown();
    }
  }

  connectedCallback() {
    // Add click outside listener
    this.boundHandleClickOutside = (event) => {
      if (!this.isOpen) return;

      const combobox = this.template.querySelector('.slds-combobox');
      if (combobox && !combobox.contains(event.target)) {
        this.closeDropdown();
      }
    };
    // Use a small delay to avoid immediate closure when opening dropdown
    setTimeout(() => {
      document.addEventListener('click', this.boundHandleClickOutside);
    }, 100);
  }

  disconnectedCallback() {
    // Remove click outside listener
    if (this.boundHandleClickOutside) {
      document.removeEventListener('click', this.boundHandleClickOutside);
    }
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

  handleBlur() {
    // Dispatch blur event for validation
    this.dispatchEvent(
      new CustomEvent('fieldblur', {
        detail: {
          field: this.field,
          value: this.displayValue
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

