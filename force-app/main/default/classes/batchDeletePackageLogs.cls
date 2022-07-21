global with sharing class batchDeletePackageLogs implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        checkAccess();

        return Database.getQueryLocator([SELECT Id FROM Package_Log__c LIMIT 50000000]);
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
            'Read' => new Set<String> {
                'Id'
            },
            'Delete' => new Set<String>()
        }
    };

    private static void checkAccess(){
        DmlManager.checkAccess(accessChecks);
    }
}