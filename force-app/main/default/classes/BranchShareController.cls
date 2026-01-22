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
        List<String> roleList = new List<String>{ 'Regional Heads' };
        
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

        // Return different mock users based on the selected role
        List<Object> usersList = getMockUsersByRole(role);
        
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

    // Helper to return different mock users for each role
    private static List<Object> getMockUsersByRole(String role) {
        List<Object> usersList = new List<Object>();

        if (String.isBlank(role)) {
            // Fallback generic users
            usersList.add(new Map<String, String>{ 'id' => '005000000000001AAA', 'name' => 'Generic User 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000002AAA', 'name' => 'Generic User 2' });
            return usersList;
        }

        String normalizedRole = role.trim().toLowerCase();

        if (normalizedRole == 'senior manager') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000011AAA', 'name' => 'Senior Manager 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000012AAA', 'name' => 'Senior Manager 2' });
        } else if (normalizedRole == 'regional head') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000021AAA', 'name' => 'Regional Head 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000022AAA', 'name' => 'Regional Head 2' });
        } else if (normalizedRole == 'branch manager') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000031AAA', 'name' => 'Branch Manager 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000032AAA', 'name' => 'Branch Manager 2' });
        } else if (normalizedRole == 'branch head') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000041AAA', 'name' => 'Branch Head 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000042AAA', 'name' => 'Branch Head 2' });
        } else if (normalizedRole == 'branch coordinator') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000051AAA', 'name' => 'Branch Coordinator 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000052AAA', 'name' => 'Branch Coordinator 2' });
        } else if (normalizedRole == 'branch member') {
            usersList.add(new Map<String, String>{ 'id' => '005000000000061AAA', 'name' => 'Branch Member 1' });
            usersList.add(new Map<String, String>{ 'id' => '005000000000062AAA', 'name' => 'Branch Member 2' });
        } else {
            // Unknown role – fallback users
            return null;
        }

        return usersList;
    }
}