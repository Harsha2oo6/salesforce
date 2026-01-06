/**
 * Service module for fetching form configuration from Apex
 */

import getFormConfig from '@salesforce/apex/DynamicFormController.getFormConfig';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Fetches form configuration from Apex
 * @param {Object} component - The LWC component instance (for imperative Apex call)
 * @param {string} formName - Name/identifier of the form to fetch
 * @returns {Promise<Object>} - Promise that resolves to form configuration object
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
    
    // Show error toast
    const evt = new ShowToastEvent({
      title: 'Error',
      message: 'Failed to load form configuration: ' + (error.body?.message || error.message || 'Unknown error'),
      variant: 'error',
      mode: 'sticky'
    });
    component.dispatchEvent(evt);

    throw error;
  }
}

