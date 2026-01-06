public with sharing class ActivitiesController {
    
    // Activity filter enum mapping
    private static final String LEAD_ACTIVITY_ENUM = 'LEAD_ACTIVITY';
    private static final String TASK_ENUM = 'TASK';
    
    // Wrapper class for date filter
    public class DateFilter {
        @AuraEnabled public String from_date;
        @AuraEnabled public String to_date;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getActivities(
        String opportunityId,
        List<String> activityFilter,
        DateFilter dateFilter,
        Integer offset,
        Integer limitRecords
    ) {
        // Return JSON string matching new API spec
        // When real API is ready, replace this with HTTP callout using the parameters
        // For now, return mock data filtered by activity filter and date range
        // Note: opportunityId is accepted but not used in mock implementation
        
        // Build all mock activities
        List<Map<String, Object>> allActivities = buildAllActivities();
        
        // Filter by activity_filter array (maps enum values to internal categories)
        List<Map<String, Object>> filteredActivities = new List<Map<String, Object>>();
        
        if (activityFilter != null && !activityFilter.isEmpty()) {
            // Build set of allowed categories from activity_filter enum values
            Set<String> allowedCategories = new Set<String>();
            for (String filter : activityFilter) {
                if (filter == LEAD_ACTIVITY_ENUM) {
                    allowedCategories.add(LEAD_ACTIVITY_ENUM);
                } else if (filter == TASK_ENUM) {
                    allowedCategories.add(TASK_ENUM);
                }
            }
            
            // Filter activities by allowed categories
            for (Map<String, Object> activity : allActivities) {
                String category = (String)activity.get('activity_category');
                if (allowedCategories.contains(category)) {
                    filteredActivities.add(activity);
                }
            }
        } else {
            // If no filter provided, return all (for backward compatibility)
            filteredActivities = allActivities;
        }
        
        // Filter by date range (using activity_datetime equivalent) - OPTIONAL
        String fromDate = (dateFilter != null && String.isNotBlank(dateFilter.from_date)) ? dateFilter.from_date : null;
        String toDate = (dateFilter != null && String.isNotBlank(dateFilter.to_date)) ? dateFilter.to_date : null;
        
        if (String.isNotBlank(fromDate) || String.isNotBlank(toDate)) {
            List<Map<String, Object>> dateFilteredActivities = new List<Map<String, Object>>();
            for (Map<String, Object> activity : filteredActivities) {
                // Use created_at for lead activities, completed_at or due_date for tasks
                String dateTimeStr = (String)activity.get('created_at');
                if (String.isBlank(dateTimeStr)) {
                    dateTimeStr = (String)activity.get('completed_at');
                }
                if (String.isBlank(dateTimeStr)) {
                    dateTimeStr = (String)activity.get('due_date');
                }
                
                if (String.isNotBlank(dateTimeStr)) {
                    // Parse date from datetime string (format: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ)
                    Date activityDate;
                    if (dateTimeStr.contains('T')) {
                        activityDate = Date.valueOf(dateTimeStr.split('T')[0]);
                    } else {
                        activityDate = Date.valueOf(dateTimeStr);
                    }
                    
                    Date fromDateValue = String.isNotBlank(fromDate) ? Date.valueOf(fromDate) : null;
                    Date toDateValue = String.isNotBlank(toDate) ? Date.valueOf(toDate) : null;
                    
                    Boolean includeActivity = true;
                    if (fromDateValue != null && activityDate < fromDateValue) {
                        includeActivity = false;
                    }
                    if (toDateValue != null && activityDate > toDateValue) {
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
        
        // Calculate total records BEFORE pagination
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
        
        // Transform activities to new response format
        List<Map<String, Object>> transformedActivities = new List<Map<String, Object>>();
        for (Map<String, Object> activity : paginatedActivities) {
            transformedActivities.add(transformActivityToNewFormat(activity));
        }
        
        // Build response matching new API spec
        Map<String, Object> response = new Map<String, Object>();
        response.put('total', totalRecords);
        response.put('activities', transformedActivities);
        
        return JSON.serialize(response);
    }
    
    /**
     * Transforms an activity from internal format to new API response format
     */
    private static Map<String, Object> transformActivityToNewFormat(Map<String, Object> activity) {
        Map<String, Object> transformed = new Map<String, Object>();
        
        // Basic fields
        transformed.put('id', activity.get('id'));
        transformed.put('activity_type', activity.get('activity_type'));
        transformed.put('activity_name', activity.get('title'));
        
        // Determine activity_datetime (prefer created_at, then completed_at, then due_date)
        String activityDateTime = (String)activity.get('created_at');
        if (String.isBlank(activityDateTime)) {
            activityDateTime = (String)activity.get('completed_at');
        }
        if (String.isBlank(activityDateTime)) {
            activityDateTime = (String)activity.get('due_date');
        }
        transformed.put('activity_datetime', activityDateTime);
        
        // task_user_name from assigned_to
        transformed.put('task_user_name', activity.get('assigned_to'));
        
        // Build fields array with only non-empty values
        List<Map<String, Object>> fields = buildActivityFields(activity);
        transformed.put('fields', fields);
        
        return transformed;
    }
    
    /**
     * Builds the fields array for an activity, including only fields with filled values
     */
    private static List<Map<String, Object>> buildActivityFields(Map<String, Object> activity) {
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        Integer order = 1;
        
        String category = (String)activity.get('activity_category');
        
        if (category == LEAD_ACTIVITY_ENUM) {
            // Lead Activity fields
            Map<String, Object> relatedTo = (Map<String, Object>)activity.get('related_to');
            if (relatedTo != null) {
                String leadId = (String)relatedTo.get('id');
                if (String.isNotBlank(leadId)) {
                    fields.add(createField('lead_id', 'string', leadId, order++));
                }
                
                String leadName = (String)relatedTo.get('name');
                if (String.isNotBlank(leadName)) {
                    fields.add(createField('lead_name', 'string', leadName, order++));
                }
            }
            
            String status = (String)activity.get('status');
            if (String.isNotBlank(status)) {
                fields.add(createField('field_status', 'string', status, order++));
            }
            
            String dueDate = (String)activity.get('due_date');
            if (String.isNotBlank(dueDate)) {
                fields.add(createField('field_due_date', 'date', dueDate, order++));
            }
            
            String createdAt = (String)activity.get('created_at');
            if (String.isNotBlank(createdAt)) {
                fields.add(createField('field_created_at', 'datetime', createdAt, order++));
            }
            
        } else if (category == TASK_ENUM) {
            // Agent Task fields
            String status = (String)activity.get('status');
            if (String.isNotBlank(status)) {
                fields.add(createField('field_status', 'string', status, order++));
            }
            
            String dueDate = (String)activity.get('due_date');
            if (String.isNotBlank(dueDate)) {
                fields.add(createField('field_due_date', 'date', dueDate, order++));
            }
            
            String completedAt = (String)activity.get('completed_at');
            if (String.isNotBlank(completedAt)) {
                fields.add(createField('field_completed_at', 'datetime', completedAt, order++));
            }
        }
        
        return fields;
    }
    
    /**
     * Helper method to create a field entry
     */
    private static Map<String, Object> createField(String name, String type, String value, Integer order) {
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', name);
        field.put('type', type);
        field.put('value', value);
        field.put('order', order);
        return field;
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
        activity.put('activity_category', LEAD_ACTIVITY_ENUM);
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
        activity.put('activity_category', TASK_ENUM);
        activity.put('activity_type', 'task');
        activity.put('title', title);
        activity.put('assigned_to', assignedTo);
        activity.put('status', status);
        activity.put('due_date', dueDate);
        activity.put('completed_at', completedAt);
        
        return activity;
    }
}