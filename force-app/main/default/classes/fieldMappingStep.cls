public with sharing class fieldMappingStep {

    @AuraEnabled
    public static String initialCall() {
        ResponseData rd =  new ResponseData();
        try {
            Setup_Metadata__mdt setupMetadata = [SELECT Id, Label, Steps_Completed__c FROM Setup_Metadata__mdt WHERE Label = 'Default' LIMIT 1];

            Map<String, Object> stepsCompleted = new Map<String, Object>{
                'C-FIELD-MAPPING-STEP' => 1
            };

            if (!String.isEmpty(setupMetadata.Steps_Completed__c)) {
                Map<String, Object> newStepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupMetadata.Steps_Completed__c);
                newStepsCompleted.putall(stepsCompleted);
                setupMetadata.Steps_Completed__c = JSON.serialize(newStepsCompleted);
            } else {
                setupMetadata.Steps_Completed__c = JSON.serialize(stepsCompleted);
            }

            Utilities.Upsert_MDT_Value('Setup_Metadata__mdt.' + setupMetadata.Label,
                setupMetadata.Label,
                new LIST<string>{'Steps_Completed__c'},
                new LIST<object>{setupMetadata.Steps_Completed__c}
                );
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getRightslineTemplates(){
        ResponseData rd = new ResponseData();
        try {
            HttpResponse response = Utilities.makeRightslineCallout('v4/contact-templates', 'GET', null);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                List<Object> responseList = (List<Object>)responseBody.get('templates');
                List<Object> templateList = new List<Object>();

                for (Object templateObject: responseList) {
                    Map<String, Object> templateMap = (Map<String, Object>)templateObject;
                    templateMap.remove('processId');
                    templateMap.remove('processName');
                    templateList.add(templateMap);
                }

                rd.put('templateList', templateList);
            } else {
                Map<String, Object> error = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                rd.addError((String)error.get('message'));
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }
}