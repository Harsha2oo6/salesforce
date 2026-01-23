public with sharing class StudentController {
    @AuraEnabled(cacheable=true)
    public static List<StudentDTO> searchStudents(String collegeName) {
        try {
            StudentService service = new StudentService();
            List<Student__c> students = service.searchStudents(collegeName);
            
            List<StudentDTO> results = new List<StudentDTO>();
            for (Student__c student : students) {
                results.add(new StudentDTO(student));
            }
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching students: ' + e.getMessage());
        }
    }
}
