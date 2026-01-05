import { LightningElement, track, api } from 'lwc';

export default class CommonPopupButton extends LightningElement {
    @api buttonLabel = 'Popup Button';
    @api variant = 'brand';
    @track showModal = false;

    // ---------- OPEN / CLOSE ----------
    handleOnClickPopupButton() {
        this.showModal = true;
    }
    handleClose() {
        this.showModal = false;
    }
    handleCloseModalFromChild() {
        this.handleClose();
    }

}
