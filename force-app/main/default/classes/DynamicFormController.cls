public with sharing class DynamicFormController {
  /**
   * Fetches form configuration by form name
   * @param formName The name/identifier of the form
   * @return JSON string containing the form configuration
   */
  @AuraEnabled(cacheable=true)
  public static String getFormConfig(String formName) {
    try {
      // TODO: Replace this with actual implementation to fetch from Custom Metadata, Custom Object, or Static Resource
      // For now, returning a sample configuration
      // In production, you would fetch from:
      // - Custom Metadata Types (recommended)
      // - Custom Objects
      // - Static Resources
      // - Named Credentials (external APIs)

      if (String.isBlank(formName)) {
        throw new AuraHandledException('Form name is required');
      }

      // Example: Fetch from Custom Metadata
      // List<Form_Configuration__mdt> configs = [
      //     SELECT Id, Form_JSON__c
      //     FROM Form_Configuration__mdt
      //     WHERE DeveloperName = :formName
      //     LIMIT 1
      // ];
      //
      // if (configs.isEmpty()) {
      //     throw new AuraHandledException('Form configuration not found: ' + formName);
      // }
      //
      // return configs[0].Form_JSON__c;

      // Temporary: Return sample config for testing
      // Remove this and implement actual data fetching
      return getSampleConfig();
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching form config: ' + e.getMessage()
      );
    }
  }

  /**
   * Submits form data
   * @param formValuesJson JSON string containing form values
   * @return JSON string with success/error message
   */
  @AuraEnabled
  public static String submitForm(String formValuesJson) {
    try {
      if (String.isBlank(formValuesJson)) {
        throw new AuraHandledException('Form data is required');
      }

      // Parse form data
      Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(
        formValuesJson
      );
      String formName = (String) formData.get('formName');
      Map<String, Object> values = (Map<String, Object>) formData.get('values');

      // TODO: Implement actual form submission logic
      // This could include:
      // - Creating/updating records
      // - Calling external APIs
      // - Processing business logic
      // - Sending notifications

      // Example: Create a record
      // Account acc = new Account();
      // acc.Name = (String) values.get('accountName');
      // acc.Phone = (String) values.get('phone');
      // insert acc;

      // Return success response
      Map<String, Object> response = new Map<String, Object>();
      response.put('success', true);
      response.put('message', 'Form submitted successfully');
      response.put('timestamp', Datetime.now().format());
      System.debug('response: ' + JSON.serialize(response));
      return JSON.serialize(response);
    } catch (Exception e) {
      // Return error response
      Map<String, Object> response = new Map<String, Object>();
      response.put('success', false);
      response.put('message', 'Error submitting form: ' + e.getMessage());
      System.debug('response: ' + JSON.serialize(response));
      return JSON.serialize(response);
    }
  }

  /**
   * Sample configuration for testing
   * Remove this method when implementing actual data fetching
   */
  private static String getSampleConfig() {
    // This is a sample configuration matching the structure provided in requirements
    // Replace with actual data source in production
    Map<String, Object> config = new Map<String, Object>();
    List<Map<String, Object>> fields = new List<Map<String, Object>>();

    // Field 1: Phone Number
    Map<String, Object> phoneField = new Map<String, Object>();
    phoneField.put('type', 'phone_number');
    phoneField.put('field', 'mobile_number');
    phoneField.put('label', 'Mobile Number');
    phoneField.put('placeHolder', 'Enter mobile number');
    phoneField.put('helperText', 'Used for OTP verification');
    phoneField.put('isRequired', false);
    phoneField.put('defaultValue', '');
    phoneField.put('relevantCondition', 'true');
    phoneField.put('relevantFields', new List<String>());
    List<Map<String, Object>> phoneValidations = new List<Map<String, Object>>();
    Map<String, Object> phoneValidation = new Map<String, Object>();
    phoneValidation.put('regex', '^[6-9]\\d{9}$');
    phoneValidation.put('message', 'Invalid mobile number');
    phoneValidations.add(phoneValidation);
    phoneField.put('validation_regexs', phoneValidations);
    fields.add(phoneField);

    // Field 2: Radio Group (conditional - appears when mobile_number is '995439')
    Map<String, Object> radioField = new Map<String, Object>();
    radioField.put('type', 'radio_group');
    radioField.put('field', 'user_type');
    radioField.put('label', 'User Type');
    radioField.put('isRequired', true);
    radioField.put('defaultValue', '');
    radioField.put(
      'relevantCondition',
      'values[\'mobile_number\'] === \'9568952395\''
    );
    List<String> radioRelevantFields = new List<String>{ 'mobile_number' };
    radioField.put('relevantFields', radioRelevantFields);
    radioField.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> radioOptions = new List<Map<String, Object>>();
    Map<String, Object> radioOption1 = new Map<String, Object>();
    radioOption1.put('label', 'Admin');
    radioOption1.put('value', 'admin');
    radioOption1.put('condition', 'values[\'mobile_number\'] === \'995439\'');
    radioOptions.add(radioOption1);
    Map<String, Object> radioOption2 = new Map<String, Object>();
    radioOption2.put('label', 'User');
    radioOption2.put('value', 'user');
    radioOption2.put('condition', 'values[\'mobile_number\'] !== \'995439\'');
    radioOptions.add(radioOption2);
    radioField.put('options', radioOptions);
    fields.add(radioField);

    // Field 3: Select (Dropdown)
    Map<String, Object> selectField = new Map<String, Object>();
    selectField.put('type', 'select');
    selectField.put('field', 'country');
    selectField.put('label', 'Country');
    selectField.put('placeHolder', 'Select country');
    selectField.put('isRequired', true);
    selectField.put('defaultValue', 'IN');
    selectField.put('relevantCondition', 'true');
    selectField.put('relevantFields', new List<String>());
    selectField.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> selectOptions = new List<Map<String, Object>>();
    Map<String, Object> selectOption1 = new Map<String, Object>();
    selectOption1.put('label', 'India');
    selectOption1.put('value', 'IN');
    selectOption1.put('condition', 'true');
    selectOptions.add(selectOption1);
    Map<String, Object> selectOption2 = new Map<String, Object>();
    selectOption2.put('label', 'USA');
    selectOption2.put('value', 'US');
    selectOption2.put('condition', 'values[\'user_type\'] === \'admin\'');
    selectOptions.add(selectOption2);
    selectField.put('options', selectOptions);
    fields.add(selectField);

    // Field 4: Multi-Select (conditional - appears when user_type is 'admin')
    Map<String, Object> multiSelectField = new Map<String, Object>();
    multiSelectField.put('type', 'multi_select');
    multiSelectField.put('field', 'allowed_modules');
    multiSelectField.put('label', 'Allowed Modules');
    multiSelectField.put('placeHolder', 'Select modules');
    multiSelectField.put('isRequired', false);
    multiSelectField.put('defaultValue', new List<String>());
    // multiSelectField.put(
    //   'relevantCondition',
    //   'values[\'user_type\'] === \'admin\''
    // );
    List<String> multiSelectRelevantFields = new List<String>{ 'user_type' };
    multiSelectField.put('relevantFields', multiSelectRelevantFields);
    multiSelectField.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> multiSelectOptions = new List<Map<String, Object>>();
    Map<String, Object> multiSelectOption1 = new Map<String, Object>();
    multiSelectOption1.put('label', 'Dashboard');
    multiSelectOption1.put('value', 'dashboard');
    multiSelectOption1.put('condition', 'true');
    multiSelectOptions.add(multiSelectOption1);
    Map<String, Object> multiSelectOption2 = new Map<String, Object>();
    multiSelectOption2.put('label', 'Reports');
    multiSelectOption2.put('value', 'reports');
    multiSelectOption2.put('condition', 'values[\'country\'] === \'IN\'');
    multiSelectOptions.add(multiSelectOption2);
    multiSelectField.put('options', multiSelectOptions);
    fields.add(multiSelectField);

    // Field 5: Checkbox Group
    Map<String, Object> checkboxField = new Map<String, Object>();
    checkboxField.put('type', 'checkbox');
    checkboxField.put('field', 'notifications');
    checkboxField.put('label', 'Notifications');
    checkboxField.put('isRequired', false);
    checkboxField.put('defaultValue', new List<String>());
    checkboxField.put('relevantCondition', 'true');
    checkboxField.put('relevantFields', new List<String>());
    checkboxField.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> checkboxOptions = new List<Map<String, Object>>();
    Map<String, Object> checkboxOption1 = new Map<String, Object>();
    checkboxOption1.put('label', 'SMS Alerts');
    checkboxOption1.put('value', 'sms');
    checkboxOption1.put('condition', 'values[\'mobile_number\'] !== \'\'');
    checkboxOptions.add(checkboxOption1);
    Map<String, Object> checkboxOption2 = new Map<String, Object>();
    checkboxOption2.put('label', 'Email Alerts');
    checkboxOption2.put('value', 'email');
    checkboxOption2.put('condition', 'values[\'country\'] === \'US\'');
    checkboxOptions.add(checkboxOption2);
    checkboxField.put('options', checkboxOptions);
    fields.add(checkboxField);

    // Field 6: Text Field (conditional - appears when mobile_number is '995439')
    Map<String, Object> textField = new Map<String, Object>();
    textField.put('type', 'text');
    textField.put('field', 'referral_code');
    textField.put('label', 'Referral Code');
    textField.put('placeHolder', 'Enter referral code');
    textField.put('isRequired', false);
    textField.put('defaultValue', '');
    textField.put(
      'relevantCondition',
      'values[\'mobile_number\'] === \'995439\''
    );
    List<String> textRelevantFields = new List<String>{ 'mobile_number' };
    textField.put('relevantFields', textRelevantFields);
    List<Map<String, Object>> textValidations = new List<Map<String, Object>>();
    Map<String, Object> textValidation = new Map<String, Object>();
    textValidation.put('regex', '^[A-Z0-9]{6}$');
    textValidation.put('message', 'Referral code must be 6 characters');
    textValidations.add(textValidation);
    textField.put('validation_regexs', textValidations);
    fields.add(textField);

    // Field 7: Text Area (conditional - appears when user_type is 'admin')
    Map<String, Object> textAreaField = new Map<String, Object>();
    textAreaField.put('type', 'text_area');
    textAreaField.put('field', 'remarks');
    textAreaField.put('label', 'Remarks');
    textAreaField.put('placeHolder', 'Enter remarks');
    textAreaField.put('isRequired', false);
    textAreaField.put('defaultValue', '');
    textAreaField.put(
      'relevantCondition',
      'values[\'user_type\'] === \'admin\''
    );
    List<String> textAreaRelevantFields = new List<String>{ 'user_type' };
    textAreaField.put('relevantFields', textAreaRelevantFields);
    textAreaField.put('validation_regexs', new List<Map<String, Object>>());
    fields.add(textAreaField);

    // Field 8: Date Picker (conditional - appears when user_type is 'admin')
    Map<String, Object> dateField = new Map<String, Object>();
    dateField.put('type', 'date');
    dateField.put('field', 'activation_date');
    dateField.put('label', 'Activation Date');
    dateField.put('isRequired', true);
    dateField.put('defaultValue', '');
    // dateField.put('relevantCondition', 'values[\'user_type\'] === \'admin\'');
    List<String> dateRelevantFields = new List<String>{ 'user_type' };
    dateField.put('relevantFields', dateRelevantFields);
    dateField.put('validation_regexs', new List<Map<String, Object>>());
    dateField.put('format', 'DD/MM/YYYY');
    dateField.put('min_date', '01/01/2024');
    dateField.put('max_date', '31/12/2026');
    List<String> excludeDates = new List<String>{ '25/12/2025' };
    dateField.put('exclude_dates', excludeDates);
    fields.add(dateField);
    // Field 9: Date Time Picker (conditional - appears when user_type is 'admin')
    Map<String, Object> dateTimeField = new Map<String, Object>();
    dateTimeField.put('type', 'datetime');
    dateTimeField.put('field', 'activation_date_time');
    dateTimeField.put('label', 'Activation Date Time');
    dateTimeField.put('isRequired', true);
    dateTimeField.put('defaultValue', '');
    // dateTimeField.put('relevantCondition', 'values[\'user_type\'] === \'admin\'');
    List<String> dateTimeRelevantFields = new List<String>{ 'user_type' };
    dateTimeField.put('relevantFields', dateTimeRelevantFields);
    dateTimeField.put('validation_regexs', new List<Map<String, Object>>());
    dateTimeField.put('format', 'YYYY-MM-DD HH:MM:SS');
    dateTimeField.put('min_date', '01/01/2024 00:00:00');
    dateTimeField.put('max_date', '31/12/2026 23:59:59');

    fields.add(dateTimeField);
    config.put('fields', fields);
    return JSON.serialize(config);
  }
}
