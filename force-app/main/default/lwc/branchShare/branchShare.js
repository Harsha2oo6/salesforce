import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class BranchShare extends LightningElement {
    selectedIds = [];
    idsString = '';

    connectedCallback() {
        this.getRoleAccess();
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            const idsParam = currentPageReference.state.c__ids;
            if (idsParam) {
                this.idsString = idsParam;
                this.selectedIds = idsParam.split(',');
            }
        }
    }

    // --- NEW GETTER ---
    // This calculates TRUE if the list is empty, FALSE if it has records
    get isAssignDisabled() {
        return this.selectedIds.length === 0;
    }

    handleDeassign() {
        window.history.back();
    }
    
    handleAssign() {
        alert(`Ready to process ${this.selectedIds.length} records!`);
    }
}