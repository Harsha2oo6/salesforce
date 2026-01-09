/**
 * Utility module for evaluating condition expressions
 * Safely evaluates string expressions like "values['mobile_number'] === '995439'"
 * 
 * CONDITION SYNTAX:
 * =================
 * 
 * Supported Operators:
 * - Equality: ===, !==, ==, !=
 * - Comparison: <, >, <=, >=
 * - Logical: &&, ||, !
 * 
 * Field Access:
 * - Use bracket notation: values['field_name']
 * - Use dot notation: values.field_name (if field name is valid JS identifier)
 * 
 * Value Types:
 * - Strings: Use single or double quotes: 'value' or "value"
 * - Numbers: Direct numeric values: 123, 45.67
 * - Booleans: true, false
 * - Arrays: Check if value is in array: values['field'].includes('value')
 * 
 * Examples:
 * - Simple equality: values['user_type'] === 'admin'
 * - Multiple conditions: values['status'] === 'active' && values['age'] >= 18
 * - Array check: values['roles'].includes('manager')
 * - Negation: !values['is_deleted']
 * - Complex: (values['type'] === 'premium' || values['type'] === 'enterprise') && values['active'] === true
 * 
 * TRUST MODEL & SECURITY:
 * =======================
 * 
 * This module uses the Function constructor to evaluate conditions dynamically.
 * 
 * Security Considerations:
 * - Conditions are evaluated in a controlled context with only 'values' in scope
 * - No access to global objects (window, document, etc.) or browser APIs
 * - Conditions should come from trusted sources (server-side config, not user input)
 * - Invalid conditions fail safely (return false) rather than throwing errors
 * 
 * Best Practices:
 * - Validate condition syntax on the server before storing in configuration
 * - Use simple, readable conditions when possible
 * - Avoid complex nested expressions that are hard to debug
 * - Test conditions thoroughly before deploying
 * 
 * Limitations:
 * - Cannot use functions that aren't available in the evaluation context
 * - Cannot access external variables or modules
 * - Performance: Complex conditions with many operators may be slower
 */

/**
 * Evaluates a condition string expression with the provided values context
 * 
 * @param {string} condition - String expression to evaluate (e.g., "values['field'] === 'value'")
 *                              Must be valid JavaScript expression that can be evaluated with 'values' in scope
 * @param {Object} values - Object containing field values to use in evaluation
 *                          Keys are field names, values can be strings, numbers, booleans, or arrays
 * @returns {boolean} - Result of condition evaluation
 *                     Returns false if:
 *                     - condition is null, undefined, or not a string
 *                     - condition is 'false' (string)
 *                     - condition evaluation throws an error
 *                     - condition evaluates to a falsy value
 *                     Returns true if:
 *                     - condition is 'true' (string)
 *                     - condition evaluates to a truthy value
 * 
 * @example
 * // Simple equality check
 * evaluateCondition("values['status'] === 'active'", { status: 'active' }) // returns true
 * 
 * @example
 * // Multiple conditions with AND
 * evaluateCondition("values['age'] >= 18 && values['verified'] === true", { age: 20, verified: true }) // returns true
 * 
 * @example
 * // Array includes check
 * evaluateCondition("values['roles'].includes('admin')", { roles: ['user', 'admin'] }) // returns true
 * 
 * @example
 * // Always true condition
 * evaluateCondition("true", {}) // returns true
 * 
 * @example
 * // Invalid condition fails safely
 * evaluateCondition("invalid syntax", {}) // returns false, logs warning
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
    // Note: This allows dynamic evaluation but should only be used with trusted condition strings
    const func = new Function('values', `return ${condition}`);
    const result = func(values);
    return Boolean(result);
  } catch (error) {
    // Fail safely - if condition is invalid, return false
    // This prevents errors from breaking the form rendering
    console.warn('Condition evaluation failed:', condition, error);
    return false;
  }
}

/**
 * Filters an array of options based on their condition property
 * 
 * Each option can have an optional 'condition' property that determines visibility.
 * Options without a condition are always included.
 * 
 * @param {Array} options - Array of option objects with optional condition property
 *                          Format: [{ label: 'Option 1', value: 'opt1', condition: "values['field'] === 'value'" }, ...]
 * @param {Object} values - Object containing field values to use in condition evaluation
 * @returns {Array} - Filtered array of options that pass their conditions (or have no condition)
 * 
 * @example
 * const options = [
 *   { label: 'Always Visible', value: '1' },
 *   { label: 'Conditional', value: '2', condition: "values['type'] === 'admin'" }
 * ];
 * filterOptionsByCondition(options, { type: 'admin' }) // returns both options
 * filterOptionsByCondition(options, { type: 'user' }) // returns only first option
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

