import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import PRODUCT_DATA_CHANNEL from '@salesforce/messageChannel/ProductDataChannel__c';

/**
 * NiatKeyFieldsCard - Displays key fields from product details
 * 
 * SUBSCRIBER COMPONENT:
 * This component subscribes to ProductDataChannel via LMS to receive
 * shared product details data. It does NOT call Apex directly.
 * 
 * Required: pageDataProvider component must be on the same Lightning page.
 * 
 * Optional @api: keyFields can still be passed from parent for flexibility
 */
export default class NiatKeyFieldsCard extends LightningElement {
    @api keyFields = []; // Optional: can be passed from parent if needed
    @api cardTitle = 'Key Fields';
    
    @track internalKeyFields = [];
    @track isLoading = true;
    @track error;
    @track useExternalData = false; // Flag to indicate if using LMS data

    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        // If keyFields prop is provided, use them directly
        if (this.keyFields && this.keyFields.length > 0) {
            this.useExternalData = false;
            this.isLoading = false;
        } else {
            // Otherwise, subscribe to LMS channel
            this.useExternalData = true;
            this.subscribeToChannel();
        }
    }

    disconnectedCallback() {
        this.unsubscribeFromChannel();
    }

    /**
     * Subscribe to the ProductDataChannel to receive shared data
     * Uses APPLICATION_SCOPE to receive messages from any component on the page
     */
    subscribeToChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                PRODUCT_DATA_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     * Unsubscribe when component is removed from DOM
     */
    unsubscribeFromChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    /**
     * Handle incoming messages from the ProductDataChannel
     * @param {Object} message - The LMS message
     * @param {Object} message.payload - The Apex response data
     * @param {string} message.status - 'loading' | 'success' | 'error'
     * @param {Object|null} message.error - Error details
     */
    handleMessage(message) {
        // Only process if we're using external (LMS) data
        if (!this.useExternalData) {
            return;
        }

        // Only process DATA_RESPONSE messages (ignore DATA_REQUEST)
        if (message.messageType && message.messageType !== 'DATA_RESPONSE') {
            return;
        }

        const { payload, status, error } = message;

        if (status === 'loading') {
            this.isLoading = true;
            this.error = undefined;
            return;
        }

        if (status === 'error') {
            this.isLoading = false;
            // Silently handle errors - don't break the component
            console.warn('[NiatKeyFieldsCard] Error received from LMS:', error);
            this.error = undefined; // Don't show error to avoid template issues
            this.internalKeyFields = [];
            return;
        }

        if (status === 'success' && payload) {
            const keyFields = payload.key_fields || [];
            
            // Sort key fields by order if present
            if (keyFields.length > 0 && keyFields[0].order !== undefined) {
                this.internalKeyFields = [...keyFields].sort((a, b) => {
                    const orderA = a.order || 0;
                    const orderB = b.order || 0;
                    return orderA - orderB;
                });
            } else {
                this.internalKeyFields = keyFields;
            }
            
            this.isLoading = false;
            this.error = undefined;
        }
    }

    // Get keyFields from prop or internal state
    getKeyFields() {
        return (this.keyFields && this.keyFields.length > 0) ? this.keyFields : this.internalKeyFields;
    }

    // Sort fields by order
    get sortedKeyFields() {
        const fields = this.getKeyFields();
        if (!fields || !Array.isArray(fields) || fields.length === 0) {
            return [];
        }
        return [...fields].sort((a, b) => {
            const orderA = a.order || 0;
            const orderB = b.order || 0;
            return orderA - orderB;
        });
    }

    get hasKeyFields() {
        const fields = this.getKeyFields();
        return Array.isArray(fields) && fields.length > 0;
    }

    get errorMessage() {
        if (!this.error) return 'Unknown error';
        return this.error.message || 'Unknown error';
    }
}
