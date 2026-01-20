Map<String, Object> values = new Map<String, Object>{
    'CALL_STATUS__c' => 'already_enrolled_user'
};

System.debug('--> values[CALL_STATUS__c] = ' + values.get('CALL_STATUS__c'));

String condition = '(values[CALL_STATUS__c] === already_enrolled_user)';
System.debug('--> condition string = ' + condition);
Boolean eligible = CustomConditionEvaluator.evaluateCondition(values, condition);
System.debug('--> result = ' + eligible);
