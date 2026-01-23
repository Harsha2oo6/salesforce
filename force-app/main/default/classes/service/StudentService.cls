public inherited sharing class StudentService {
    public List<Student__c> searchStudents(String collegeName) {
        StudentSelector selector = new StudentSelector();
        
        if (String.isBlank(collegeName)) {
            return selector.selectRecentStudents();
        }
        
        return selector.selectStudentsByCollegeName(collegeName);
    }
}
