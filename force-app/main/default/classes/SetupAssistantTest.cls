@isTest
public with sharing class SetupAssistantTest {
    @isTest
    static public void testSetupAssistant() {
        Test.startTest();
        SetupAssistant sa = new SetupAssistant();
        Test.stopTest();

        System.assertEquals(Constants.NAMESPACE, sa.namespace);
    }

    /*@isTest
    static public void saveData() {
        Test.startTest();
        String response = SetupAssistant.saveData(new Map<String, Object>(), new Map<String, Object>());
        Test.stopTest();

        List<Setup_Data__c> newData = [SELECT Id, Name FROM Setup_Data__c];
        System.assert(0 < newData.size(), '`data` not found');
        System.assert(2 > newData.size(), 'multiple `data` found');

        System.assertEquals('Default', newData.get(0).Name);

        System.assert(null != Setup_Settings__c.getOrgDefaults(), '`settings` not found');
    }

    @isTest
    static public void getData() {
        SetupAssistant.saveData(new Map<String, Object>(), new Map<String, Object>());

        Test.startTest();
        String response = SetupAssistant.getData();
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));

        Map<String, Object> resultsMap = (Map<String, Object>)responseMap.get('results');
        System.assert(resultsMap.containsKey('setupData'), '`data` not found');
        System.assert(resultsMap.containsKey('setupSettings'), '`settings` not found');
    }*/
}
