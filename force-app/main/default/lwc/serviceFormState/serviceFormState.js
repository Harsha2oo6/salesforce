/**
 * Service module for form state management
 * Handles dependency resets and visibility computation
 */

import { evaluateCondition } from 'c/utilityConditionEvaluator';

/**
 * Resets dependent fields when a field value changes
 * @param {Object} values - Current form values object
 * @param {string} changedFieldName - Name of the field that changed
 * @param {Array} configFields - Array of all field configurations
 * @returns {Object} - Updated values object with dependent fields reset
 */
export function resetDependentFields(values, changedFieldName, configFields) {
  const updatedValues = { ...values };

  // Find all fields that depend on the changed field
  configFields.forEach((field) => {
    if (
      field.relevantFields &&
      Array.isArray(field.relevantFields) &&
      field.relevantFields.includes(changedFieldName)
    ) {
      // Reset this field to its default value
      updatedValues[field.field] = field.defaultValue !== undefined 
        ? (Array.isArray(field.defaultValue) ? [...field.defaultValue] : field.defaultValue)
        : (field.type === 'multi_select' || field.type === 'checkbox' ? [] : '');
    }
  });

  return updatedValues;
}

/**
 * Computes which fields should be visible based on their relevantCondition
 * @param {Array} configFields - Array of all field configurations
 * @param {Object} values - Current form values object
 * @returns {Array} - Array of visible field configurations
 */
export function computeVisibleFields(configFields, values) {
  if (!Array.isArray(configFields)) {
    return [];
  }

  return configFields.filter((field) => {
    // If no condition specified, field is visible
    if (!field.relevantCondition) {
      return true;
    }

    // Evaluate condition
    return evaluateCondition(field.relevantCondition, values);
  });
}

/**
 * Initializes form values with default values from config
 * @param {Array} configFields - Array of all field configurations
 * @returns {Object} - Initialized values object
 */
export function initializeFormValues(configFields) {
  const values = {};

  if (!Array.isArray(configFields)) {
    return values;
  }

  configFields.forEach((field) => {
    if (field.defaultValue !== undefined) {
      // Deep copy arrays to avoid reference issues
      values[field.field] = Array.isArray(field.defaultValue)
        ? [...field.defaultValue]
        : field.defaultValue;
    } else {
      // Set default based on field type
      if (field.type === 'multi_select' || field.type === 'checkbox') {
        values[field.field] = [];
      } else {
        values[field.field] = '';
      }
    }
  });

  return values;
}

/**
 * Filters options for a field based on their conditions
 * @param {Array} options - Array of option objects
 * @param {Object} values - Current form values object
 * @returns {Array} - Filtered array of options
 */
export function getFilteredOptions(options, values) {
  if (!Array.isArray(options)) {
    return [];
  }

  return options.filter((option) => {
    if (!option.condition) {
      return true; // Include if no condition
    }
    return evaluateCondition(option.condition, values);
  });
}

