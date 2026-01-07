import { LightningElement } from 'lwc';

export default class NiatHighlightsPanel extends LightningElement {
    handlePayloadToSendToParent(event) {
        const { formData } = event.detail;
    }
}