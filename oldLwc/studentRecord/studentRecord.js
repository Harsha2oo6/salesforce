import { LightningElement, api } from 'lwc';
import getRelatedBranchInfo from '@salesforce/apex/StudentController.getRelatedBranchInfo';
import getStudentsInSameBranch from '@salesforce/apex/StudentController.getStudentsInSameBranch';

export default class StudentRecord extends LightningElement {
    @api recordId;
    
    branchInfo;
    studentsInBranch = [];
    isLoading = false;
    dataLoaded = false;
    
    branchColumns = [
        { label: 'Field', fieldName: 'field', type: 'text' },
        { label: 'Value', fieldName: 'value', type: 'text' }
    ];
    studentColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Registration Number', fieldName: 'Reg_No__c', type: 'text' },
        { label: 'Course', fieldName: 'Course__c', type: 'text' },
        { label: 'Age', fieldName: 'Age__c', type: 'number' }
    ];
    
    handleRelatedTabActive() {
        // Only fetch data if not already loaded
        if (!this.dataLoaded) {
            this.loadRelatedData();
        }
    }
    
    loadRelatedData() {
        this.isLoading = true;
        this.dataLoaded = true;
        
        // Call both Apex methods in parallel
        Promise.all([
            getRelatedBranchInfo({ studentId: this.recordId }),
            getStudentsInSameBranch({ studentId: this.recordId })
        ])
        .then(([branchData, studentsData]) => {
            this.branchInfo = branchData;
            this.studentsInBranch = studentsData || [];
        })
        .catch((error) => {
            console.error('Error fetching related data:', error);
            this.branchInfo = null;
            this.studentsInBranch = [];
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
    
    get branchInfoItems() {
        if (!this.branchInfo) {
            return [];
        }
        return [
            { 
                label: 'Branch Name', 
                value: this.branchInfo.Name,
                isEditable: false,
                isLink: false
            },
            { 
                label: 'Total Seats', 
                value: this.branchInfo.Total_seats__c || 'N/A',
                isEditable: false,
                isLink: false
            },
            { 
                label: 'Fee per Semester', 
                value: this.branchInfo.Fee_per_semester__c || 'N/A',
                isEditable: false,
                isLink: false
            }
        ];
    }
    
    get studentsInBranchItems() {
        if (!this.studentsInBranch || this.studentsInBranch.length === 0) {
            return [];
        }
        return this.studentsInBranch.map(student => ({
            label: student.Name || 'N/A',
            value: `Reg No: ${student.Reg_No__c || 'N/A'} | Course: ${student.Course__c || 'N/A'} | Age: ${student.Age__c || 'N/A'}`,
            isEditable: true,
            isLink: false,
            fieldName: student.Id
        }));
    }
    
    get hasBranchInfo() {
        return this.branchInfo !== null && this.branchInfo !== undefined;
    }
    
    get hasStudentsInBranch() {
        return this.studentsInBranch && this.studentsInBranch.length > 0;
    }
    
    handleEdit(event) {
        const fieldName = event.detail.fieldName;
        // Add your edit logic here
    }
}