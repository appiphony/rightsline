public with sharing class Utilities {
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

    public static HttpResponse makeRightslineCallout(String endPoint, String httpMethod, String body) {
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

                    Utilities.Upsert_MDT_Value('Setup_Metadata__mdt.' + setupMetadata.Label, setupMetadata.Label,
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
    
    public static void Upsert_MDT_Value(string strMDTAndRecord, string strMasterLabel, LIST<string> fieldLIST, LIST<object> valueLIST) {
        // parameter passed should be the MDT.DeveloperName (i.e. MDT_Case_Webservice__mdt.Default_Get_SOQL)
        // If this is an update to an existing record, only send the applicable field(s) to be updated

        // Setup custom metadata to be created
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = strMDTAndRecord;
        customMetadata.label = strMasterLabel;
    
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        integer nIndex = 0;
        for (string strField : fieldLIST) {
            customField = new Metadata.CustomMetadataValue();
            customField.field = strField;
            customField.value = valueLIST[nIndex];
            customMetadata.values.add(customField);
            system.debug(customField);
            
            nIndex ++;
        } // END for (string strField : fieldLIST)
    
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
    
        // Setup deploy callback, MyDeployCallback implements
        // the Metadata.DeployCallback interface (code for
        // this class not shown in this example)
        MetadataDeploy_Callback callback = new MetadataDeploy_Callback();
    
        // Enqueue custom metadata deployment
        system.debug('Container: ' + mdContainer);
        if (!test.isRunningTest()) Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    } // END Upsert_MDT_Value
    
    public static void Upsert_MDT_Value(LIST<CustomMetadataType_DataType> CMDTLIST) {
        // parameter passed should be a LIST of Custom Metadata Type Datatype with the MDT.DeveloperName (i.e. MDT_Case_Webservice__mdt.Default_Get_SOQL)
        // If this is an update to an existing record, only send the applicable field(s) to be updated

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        integer nIndex = 0;
        for (CustomMetadataType_DataType cmdtItem : CMDTLIST) {
            customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = cmdtItem.strMDTAndRecord;
            customMetadata.label = cmdtItem.strMasterLabel;

            nIndex = 0;
            for (string strField : cmdtItem.fieldLIST) {
                customField = new Metadata.CustomMetadataValue();
                customField.field = strField;
                customField.value = cmdtItem.valueLIST[nIndex];
                customMetadata.values.add(customField);
                system.debug(customField);
                
                nIndex ++;
            } // END for (string strField : fieldLIST)
            system.debug(customMetadata);
            mdContainer.addMetadata(customMetadata);
        } // END for (CustomMetadataType_DataType cmdtItem : CMDTLIST) {

        // Setup deploy callback, MyDeployCallback implements
        // the Metadata.DeployCallback interface (code for
        // this class not shown in this example)
        MetadataDeploy_Callback callback = new MetadataDeploy_Callback();
    
        // Enqueue custom metadata deployment
        system.debug('Container: ' + mdContainer);
        if (!test.isRunningTest()) Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    } // END Upsert_MDT_Value
    
    public class MetadataDeploy_Callback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext callbackContext) {
            // Intentionally empty
            system.debug(result);
            system.debug(callbackContext);
        } // END handleResult
    } // END MetadataDeploy_Callback

    public class CustomMetadataType_DataType {
        /*
        Created By: Robert Nunemaker
        Created On: 07/31/2017
        Purpose: DataType to store Custom Metadata Types for APEX upload in bulk
        --------------------------------------------------------------------------
        Modified By:  
        Modified On:  
        Modification: 
        */

        public string strMDTAndRecord; 
        public string strMasterLabel;
        public LIST<string> fieldLIST = new LIST<string>();
        public LIST<object> valueLIST = new LIST<object>();
    
    }
}
