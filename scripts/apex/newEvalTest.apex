Map<String, Object> values = new Map<String, Object>{
    'PRODUCT_OPPORTUNITY' => new Map<String, Object>{
        // Core timestamps
        'CreatedDate' => '2024-01-03 08:00:00',
        'LATEST_REGISTRATION_DATE_TIME__c' => '2026-01-09 09:00:00',
        'FIRST_RESURFACED_DATETIME__c' => null,
        'FIRST_QUALIFIED_DATE_TIME__c' => null,

        // Stage / status
        'STAGE__c' => 'Repository',
        'LEAD_ORIGIN__c' => null,

        // Resurface / counters
        'RESURFACED_COUNT__c' => 0,
        'LEAD_APPROACHED_COUNT__c' => 0,

        // Channel entry dates (all start null so CUSTOM rules can fire)
        'AFFILIATE_CHANNEL_ENTRY_DATE__c' => null,
        'EMPLOYEE_REFERRAL_CHANNEL_ENTRY_DATE__c' => null,
        'INBOUND_CHANNEL_ENTRY_DATE__c' => null,
        'OUTBOUND_CHANNEL_ENTRY_DATE__c' => null,
        'IM_CHANNEL_ENTRY_DATE__c' => null,
        'OFFLINE_SCHOOL_CHANNEL_VISITS_ENTRY_DATE__c' => null,
        'INVITE_AND_EARN_CHANNEL_ENTRY_DATE__c' => null,
        'ASL_CHANNEL_ENTRY_DATE__c' => null,
        'DIGITAL_AFFILIATE_CHANNEL_ENTRY_DATE__c' => null,
        'NET_CHANNEL_ENTRY_DATE__c' => null,
        'REFERRAL_CHANNEL_ENTRY_DATE__c' => null,
        'DIGITAL_MARKETING_CHANNEL_ENTRY_DATE__c' => null,
        'BRAND_SEARCH_CHANNEL_ENTRY_DATE__c' => null,
        'SEO_CHANNEL_ENTRY_DATE__c' => null,
        'INVITE_EARNBOOT_CHANNEL_ENTRY_DATE__c' => null,
        'COLLEGE_DOST_CHANNEL_ENTRY_DATE__c' => null,
        'AUXILIARY_CONTENT_CHANNEL_ENTRY_DATE__c' => null,
        'BTL_ACTIVITY_CHANNEL_ENTRY_DATE__c' => null,
        'ADMISSION_CONSULTANT_CHANNEL_ENTRY_DATE__c' => null,
        'PRINCIPAL_AFFILIATE_CHANNEL_ENTRY_DATE__c' => null,
        'BRAND_ENGAGEMENT_CHANNEL_ENTRY_DATE__c' => null,
        'COLLEGE_DUNIA_CHANNEL_ENTRY_DATE__c' => null,
        'COLLEGE_DEKHO_CHANNEL_ENTRY_DATE__c' => null,
        'JUSTDIAL_CHANNEL_ENTRY_DATE__c' => null,
        'ASSL_CHANNEL_ENTRY_DATE__c' => null
    },

    'ACTIVITY' => new Map<String, Object>{
        // Must be DateTime for comparisons
        'activity_datetime' => '2024-01-03 09:00:00',

        // Change this value to test different CUSTOM channel conditions
        'CHANNEL__c' => 'Affiliate'
    }
};

List<String> conditions = ConditionTestHelper.getConditions();
integer i = 0;
for (String condition : conditions) {
    i++;
    Boolean eligible = CustomConditionEvaluator.evaluateCondition(values, condition);
    System.debug('-->' + 'condition' +i + '-->'+ eligible);
}
// Object createdDate = ((Map<String, Object>)values.get('PRODUCT_OPPORTUNITY')).get('CreatedDate');
// System.debug('-->' + 'values[PRODUCT_OPPORTUNITY[CreatedDate]]' + '-->' + createdDate);

// String condition ='(values[PRODUCT_OPPORTUNITY[LATEST_QUALIFIED_DATE_TIME__c]] === null && values[PRODUCT_OPPORTUNITY[PRESALES_LEAD_JOURNEY__c]] === null)';
// Boolean eligible = CustomConditionEvaluator.evaluateCondition(values, condition);
// System.debug('-->' + 'condition' + '-->'+ eligible);/*  */