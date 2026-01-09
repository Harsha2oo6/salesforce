public with sharing class EligibilityController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getValuesPayload() {

        // ACTIVITY values
        // These values are chosen so that all JSON conditions for ACTIVITY
        // (e.g. SESSION_ATTENDED_DURATION_MIN > 30 and activity_datetime comparisons)
        // can evaluate to true.
        Map<String, Object> activity = new Map<String, Object>{
            'highest_qualification'        => 'Graduation (Ongoing)',
            'SESSION_ATTENDED_DURATION_MIN'=> 45,
            'activity_datetime'            => '2026-01-01T10:00:00Z',

            // Sample Date fields for testing standard literals like TODAY / TOMORROW
            'activity_date'                => Date.today(),
            'future_activity_date'         => Date.today().addDays(1),
            'activity_date_next_month'     => Date.today().addMonths(1),
            'activity_date_next_year'      => Date.today().addYears(1)
        };

        // PRODUCT_OPPORTUNITY values
        // These values are chosen so that all JSON conditions for PRODUCT_OPPORTUNITY
        // (Stage__c checks, first/latest qualified fields, nurturing channel, etc.)
        // can evaluate to true.
        Map<String, Object> productOpportunity = new Map<String, Object>{
            'highest_qualification'            => 'Diploma',
            'expected_graduation_year'         => 2026,

            // Stage__c should NOT be any of:
            // 'NAT Initiated', 'Exam Fee Paid', 'Exam Slot Booked',
            // 'Exam Not Attended', 'Exam Attended Not Qualified'
            'Stage__c'                         => 'Qualified',

            // For custom conditions where these must be null initially
            'First_Qualified_Date_Time__c'     => null,
            'First_Qualified_Cycle__c'         => null,

            // Can be any valid values; included for completeness
            'Latest_Approached_Date_time'      => '2025-12-31T09:00:00Z',
            'first_Approached_Date_time'       => '2025-12-01T09:00:00Z',
            'Latest_Qualified_Date_Time__c'    => null,
            'Latest_Qualified_Cycle'           => '2026-CYCLE-1',

            // To satisfy activity_datetime !== Session_Attended_on
            'Session_Attended_on'              => '2026-01-02T10:00:00Z',

            // For conditions expecting this to be null
            'Nurturing_Channel'                => null,

            // For opportunity_stage_update_conditions
            'Presales_Lead_Type__c'           => 'Non-NAT Lead',

            // Sample Date field for testing THISYEAR / THISMONTH
            'Application_Date__c'             => DateTime.now(),

            // Example count value (not constrained by conditions themselves)
            'Lead_Approached_Count__c'        => 1
        };

        Map<String, Object> values = new Map<String, Object>{
            'ACTIVITY' => activity,
            'PRODUCT_OPPORTUNITY' => productOpportunity
        };

        return values;
    }
}