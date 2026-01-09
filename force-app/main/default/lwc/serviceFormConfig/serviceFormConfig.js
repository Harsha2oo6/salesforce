/**
 * Service module for fetching form configuration from Apex
 * Pure service layer - no UI concerns (no toasts, no UI state)
 */

import getFormConfig from '@salesforce/apex/DynamicFormController.getFormConfig';

/**
 * Fetches form configuration from Apex
 * @param {Object} component - The LWC component instance (for imperative Apex call)
 * @param {string} formName - Name/identifier of the form to fetch
 * @returns {Promise<Object>} - Promise that resolves to form configuration object
 * @throws {Error} - Throws structured error on failure (UI layer handles display)
 */
export async function fetchFormConfig(component, formName) {
  try {
    const configJson = await getFormConfig({ formName: formName });
    
    if (!configJson) {
      throw new Error('No configuration returned from server');
    }

    // Parse JSON string to object
    const config = JSON.parse(configJson);
    
    if (!config.fields || !Array.isArray(config.fields)) {
      throw new Error('Invalid configuration format: fields array is required');
    }

    return config;
  } catch (error) {
    console.error('Error fetching form config:', error);
    
    // Re-throw with structured error information (no UI concerns here)
    const errorMessage = error.body?.message || error.message || 'Unknown error';
    const structuredError = new Error(`Failed to load form configuration: ${errorMessage}`);
    structuredError.originalError = error;
    throw structuredError;
  }
}

