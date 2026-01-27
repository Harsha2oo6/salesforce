public inherited sharing class StudentDTO {
    @AuraEnabled public String id;
    @AuraEnabled public String name;
    @AuraEnabled public String branchName;
    @AuraEnabled public String collegeName;

    public StudentDTO(Student__c student) {
        this.id = student.Id;
        this.name = student.Name;
        // Handle potential nulls in relationships
        if (student.Branch__r != null) {
            this.branchName = student.Branch__r.Name;
            if (student.Branch__r.which_college_it_is__r != null) {
                this.collegeName = student.Branch__r.which_college_it_is__r.Name;
            }
        }
    }
}
