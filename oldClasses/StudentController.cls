public with sharing class StudentController {

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {
        return [
            SELECT Id, Name, Course__c, Age__c
            FROM Student__c
        ];
    }
    @AuraEnabled
    public static void createStudent(Student__c student) {
        insert student;
    }
    @AuraEnabled
    public static void updateStudentDetails(Id studentId, string course, Integer age, Id branchId) {
        Student__c student = [SELECT Id, Name, Course__c, Age__c, Branch__c FROM Student__c WHERE Id = :studentId LIMIT 1];
        if (course != null) {
            student.Course__c = course;
        }
    
        if (age != null) {
            student.Age__c = age;
        }
    
        if (branchId != null) {
            student.Branch__c = branchId;
        }
        update student;
    }
    @AuraEnabled
    public static void deleteStudent(string studentName) {
        Student__c student = [SELECT Id FROM Student__c WHERE Name = :studentName LIMIT 1];
        delete student;
    }
    public static Id getStudentId(string studentName) {
        Student__c student = [SELECT Id FROM Student__c WHERE Name = :studentName ];
        return student.Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static Branch__c getRelatedBranchInfo(Id studentId) {
        Student__c student = [
            SELECT Id, Branch__c
            FROM Student__c 
            WHERE Id = :studentId 
            LIMIT 1
        ];
        
        if (student.Branch__c != null) {
            return [
                SELECT Id, Name, Total_seats__c, Fee_per_semester__c
                FROM Branch__c
                WHERE Id = :student.Branch__c
                LIMIT 1
            ];
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudentsInSameBranch(Id studentId) {
        Student__c currentStudent = [
            SELECT Id, Branch__c 
            FROM Student__c 
            WHERE Id = :studentId 
            LIMIT 1
        ];
        
        if (currentStudent.Branch__c == null) {
            return new List<Student__c>();
        }
        
        return [
            SELECT Id, Name, Course__c, Age__c, Reg_No__c, Branch__c
            FROM Student__c 
            WHERE Branch__c = :currentStudent.Branch__c 
            AND Id != :studentId
            ORDER BY Name
        ];
    }
}
