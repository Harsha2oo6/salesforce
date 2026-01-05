import { LightningElement, track, wire } from 'lwc';
import { publish, subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import PRODUCT_DATA_CHANNEL from '@salesforce/messageChannel/ProductDataChannel__c';

/**
 * CallSteps - Multi-step call flow component
 * 
 * SUBSCRIBER COMPONENT:
 * This component subscribes to ProductDataChannel via LMS to receive
 * shared product details data (phone numbers, names).
 * 
 * When this component mounts (even if late), it requests data from the provider.
 * 
 * Required: pageDataProvider component must be on the same Lightning page.
 */
export default class NiatCallSteps extends LightningElement {
    @track currentStep = 'CALL_OPTIONS';
    @track callStatus = 'initiating'; // 'initiating' | 'initiated' | 'complete'
    @track isCalling = false;
    @track fullName = '';
    @track phoneNumbers = [];
    @track isDataLoading = true;
    @track selectedNumber = undefined;
    subscription = null;
    rawProductData = null;
    hasReceivedData = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToChannel();
        // Request data from the provider (in case we mounted late)
        this.requestData();
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
     * Request data from the provider
     * This is useful when this component mounts after the initial data publish
     */
    requestData() {
        if (this.messageContext) {
            publish(this.messageContext, PRODUCT_DATA_CHANNEL, {
                messageType: 'DATA_REQUEST'
            });
        }
    }

    /**
     * Handle incoming messages from the ProductDataChannel
     * @param {Object} message - The LMS message
     */
    handleMessage(message) {
        // Only process DATA_RESPONSE messages
        if (message.messageType !== 'DATA_RESPONSE') {
            return;
        }

        const { payload, status } = message;

        if (status === 'loading') {
            this.isDataLoading = true;
            return;
        }

        if (status === 'error') {
            this.isDataLoading = false;
            console.warn('[CallSteps] Error received from LMS, using fallback data');
            return;
        }

        if (status === 'success' && payload) {
            this.rawProductData = payload;
            this.extractDataFromPayload(payload);
            this.isDataLoading = false;
            this.hasReceivedData = true;
        }
    }

    /**
     * Extract phone numbers and name from the shared payload
     * @param {Object} payload - The Apex response containing key_fields and sections
     */
    /**
     * Extract phone numbers and name from the shared payload
     * Phone numbers are extracted from Personal Details section fields with type 'phone'
     * @param {Object} payload - The Apex response containing key_fields and sections
     */
    extractDataFromPayload(payload) {
        const phoneNumbersArr = [];

        if (payload.sections && Array.isArray(payload.sections)) {
            const personalDetails = payload.sections.find(section => section.section_name === 'Personal Details');
            if (personalDetails && personalDetails.fields && Array.isArray(personalDetails.fields)) {
                personalDetails.fields.forEach(field => {
                    // Extract full_name
                    if (field.name === 'full_name' && field.value) {
                        this.fullName = field.value;
                    }
                    // Extract phone fields from Personal Details
                    if (field.type === 'phone' && field.value) {
                        phoneNumbersArr.push({
                            label: field.value+' ('+field.name+')',
                            value: field.value
                        });
                    }
                });
            }
        }

        // Set phone numbers for lightning-radio-group
        this.phoneNumbers = phoneNumbersArr;
    }

    // ---------- OPEN / CLOSE ----------
    handleOnClickCallButton() {
        this.selectedNumber = undefined; // Reset when opening popup
        this.currentStep = 'CALL_OPTIONS';
    }

    resetState() {
        this.currentStep = 'CALL_OPTIONS';
        this.callStatus = 'initiating';
        this.isCalling = false;
        this.selectedNumber = undefined;
    }

    // ---------- STEP NAV ----------
    goToCallOptions() {
        this.currentStep = 'CALL_OPTIONS';
        this.callStatus = 'initiating';
        this.selectedNumber = undefined;
    }

    handleTataCall() {
        this.currentStep = 'TATA_SELECT_NUMBER';
    }

    handleDirectCall() {
        this.selectedNumber = undefined; // Reset selectedNumber for direct call
        this.currentStep = 'FORM';
    }

    handleNumberSelect(event) {
        this.selectedNumber = event.detail.value;
    }

    async handleContinueAfterNumber() {
        this.currentStep = 'TATA_CALLING';
        await this.mockCall();
    }

    async mockCall() {
        this.isCalling = true;
        this.callStatus = 'initiating';

        // After 2s, show "Call initiated"
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            if (this.currentStep === 'TATA_CALLING') {
                this.callStatus = 'initiated';
            }
        }, 2000);

        // After 5s total, show "Call complete"
        return new Promise((resolve) => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (this.currentStep === 'TATA_CALLING') {
                    this.callStatus = 'complete';
                    this.isCalling = false;
                }
                resolve();
            }, 5000);
        });
    }

    handleContinueAfterCall() {
        this.currentStep = 'FORM';
    }
    handleCallAgain() {
        this.goToCallOptions();
    }

    // Form configuration
    formConfig = [
        {
            type: "text",
            field: "firstname",
            label: "First Name",
            shouldShowLabel: true,
            placeholder: "Enter first name",
            maxLength: 100
        },
        {
            type: "text",
            field: "lastname",
            label: "Last Name",
            shouldShowLabel: true,
            placeholder: "Enter last name",
            maxLength: 100
        },
        {
            type: "email",
            field: "email",
            label: "Email Address",
            shouldShowLabel: true,
            placeholder: "example@email.com"
        },
        {
            type: "text",
            field: "fullName",
            label: "Full Name",
            shouldShowLabel: true,
            placeholder: "Enter full name",
            maxLength: 100
        },
        {
            type: "phone",
            field: "phoneNumber",
            label: "Phone Number",
            shouldShowLabel: true,
            placeholder: "Enter phone number",
            countryCode: "+91"
        },
        {
            type: "date",
            field: "dateOfBirth",
            label: "Date of Birth",
            shouldShowLabel: true
        }
    ];

    handleFormChange(event) {
        const { field, value, formData } = event.detail;
        // console.log('event:', event);
        // console.log('field:', field);
        // console.log('value:', value);
        // console.log('formData:', JSON.stringify(formData));
    }

    handleFormSubmit(event) {
        // Collect form data from component's tracked properties
        const formData = {
            fullName: this.fullName,
            phoneNumber: this.selectedNumber || ''
        };
        
        this.sendPayloadToParent(formData);
        this.resetState();
        this.sendCloseModelEventToPopupButton();
        console.log('from callSteps.js: Form submitted:', formData);
    }

    sendCloseModelEventToPopupButton() {
        this.dispatchEvent(new CustomEvent('closemodal', {
            bubbles: true,
            composed: true
        }));
    }

    sendPayloadToParent(formData) {
        this.dispatchEvent(new CustomEvent('payloadtosendtoparent', {
            detail: { formData }
        }));
    }

    // ---------- GETTERS ----------
    get isCallOptions() {
        return this.currentStep === 'CALL_OPTIONS';
    }

    get isTataSelectNumber() {
        return this.currentStep === 'TATA_SELECT_NUMBER';
    }

    get isTataCalling() {
        return this.currentStep === 'TATA_CALLING';
    }

    get isForm() {
        return this.currentStep === 'FORM';
    }

    get isCallInitiating() {
        return this.callStatus === 'initiating';
    }

    get isCallInitiated() {
        return this.callStatus === 'initiated';
    }

    get isCallComplete() {
        return this.callStatus === 'complete';
    }

    get isNumberSelected() {
        return !!this.selectedNumber;
    }

    get hasSelectedNumber() {
        return !!this.selectedNumber;
    }

    get isContinueDisabled() {
        return !this.selectedNumber;
    }

    get hasPhoneNumbers() {
        return this.phoneNumbers && this.phoneNumbers.length > 0;
    }

    handleFullNameChange(event) {
        this.fullName = event.detail.value;
    }

    handlePhoneNumberChange(event) {
        this.selectedNumber = event.detail.value;
    }
}
