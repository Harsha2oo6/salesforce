public with sharing class ProductDetailsController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProductDetails() {
        // Return Map directly - Lightning wire service handles serialization automatically
        // When real API is ready, replace this with HTTP callout
        Map<String, Object> response = new Map<String, Object>();
        
        // Key Fields
        List<Map<String, Object>> keyFields = new List<Map<String, Object>>();
        keyFields.add(createKeyField('id', '12345', 1, 'string'));
        keyFields.add(createKeyField('dm_phone_number', '+91-9876543210', 2, 'phone'));
        keyFields.add(createKeyField('influencer_number', 'INF-20489', 3, 'string'));
        keyFields.add(createKeyField('program', 'Full Stack Web Development', 4, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        
        // Sections
        List<Map<String, Object>> sections = new List<Map<String, Object>>();
        
        // Personal Details Section
        Map<String, Object> personalSection = new Map<String, Object>();
        personalSection.put('section_name', 'Personal Details');
        List<Map<String, Object>> personalFields = new List<Map<String, Object>>();
        personalFields.add(createField('full_name', 'Rajat', 'string'));
        personalFields.add(createField('age', 23, 'number'));
        personalFields.add(createField('email', 'rajat@example.com', 'email'));
        personalFields.add(createField('phone_number', '+91-9876543210', 'phone'));
        personalFields.add(createField('parent_phone_number', '+91-9502482445', 'phone'));
        personalFields.add(createField('alternate_phone_number', '+91-9100164925', 'phone'));
        // Contact Details as nested array
        List<Map<String, Object>> contactDetails = new List<Map<String, Object>>();
        contactDetails.add(createField('phone_number', '+91-9876543210', 'phone'));
        contactDetails.add(createField('parent_phone_number', '+91-9502482445', 'phone'));
        contactDetails.add(createField('alternate_phone_number', '+91-9100164925', 'phone'));
        // personalFields.add(createField('contact_details', contactDetails, 'array'));
        
        personalSection.put('fields', personalFields);
        sections.add(personalSection);
        
        // Opportunity Information Section
        Map<String, Object> oppSection = new Map<String, Object>();
        oppSection.put('section_name', 'Opportunity Information');
        List<Map<String, Object>> oppFields = new List<Map<String, Object>>();
        oppFields.add(createField('opportunity_name', 'test1', 'string'));
        oppFields.add(createField('account_name', 'Rajat Account', 'string'));
        oppFields.add(createField('contact_id', '006e1000001BRGAA0', 'string'));
        oppFields.add(createField('stage', 'Yet To Decide To Pay', 'string'));
        oppFields.add(createField('close_date', '2025-10-18', 'date'));
        oppFields.add(createField('amount', 75000, 'number'));
        oppFields.add(createField('language', 'English', 'string'));
        oppFields.add(createField('phone_number', '+91-9876543210', 'phone'));
        oppFields.add(createField('program_uid', 'PROG-FSWD-2025', 'string'));
        oppFields.add(createField('cycle', 'Cycle-2 (May 2nd)', 'string'));
        oppFields.add(createField('performance_bucket', 'High Intent', 'string'));
        oppFields.add(createField('discovery_completed', false, 'boolean'));
        oppFields.add(createField('city_town_village', 'Hyderabad', 'string'));
        oppFields.add(createField('orientation_session_attended_language', 'English', 'string'));
        oppSection.put('fields', oppFields);
        sections.add(oppSection);
        
        response.put('key_fields', keyFields);
        response.put('sections', sections);
        
        return response;
    }
    
    private static Map<String, Object> createKeyField(String name, Object value, Integer order, String type) {
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', name);
        field.put('value', value);
        field.put('order', order);
        field.put('type', type);
        return field;
    }
    
    private static Map<String, Object> createField(String name, Object value, String type) {
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', name);
        field.put('value', value);
        field.put('type', type);
        return field;
    }
}