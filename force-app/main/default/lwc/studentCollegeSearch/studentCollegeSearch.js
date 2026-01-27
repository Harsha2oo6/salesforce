import { LightningElement, track } from 'lwc';
import searchStudents from '@salesforce/apex/StudentController.searchStudents';
import { NavigationMixin } from 'lightning/navigation';

/* 
 * Columns definition for the datatable.
 * Using DTO fields: name, branchName, collegeName
 */
const COLUMNS = [
    {
        label: 'Student Name',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'name' },
            target: '_blank'
        }
    },
    { label: 'Branch', fieldName: 'branchName', type: 'text' },
    { label: 'College', fieldName: 'collegeName', type: 'text' }
];

export default class StudentCollegeSearch extends NavigationMixin(LightningElement) {
    searchTerm = '';
    @track records = [];
    columns = COLUMNS;
    isLoading = false;
    error;


    connectedCallback() {
        this.handleSearch();
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch() {
        this.isLoading = true;
        this.error = undefined;

        try {
            // Even if searchTerm is empty, Apex will now return recent records
            const result = await searchStudents({ collegeName: this.searchTerm });
            
            // Transform result to include recordLink
            this.records = result.map(record => ({
                ...record,
                recordLink: `/lightning/r/Student__c/${record.id}/view`
            }));
        } catch (err) {
            this.error = err.body ? err.body.message : err.message;
            this.records = [];
        } finally {
            this.isLoading = false;
        }
    }




}
