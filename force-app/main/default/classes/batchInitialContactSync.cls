public with sharing class batchInitialContactSync {
}
/*global with sharing class batchInitialContactSync implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        checkAccess();

        List<Contact_Mapping__mdt> contactMappingList = [SELECT Id, Outbound_Mapping__c, Rightsline_Template_Id__c, Salesforce_Object__c, Salesforce_Object_Record_Type__c FROM Contact_Mapping__mdt WHERE Salesforce_Object__c != null];

        //List<List<SObject>> syncRecordLists = new List<List<SObject>>();
        List<sObject> sfRecordObjectList = new List<sObject>();
        sfRecordObjectList.addAll(contactMappingList);
        //syncRecordLists.add(contactMappingList);

        for (Contact_Mapping__mdt contactMap : contactMappingList) {
            List<String> sfFieldList = new List<String>();
            List<Object> fieldObjectList = (List<Object>)JSON.deserializeUntyped(contactMap.Outbound_Mapping__c);
            String queryString = 'SELECT Id';

            for (Object fieldObject : fieldObjectList) {
                Map<String,Object> fieldMap = (Map<String,Object>)fieldObject;

                if (String.isNotEmpty((String)fieldMap.get('sfField'))) {
                    if (!sfFieldList.contains((String)fieldMap.get('sfField'))) {
                        sfFieldList.add((String)fieldMap.get('sfField'));
                        queryString += ', ' + (String)fieldMap.get('sfField');
                    }
                    System.debug(queryString);
                }
            }

            queryString += ' FROM ' + contactMap.Salesforce_Object__c;
            System.debug(queryString);
            System.debug(Database.query(queryString));

            sfRecordObjectList.addAll(Database.query(queryString));
            //syncRecordLists.add(sfRecordObjectList);
        }

        //return syncRecordLists;
        return sfRecordObjectList;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        AggregateResult ar = [SELECT count(Id) packageLogCount FROM Package_Log__c];
        if((Integer)ar.get('packageLogCount') > 0) {
            Database.executeBatch(new batchDeletePackageLogs(), 2000);
        }
    }

    private static Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
        'Package_Log__c' => new Map<String, Set<String>> {
            'Create' => new Set<String> {
                'Id, Dump__c, isRetryLog__c, Location__c, Message__c, Object_Api_Name__c, Operation__c, Record_Id__c, Type__c'
            },
            'Read' => new Set<String> {
                'Id, Dump__c, isRetryLog__c, Location__c, Message__c, Object_Api_Name__c, Operation__c, Record_Id__c, Type__c'
            }
        }
    };

    private static void checkAccess(){
        DmlManager.checkAccess(accessChecks);
    }
}*/
