public with sharing class NewTask {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTask(String product_opportunity_id) {
        simulateLatency();
        // Build form config structure
        Map<String, Object> formConfig = new Map<String, Object>();
        formConfig.put('title', 'Task Name');
        
        // Build fields array
        List<Map<String, Object>> fields = new List<Map<String, Object>>();
        
        // Build mobile number field
        Map<String, Object> mobileField = new Map<String, Object>();
        // Align keys with DynamicFormController.getSampleConfig
        mobileField.put('type', 'phone_number');
        mobileField.put('field_id', 'mobile_number');
        mobileField.put('label', 'Mobile Number');
        mobileField.put('placeHolder', 'Enter mobile number');
        mobileField.put('helperText', 'Used for OTP verification');
        mobileField.put('isRequired', true);
        mobileField.put('defaultValue', '');
        mobileField.put('relevantCondition', 'true');
        mobileField.put('relevantFields', new List<String>());
        
        // Build validation_regexs array
        List<Map<String, Object>> validationRegexs = new List<Map<String, Object>>();
        Map<String, Object> regexObj = new Map<String, Object>();
        regexObj.put('regex', '^[6-9]\\d{9}$');
        regexObj.put('message', 'Invalid mobile number');
        validationRegexs.add(regexObj);
        mobileField.put('validation_regexs', validationRegexs);
        
        fields.add(mobileField);

        Map<String, Object> nameField = new Map<String, Object>();
        nameField.put('type', 'text');
        nameField.put('field_id', 'name');
        nameField.put('label', 'Name');
        nameField.put('placeHolder', 'Enter name');
        nameField.put('helperText', 'Enter name');
        nameField.put('isRequired', true);
        nameField.put('defaultValue', '');
        nameField.put('relevantCondition', 'true');
        nameField.put('relevantFields', new List<String>());
        List<Map<String, Object>> nameValidationRegexs = new List<Map<String, Object>>();
        Map<String, Object> nameRegexObj = new Map<String, Object>();
        nameRegexObj.put('regex', '^[A-Za-z]{3,20}$');
        nameRegexObj.put('message', 'Name must be between 3 and 20 characters');
        nameValidationRegexs.add(nameRegexObj);
        nameField.put('validation_regexs', nameValidationRegexs);
        fields.add(nameField);
        formConfig.put('fields', fields);
        
        Map<String, Object> formConfig2 = new Map<String, Object>();
        formConfig2.put('title', 'Task 2');
        List<Map<String, Object>> fields2 = new List<Map<String, Object>>();
        Map<String, Object> field2 = new Map<String, Object>();
        field2.put('type', 'text');
        field2.put('field_id', 'task_2');
        field2.put('label', 'Task 2');
        field2.put('placeHolder', 'Enter task 2');
        field2.put('helperText', 'Enter task 2');
        field2.put('isRequired', true);
        field2.put('defaultValue', '');
        field2.put('relevantCondition', 'true');
        field2.put('relevantFields', new List<String>());
        fields2.add(field2);
        formConfig2.put('fields', fields2);
        
        Map<String, Object> formConfig3 = new Map<String, Object>();
        formConfig3.put('title', 'Task 3');
        List<Map<String, Object>> fields3 = new List<Map<String, Object>>();
        Map<String, Object> field3 = new Map<String, Object>();
        field3.put('type', 'text');
        field3.put('field_id', 'task_3');
        field3.put('label', 'Task 3');
        field3.put('placeHolder', 'Enter task 3');
        field3.put('helperText', 'Enter task 3');
        field3.put('isRequired', true);
        field3.put('defaultValue', '');
        field3.put('relevantCondition', 'true');
        field3.put('relevantFields', new List<String>());
        fields3.add(field3);
        formConfig3.put('fields', fields3);
        
        // Build response
        Map<String, Object> response = new Map<String, Object>();
        List<Map<String, Object>> tasks = new List<Map<String, Object>>();
        
        // Build task object
        Map<String, Object> task = new Map<String, Object>();
        task.put('task_activity_code', 'PREP_SESSION_REMARKS');
        task.put('task_form_config', formConfig);
        
        Map<String, Object> task2 = new Map<String, Object>();
        task2.put('task_activity_code', 'TASK_2');
        task2.put('task_form_config', formConfig2);
        
        Map<String, Object> task3 = new Map<String, Object>();
        task3.put('task_activity_code', 'TASK_3');
        task3.put('task_form_config', formConfig3);
        
        tasks.add(task2);
        tasks.add(task);
        tasks.add(task3);
        response.put('tasks', tasks);
        
        return response;
    }
    private static void simulateLatency() {
        Long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < 1000) { /* 1 sec delay */ }
    }
}