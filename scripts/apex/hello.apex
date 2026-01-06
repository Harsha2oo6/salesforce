Map<String, Object> values = EligibilityController.getValuesPayload();
List<Map<String, String>> rulesList = new List<Map<String, String>>();

// Rule 1: NON_NAT_LEAD_SESSION_DURATION (Line 331)
// Presales Lead Type is Non-NAT/null AND Session Duration > 30
String NON_NAT_LEAD_SESSION_DURATION = '(values[PRODUCT_OPPORTUNITY["Presales_Lead_Type__c"]] === "Non-NAT Lead" || values[PRODUCT_OPPORTUNITY["Presales_Lead_Type__c"]] === null) && values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30';
rulesList.add(new Map<String, String>{'name' => 'NON_NAT_LEAD_SESSION_DURATION', 'rule' => NON_NAT_LEAD_SESSION_DURATION});

// Rule 2: NURTURING_CHANNEL_NULL (Line 320)
// Nurturing Channel is null
String NURTURING_CHANNEL_NULL = 'values[PRODUCT_OPPORTUNITY["Nurturing_Channel"]] === null';
rulesList.add(new Map<String, String>{'name' => 'NURTURING_CHANNEL_NULL', 'rule' => NURTURING_CHANNEL_NULL});

// Rule 3: ACTIVITY_SESSION_DATE_MISMATCH (Line 309)
// Activity datetime differs from Session Attended on
String ACTIVITY_SESSION_DATE_MISMATCH = 'values[ACTIVITY["activity_datetime"]] !== values[PRODUCT_OPPORTUNITY["Session_Attended_on"]]';
rulesList.add(new Map<String, String>{'name' => 'ACTIVITY_SESSION_DATE_MISMATCH', 'rule' => ACTIVITY_SESSION_DATE_MISMATCH});

// Rule 4: FIRST_CYCLE_NULL_WITH_STAGE_CHECK (Line 297)
// Session > 30, First Qualified Cycle null, stage not in exam stages
String FIRST_CYCLE_NULL_WITH_STAGE_CHECK = 'values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30 && values[PRODUCT_OPPORTUNITY["First_Qualified_Cycle__c"]] === null && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "NAT Initiated" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Fee Paid" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Slot Booked" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Not Attended" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Attended Not Qualified"';
rulesList.add(new Map<String, String>{'name' => 'FIRST_CYCLE_NULL_WITH_STAGE_CHECK', 'rule' => FIRST_CYCLE_NULL_WITH_STAGE_CHECK});

// Rule 5: SESSION_DURATION_STAGE_CONDITION_A (Line 291)
// Session > 30, stage not in exam stages
String SESSION_DURATION_STAGE_CONDITION_A = 'values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30 && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "NAT Initiated" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Fee Paid" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Slot Booked" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Not Attended" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Attended Not Qualified"';
rulesList.add(new Map<String, String>{'name' => 'SESSION_DURATION_STAGE_CONDITION_A', 'rule' => SESSION_DURATION_STAGE_CONDITION_A});

// Rule 6: FIRST_QUALIFIED_DATE_WITH_STAGE_CHECK (Line 280)
// Session > 30, First Qualified DateTime null, stage not in exam stages
String FIRST_QUALIFIED_DATE_WITH_STAGE_CHECK = 'values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30 && values[PRODUCT_OPPORTUNITY["First_Qualified_Date_Time__c"]] === null && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "NAT Initiated" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Fee Paid" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Slot Booked" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Not Attended" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Attended Not Qualified"';
rulesList.add(new Map<String, String>{'name' => 'FIRST_QUALIFIED_DATE_WITH_STAGE_CHECK', 'rule' => FIRST_QUALIFIED_DATE_WITH_STAGE_CHECK});

// Rule 7: SESSION_DURATION_STAGE_CONDITION_B (Line 274)
// Session > 30, stage not in exam stages
String SESSION_DURATION_STAGE_CONDITION_B = 'values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30 && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "NAT Initiated" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Fee Paid" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Slot Booked" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Not Attended" && values[PRODUCT_OPPORTUNITY["Stage__c"]] !== "Exam Attended Not Qualified"';
rulesList.add(new Map<String, String>{'name' => 'SESSION_DURATION_STAGE_CONDITION_B', 'rule' => SESSION_DURATION_STAGE_CONDITION_B});

String sample= '(values[PRODUCT_OPPORTUNITY["Presales_Lead_Type__c"]] === "Non-NAT Lead" || values[PRODUCT_OPPORTUNITY["Presales_Lead_Type__c"]] === null) && values[ACTIVITY["SESSION_ATTENDED_DURATION_MIN"]] > 30';
// Evaluate all rules
for (Map<String, String> ruleMap : rulesList) {
    String ruleName = ruleMap.get('name');
    String ruleExpression = ruleMap.get('rule');
    Boolean eligible = EligibilityEvaluator.evaluateEligibility(values, ruleExpression);

    System.debug('-->' + ruleName + '-->' + eligible);
}
// Boolean eligible = EligibilityEvaluator.evaluateEligibility(values, sample);

// System.debug('-->' + 'sample' + '-->' + eligible);