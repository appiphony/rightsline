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
