Map<String, Object> values = EligibilityController.getValuesPayload();

List<Map<String, String>> testRulesList = new List<Map<String, String>>();

// Rule 1: ACTIVITY_DATE_IS_TODAY
// activity_date equals TODAY (uses standard literal resolution)
String ACTIVITY_DATE_IS_TODAY = 'values[ACTIVITY["activity_date"]] === DATE_TODAY';
testRulesList.add(new Map<String, String>{'name' => 'ACTIVITY_DATE_IS_TODAY', 'rule' => ACTIVITY_DATE_IS_TODAY});

// Rule 2: FUTURE_ACTIVITY_AFTER_TODAY
// future_activity_date greater than TODAY
String FUTURE_ACTIVITY_IS_AFTER_TODAY = 'values[ACTIVITY["future_activity_date"]] > DATE_TODAY';
testRulesList.add(new Map<String, String>{'name' => 'FUTURE_ACTIVITY_IS_AFTER_TODAY', 'rule' => FUTURE_ACTIVITY_IS_AFTER_TODAY});

// Rule 3: APPLICATION_IN_THIS_YEAR
// Application_Date__c greater than or equal to THISYEAR
String APPLICATION_IN_THIS_YEAR = 'values[PRODUCT_OPPORTUNITY["Application_Date__c"]] === DATE_THIS_YEAR';
testRulesList.add(new Map<String, String>{'name' => 'APPLICATION_IN_THIS_YEAR', 'rule' => APPLICATION_IN_THIS_YEAR});

// Rule 4: ACTIVITY_DATE_IS_TOMORROW
// activity_date equals TOMORROW (uses standard literal resolution)
String ACTIVITY_DATE_IS_TOMORROW = 'values[ACTIVITY["activity_date"]] === DATE_TOMORROW';
testRulesList.add(new Map<String, String>{'name' => 'ACTIVITY_DATE_IS_TOMORROW', 'rule' => ACTIVITY_DATE_IS_TOMORROW});

// Rule 5: FUTURE_ACTIVITY_AFTER_TOMORROW
// future_activity_date greater than TOMORROW
String FUTURE_ACTIVITY_IS_AFTER_TOMORROW = 'values[ACTIVITY["future_activity_date"]] > DATE_TOMORROW';
testRulesList.add(new Map<String, String>{'name' => 'FUTURE_ACTIVITY_IS_AFTER_TOMORROW', 'rule' => FUTURE_ACTIVITY_IS_AFTER_TOMORROW});

// Rule 6: ACTIVITY_DATE_IS_THIS_MONTH
// activity_date equals THIS_MONTH (uses standard literal resolution)
String ACTIVITY_DATE_IS_THIS_MONTH = 'values[ACTIVITY["activity_date"]] === DATE_THIS_MONTH';
testRulesList.add(new Map<String, String>{'name' => 'ACTIVITY_DATE_IS_THIS_MONTH', 'rule' => ACTIVITY_DATE_IS_THIS_MONTH});

// Rule 7: FUTURE_ACTIVITY_AFTER_THIS_MONTH
// future_activity_date greater than THIS_MONTH
String FUTURE_ACTIVITY_IS_AFTER_THIS_MONTH = 'values[ACTIVITY["future_activity_date"]] > DATE_THIS_MONTH';
testRulesList.add(new Map<String, String>{'name' => 'FUTURE_ACTIVITY_IS_AFTER_THIS_MONTH', 'rule' => FUTURE_ACTIVITY_IS_AFTER_THIS_MONTH});

// Rule 8: FUTURE_ACTIVITY_IS_TOMORROW
// future_activity_date equals TOMORROW (uses standard literal resolution)
String FUTURE_ACTIVITY_IS_TOMORROW = 'values[ACTIVITY["future_activity_date"]] === DATE_TOMORROW';
testRulesList.add(new Map<String, String>{'name' => 'FUTURE_ACTIVITY_IS_TOMORROW', 'rule' => FUTURE_ACTIVITY_IS_TOMORROW});

// Rule 9: FUTURE_ACTIVITY_IS_THIS_MONTH
// future_activity_date equals THIS_MONTH (uses standard literal resolution)
String FUTURE_ACTIVITY_IS_THIS_MONTH = 'values[ACTIVITY["future_acttivity_date"]] === null';
testRulesList.add(new Map<String, String>{'name' => 'FUTURE_ACTIVITY_IS_THIS_MONTH', 'rule' => FUTURE_ACTIVITY_IS_THIS_MONTH});

for (Map<String, String> ruleMap : testRulesList) {
    String ruleName = ruleMap.get('name');
    String ruleExpression = ruleMap.get('rule');
    Boolean eligible = CustomConditionEvaluator.evaluateCustomCondition(values, ruleExpression);

    System.debug('-->' + ruleName + '-->' + eligible);
    System.debug('-------------------------------------------------------------');
}
// System.debug('-->' + 'Date.now()' + '-->' + DateTime.now().addYears(1));
// System.debug(CustomConditionEvaluator.evaluateCustomCondition(values, FUTURE_ACTIVITY_IS_THIS_MONTH));