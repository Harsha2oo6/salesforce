public inherited sharing class StudentSelector {
    public List<Student__c> selectStudentsByCollegeName(String searchKey) {
        String key = '%' + searchKey + '%';
        // Querying Student__c and related Branch and College names
        // Note: Ensuring fields exist. Branch__r is the relationship to Branch__c (assumed)
        // and which_college_it_is__r is the relationship to College__c (assumed)
        return [
            SELECT Id, Name, Branch__r.Name, Branch__r.which_college_it_is__r.Name
            FROM Student__c
            WHERE Branch__r.which_college_it_is__r.Name LIKE :key
            WITH SECURITY_ENFORCED
            LIMIT 50
        ];
         // Using SOSL for better performance on large datasets
        // SOSL is indexed and optimized for text search across millions of records
        // String soslQuery = 'FIND :searchKey IN ALL FIELDS RETURNING Student__c(Id, Name, Branch__r.Name, Branch__r.which_college_it_is__r.Name WHERE Branch__r.which_college_it_is__r.Name != null LIMIT 50)';
        
        // List<List<SObject>> searchResults = Search.query(soslQuery);
        
        // if (searchResults.isEmpty() || searchResults[0].isEmpty()) {
        //     return new List<Student__c>();
        // }
        
        // return (List<Student__c>) searchResults[0];
    }

    public List<Student__c> selectRecentStudents() {
        return [
            SELECT Id, Name, Branch__r.Name, Branch__r.which_college_it_is__r.Name
            FROM Student__c
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }
}
