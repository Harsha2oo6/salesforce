public with sharing class BranchShareController {
    
    /**
     * API 1: Fetch Child Roles
     * Returns: { "roles": ["Senior Manager", "Regional Head"] }
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getRoleAccess(List<String> recordIds, String action) {
        // Mock Latency
        simulateLatency();

        // MOCK LOGIC: Returns hardcoded roles wrapped in a Map
        // In real life: Query AccessConfig__c based on User and Action
        List<String> roleList = new List<String>{ 'Senior Manager', 'Regional Head' };
        
        return new Map<String, Object>{
            'roles' => roleList
        };
    }
    
    /**
     * API 2: Fetch Eligible Users
     * Returns: { "users": [ {"id": "...", "name": "..."}, ... ] }
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getUserIds(String role) {
        simulateLatency();

        List<Object> usersList = new List<Object>();
        
        // Mock Data
        usersList.add(new Map<String, String>{ 'id' => '005000000000001AAA', 'name' => 'John Doe' });
        usersList.add(new Map<String, String>{ 'id' => '005000000000002AAA', 'name' => 'Jane Smith' });
        usersList.add(new Map<String, String>{ 'id' => '005000000000003AAA', 'name' => 'Bob Johnson' });
        
        return new Map<String, Object>{
            'users' => usersList
        };
    }
    
    /**
     * API 3: Assign / De-Assign
     * Returns: { "success": true, "count": 15, "message": "..." }
     */
    @AuraEnabled
    public static Map<String, Object> getAssignmentResponse(List<String> product_opportunityIds, String userId, String action) {
        try {
            simulateLatency();
            
            Integer recordCount = product_opportunityIds != null ? product_opportunityIds.size() : 0;
            String actionText = (action == 'ASSIGN') ? 'assigned' : 'de-assigned';
            String message = 'Successfully ' + actionText + ' ' + recordCount + ' record(s).';
            
            return new Map<String, Object>{
                'success' => true,
                'count' => recordCount,
                'message' => message
            };
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    // Helper for delay
    private static void simulateLatency() {
        Long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < 1000) { /* 1 sec delay */ }
    }
}