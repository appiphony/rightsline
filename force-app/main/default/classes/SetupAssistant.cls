public with sharing class SetupAssistant {
    public String namespace { get; set; }

    public setupAssistant() {
        namespace = constants.NAMESPACE;
    }

    @AuraEnabled
    public static String getPackageVersion() {
        responseData rd = new responseData();
        
        try {
            rd.put('major', System.requestVersion().major());
            rd.put('minor', System.requestVersion().minor());
        } catch(Exception e) {
            rd.addError(e);
        }
        
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getData() {
        responseData rd = new responseData();

        try {
            checkAccess();

            List<AggregateResult> numPackageLogsList = [SELECT count(Id) packageLogCount FROM Package_Log__c];

            rd.put('setupMetadata', getSetupData());
            rd.put('currentLogRecordCount', numPackageLogsList[0].get('packageLogCount'));
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String saveData(Map<String, Object> setupMetadata) {
        responseData rd = new responseData();

        try {
            checkAccess();

            if (setupMetadata != null) {
                Setup_Metadata__mdt dataObj = (Setup_Metadata__mdt)utilities.getSobjectByMap(setupMetadata, constants.NAMESPACE_API + 'Setup_Metadata__mdt');
                saveSetupData(dataObj);
            }

            return getData();
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static Setup_Metadata__mdt getSetupData() {
        checkAccess();

        Set<String> fields = new Set<String>{'Id'};

        // Get all the custom fields.
        for (Schema.SObjectField field : Setup_Metadata__mdt.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                fields.add(fieldDescribe.getName());
            }
        }

        String query = 'SELECT ' + String.join(new List<String>(fields), ',') + 
                       ' FROM ' + constants.NAMESPACE_API + 'Setup_Metadata__mdt' + 
                       ' WHERE Label = \'Default\'';

        List<Setup_Metadata__mdt> data = Database.query(query);
        Setup_Metadata__mdt setupMetadata = new Setup_Metadata__mdt();

        if (!data.isEmpty()) {
            setupMetadata = data[0];
        }

        setupMetadata.Label = 'Default';

        if (String.isEmpty(setupMetadata.Steps_Completed__c)) {
            setupMetadata.Steps_Completed__c = '{}';
        }

        if (String.isNotEmpty(setupMetadata.Access_Key__c)) {
            setupMetadata.Access_Key__c = constants.BLUR_STRING;
            setupMetadata.Secret_Key__c = constants.BLUR_STRING;
            setupMetadata.Session_Token__c = constants.BLUR_STRING;
            setupMetadata.Temp_Access_Key__c = constants.BLUR_STRING;
            setupMetadata.Temp_Secret_Key__c = constants.BLUR_STRING;
        }
        System.debug(setupMetadata);
        return setupMetadata;
    }

    public static void saveSetupData(Setup_Metadata__mdt setupMetadata) {
        checkAccess();
        
        List<Setup_Metadata__mdt> data = [SELECT Id, Steps_Completed__c, Package_Log_Limit__c, Package_Log_Type__c
                                    FROM Setup_Metadata__mdt 
                                    WHERE Label = 'Default'];

        if (!data.isEmpty()) {
            // override id
            setupMetadata.Id = data[0].Id;

            // merge completed steps
            if (String.isNotEmpty(setupMetadata.Steps_Completed__c) && String.isNotEmpty(data[0].Steps_Completed__c)) {
                Map<String, Object> stepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(data[0].Steps_Completed__c);
                Map<String, Object> newStepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupMetadata.Steps_Completed__c);
                newStepsCompleted.putAll(stepsCompleted);
                setupMetadata.Steps_Completed__c = JSON.serialize(newStepsCompleted);
            }
        }

        // override name
        setupMetadata.Label = 'Default';

        utilities.upsertMetadata('Setup_Metadata__mdt.' + setupMetadata.Label, 
                                setupMetadata.Label,
                                new LIST<string>{'Steps_Completed__c', 
                                                'Package_Log_Limit__c',
                                                'Package_Log_Type__c'},
                                new LIST<object>{setupMetadata.Steps_Completed__c, 
                                                setupMetadata.Package_Log_Limit__c,
                                                setupMetadata.Package_Log_Type__c}
                                );
    }

    private static void checkAccess() {
        //
    }
}
