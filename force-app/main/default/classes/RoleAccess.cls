public with sharing class RoleAccess {
    public static Map<String, Object> getRoleAccess(String recordId, String role) {
        // Wait for 3 seconds
        Long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < 3000) {
            // Wait loop
        }
        
        // Take the first record ID from the list
        String recordId = recordIds != null && recordIds.size() > 0 ? recordIds[0] : null;
        
        // Return all available roles
        return new List<String>{
            'Senior Manager', 
            'Regional Head', 
            'Branch Manager', 
            'Branch Head', 
            'Branch Coordinator', 
            'Branch Member'
        };
    }
    public static String getUserIds(String role) {
        // Wait for 3 seconds
        Long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < 3000) {
            // Wait loop
        }
        
        List<Object> users = new List<Object>{
            new Map<String, Object>{
                'id' => '111',
                'name' => 'User1',
            },
            new Map<String, Object>{
                'id' => '222',
                'name' => 'User2',
            },
            new Map<String, Object>{
                'id' => '333',
                'name' => 'User3',
            }
        };
        return users;
    }
    public static String getAssignmentResponse(String userId) {
        // Wait for 3 seconds
        Long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < 3000) {
            // Wait loop
        }
        Map<String, Object> response = new Map<String, Object>{
            'success' => 'true',
            'count' => 10,
            'message' => 'Successfully assigned n opportunities.',
        };
        return response;
    }
}