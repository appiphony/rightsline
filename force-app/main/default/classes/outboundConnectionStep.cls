public with sharing class outboundConnectionStep {

    @AuraEnabled
    public static String getTempCreds(String jsonString) {
        ResponseData rd =  new ResponseData();
        try {
            Map<String, Object> credsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String apiKey = (String)credsMap.get('apiKey');
            String accessKey = (String)credsMap.get('accessKey');
            String secretKey = (String)credsMap.get('secretKey');

            HttpResponse response = utilities.tempCredsCallout(apiKey, accessKey, secretKey);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                String sessionToken = (String)responseBody.get('sessionToken');
                String tempAccessKey = (String)responseBody.get('accessKey');
                String tempSecretKey = (String)responseBody.get('secretKey');

                List<Setup_Metadata__mdt> setupMetadataRecords = [SELECT Id, Label, Steps_Completed__c FROM Setup_Metadata__mdt WHERE Label = 'Default' LIMIT 1];
                Setup_Metadata__mdt setupMetadata;
                setupMetadata = setupMetadataRecords.isEmpty() ? new Setup_Metadata__mdt(Label = 'Default') : setupMetadataRecords[0];

                utilities.upsertMetadata('Setup_Metadata__mdt.' + setupMetadata.Label,
                                            setupMetadata.Label,
                                            new LIST<string>{'Api_Key__c', 
                                                            'Access_Key__c', 
                                                            'Secret_Key__c', 
                                                            'Session_Token__c', 
                                                            'Temp_Access_Key__c', 
                                                            'Temp_Secret_Key__c'},
                                            new LIST<object>{apiKey, 
                                                            accessKey, 
                                                            secretKey, 
                                                            sessionToken, 
                                                            tempAccessKey, 
                                                            tempSecretKey}
                                            );
            } else {
                rd.addError('Invalid Credentials');
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String clearCreds() {
        ResponseData rd = new ResponseData();
        try {
            Setup_Metadata__mdt setupMetadata = [SELECT Id, Label FROM Setup_Metadata__mdt WHERE Label = 'Default' LIMIT 1];

            utilities.upsertMetadata('Setup_Metadata__mdt.' + setupMetadata.Label,
                                    setupMetadata.Label,
                                    new LIST<string>{'Api_Key__c', 
                                                    'Access_Key__c', 
                                                    'Secret_Key__c', 
                                                    'Session_Token__c', 
                                                    'Temp_Access_Key__c', 
                                                    'Temp_Secret_Key__c'},
                                    new LIST<object>{'', 
                                                    '', 
                                                    '', 
                                                    '', 
                                                    '', 
                                                    ''}
                                    );
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }
}