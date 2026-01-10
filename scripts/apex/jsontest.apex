Map<String, Object> values = new Map<String, Object>{
    'PRODUCT_OPPORTUNITY' => new Map<String, Object>{
        // Core timestamps
        'CreatedDate' => DateTime.newInstance(2024, 1, 1, 10, 0, 0),
        'LATEST_REGISTRATION_DATE_TIME__c' => DateTime.newInstance(2024, 1, 2, 9, 0, 0),
        'FIRST_RESURFACED_DATETIME__c' => null,
        'LATEST_QUALIFIED_DATE_TIME__c' => null,
        'FIRST_QUALIFIED_DATE_TIME__c' => null,

        // Stage / status
        'STAGE__c' => 'Repository',
        'LEAD_ORIGIN__c' => null,
        'PRESALES_LEAD_JOURNEY__c' => null,

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
        'activity_datetime' => '2024-01-03 08:00:00',

        // Change this value to test different CUSTOM channel conditions
        'CHANNEL__c' => 'Affiliate'
    }
};


String condition1 = "(values[PRODUCT_OPPORTUNITY[CreatedDate]] < values[ACTIVITY[activity_datetime]] && values[PRODUCT_OPPORTUNITY[LATEST_REGISTRATION_DATE_TIME__c]] !== DATE_TODAY && values[PRODUCT_OPPORTUNITY[FIRST_RESURFACED_DATETIME__c]] === null)";

String condition2 = "(values[PRODUCT_OPPORTUNITY[CreatedDate]] < values[ACTIVITY[activity_datetime]] && values[PRODUCT_OPPORTUNITY[LATEST_REGISTRATION_DATE_TIME__c]] !== DATE_TODAY)";

String condition3 = "(values[ACTIVITY[CHANNEL__c]] === Affiliate && values[PRODUCT_OPPORTUNITY[AFFILIATE_CHANNEL_ENTRY_DATE__c]] === null)";

String condition4 = "(values[ACTIVITY[CHANNEL__c]] === Employee Referral && values[PRODUCT_OPPORTUNITY[EMPLOYEE_REFERRAL_CHANNEL_ENTRY_DATE__c]] === null)";

String condition5 = "(values[ACTIVITY[CHANNEL__c]] === Inbound && values[PRODUCT_OPPORTUNITY[INBOUND_CHANNEL_ENTRY_DATE__c]] === null)";

String condition6 = "(values[ACTIVITY[CHANNEL__c]] === Outbound && values[PRODUCT_OPPORTUNITY[OUTBOUND_CHANNEL_ENTRY_DATE__c]] === null)";

String condition7 = "(values[ACTIVITY[CHANNEL__c]] === IM && values[PRODUCT_OPPORTUNITY[IM_CHANNEL_ENTRY_DATE__c]] === null)";

String condition8 = "(values[ACTIVITY[CHANNEL__c]] === Offline 12th College Visits && values[PRODUCT_OPPORTUNITY[OFFLINE_SCHOOL_CHANNEL_VISITS_ENTRY_DATE__c]] === null)";

String condition9 = "(values[ACTIVITY[CHANNEL__c]] === Invite and Earn && values[PRODUCT_OPPORTUNITY[INVITE_AND_EARN_CHANNEL_ENTRY_DATE__c]] === null)";

String condition10 = "(values[ACTIVITY[CHANNEL__c]] === ASL && values[PRODUCT_OPPORTUNITY[ASL_CHANNEL_ENTRY_DATE__c]] === null)";

String condition11 = "(values[ACTIVITY[CHANNEL__c]] === Digital Affiliate && values[PRODUCT_OPPORTUNITY[DIGITAL_AFFILIATE_CHANNEL_ENTRY_DATE__c]] === null)";

String condition12 = "(values[ACTIVITY[CHANNEL__c]] === NET && values[PRODUCT_OPPORTUNITY[NET_CHANNEL_ENTRY_DATE__c]] === null)";

String condition13 = "(values[ACTIVITY[CHANNEL__c]] === Referral && values[PRODUCT_OPPORTUNITY[REFERRAL_CHANNEL_ENTRY_DATE__c]] === null)";

String condition14 = "(values[ACTIVITY[CHANNEL__c]] === Digital Marketing && values[PRODUCT_OPPORTUNITY[DIGITAL_MARKETING_CHANNEL_ENTRY_DATE__c]] === null)";

String condition15 = "(values[ACTIVITY[CHANNEL__c]] === Brand Search && values[PRODUCT_OPPORTUNITY[BRAND_SEARCH_CHANNEL_ENTRY_DATE__c]] === null)";

String condition16 = "(values[ACTIVITY[CHANNEL__c]] === SEO && values[PRODUCT_OPPORTUNITY[SEO_CHANNEL_ENTRY_DATE__c]] === null)";

String condition17 = "(values[ACTIVITY[CHANNEL__c]] === Invite and Earn Bootcamp && values[PRODUCT_OPPORTUNITY[INVITE_EARNBOOT_CHANNEL_ENTRY_DATE__c]] === null)";

