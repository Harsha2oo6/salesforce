import { LightningElement } from 'lwc';

export default class NiatHighlightsPanel extends LightningElement {
    handlePayloadToSendToParent(event) {
        const { formData } = event.detail;
        // console.log('from highlightsPanel.js: Payload received:', formData);
    }
}