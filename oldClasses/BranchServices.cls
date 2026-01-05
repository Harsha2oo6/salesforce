public with sharing class BranchServices {
    
    @AuraEnabled
    public static void createBranch(Branch__c branch){
        insert branch;
    }
    @AuraEnabled (cacheable=true)
    public static List<Branch__c> getAllbranches() {
        List<Branch__c> branches = [SELECT Id, Name FROM Branch__c];
        return branches;
    }
    public static List<Student__c> getStudentUnderBranch(Id branchId) {
        List<Student__c> students = [SELECT Reg_No__c, Name, Course__c, Age__c ,Branch__c FROM Student__c WHERE Branch__c = :branchId];
        return students;
    }
    public static Map<string, List<Student__c>> getAllStudentsAndBranches() {
        Map<string,List<Student__c>> studentsMap = new Map<string,List<Student__c>>();
        List<Branch__c> branches = [SELECT Id, Name ,Total_seats__c ,Fee_per_semester__c FROM Branch__c];
        for (Branch__c branch : branches) {
            List<Student__c> students = [SELECT Id, Name, Course__c, Age__c FROM Student__c WHERE Branch__c = :branch.Id];
            studentsMap.put(branch.Name, students);
        }
        return studentsMap;
    }
    @AuraEnabled (cacheable=true)
    public static Id getBranchId(string branchName){
        List<Branch__c> singleBranch = [SELECT Id FROM Branch__c WHERE Name = :branchName LIMIT 1];
        return singleBranch[0].Id;
    }
}   