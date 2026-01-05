import { LightningElement, wire } from 'lwc';
import { publish, subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import PRODUCT_DATA_CHANNEL from '@salesforce/messageChannel/ProductDataChannel__c';
import getProductDetails from '@salesforce/apex/ProductDetailsController.getProductDetails';

/**
 * PageDataProvider - A hidden LWC component that acts as the single source of truth
 * for product details data on a Lightning Record Page.
 * 
 * USAGE:
 * 1. Add this component to your Lightning Record Page via App Builder
 * 2. This component will call Apex ONCE and publish data via LMS
 * 3. All other components should subscribe to ProductDataChannel to receive data
 * 
 * FEATURES:
 * - Caches data and re-publishes when late subscribers request it
 * - Supports request-response pattern for components that mount later
 */
export default class PageDataProvider extends LightningElement {
    @wire(MessageContext)
    messageContext;

    cachedMessage = null;
    subscription = null;

    @wire(getProductDetails)
    wiredProductDetails({ error, data }) {
        if (data) {
            this.cachedMessage = {
                messageType: 'DATA_RESPONSE',
                payload: data,
                status: 'success',
                error: null
            };
            this.publishData(this.cachedMessage);
            
            // Re-publish after delays to catch late subscribers
            this.scheduleRepublish();
        } else if (error) {
            this.cachedMessage = {
                messageType: 'DATA_RESPONSE',
                payload: null,
                status: 'error',
                error: {
                    message: error.body?.message || error.message || 'Unknown error occurred'
                }
            };
            this.publishData(this.cachedMessage);
            console.error('[PageDataProvider] Error fetching product details:', error);
        }
    }

    connectedCallback() {
        // Subscribe to listen for DATA_REQUEST messages from late-mounting components
        this.subscribeToRequests();
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    /**
     * Subscribe to listen for DATA_REQUEST messages
     * When a component mounts late and needs data, it sends a request
     */
    subscribeToRequests() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                PRODUCT_DATA_CHANNEL,
                (message) => this.handleIncomingMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     * Handle incoming messages - respond to DATA_REQUEST with cached data
     */
    handleIncomingMessage(message) {
        if (message.messageType === 'DATA_REQUEST') {
            // A component is requesting data - send cached response
            if (this.cachedMessage) {
                // Small delay to ensure the requester's subscription is ready
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.publishData(this.cachedMessage);
                }, 50);
            }
        }
    }

    /**
     * Schedule multiple re-publishes to catch late-connecting subscribers
     */
    scheduleRepublish() {
        const delays = [100, 300, 500, 1000];
        delays.forEach(delay => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (this.cachedMessage && this.messageContext) {
                    this.publishData(this.cachedMessage);
                }
            }, delay);
        });
    }

    /**
     * Publishes data to the ProductDataChannel
     * @param {Object} message - The message to publish
     */
    publishData(message) {
        if (this.messageContext) {
            publish(this.messageContext, PRODUCT_DATA_CHANNEL, message);
        }
    }
}
