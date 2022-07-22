public with sharing class fieldMappingStep {

    @AuraEnabled
    public static String getData(){
        ResponseData rd = new ResponseData();
        try {
            HttpResponse response = utilities.makeCallout('v4/contact-templates', 'GET', null);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            if (response.getStatusCode() == 200) {
                List<Object> responseList = (List<Object>)responseBody.get('templates');
                List<Map<String, String>> templateList = new List<Map<String, String>>();

                for (Object templateObject: responseList) {
                    Map<String, Object> templateMap = (Map<String, Object>)templateObject;
                    templateList.add(new Map<String, String> {
                        'label' => String.valueOf(templateMap.get('templateName')),
                        'value' => String.valueOf(templateMap.get('templateId'))
                    });
                }

                rd.put('templateList', templateList);

                List<Map<String, String>> objList = new List<Map<String, String>>();

                for(Schema.SObjectType sObjType : Schema.getGlobalDescribe().values()){
                    Schema.DescribeSObjectResult describedSObj = sObjType.getDescribe();

                    if(describedSObj.getName() != constants.NAMESPACE_API + 'Setup_Metadata__mdt'
                        && describedSObj.getName() != constants.NAMESPACE_API + 'Contact_Mapping__mdt'
                        && describedSObj.getName() != constants.NAMESPACE_API + 'Package_Log__c'
                        && !describedSObj.getName().endsWith('__ka')
                        && !describedSObj.getName().endsWith('__kav')){

                        Map<String, String> objMap = new Map<String, String>();

                        objMap.put('label', describedSObj.getLabel());
                        objMap.put('value', describedSObj.getName());
                        objList.add(objMap);
                    }
                }

                rd.put('objList', objList);

                List<Contact_Mapping__mdt> contactMappingList = [SELECT Id, Label, Outbound_Mapping__c, Rightsline_Template_Id__c, Salesforce_Object__c, Salesforce_Object_Record_Type__c FROM Contact_Mapping__mdt WHERE Salesforce_Object__c != null];

                rd.put('contactMappingList', contactMappingList);
            } else {
                rd.addError((String)responseBody.get('message'));
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getRightslineFields(String templateId){
        ResponseData rd = new ResponseData();
        try {
            HttpResponse response = utilities.makeCallout('v4/contact-templates/' + templateId, 'GET', null);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            if (response.getStatusCode() == 200) {
                List<Object> responseList = (List<Object>)responseBody.get('fields');
                List<Map<String, Object>> fieldList = new List<Map<String, Object>>();

                for(Object field : responseList) {
                    Map<String, Object> fieldMap = (Map<String, Object>)field;
                    fieldList.add(new Map<String, Object> {
                        'label' => fieldMap.get('fieldName'),
                        'value' => fieldMap.get('label'),
                        'required' => fieldMap.get('required')
                    });
                }

                rd.put('templateFieldList', fieldList);
            } else {
                rd.addError((String)responseBody.get('message'));
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getSalesforceFields(String objName, Boolean getLookups) {
        responseData rd = new responseData();

        try{
            List<Map<String, Object>> fieldGroups = new List<Map<String, Object>>();
            List<Map<String, String>> loanFields = new List<Map<String, String>>();
            List<Map<String, String>> lookupObjs = new List<Map<String, String>>();
            List<Map<String, String>> recordTypeOptions = new List<Map<String,String>>();

            Schema.DescribeSObjectResult describedObj = Schema.describeSObjects(new List<String>{objName}).get(0);
            Map<String, Object> loanGroupOpt = new Map<String, Object>{
                'isOptGroup' => true,
                'label' => describedObj.getLabel(),
                'options' => new List<Map<String, String>>()
            };
            List<Schema.RecordTypeInfo> recordTypes = describedObj.getRecordTypeInfos();
            for(Schema.RecordTypeInfo recordType : recordTypes) {
                if(recordType.isActive() && recordType.isAvailable() && !recordType.isMaster()) {
                    recordTypeOptions.add(new Map<String, String> {
                        'label' => recordType.getName(),
                        'value' => recordType.getRecordTypeId()
                    });
                }
            }

            if(recordTypeOptions.isEmpty()) {
                recordTypeOptions.add(new Map<String, String> {
                    'label' => 'Default',
                    'value' => 'Default'
                });
            }

            fieldGroups.add(loanGroupOpt);

            List<String> leadLabelList = new List<String>();
            List<String> sortedLeadLabelList = new List<String>();

            for (Schema.SObjectField field : describedObj.fields.getMap().values()) {
                Schema.DescribeFieldResult describedField = field.getDescribe();

                if(describedField.isUpdateable() && describedField.isAccessible() && describedField.isCreateable()){
                    String fieldApiName = describedField.getName();

                    if(String.valueOf(describedField.getType()) != 'REFERENCE'){
                        Map<String, String> fieldMap = new Map<String, String> {
                            'label' => describedField.getLabel(),
                            'value' => fieldApiName,
                            'type' => String.valueOf(describedField.getType())
                        };

                        leadLabelList.add(fieldMap.get('label'));
                        sortedleadLabelList.add(fieldMap.get('label'));
                        loanFields.add(fieldMap);
                    }

                    if(String.valueOf(describedField.getType()) == 'REFERENCE' && !describedField.isNamePointing()){
                        Schema.DescribeSObjectResult parentObj = describedField.getReferenceTo().get(0).getDescribe(Schema.SObjectDescribeOptions.DEFERRED);

                        if(parentObj.getName() == objName){
                            continue;
                        }

                        Set<String> blackListedRefs = new Set<String>{'CreatedById', 'OwnerId', 'LastModifiedById'};
                        //collect lookup for possible coborrower mapping locations
                        if(getLookups && !blackListedRefs.contains(fieldApiName)){
                            Map<String, String> lookupObj = new Map<String, String> {
                                'label' => describedField.getLabel() + ' (' + parentObj.getLabel() + ')',
                                'value' => fieldApiName,
                                'relationName' => describedField.getRelationshipName(),
                                'lookupObject' => parentObj.getName()
                            };
                            lookupObjs.add(lookupObj);

                            List<Map<String, String>> parentFields = new List<Map<String, String>>();
                            Map<String, Object> parentGroup = new Map<String, Object>{
                                'isOptGroup' => true,
                                'label' => parentObj.getLabel() + ' - ' + describedField.getLabel(),
                                'options' => new List<Map<String, String>>()
                            };

                            List<String> labelList = new List<String>();
                            List<String> sortedLabelList = new List<String>();

                            for (Schema.SObjectField parentField : parentObj.fields.getMap().values()) {
                                Schema.DescribeFieldResult describedParentField = parentField.getDescribe();

                                if(describedParentField.isAccessible()){
                                    Map<String, String> parentFieldMap = new Map<String, String> {
                                        'label' => describedParentField.getLabel(),
                                        'value' => describedField.getRelationshipName() + '.' + describedParentField.getName(),
                                        'parentObjectApiName' => parentObj.getName(),
                                        'relationshipName' => describedField.getRelationshipName(),
                                        'fieldName' => describedField.getName(),
                                        'type' => String.valueOf(describedParentField.getType())
                                    };
                                    labelList.add(parentFieldMap.get('label'));
                                    sortedLabelList.add(parentFieldMap.get('label'));
                                    parentFields.add(parentFieldMap);

                                }
                            }

                            sortedLabelList.sort();
                            List<Map<String, String>> sortedParentFields = new List<Map<String, String>>();
                            for(String label : sortedLabelList) {
                                sortedParentFields.add(parentFields[labelList.indexOf(label)]);
                            }
                            
                            parentGroup.put('options', sortedParentFields);
                            fieldGroups.add(parentGroup);
                        }
                    }
                }
            }

            sortedLeadLabelList.sort();
            List<Map<String, String>> sortedLoanFields = new List<Map<String, String>>();
            for(String label : sortedLeadLabelList) {
                sortedLoanFields.add(loanfields[leadLabelList.indexOf(label)]);
            }
            loanGroupOpt.put('options', sortedLoanFields);

            rd.put('fields', fieldGroups);
            rd.put('lookupObjs', lookupObjs);
            rd.put('recordTypeOptions', recordTypeOptions);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonStringWithNamespace();
    }

    @AuraEnabled
    public static String saveContactMapping(String jsonString){
        ResponseData rd = new ResponseData();
        try {
            System.debug(jsonString);
            Map<String, Object> contactMappingMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String contactMappingLabel = (String)contactMappingMap.get('Label');
            String contactMappingDeveloperName = (String)contactMappingMap.get('DeveloperName');
            
            List<Contact_Mapping__mdt> contactMappingRecords = [SELECT Id, Label, DeveloperName FROM Contact_Mapping__mdt WHERE Label =:contactMappingLabel LIMIT 1];
            Contact_Mapping__mdt contactMapping;
            contactMapping = contactMappingRecords.isEmpty() ? new Contact_Mapping__mdt(Label = contactMappingLabel, DeveloperName = contactMappingDeveloperName) : contactMappingRecords[0];

            utilities.upsertMetadata('Contact_Mapping__mdt.' + contactMapping.DeveloperName,
                                        contactMapping.Label,
                                        new List<String>{'Outbound_Mapping__c', 
                                                        'Salesforce_Object__c', 
                                                        'Salesforce_Object_Record_Type__c', 
                                                        'Rightsline_Template_Id__c'},
                                        new List<Object>{contactMappingMap.get('Outbound_Mapping__c'), 
                                                        contactMappingMap.get('Salesforce_Object__c'), 
                                                        contactMappingMap.get('Salesforce_Object_Record_Type__c'), 
                                                        contactMappingMap.get('Rightsline_Template_Id__c')}
                                        );
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String deleteContactMapping(String contactMappingLabel){
        ResponseData rd = new ResponseData();
        try {
            Contact_Mapping__mdt contactMappingRecord = [SELECT Id, Label, DeveloperName FROM Contact_Mapping__mdt WHERE Label =:contactMappingLabel];

            utilities.upsertMetadata('Contact_Mapping__mdt.' + contactMappingRecord.DeveloperName,
                                        contactMappingLabel,
                                        new LIST<string>{'Outbound_Mapping__c', 
                                                        'Salesforce_Object__c', 
                                                        'Salesforce_Object_Record_Type__c', 
                                                        'Rightsline_Template_Id__c'},
                                        new LIST<object>{null,
                                                        null,
                                                        null,
                                                        null}
                                        );
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }
}
