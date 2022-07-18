public with sharing class debugLogStep {

    @AuraEnabled
    public static String initialCall() {
        ResponseData rd =  new ResponseData();
        try {
            Setup_Metadata__mdt setupMetadata = [SELECT Id, Label, Steps_Completed__c FROM Setup_Metadata__mdt WHERE Label = 'Default' LIMIT 1];

            Map<String, Object> stepsCompleted = new Map<String, Object>{
                'C-DEBUG-LOG-STEP' => 1
            };

            if (!String.isEmpty(setupMetadata.Steps_Completed__c)) {
                Map<String, Object> newStepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupMetadata.Steps_Completed__c);
                newStepsCompleted.putall(stepsCompleted);
                setupMetadata.Steps_Completed__c = JSON.serialize(newStepsCompleted);
            } else {
                setupMetadata.Steps_Completed__c = JSON.serialize(stepsCompleted);
            }

            utilities.Upsert_MDT_Value('Setup_Metadata__mdt.' + setupMetadata.Label,
                setupMetadata.Label,
                new LIST<string>{'Steps_Completed__c'},
                new LIST<object>{setupMetadata.Steps_Completed__c}
                );
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }
}