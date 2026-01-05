public with sharing class ActivitiesController {
    
    @AuraEnabled(cacheable=true)
    public static String getActivities(
        String activityCategory,
        String fromDate,
        String toDate,
        Integer offset,
        Integer limitRecords
    ) {
        // Return JSON string matching sample.json structure
        // When real API is ready, replace this with HTTP callout using the parameters
        // For now, return mock data filtered by category and date range
        
        // Build all mock activities
        List<Map<String, Object>> allActivities = buildAllActivities();
        
        // Filter by activity category (REQUIRED - must match exactly)
        List<Map<String, Object>> filteredActivities = new List<Map<String, Object>>();
        for (Map<String, Object> activity : allActivities) {
            String category = (String)activity.get('activity_category');
            // Only include activities that match the requested category
            // If activityCategory is provided, it must match exactly
            if (String.isNotBlank(activityCategory)) {
                if (category == activityCategory) {
                    filteredActivities.add(activity);
                }
            } else {
                // If no category provided, return all (for backward compatibility)
                filteredActivities.add(activity);
            }
        }
        
        // Filter by date range (using due_date) - OPTIONAL
        if (String.isNotBlank(fromDate) || String.isNotBlank(toDate)) {
            List<Map<String, Object>> dateFilteredActivities = new List<Map<String, Object>>();
            for (Map<String, Object> activity : filteredActivities) {
                String dueDateStr = (String)activity.get('due_date');
                if (String.isNotBlank(dueDateStr)) {
                    Date dueDate = Date.valueOf(dueDateStr);
                    Date fromDateValue = String.isNotBlank(fromDate) ? Date.valueOf(fromDate) : null;
                    Date toDateValue = String.isNotBlank(toDate) ? Date.valueOf(toDate) : null;
                    
                    Boolean includeActivity = true;
                    if (fromDateValue != null && dueDate < fromDateValue) {
                        includeActivity = false;
                    }
                    if (toDateValue != null && dueDate > toDateValue) {
                        includeActivity = false;
                    }
                    
                    if (includeActivity) {
                        dateFilteredActivities.add(activity);
                    }
                } else {
                    // Include activities without dates
                    dateFilteredActivities.add(activity);
                }
            }
            filteredActivities = dateFilteredActivities;
        }
        
        // Calculate total records BEFORE pagination (this is the count of filtered items)
        Integer totalRecords = filteredActivities.size();
        
        // Apply pagination (offset and limit)
        Integer currentOffset = offset != null ? offset : 0;
        Integer currentLimit = limitRecords != null ? limitRecords : 10;
        
        // Slice the filtered activities array based on offset and limit
        List<Map<String, Object>> paginatedActivities = new List<Map<String, Object>>();
        Integer startIndex = currentOffset;
        Integer endIndex = Math.min(currentOffset + currentLimit, filteredActivities.size());
        
        for (Integer i = startIndex; i < endIndex; i++) {
            paginatedActivities.add(filteredActivities[i]);
        }
        
        // Calculate pagination metadata
        Integer nextOffset = currentOffset + currentLimit;
        Boolean hasMore = nextOffset < totalRecords;
        
        // Build response matching sample.json structure
        Map<String, Object> response = new Map<String, Object>();
        response.put('offset', currentOffset);
        response.put('limit', currentLimit);
        response.put('total_records', totalRecords); // Total count of filtered items (not paginated)
        response.put('has_more', hasMore);
        response.put('next_offset', hasMore ? nextOffset : currentOffset);
        response.put('activities', paginatedActivities); // Only the paginated slice
        
        return JSON.serialize(response);
    }
    
    private static List<Map<String, Object>> buildAllActivities() {
        List<Map<String, Object>> activities = new List<Map<String, Object>>();
        
        // Lead Activities
        activities.add(createLeadActivity('act_001', 'Student Follow-Up Call', 'N24H-0007', 'Swamy', 'Rajat Kaushik', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_003', 'Student Follow-Up Call 3', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_006', 'Student Follow-Up Call 4', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_007', 'Student Follow-Up Call 5', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_008', 'Student Follow-Up Call 6', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_009', 'Student Follow-Up Call 7', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_010', 'Student Follow-Up Call 8', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_011', 'Student Follow-Up Call 9', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_012', 'Student Follow-Up Call 10', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_013', 'Student Follow-Up Call 11', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        activities.add(createLeadActivity('act_014', 'Student Follow-Up Call 12', 'NW0000392', 'Swamy 2', 'Rajat Kaushik 2', 'upcoming', '2025-01-05', '2025-01-02T10:15:00Z'));
        
        // Agent Tasks
        activities.add(createAgentTask('act_002', 'Fix production bug', 'Ankit Sharma', 'completed', '2025-01-06', '2025-01-06T18:30:00Z'));
        activities.add(createAgentTask('act_005', 'Fix production bug 2', 'Ankit Sharma 2', 'completed', '2025-01-06', '2025-01-06T18:30:00Z'));
        activities.add(createAgentTask('act_015', 'Code review for new feature', 'Priya Singh', 'upcoming', '2025-01-07', null));
        activities.add(createAgentTask('act_016', 'Update documentation', 'Rahul Verma', 'upcoming', '2025-01-08', null));
        activities.add(createAgentTask('act_017', 'Deploy to staging environment', 'Sneha Patel', 'completed', '2025-01-09', '2025-01-09T14:20:00Z'));
        activities.add(createAgentTask('act_018', 'Write unit tests', 'Vikram Kumar', 'upcoming', '2025-01-10', null));
        activities.add(createAgentTask('act_019', 'Performance optimization', 'Meera Nair', 'completed', '2025-01-11', '2025-01-11T16:45:00Z'));
        activities.add(createAgentTask('act_020', 'Security audit', 'Arjun Reddy', 'upcoming', '2025-01-12', null));
        activities.add(createAgentTask('act_021', 'Database migration script', 'Kavya Iyer', 'completed', '2025-01-13', '2025-01-13T11:30:00Z'));
        activities.add(createAgentTask('act_022', 'API integration testing', 'Rohan Desai', 'upcoming', '2025-01-14', null));
        activities.add(createAgentTask('act_023', 'Bug fix - Login issue', 'Neha Joshi', 'completed', '2025-01-15', '2025-01-15T09:15:00Z'));
        activities.add(createAgentTask('act_024', 'UI/UX improvements', 'Aditya Shah', 'upcoming', '2025-01-16', null));
        activities.add(createAgentTask('act_025', 'Backup verification', 'Suresh Menon', 'completed', '2025-01-17', '2025-01-17T13:00:00Z'));
        activities.add(createAgentTask('act_026', 'Monitor system logs', 'Deepak Rao', 'upcoming', '2025-01-18', null));
        activities.add(createAgentTask('act_027', 'Update dependencies', 'Lakshmi Nair', 'completed', '2025-01-19', '2025-01-19T15:30:00Z'));
        activities.add(createAgentTask('act_028', 'Client meeting preparation', 'Rajesh Kumar', 'upcoming', '2025-01-20', null));
        
        return activities;
    }
    
    private static Map<String, Object> createLeadActivity(
        String id, String title, String leadId, String leadName, 
        String assignedTo, String status, String dueDate, String createdAt
    ) {
        Map<String, Object> activity = new Map<String, Object>();
        activity.put('id', id);
        activity.put('activity_category', 'lead_activity');
        activity.put('activity_type', 'task');
        activity.put('title', title);
        
        Map<String, Object> relatedTo = new Map<String, Object>();
        relatedTo.put('type', 'lead');
        relatedTo.put('id', leadId);
        relatedTo.put('name', leadName);
        activity.put('related_to', relatedTo);
        
        activity.put('assigned_to', assignedTo);
        activity.put('status', status);
        activity.put('due_date', dueDate);
        activity.put('created_at', createdAt);
        
        return activity;
    }
    
    private static Map<String, Object> createAgentTask(
        String id, String title, String assignedTo, 
        String status, String dueDate, String completedAt
    ) {
        Map<String, Object> activity = new Map<String, Object>();
        activity.put('id', id);
        activity.put('activity_category', 'agent_task');
        activity.put('activity_type', 'task');
        activity.put('title', title);
        activity.put('assigned_to', assignedTo);
        activity.put('status', status);
        activity.put('due_date', dueDate);
        activity.put('completed_at', completedAt);
        
        return activity;
    }
}