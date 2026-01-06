/**
 * Utility module for evaluating condition expressions
 * Safely evaluates string expressions like "values['mobile_number'] === '995439'"
 */

/**
 * Evaluates a condition string expression with the provided values context
 * @param {string} condition - String expression to evaluate (e.g., "values['field'] === 'value'")
 * @param {Object} values - Object containing field values to use in evaluation
 * @returns {boolean} - Result of condition evaluation, false if evaluation fails
 */
export function evaluateCondition(condition, values) {
  if (!condition || typeof condition !== 'string') {
    return false;
  }

  // Handle simple 'true' condition
  if (condition.trim() === 'true') {
    return true;
  }

  // Handle simple 'false' condition
  if (condition.trim() === 'false') {
    return false;
  }

  try {
    // Create a function that evaluates the condition with values in scope
    // Using Function constructor to safely evaluate the expression
    const func = new Function('values', `return ${condition}`);
    const result = func(values);
    return Boolean(result);
  } catch (error) {
    // Fail safely - if condition is invalid, return false
    console.warn('Condition evaluation failed:', condition, error);
    return false;
  }
}

/**
 * Filters an array of options based on their condition property
 * @param {Array} options - Array of option objects with condition property
 * @param {Object} values - Object containing field values to use in condition evaluation
 * @returns {Array} - Filtered array of options that pass their conditions
 */
export function filterOptionsByCondition(options, values) {
  if (!Array.isArray(options)) {
    return [];
  }

  return options.filter((option) => {
    if (!option.condition) {
      return true; // Include option if no condition specified
    }
    return evaluateCondition(option.condition, values);
  });
}

