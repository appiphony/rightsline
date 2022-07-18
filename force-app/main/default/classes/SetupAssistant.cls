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

            Setup_Settings__c settings = Setup_Settings__c.getOrgDefaults();
            for (Schema.SObjectField field : Setup_Settings__c.sObjectType.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (fieldDescribe.isCustom()) {
                    String fieldName = fieldDescribe.getName();

                    if (null != settings.get(fieldName)) {
                        settings.put(fieldName, constants.BLUR_STRING);
                    }
                }
            }

            rd.put('setupMetadata', getSetupData());
            rd.put('setupSettings', settings);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String saveData(Map<String, Object> setupData, Map<String, Object> setupSettings) {
        responseData rd = new responseData();

        try {
            checkAccess();

            if (setupData != null) {
                Setup_Data__c dataObj = (Setup_Data__c)utilities.getSobjectByMap(setupData, constants.NAMESPACE_API + 'Setup_Data__c');
                saveSetupData(dataObj);
            }

            if (setupSettings != null) {
                for (String field : setupSettings.keySet()) {
                    if (constants.BLUR_STRING == setupSettings.get(field)) {
                        setupSettings.remove(field);
                    }
                }
                Setup_Settings__c settingsObj = (Setup_Settings__c)utilities.getSobjectByMap(setupSettings, constants.NAMESPACE_API + 'Setup_Settings__c');
                settingsObj.Id = Setup_Settings__c.getOrgDefaults().Id;

                upsert settingsObj;
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

        return setupMetadata;
    }

    public static void saveSetupData(Setup_Data__c setupData) {
        checkAccess();
        
        List<Setup_Data__c> data = [SELECT Id, Steps_Completed__c 
                                    FROM Setup_Data__c 
                                    WHERE Name = 'Default'];

        if (!data.isEmpty()) {
            // override id
            setupData.Id = data[0].Id;

            // merge completed steps
            if (String.isNotEmpty(setupData.Steps_Completed__c) && String.isNotEmpty(data[0].Steps_Completed__c)) {
                Map<String, Object> stepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(data[0].Steps_Completed__c);
                Map<String, Object> newStepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupData.Steps_Completed__c);
                newStepsCompleted.putAll(stepsCompleted);
                setupData.Steps_Completed__c = JSON.serialize(newStepsCompleted);
            }
        }

        // override name
        setupData.Name = 'Default';

        upsert setupData;
    }

    private static void checkAccess() {
        Set<String> dataReadFields = new Set<String>();
        Set<String> dataUpdateFields = new Set<String>();

        for (Schema.SObjectField field : Setup_Data__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                if (fieldDescribe.isAccessible()) {
                    dataReadFields.add(fieldDescribe.getName());
                }
                if (fieldDescribe.isUpdateable()) {
                    dataUpdateFields.add(fieldDescribe.getName());
                }
            }
        }

        dataReadFields.add('Name');
        dataUpdateFields.add('Name');

        Set<String> settingsReadFields = new Set<String>();
        Set<String> settingsUpdateFields = new Set<String>();

        for (Schema.SObjectField field : Setup_Settings__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                if (fieldDescribe.isAccessible()) {
                    settingsReadFields.add(fieldDescribe.getName());
                }
                if (fieldDescribe.isUpdateable()) {
                    settingsUpdateFields.add(fieldDescribe.getName());
                }
            }
        }

        settingsReadFields.add('Name');
        settingsUpdateFields.add('Name');

        DmlManager.checkAccess(new Map<String, Map<String, Set<String>>> {
            'Setup_Data__c' => new Map<String, Set<String>> {
                'Read' => dataReadFields,
                'Create' => dataUpdateFields,
                'Update' => dataUpdateFields
            },
            'Setup_Settings__c' => new Map<String, Set<String>> {
                'Read' => settingsReadFields,
                'Create' => settingsUpdateFields,
                'Update' => settingsUpdateFields
            }
        });
    }
}
