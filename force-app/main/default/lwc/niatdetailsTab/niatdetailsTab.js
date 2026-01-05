import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import PRODUCT_DATA_CHANNEL from '@salesforce/messageChannel/ProductDataChannel__c';

/**
 * NiatDetailsTab - Displays product sections data
 * 
 * SUBSCRIBER COMPONENT:
 * This component subscribes to ProductDataChannel via LMS to receive
 * shared product details data. It does NOT call Apex directly.
 * 
 * Required: pageDataProvider component must be on the same Lightning page.
 */
export default class NiatDetailsTab extends LightningElement {
    @track sections = [];
    @track isLoading = true;
    @track error;
    @track rawData = null;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToChannel();
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
            this.error = error;
            console.error('[NiatDetailsTab] Error received from LMS:', error);
            return;
        }

        if (status === 'success' && payload) {
            this.rawData = payload;
            this.sections = this.processSections(payload.sections || []);
            this.isLoading = false;
            this.error = undefined;
        }
    }

    /**
     * Process sections to flatten array-type fields for rendering
     * If a field has type 'array', its value items are spread into the fields list
     * @param {Array} sections - The sections array from API
     * @returns {Array} - Processed sections with flattened array fields
     */
    processSections(sections) {
        return sections.map(section => {
            const flattenedFields = [];
            
            if (section.fields && Array.isArray(section.fields)) {
                section.fields.forEach(field => {
                    if (field.type === 'array' && Array.isArray(field.value)) {
                        // Flatten: spread the array items as individual fields
                        flattenedFields.push(...field.value);
                    } else {
                        // Keep non-array fields as-is
                        flattenedFields.push(field);
                    }
                });
            }
            
            return {
                ...section,
                fields: flattenedFields,
                hasFields: Array.isArray(flattenedFields) && flattenedFields.length > 0
            };
        });
    }

    get tabs() {
        return [
            { label: 'Details', value: 'details' },
        ];
    }

    get errorMessage() {
        if (!this.error) return 'Unknown error';
        return this.error.message || 'Unknown error';
    }

    get hasSections() {
        return Array.isArray(this.sections) && this.sections.length > 0;
    }
}
