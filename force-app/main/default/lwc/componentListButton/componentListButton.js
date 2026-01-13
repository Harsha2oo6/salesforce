import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRoleAccess from '@salesforce/apex/BranchShareController.getRoleAccess';
import getUserIds from '@salesforce/apex/BranchShareController.getUserIds';
import getAssignmentResponse from '@salesforce/apex/BranchShareController.getAssignmentResponse';

export default class ComponentListButton extends LightningElement {
    // URL Parameters
    selectedIds = [];
    action = '';
    
    // UI State
    isLoading = false;
    isLoadingUsers = false;
    roles = [];
    users = [];
    selectedRole = '';
    selectedUserId = '';
    isSubmitted = false;
    assignmentSuccessMessage = '';
    // Role options for combobox
    roleOptions = [];
    userOptions = [];
    
 
    // Wire adapter for CurrentPageReference
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        this.resetState();
        if (currentPageReference && currentPageReference.state) {
            const idsParam = currentPageReference.state.c__ids;
            const actionParam = currentPageReference.state.c__action;
            
            if (idsParam) {
                this.selectedIds = idsParam.split(',').filter(id => id.trim() !== '');
            }
            
            if (actionParam) {
                this.action = actionParam.toUpperCase();
            }
            
            // Load roles once we have the parameters
            if (this.selectedIds.length > 0 && this.action) {
                this.loadRoles();
            }
        }
    }
    
    resetState() {
        this.isSubmitted = false;
        this.selectedUserId = '';
        this.selectedRole = '';
        this.roleOptions = [];
        this.userOptions = [];
        this.assignmentSuccessMessage = '';
        this.isLoading = false;
        this.isLoadingUsers = false;
        this.selectedIds = [];
        this.action = '';
    }
    connectedCallback() {
        // Wire adapter will handle loading roles when state is available
    }
    
    loadRoles() {
        this.isLoading = true;
        getRoleAccess({ recordIds: this.selectedIds, action: this.action })
            .then(result => {
                // Extract roles from Map response: { "roles": [...] }
                const rolesList = result && result.roles ? result.roles : [];
                this.roles = rolesList;
                this.roleOptions = this.roles.map(role => ({
                    label: role,
                    value: role
                }));
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading roles:', error);
                this.showToast('Error', 'Failed to load roles: ' + (error.body?.message || error.message), 'error');
                this.isLoading = false;
            });
    }
    
    handleRoleChange(event) {
        this.selectedRole = event.detail.value;
        this.selectedUserId = ''; // Reset user selection
        this.users = [];
        this.userOptions = [];
        
        if (this.selectedRole) {
            this.loadUsers();
        }
    }
    
    loadUsers() {
        this.isLoadingUsers = true;
        getUserIds({ role: this.selectedRole })
            .then(result => {
                // Extract users from Map response: { "users": [...] }
                const usersList = result && result.users ? result.users : [];
                this.users = usersList;
                // Handle lowercase keys (id, name) from RoleAccess format
                this.userOptions = this.users.map(user => ({
                    label: user.name || user.Name,
                    value: user.id || user.Id
                }));
                this.isLoadingUsers = false;
            })
            .catch(error => {
                console.error('Error loading users:', error);
                this.showToast('Error', 'Failed to load users: ' + (error.body?.message || error.message), 'error');
                this.isLoadingUsers = false;
            });
    }
    
    handleUserChange(event) {
        this.selectedUserId = event.detail.value;
    }
    
    handleSave() {
        if (!this.selectedUserId) {
            this.showToast('Validation Error', 'Please select a user', 'error');
            return;
        }
        
        this.isLoading = true;
        this.isSubmitted = false;
        getAssignmentResponse({
            product_opportunityIds: this.selectedIds,
            userId: this.selectedUserId,
            action: this.action
        })
            .then(result => {
                console.log('Assignment response:', result);
                this.isLoading = false;
                // Extract message from response Map: { "success": true, "count": 15, "message": "..." }
                if (result && result.success) {
                    this.isSubmitted = true;
                    const message = result.message || 'Assignment completed successfully';
                    this.assignmentSuccessMessage = message;
                } else {
                    this.showToast('Error', 'Assignment failed. Please try again.', 'error');
                }
            })
            .catch(error => {
                console.error('Error performing assignment:', error);
                this.showToast('Error', 'Failed to perform assignment: ' + (error.body?.message || error.message), 'error');
                this.isLoading = false;
            });
    }
    

    handleGoBack() {
        window.history.go(-3);
    }
    
    
    // Getters for UI
    get cardTitle() {
        if (this.action === 'ASSIGN') {
            return 'Assign Records';
        } else if (this.action === 'DEASSIGN') {
            return 'De-Assign Records';
        }
        return 'Update Button';
    }
    
    get summaryMessage() {
        const actionText = this.action === 'ASSIGN' ? 'assign' : 'de-assign';
        return `You are about to ${actionText} ${this.selectedIds.length} record(s).`;
    }
    
    get isUserComboboxDisabled() {
        return !this.selectedRole || this.isLoadingUsers;
    }
    
    get userPlaceholder() {
        if (this.isLoadingUsers) {
            return 'Loading users...';
        }
        return 'Select a user';
    }
    
    get isSaveDisabled() {
        return !this.selectedUserId || this.isLoading;
    }
    
    get hasRecords() {
        return this.selectedIds.length > 0;
    }

    get showForm() {
        return !this.isSubmitted;
    }

    get showPostSubmit() {
        return this.isSubmitted;
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}
