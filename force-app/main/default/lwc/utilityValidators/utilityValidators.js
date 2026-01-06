/**
 * Utility module for form field validation
 * Handles regex-based validation and required field validation
 */

/**
 * Validates a value against an array of validation rules
 * @param {string|Array} value - The value to validate (string for text fields, array for multi-select)
 * @param {Array} validationRules - Array of validation rule objects with regex and message
 * @returns {Array<string>} - Array of error messages (empty if validation passes)
 */
export function runValidations(value, validationRules) {
  if (!validationRules || !Array.isArray(validationRules) || validationRules.length === 0) {
    return [];
  }

  const errors = [];

  // Convert value to string for regex validation
  const stringValue = Array.isArray(value) ? value.join('') : String(value || '');

  validationRules.forEach((rule) => {
    if (!rule.regex || !rule.message) {
      return; // Skip invalid rules
    }

    try {
      const regex = new RegExp(rule.regex);
      if (!regex.test(stringValue)) {
        errors.push(rule.message);
      }
    } catch (error) {
      // Invalid regex pattern - log warning but don't fail validation
      console.warn('Invalid regex pattern:', rule.regex, error);
    }
  });

  return errors;
}

/**
 * Validates if a required field has a value
 * @param {string|Array} value - The value to check
 * @param {boolean} isRequired - Whether the field is required
 * @returns {string|null} - Error message if validation fails, null if passes
 */
export function validateRequired(value, isRequired) {
  if (!isRequired) {
    return null;
  }

  // Check if value is empty
  if (value === null || value === undefined) {
    return 'This field is required';
  }

  // For strings, check if empty or whitespace only
  if (typeof value === 'string' && value.trim() === '') {
    return 'This field is required';
  }

  // For arrays, check if empty
  if (Array.isArray(value) && value.length === 0) {
    return 'This field is required';
  }

  return null;
}

/**
 * Validates a field with both required and regex validations
 * @param {string|Array} value - The value to validate
 * @param {boolean} isRequired - Whether the field is required
 * @param {Array} validationRules - Array of validation rule objects
 * @returns {Array<string>} - Array of error messages (empty if validation passes)
 */
export function validateField(value, isRequired, validationRules) {
  const errors = [];

  // Check required validation first
  const requiredError = validateRequired(value, isRequired);
  if (requiredError) {
    errors.push(requiredError);
    return errors; // Return early if required validation fails
  }

  // Only run regex validations if field has a value
  if (value !== null && value !== undefined && value !== '') {
    const regexErrors = runValidations(value, validationRules || []);
    errors.push(...regexErrors);
  }

  return errors;
}