String condition18 = "(values[ACTIVITY[CHANNEL__c]] === College Dost && values[PRODUCT_OPPORTUNITY[COLLEGE_DOST_CHANNEL_ENTRY_DATE__c]] === null)";

String condition19 = "(values[ACTIVITY[CHANNEL__c]] === Auxiliary Content && values[PRODUCT_OPPORTUNITY[AUXILIARY_CONTENT_CHANNEL_ENTRY_DATE__c]] === null)";

String condition20 = "(values[ACTIVITY[CHANNEL__c]] === BTL Activity && values[PRODUCT_OPPORTUNITY[BTL_ACTIVITY_CHANNEL_ENTRY_DATE__c]] === null)";

String condition21 = "(values[ACTIVITY[CHANNEL__c]] === Affiliate - Admission Consultants && values[PRODUCT_OPPORTUNITY[ADMISSION_CONSULTANT_CHANNEL_ENTRY_DATE__c]] === null)";

String condition22 = "(values[ACTIVITY[CHANNEL__c]] === Affiliate - Principals && values[PRODUCT_OPPORTUNITY[PRINCIPAL_AFFILIATE_CHANNEL_ENTRY_DATE__c]] === null)";

String condition23 = "(values[ACTIVITY[CHANNEL__c]] === Brand Engagement && values[PRODUCT_OPPORTUNITY[BRAND_ENGAGEMENT_CHANNEL_ENTRY_DATE__c]] === null)";

String condition24 = "(values[ACTIVITY[CHANNEL__c]] === College Dunia && values[PRODUCT_OPPORTUNITY[COLLEGE_DUNIA_CHANNEL_ENTRY_DATE__c]] === null)";

String condition25 = "(values[ACTIVITY[CHANNEL__c]] === College Dekho && values[PRODUCT_OPPORTUNITY[COLLEGE_DEKHO_CHANNEL_ENTRY_DATE__c]] === null)";

String condition26 = "(values[ACTIVITY[CHANNEL__c]] === Justdial && values[PRODUCT_OPPORTUNITY[JUSTDIAL_CHANNEL_ENTRY_DATE__c]] === null)";

String condition27 = "(values[ACTIVITY[CHANNEL__c]] === ASSL && values[PRODUCT_OPPORTUNITY[ASSL_CHANNEL_ENTRY_DATE__c]] === null)";

String condition28 = "(values[PRODUCT_OPPORTUNITY[LEAD_ORIGIN__c]] === null)";

String condition29 = "(values[PRODUCT_OPPORTUNITY[CreatedDate]] < values[ACTIVITY[activity_datetime]])";

String condition30 = "(values[PRODUCT_OPPORTUNITY[LATEST_QUALIFIED_DATE_TIME__c]] === null && values[PRODUCT_OPPORTUNITY[PRESALES_LEAD_JOURNEY__c]] === null)";

String condition31 = "(values[PRODUCT_OPPORTUNITY[CreatedDate]] < values[ACTIVITY[activity_datetime]])";

String condition32 = "(values[PRODUCT_OPPORTUNITY[CreatedDate]] > values[ACTIVITY[activity_datetime]] && values[PRODUCT_OPPORTUNITY[LATEST_REGISTRATION_DATE_TIME__c]] !== DATE_TODAY)";

String condition33 = "(values[PRODUCT_OPPORTUNITY[FIRST_QUALIFIED_DATE_TIME__c]] === null && (values[PRODUCT_OPPORTUNITY[STAGE__c]] === Repository || values[PRODUCT_OPPORTUNITY[STAGE__c]] === Presales Call Initiated || values[PRODUCT_OPPORTUNITY[STAGE__c]] === Presales Nurturing Phase || values[PRODUCT_OPPORTUNITY[STAGE__c]] === Lead Lost))";

List<String> conditions = new List<String>();
conditions.add(condition1);
conditions.add(condition2);
conditions.add(condition3);
conditions.add(condition4);
conditions.add(condition5);
conditions.add(condition6);
conditions.add(condition7);
conditions.add(condition8);
conditions.add(condition9);
conditions.add(condition10);
conditions.add(condition11);
conditions.add(condition12);
conditions.add(condition13);
conditions.add(condition14);
conditions.add(condition15);
conditions.add(condition16);
conditions.add(condition17);
conditions.add(condition18);
conditions.add(condition19);
conditions.add(condition20);
conditions.add(condition21);
conditions.add(condition22);
conditions.add(condition23);
conditions.add(condition24);
conditions.add(condition25);
conditions.add(condition26);
conditions.add(condition27);
conditions.add(condition28);
conditions.add(condition29);
conditions.add(condition30);
conditions.add(condition31);
conditions.add(condition32);
conditions.add(condition33);

// for (String condition : conditions) {
//     Boolean eligible = CustomConditionEvaluator.evaluateCustomCondition(values, condition);
//     System.debug('-->' + condition + '-->' + eligible);
// }

Boolean eligible = CustomConditionEvaluator.evaluateCustomCondition(values, condition33);
System.debug('-->' + 'condition33' + '-->' + eligible);