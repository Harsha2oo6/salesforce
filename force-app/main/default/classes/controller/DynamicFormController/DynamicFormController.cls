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

      // Temporary: Return specific configs for testing by formName
      // Remove/replace this routing when implementing actual data fetching
      if (formName == 'SESSION_NOT_ATTENDED_CALL') {
        return getSessionNotAttendedConfig();
      }

      // Default sample config
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
        multiSelectField.put('type', 'Multi_select');
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

  /**
   * "Session Not Attended Call" configuration built via Apex Maps/Lists.
   * This mirrors the JSON structure from sample.json (344-1294).
   */
  private static String getSessionNotAttendedConfig() {
    Map<String, Object> config = new Map<String, Object>();
    config.put('title', 'Session Not Attended Call');

    List<Map<String, Object>> fields = new List<Map<String, Object>>();

    // 1) Call Type
    Map<String, Object> callType = new Map<String, Object>();
    callType.put('label', 'Call Type');
    callType.put('field_id', 'CALL_TYPE__c');
    callType.put('type', 'select');
    callType.put('place_holder', '');
    callType.put('helper_text', '');
    callType.put('is_required', true);
    callType.put('default_value', '');
    callType.put('relevant_condition', '');
    callType.put('relevant_field_ids', new List<String>());
    callType.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> callTypeOptions = new List<Map<String, Object>>();
    Map<String, Object> ctOpt1 = new Map<String, Object>();
    ctOpt1.put('label', 'Tata Tele');
    ctOpt1.put('value', 'tata_tele');
    ctOpt1.put('condition', 'true');
    callTypeOptions.add(ctOpt1);
    Map<String, Object> ctOpt2 = new Map<String, Object>();
    ctOpt2.put('label', 'Direct Call');
    ctOpt2.put('value', 'direct_call');
    ctOpt2.put('condition', 'true');
    callTypeOptions.add(ctOpt2);
    callType.put('options', callTypeOptions);
    fields.add(callType);

    // 2) Call Status
    Map<String, Object> callStatus = new Map<String, Object>();
    callStatus.put('label', 'Call Status');
    callStatus.put('field_id', 'CALL_STATUS__c');
    callStatus.put('type', 'select');
    callStatus.put('place_holder', '');
    callStatus.put('helper_text', '');
    callStatus.put('is_required', true);
    callStatus.put('default_value', '');
    callStatus.put('relevant_condition', '');
    callStatus.put('relevant_field_ids', new List<String>());
    callStatus.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> statusOptions = new List<Map<String, Object>>();
    String[][] statusPairs = new String[][]{
      new String[]{'Call Done', 'call_done'},
      new String[]{'Call Back', 'call_back'},
      new String[]{'Call Busy', 'call_busy'},
      new String[]{'Switch Off', 'switch_off'},
      new String[]{'Not Reachable', 'not_reachable'},
      new String[]{'Not Answered', 'not_answered'},
      new String[]{'Call Rejected', 'call_rejected'},
      new String[]{'Wrong Number', 'wrong_number'},
      new String[]{'Language Barrier', 'language_barrier'},
      new String[]{'Already Enrolled User', 'already_enrolled_user'}
    };
    for (String[] pair : statusPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      statusOptions.add(opt);
    }
    callStatus.put('options', statusOptions);
    fields.add(callStatus);

    // 3) Whom Did you talk to?
    Map<String, Object> whomTalk = new Map<String, Object>();
    whomTalk.put('label', 'Whom Did you talk to?');
    whomTalk.put('field_id', 'WHOM_DID_YOU_TALK_TO__c');
    whomTalk.put('type', 'select');
    whomTalk.put('place_holder', '');
    whomTalk.put('helper_text', '');
    whomTalk.put('is_required', true);
    whomTalk.put('default_value', '');
    whomTalk.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === call_back || values[CALL_STATUS__c] === call_done)'
    );
    whomTalk.put('relevant_field_ids', new List<String>());
    whomTalk.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> whomOptions = new List<Map<String, Object>>();
    String[][] whomPairs = new String[][]{
      new String[]{'Parent', 'parent'},
      new String[]{'Student', 'student'},
      new String[]{'Both', 'both'}
    };
    for (String[] pair : whomPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      whomOptions.add(opt);
    }
    whomTalk.put('options', whomOptions);
    fields.add(whomTalk);

    // 4) How Did the Call Go?
    Map<String, Object> howCall = new Map<String, Object>();
    howCall.put('label', 'How Did the Call Go?');
    howCall.put('field_id', 'HOW_DID_THE_CALL_GO__c');
    howCall.put('type', 'select');
    howCall.put('place_holder', '');
    howCall.put('helper_text', '');
    howCall.put('is_required', true);
    howCall.put('default_value', '');
    howCall.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === call_done)'
    );
    howCall.put('relevant_field_ids', new List<String>());
    howCall.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> howOptions = new List<Map<String, Object>>();
    String[][] howPairs = new String[][]{
      new String[]{'Will Attend the Session', 'will_attend_the_session'},
      new String[]{'Rescheduled the Session', 'rescheduled_the_session'},
      new String[]{'Interested in Campus Visit', 'interested_in_campus_visit'},
      new String[]{'Irrelevant to NIAT', 'irrelevant_to_niat'},
      new String[]{'Not Interested in NIAT', 'not_interested_in_niat'}
    };
    for (String[] pair : howPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      howOptions.add(opt);
    }
    howCall.put('options', howOptions);
    fields.add(howCall);

    // 5) Who Will Attend the Session?
    Map<String, Object> whoAttend = new Map<String, Object>();
    whoAttend.put('label', 'Who Will Attend the Session?');
    whoAttend.put('field_id', 'WHO_WILL_ATTEND_THE_SESSION__c');
    whoAttend.put('type', 'select');
    whoAttend.put('place_holder', '');
    whoAttend.put('helper_text', '');
    whoAttend.put('is_required', true);
    whoAttend.put('default_value', '');
    whoAttend.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === will_attend_the_session || values[HOW_DID_THE_CALL_GO__c] === rescheduled_the_session)'
    );
    whoAttend.put('relevant_field_ids', new List<String>());
    whoAttend.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> whoAttendOptions = new List<Map<String, Object>>();
    for (String[] pair : whomPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      whoAttendOptions.add(opt);
    }
    whoAttend.put('options', whoAttendOptions);
    fields.add(whoAttend);

    // 6) Reason for Rescheduling Session
    Map<String, Object> reasonReschedule = new Map<String, Object>();
    reasonReschedule.put('label', 'Reason for Rescheduling Session');
    reasonReschedule.put('field_id', 'REASON_NOT_RESCHEDULING_SESSION_NOW__c');
    reasonReschedule.put('type', 'select');
    reasonReschedule.put('place_holder', '');
    reasonReschedule.put('helper_text', '');
    reasonReschedule.put('is_required', true);
    reasonReschedule.put('default_value', '');
    reasonReschedule.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === rescheduled_the_session)'
    );
    reasonReschedule.put('relevant_field_ids', new List<String>());
    reasonReschedule.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> reasonRescheduleOptions = new List<Map<String, Object>>();
    String[][] reasonReschedulePairs = new String[][]{
      new String[]{'Family Function', 'family_function'},
      new String[]{'Health Issues', 'health_issues'},
      new String[]{'Internet Problem', 'internet_problem'},
      new String[]{'Have Classes (Online/Offline)', 'have_classes_(online/offline)'},
      new String[]{'Work At Home', 'work_at_home'},
      new String[]{'Exams', 'exams'},
      new String[]{'Unavailability Of Mobile', 'unavailability_of_mobile'},
      new String[]{'Power Cut', 'power_cut'},
      new String[]{'In Journey', 'in_journey'},
      new String[]{'Went out with friends/family', 'went_out_with_friends/family'},
      new String[]{'Unavailablity of Parent', 'unavailablity_of_parent'},
      new String[]{'Unavailablity of Student', 'unavailablity_of_student'},
      new String[]{'Other', 'other'}
    };
    for (String[] pair : reasonReschedulePairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      reasonRescheduleOptions.add(opt);
    }
    reasonReschedule.put('options', reasonRescheduleOptions);
    fields.add(reasonReschedule);

    // 7) Other Reason for Rescheduling Session
    Map<String, Object> otherReasonReschedule = new Map<String, Object>();
    otherReasonReschedule.put(
      'label',
      'Other Reason for Rescheduling Session'
    );
    otherReasonReschedule.put('field_id', 'OTHER_REASON_RESCHEDULING_SESSION__c');
    otherReasonReschedule.put('type', 'text');
    otherReasonReschedule.put('place_holder', '');
    otherReasonReschedule.put('helper_text', '');
    otherReasonReschedule.put('is_required', true);
    otherReasonReschedule.put('default_value', '');
    // Tie "Other Reason" visibility to REASON_NOT_RESCHEDULING_SESSION_NOW__c === other
    otherReasonReschedule.put(
      'relevant_condition',
      '(values[REASON_NOT_RESCHEDULING_SESSION_NOW__c] === other)'
    );
    otherReasonReschedule.put('relevant_field_ids', new List<String>());
    otherReasonReschedule.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    fields.add(otherReasonReschedule);

    // 8) Session Reschedule Date and Time
    Map<String, Object> sessionRescheduleDateTime = new Map<String, Object>();
    sessionRescheduleDateTime.put(
      'label',
      'Session Reschedule Date and Time'
    );
    sessionRescheduleDateTime.put(
      'field_id',
      'SESSION_RESCHEDULE_DATE_AND_TIME__c'
    );
    sessionRescheduleDateTime.put('type', 'date');
    sessionRescheduleDateTime.put('place_holder', '');
    sessionRescheduleDateTime.put('helper_text', '');
    sessionRescheduleDateTime.put('is_required', true);
    sessionRescheduleDateTime.put('default_value', '');
    sessionRescheduleDateTime.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === rescheduled_the_session)'
    );
    sessionRescheduleDateTime.put('relevant_field_ids', new List<String>());
    sessionRescheduleDateTime.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    sessionRescheduleDateTime.put('format', 'YYYY-MM-DD');
    fields.add(sessionRescheduleDateTime);

    // 9) Who all will visit the campus?
    Map<String, Object> whoVisitCampus = new Map<String, Object>();
    whoVisitCampus.put('label', 'Who all will visit the campus?');
    whoVisitCampus.put('field_id', 'WHO_ALL_WILL_VISIT_THE_CAMPUS__c');
        whoVisitCampus.put('type', 'Multi_select');
    whoVisitCampus.put('place_holder', '');
    whoVisitCampus.put('helper_text', '');
    whoVisitCampus.put('is_required', true);
    whoVisitCampus.put('default_value', new List<String>());
    whoVisitCampus.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === interested_in_campus_visit)'
    );
    whoVisitCampus.put('relevant_field_ids', new List<String>());
    whoVisitCampus.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> whoVisitOptions = new List<Map<String, Object>>();
    for (String[] pair : whomPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      whoVisitOptions.add(opt);
    }
    whoVisitCampus.put('options', whoVisitOptions);
    fields.add(whoVisitCampus);

    // 10) Campus Name - Planned to Visit?
    Map<String, Object> campusName = new Map<String, Object>();
    campusName.put('label', 'Campus Name - Planned to Visit?');
    campusName.put('field_id', 'CAMPUS_NAME_PLANNED_TO_VISIT__c');
    campusName.put('type', 'select');
    campusName.put('place_holder', '');
    campusName.put('helper_text', '');
    campusName.put('is_required', true);
    campusName.put('default_value', '');
    campusName.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === interested_in_campus_visit)'
    );
    campusName.put('relevant_field_ids', new List<String>());
    campusName.put('validation_regexs', new List<Map<String, Object>>());
    List<Map<String, Object>> campusOptions = new List<Map<String, Object>>();
    String[][] campusPairs = new String[][]{
      new String[]{'Anantapur', 'anantapur'},
      new String[]{'Hyderabad', 'hyderabad'},
      new String[]{'Tirupati', 'tirupati'},
      new String[]{'Vijayawada', 'vijayawada'},
      new String[]{'Visakhapatnam', 'visakhapatnam'},
      new String[]{'Bangalore', 'bangalore'},
      new String[]{'Pune', 'pune'},
      new String[]{'Chennai', 'chennai'},
      new String[]{'Puducherry', 'puducherry'},
      new String[]{'Jaipur', 'jaipur'},
      new String[]{'Delhi', 'delhi'},
      new String[]{'Kadapa', 'kadapa'}
    };
    for (String[] pair : campusPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      campusOptions.add(opt);
    }
    campusName.put('options', campusOptions);
    fields.add(campusName);

    // 11) Campus Visit Scheduler Form Shared with Customer?
    Map<String, Object> campusVisitShared = new Map<String, Object>();
    campusVisitShared.put(
      'label',
      'Campus Visit Scheduler Form Shared with Customer?'
    );
    campusVisitShared.put('field_id', 'CAMPUS_VISIT_SCHEDULER_SHARED__c');
    campusVisitShared.put('type', 'select');
    campusVisitShared.put('place_holder', '');
    campusVisitShared.put('helper_text', '');
    campusVisitShared.put('is_required', true);
    campusVisitShared.put('default_value', '');
    campusVisitShared.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === interested_in_campus_visit)'
    );
    campusVisitShared.put('relevant_field_ids', new List<String>());
    campusVisitShared.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> campusVisitOptions = new List<Map<String, Object>>();
    String[][] campusVisitPairs = new String[][]{
      new String[]{'Yes', 'yes'},
      new String[]{'No', 'no'}
    };
    for (String[] pair : campusVisitPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      campusVisitOptions.add(opt);
    }
    campusVisitShared.put('options', campusVisitOptions);
    fields.add(campusVisitShared);

    // 12) Lead Interest status
    Map<String, Object> leadInterestStatus = new Map<String, Object>();
    leadInterestStatus.put('label', 'Lead Interest status');
    leadInterestStatus.put('field_id', 'LEAD_INTEREST_STATUS__c');
    leadInterestStatus.put('type', 'select');
    leadInterestStatus.put('place_holder', '');
    leadInterestStatus.put('helper_text', '');
    leadInterestStatus.put('is_required', false);
    leadInterestStatus.put('default_value', '');
    leadInterestStatus.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === will_attend_the_session || values[HOW_DID_THE_CALL_GO__c] === rescheduled_the_session || values[HOW_DID_THE_CALL_GO__c] === interested_in_campus_visit)'
    );
    leadInterestStatus.put('relevant_field_ids', new List<String>());
    leadInterestStatus.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> leadInterestOptions = new List<Map<String, Object>>();
    String[][] leadInterestPairs = new String[][]{
      new String[]{'High Interest', 'high_interest'},
      new String[]{'Medium Interest', 'medium_interest'},
      new String[]{'Low Interest', 'low_interest'}
    };
    for (String[] pair : leadInterestPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      leadInterestOptions.add(opt);
    }
    leadInterestStatus.put('options', leadInterestOptions);
    fields.add(leadInterestStatus);

    // 13) Reason for Irrelevance
    Map<String, Object> reasonIrrelevance = new Map<String, Object>();
    reasonIrrelevance.put('label', 'Reason for Irrelevance');
    reasonIrrelevance.put('field_id', 'REASON_FOR_IRRELEVANCE__c');
    reasonIrrelevance.put('type', 'select');
    reasonIrrelevance.put('place_holder', '');
    reasonIrrelevance.put('helper_text', '');
    reasonIrrelevance.put('is_required', true);
    reasonIrrelevance.put('default_value', '');
    reasonIrrelevance.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === irrelevant_to_niat)'
    );
    reasonIrrelevance.put('relevant_field_ids', new List<String>());
    reasonIrrelevance.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> reasonIrrelevanceOptions = new List<Map<String, Object>>();
    String[][] reasonIrrelevancePairs = new String[][]{
      new String[]{'Academy', 'academy'},
      new String[]{'Intensive', 'intensive'},
      new String[]{'Studying 10th', 'studying_10th'},
      new String[]{'Studying 11th', 'studying_11th'},
      new String[]{'Commerce Student', 'commerce_student'},
      new String[]{'Biology Student', 'biology_student'},
      new String[]{'Arts Student', 'arts_student'},
      new String[]{'Discontinued Education', 'discontinued_education'},
      new String[]{'Working Professional', 'working_professional'},
      new String[]{'Diploma (1 Year)', 'diploma_(1_year)'},
      new String[]{'Diploma (2 Years)', 'diploma_(2_years)'},
      new String[]{'Backlogs', 'backlogs'}
    };
    for (String[] pair : reasonIrrelevancePairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      reasonIrrelevanceOptions.add(opt);
    }
    reasonIrrelevance.put('options', reasonIrrelevanceOptions);
    fields.add(reasonIrrelevance);

    // 14) Year of Graduation
    Map<String, Object> yearGraduation = new Map<String, Object>();
    yearGraduation.put('label', 'Year of Graduation');
    yearGraduation.put('field_id', 'YEAR_OF_GRADUATION__c');
    yearGraduation.put('type', 'select');
    yearGraduation.put('place_holder', '');
    yearGraduation.put('helper_text', '');
    yearGraduation.put('is_required', true);
    yearGraduation.put('default_value', '');
    // Fix condition to match option value "intensive"
    yearGraduation.put(
      'relevant_condition',
      '(values[REASON_FOR_IRRELEVANCE__c] === academy || values[REASON_FOR_IRRELEVANCE__c] === Intensive)'
    );
    yearGraduation.put('relevant_field_ids', new List<String>());
    yearGraduation.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> yearOptions = new List<Map<String, Object>>();
    for (Integer yr = 2010; yr <= 2039; yr++) {
      Map<String, Object> opt = new Map<String, Object>();
      String yStr = String.valueOf(yr);
      opt.put('label', yStr);
      opt.put('value', yStr);
      opt.put('condition', 'true');
      yearOptions.add(opt);
    }
    yearGraduation.put('options', yearOptions);
    fields.add(yearGraduation);

    // 15) Reason For Not Interested
    Map<String, Object> reasonNotInterested = new Map<String, Object>();
    reasonNotInterested.put('label', 'Reason For Not Interested');
    reasonNotInterested.put('field_id', 'REASON_FOR_NOT_INTERESTED__c');
    reasonNotInterested.put('type', 'select');
    reasonNotInterested.put('place_holder', '');
    reasonNotInterested.put('helper_text', '');
    reasonNotInterested.put('is_required', true);
    reasonNotInterested.put('default_value', '');
    reasonNotInterested.put(
      'relevant_condition',
      '(values[HOW_DID_THE_CALL_GO__c] === not_interested_in_niat)'
    );
    reasonNotInterested.put('relevant_field_ids', new List<String>());
    reasonNotInterested.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> reasonNotInterestedOptions = new List<Map<String, Object>>();
    String[][] reasonNotInterestedPairs = new String[][]{
      new String[]{'Aiming for NIT/IIT', 'aiming_for_nit/iit'},
      new String[]{
        'Assuming we are selling paid programs',
        'assuming_we_are_selling_paid_programs'
      },
      new String[]{'Casual Behaviour', 'casual_behaviour'},
      new String[]{'Fear to open unknown links', 'fear_to_open_unknown_links'},
      new String[]{
        'Parent not willing to share student number',
        'parent_not_willing_to_share_student_number'
      },
      new String[]{
        'Student is busy with college schedule',
        'student_is_busy_with_college_schedule'
      },
      new String[]{
        'Student didn’t convey to Parent',
        'student_didn’t_convey_to_parent'
      },
      new String[]{
        'Took Admission in other College',
        'took_admission_in_other_college'
      },
      new String[]{
        'Lead requested branch/program not available',
        'lead_requested_branch/program_not_available'
      },
      new String[]{'Other', 'other'}
    };
    for (String[] pair : reasonNotInterestedPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      reasonNotInterestedOptions.add(opt);
    }
    reasonNotInterested.put('options', reasonNotInterestedOptions);
    fields.add(reasonNotInterested);

    // 16) Other Reason For Not Interested
    Map<String, Object> otherReasonNotInterested = new Map<String, Object>();
    otherReasonNotInterested.put(
      'label',
      'Other Reason For Not Interested'
    );
    otherReasonNotInterested.put('field_id', 'OTHER_REASON_FOR_NOT_INTERESTED');
    otherReasonNotInterested.put('type', 'text');
    otherReasonNotInterested.put('place_holder', '');
    otherReasonNotInterested.put('helper_text', '');
    otherReasonNotInterested.put('is_required', true);
    otherReasonNotInterested.put('default_value', '');
    otherReasonNotInterested.put(
      'relevant_condition',
      '(values[REASON_FOR_NOT_INTERESTED__c] === other)'
    );
    otherReasonNotInterested.put(
      'relevant_field_ids',
      new List<String>()
    );
    otherReasonNotInterested.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    fields.add(otherReasonNotInterested);

    // 17) Attending on
    Map<String, Object> attendingOn = new Map<String, Object>();
    attendingOn.put('label', 'Attending on');
    attendingOn.put('field_id', 'ATTENDING_ON__c');
    attendingOn.put('type', 'datetime');
    attendingOn.put('place_holder', '');
    attendingOn.put('helper_text', '');
    attendingOn.put('is_required', false);
    attendingOn.put('default_value', '');
    attendingOn.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === call_done)'
    );
    attendingOn.put('relevant_field_ids', new List<String>());
    attendingOn.put('validation_regexs', new List<Map<String, Object>>());
    attendingOn.put('format', 'YYYY-MM-DD HH:MM:SS');
    attendingOn.put('min_date', '');
    attendingOn.put('max_date', '');
    attendingOn.put('exclude_dates', new List<String>());
    fields.add(attendingOn);

    // 18) Call Back Date & Time
    Map<String, Object> callBackDateTime = new Map<String, Object>();
    callBackDateTime.put('label', 'Call Back Date & Time');
    callBackDateTime.put('field_id', 'CALL_BACK_DATE_AND_TIME__c');
    callBackDateTime.put('type', 'datetime');
    callBackDateTime.put('place_holder', '');
    callBackDateTime.put('helper_text', '');
    callBackDateTime.put('is_required', true);
    callBackDateTime.put('default_value', '');
    callBackDateTime.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === call_back)'
    );
    callBackDateTime.put('relevant_field_ids', new List<String>());
    callBackDateTime.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    callBackDateTime.put('format', 'YYYY-MM-DD HH:MM:SS');
    callBackDateTime.put('min_date', '');
    callBackDateTime.put('max_date', '');
    callBackDateTime.put('exclude_dates', new List<String>());
    fields.add(callBackDateTime);

    // 19) Next Call back On
    Map<String, Object> nextCallBackOn = new Map<String, Object>();
    nextCallBackOn.put('label', 'Next Call back On');
    nextCallBackOn.put('field_id', 'NEXT_CALL_BACK_ON__c');
    nextCallBackOn.put('type', 'phone_number');
    nextCallBackOn.put('place_holder', '');
    nextCallBackOn.put('helper_text', '');
    nextCallBackOn.put('is_required', true);
    nextCallBackOn.put('default_value', '');
    nextCallBackOn.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === call_back)'
    );
    nextCallBackOn.put('relevant_field_ids', new List<String>());
    List<Map<String, Object>> nextCallValidations = new List<Map<String, Object>>();
    Map<String, Object> nextCallValidation = new Map<String, Object>();
    nextCallValidation.put('regex', '^[6-9]\\d{9}$');
    nextCallValidation.put('message', 'Invalid mobile number');
    nextCallValidations.add(nextCallValidation);
    nextCallBackOn.put('validation_regexs', nextCallValidations);
    fields.add(nextCallBackOn);

    // 20) Wrong Number Type
    Map<String, Object> wrongNumberType = new Map<String, Object>();
    wrongNumberType.put('label', 'Wrong Number Type');
    wrongNumberType.put('field_id', 'WRONG_NUMBER_TYPE__c');
    wrongNumberType.put('type', 'select');
    wrongNumberType.put('place_holder', '');
    wrongNumberType.put('helper_text', '');
    wrongNumberType.put('is_required', true);
    wrongNumberType.put('default_value', '');
    wrongNumberType.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === wrong_number)'
    );
    wrongNumberType.put('relevant_field_ids', new List<String>());
    wrongNumberType.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> wrongNumberOptions = new List<Map<String, Object>>();
    String[][] wrongNumberPairs = new String[][]{
      new String[]{
        'User Reported Wrong Number',
        'user_reported_wrong_number'
      },
      new String[]{
        'Detected Wrong Number During Call',
        'detected_wrong_number_during_call'
      }
    };
    for (String[] pair : wrongNumberPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      wrongNumberOptions.add(opt);
    }
    wrongNumberType.put('options', wrongNumberOptions);
    fields.add(wrongNumberType);

    // 21) Preferred Language
    Map<String, Object> preferredLanguage = new Map<String, Object>();
    preferredLanguage.put('label', 'Preferred Language');
    preferredLanguage.put('field_id', 'PREFERRED_LANGUAGE__c');
    preferredLanguage.put('type', 'select');
    preferredLanguage.put('place_holder', '');
    preferredLanguage.put('helper_text', '');
    preferredLanguage.put('is_required', true);
    preferredLanguage.put('default_value', '');
    preferredLanguage.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === language_barrier)'
    );
    preferredLanguage.put('relevant_field_ids', new List<String>());
    preferredLanguage.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> languageOptions = new List<Map<String, Object>>();
    String[][] languagePairs = new String[][]{
      new String[]{'Telugu', 'telugu'},
      new String[]{'Tamil', 'tamil'},
      new String[]{'Kannada', 'kannada'},
      new String[]{'Malayalam', 'malayalam'},
      new String[]{'Marathi', 'marathi'},
      new String[]{'Hindi', 'hindi'}
    };
    for (String[] pair : languagePairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      languageOptions.add(opt);
    }
    preferredLanguage.put('options', languageOptions);
    fields.add(preferredLanguage);

    // 22) Program Enrolled
    Map<String, Object> programEnrolled = new Map<String, Object>();
    programEnrolled.put('label', 'Program Enrolled');
    programEnrolled.put('field_id', 'PROGRAM_ENROLLED__c');
    programEnrolled.put('type', 'select');
    programEnrolled.put('place_holder', '');
    programEnrolled.put('helper_text', '');
    programEnrolled.put('is_required', true);
    programEnrolled.put('default_value', '');
    programEnrolled.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === already_enrolled_user)'
    );
    programEnrolled.put('relevant_field_ids', new List<String>());
    programEnrolled.put(
      'validation_regexs',
      new List<Map<String, Object>>()
    );
    List<Map<String, Object>> programOptions = new List<Map<String, Object>>();
    String[][] programPairs = new String[][]{
      new String[]{'Academy', 'academy'},
      new String[]{'Intensive', 'intensive'},
      new String[]{'NIAT', 'niat'}
    };
    for (String[] pair : programPairs) {
      Map<String, Object> opt = new Map<String, Object>();
      opt.put('label', pair[0]);
      opt.put('value', pair[1]);
      opt.put('condition', 'true');
      programOptions.add(opt);
    }
    programEnrolled.put('options', programOptions);
    fields.add(programEnrolled);

    // 23) Enrolled Number
    Map<String, Object> registeredNumber = new Map<String, Object>();
    registeredNumber.put('label', 'Enrolled Number');
    registeredNumber.put('field_id', 'REGISTERED_NUMBER__c');
    registeredNumber.put('type', 'phone_number');
    registeredNumber.put('place_holder', '');
    registeredNumber.put('helper_text', '');
    registeredNumber.put('is_required', false);
    registeredNumber.put('default_value', '');
    registeredNumber.put(
      'relevant_condition',
      '(values[CALL_STATUS__c] === already_enrolled_user)'
    );
    registeredNumber.put('relevant_field_ids', new List<String>());
    List<Map<String, Object>> regValidations = new List<Map<String, Object>>();
    Map<String, Object> regValidation = new Map<String, Object>();
    regValidation.put('regex', '^[6-9]\\d{9}$');
    regValidation.put('message', 'Invalid mobile number');
    regValidations.add(regValidation);
    registeredNumber.put('validation_regexs', regValidations);
    fields.add(registeredNumber);

    // 24) Remarks
    Map<String, Object> remarks = new Map<String, Object>();
    remarks.put('label', 'Remarks');
    remarks.put('field_id', 'REMARKS__c');
    remarks.put('type', 'text_area');
    remarks.put('place_holder', 'Enter remarks');
    remarks.put('helper_text', '');
    remarks.put('is_required', true);
    remarks.put('default_value', '');
    remarks.put('relevant_condition', '');
    remarks.put('relevant_field_ids', new List<String>());
    remarks.put('validation_regexs', new List<Map<String, Object>>());
    fields.add(remarks);

    // Note: The final empty placeholder field in sample.json is intentionally not added.

    config.put('fields', fields);
    return JSON.serialize(config);
  }

}

