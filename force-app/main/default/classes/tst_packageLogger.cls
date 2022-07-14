@isTest
public with sharing class tst_packageLogger {
    @isTest
    public static void testCreate() {
        String dump = 'dump test';

        Test.startTest();
        try {
            Object parsedJson = JSON.deserializeUntyped('bad json');
        } catch (Exception e) {
            packageLogger.create(e, null);
        }
        Test.stopTest();

        List<Package_Log__c> packageLogs = [SELECT Id FROM Package_Log__c];

        System.assertEquals(1, packageLogs.size());
    }
}
