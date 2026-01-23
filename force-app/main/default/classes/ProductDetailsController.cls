public with sharing class ProductDetailsController {

    /**
     * API Spec:
     * Request: { "opportunity_id": "" }
     * Response: {
     *   "key_fields": [{ "name": "", "type": "", "value": "", "order": 1 }],
     *   "sections": [{
     *     "Section_name": "",
     *     "order": 1,
     *     "fields": [{ "name": "", "type": "", "value": "", "order": 1 }]
     *   }]
     * }
     * 
     * HOW TO PASS RECORD ID FROM LWC:
     * =================================
     * Option 1: Using @api recordId (if component is on a Record Page)
     *   - In LWC: @api recordId;
     *   - Call: getProductDetails({ opportunityId: this.recordId })
     * 
     * Option 2: Using getRecord wire adapter
     *   - import { getRecord } from 'lightning/uiRecordApi';
     *   - @wire(getRecord, { recordId: '$recordId', fields: [...] })
     *   - Then pass the recordId to this method
     * 
     * Option 3: Pass from parent component
     *   - Parent passes recordId as @api property
     *   - Call: getProductDetails({ opportunityId: this.recordId })
     * 
     * Example LWC call:
     *   import getProductDetails from '@salesforce/apex/ProductDetailsController.getProductDetails';
     *   @api recordId;
     *   @wire(getProductDetails, { opportunityId: '$recordId' })
     *   wiredProductDetails({ error, data }) { ... }
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProductDetails(String opportunityId) {
        // TODO: When real API is ready, use opportunityId parameter for HTTP callout
        // Example: String endpoint = 'https://api.example.com/product-details?opportunity_id=' + opportunityId;
        
        // Return Map directly - Lightning wire service handles serialization automatically
        Map<String, Object> response = new Map<String, Object>();
        
        // Key Fields
        List<Map<String, Object>> keyFields = new List<Map<String, Object>>();
        keyFields.add(createKeyField('id', '12345', 1, 'string'));
        keyFields.add(createKeyField('dm_phone_numbergggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggguuuuuuuuuuuuuuuuuuuuuuuuuuuugggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg', '+91-9876543210', 2, 'phone'));
        keyFields.add(createKeyField('influencer_number', 'INF-20489', 3, 'string'));
        keyFields.add(createKeyField('program', 'Full Stack Web Developmentggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg', 4, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        keyFields.add(createKeyField('payment_plan', '6 Months EMI', 5, 'string'));
        keyFields.add(createKeyField('xyz_field', 'xyz_value', 5, 'string'));
        keyFields.add(createKeyField('xyz_field', 'xyz_value', 5, 'string'));
        keyFields.add(createKeyField('xyz_field', 'xyz_value', 5, 'string'));
        keyFields.add(createKeyField('xyz_field', 'xyz_value', 5, 'string'));
        keyFields.add(createKeyField('xyz_field', 'xyz_value', 5, 'string'));
        
        // Sections
        List<Map<String, Object>> sections = new List<Map<String, Object>>();
        
        // Personal Details Section
        Map<String, Object> personalSection = new Map<String, Object>();
        personalSection.put('Section_name', 'Personal Details'); // Spec requires capital 'S'
        personalSection.put('order', 1);
        List<Map<String, Object>> personalFields = new List<Map<String, Object>>();
        personalFields.add(createField('full_name', 'Rajat', 'string', 1));
        personalFields.add(createField('age', 23, 'number', 2));
        personalFields.add(createField('email', 'rajat@example.com', 'email', 3));
        personalFields.add(createField('phone_number', '+91-9876543210', 'phone', 4));
        personalFields.add(createField('parent_phone_number', '+91-9502482445', 'phone', 5));
        personalFields.add(createField('alternate_phone_number', '+91-9100164925', 'phone', 6));
        // Contact Details as nested array
        List<Map<String, Object>> contactDetails = new List<Map<String, Object>>();
        contactDetails.add(createField('phone_number', '+91-9876543210', 'phone', 1));
        contactDetails.add(createField('parent_phone_number', '+91-9502482445', 'phone', 2));
        contactDetails.add(createField('alternate_phone_number', '+91-9100164925', 'phone', 3));
        // personalFields.add(createField('contact_details', contactDetails, 'array'));
        
        personalSection.put('fields', personalFields);
        sections.add(personalSection);
        
        // Opportunity Information Section
        Map<String, Object> oppSection = new Map<String, Object>();
        oppSection.put('Section_name', 'Opportunity Information'); // Spec requires capital 'S'
        oppSection.put('order', 2);
        List<Map<String, Object>> oppFields = new List<Map<String, Object>>();
        oppFields.add(createField('opportunity_name', 'test1', 'string', 1));
        oppFields.add(createField('account_name', 'Rajat Account', 'string', 2));
        oppFields.add(createField('contact_id', '006e1000001BRGAA0', 'string', 3));
        oppFields.add(createField('stage', 'Yet To Decide To Pay', 'string', 4));
        oppFields.add(createField('close_date', '2025-10-18', 'date', 5));
        oppFields.add(createField('amount', 75000, 'number', 6));
        oppFields.add(createField('language', 'English', 'string', 7));
        oppFields.add(createField('phone_number', '+91-9876543210', 'phone', 8));
        oppFields.add(createField('program_uid', 'PROG-FSWD-2025', 'string', 9));
        oppFields.add(createField('cycle', 'Cycle-2 (May 2nd)', 'string', 10));
        oppFields.add(createField('performance_bucket', 'High Intent', 'string', 11));
        oppFields.add(createField('discovery_completed', false, 'boolean', 12));
        oppFields.add(createField('city_town_village', 'Hyderabad', 'string', 13));
        oppFields.add(createField('orientation_session_attended_language', 'English', 'string', 14));
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
    
    private static Map<String, Object> createField(String name, Object value, String type, Integer order) {
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', name);
        field.put('value', value);
        field.put('type', type);
        field.put('order', order); // Added order as per spec
        return field;
    }
}