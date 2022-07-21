public with sharing class utilities {
    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName) {
        return getSobjectByMap(sourceMap, sObjectName, constants.NAMESPACE_API);
    }

    /*
        Takes in a map and converts it into the specified sObject type.
        This function will strip away any keys that don't match a field on the sObject
        so you don't have to worry about it being dirty.
    */
    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName, String namespace) {
        if (!Schema.getGlobalDescribe().containsKey(sObjectName)) {
            if (Schema.getGlobalDescribe().containsKey(namespace + sObjectName)) {
                sObjectName = namespace + sObjectName;
            } else {
                return null;
            }
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        Map<String, Object> objMap = new Map<String, Object>();

        for (String field : sourceMap.keySet()) {
            String value = String.valueOf(sourceMap.get(field));

            //only retain the value if it exists on our object
            if (!fieldMap.containsKey(field)) {
                if (fieldMap.containsKey(namespace + field)) {
                    field = namespace + field;
                } else {
                    continue;
                }
            }

            objMap.put(field, String.isEmpty(value) ? null : value);
        }

        return (sObject)JSON.deserialize(JSON.serialize(objMap), Type.forName(sObjectName));
    }

    public static HttpResponse makeCallout(String endPoint, String httpMethod, String body) {
        Setup_Metadata__mdt setupMetadata = [SELECT Id, Label, Api_Key__c, Access_Key__c, Secret_Key__c, Session_Token__c, Temp_Access_Key__c, Temp_Secret_Key__c FROM Setup_Metadata__mdt WHERE Label = 'Default' LIMIT 1];

        AWSSignature aws = new AWSSignature();
        //aws.setAWS('eu-west-2','ec2','AddAYLS6VP5R5UI7D356I','ADE#9IcbnSSxcC5bsextZ1qqtkgS7elFz2IwZDA2KT');
        aws.setAWS('us-west-2', 'execute-api', setupMetadata.Temp_Access_Key__c, setupMetadata.Temp_Secret_Key__c);
        //aws.setUrl('patient.sysinfo.com','api/patient');
        aws.setUrl('ris.rightsline.com', endPoint);
        aws.setMethod(httpMethod);
        
        HttpRequest request = aws.createSigntaureRequest();
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-api-key', setupMetadata.Api_Key__c);
        request.setHeader('X-Amz-Security-Token', setupMetadata.Session_Token__c);

        if (body != null) {
            request.setBody(body);
        }

        HttpResponse response = new Http().send(request);
        
        //Retry callout if credentials are expired
        if (response.getStatusCode() == 403) {
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            String error = (String)bodyMap.get('message');
            if (error.contains('The security token included in the request is expired')) {
                HttpResponse credsResponse = tempCredsCallout(setupMetadata.Api_Key__c, setupMetadata.Access_Key__c, setupMetadata.Secret_Key__c);
                if (credsResponse.getStatusCode() == 200) {
                    Map<String, Object> credsResponseBody = (Map<String, Object>)JSON.deserializeUntyped(credsResponse.getBody());
                    aws.setAWS('us-west-2', 'execute-api', (String)credsResponseBody.get('accessKey'), (String)credsResponseBody.get('secretKey'));
                    HttpRequest retryRequest = aws.createSigntaureRequest();
                    retryRequest.setHeader('Content-Type','application/json');
                    retryRequest.setHeader('x-api-key', setupMetadata.Api_Key__c);
                    retryRequest.setHeader('X-Amz-Security-Token', (String)credsResponseBody.get('sessionToken'));

                    HttpResponse retryResponse = new Http().send(retryRequest);

                    utilities.upsertMetadata('Setup_Metadata__mdt.' + setupMetadata.Label, 
                                            setupMetadata.Label,
                                            new LIST<string>{'Session_Token__c', 
                                                            'Temp_Access_Key__c', 
                                                            'Temp_Secret_Key__c'},
                                            new LIST<object>{(String)credsResponseBody.get('sessionToken'), 
                                                            (String)credsResponseBody.get('accessKey'), 
                                                            (String)credsResponseBody.get('secretKey')}
                                            );
                    return retryResponse;
                } else {
                    return credsResponse;
                }
            }
        }
        return response;
    }

    public static HttpResponse tempCredsCallout(String apiKey, String accessKey, String secretKey) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://ris.rightsline.com/v4/auth/temporary-credentials');
        request.setMethod('POST');
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', apiKey);
        Map<String, String> body = new Map<String, String>();
        body.put('accessKey', accessKey);
        body.put('secretKey', secretKey);
        request.setBody(JSON.serialize(body));

        return new Http().send(request);
    }
    
    public static void upsertMetadata(String mdtFullName, String mdtLabel, List<String> fieldNameList, List<Object> fieldValueList) {
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = Constants.NAMESPACE_API + mdtFullName;
        customMetadata.label = mdtLabel;

        Integer index = 0;
        for(String fieldName : fieldNameList) {
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = Constants.NAMESPACE_API + fieldName;
            customField.value = fieldValueList[index];
            customMetadata.values.add(customField);
            index++;
        }

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        metadataCRUD callback = new metadataCRUD();

        if(!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }

    public class metadataCRUD implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug(' success : '+ result);
            } else {
                System.debug(' fail : '+ result);
            }
        }
    }
}
