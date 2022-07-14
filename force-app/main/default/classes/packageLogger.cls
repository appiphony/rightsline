public virtual with sharing class packageLogger {
    public static void create(String message, String type, String location, String dump) {
        try {
            dmlManager.checkAccess(new Map<String, Map<String, Set<String>>> {
                'Package_Log__c' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                        'Dump__c', 'Location__c', 'Message__c', 'Type__c'
                    },
                    'Create' => new Set<String> {
                        'Dump__c', 'Location__c', 'Message__c', 'Type__c'
                    },
                    'Update' => new Set<String> {
                        'Dump__c', 'Location__c', 'Message__c', 'Type__c'
                    }
                }
            });
        } catch (Exception e) {
            return;
        }

        insert new Package_Log__c(
            Dump__c = dump.left(131072),
            Location__c = location,
            Message__c = message,
            Type__c = type);

        Integer dmlLimit = Limits.getLimitDMLRows() - Limits.getDMLRows();

        if (0 < dmlLimit) {
            delete [SELECT Id
                    FROM Package_Log__c
                    WHERE CreatedDate < LAST_N_DAYS:7
                    LIMIT :dmlLimit];
        }
    }

    public static void create(Exception e, Object self) {
        packageLogger.create(e, self, null);
    }

    public static void create(Exception e, Object self, String dump) {
        String classString = String.valueOf(self);
        String location = classString.left(classString.indexOf(':')) + ':' + String.valueOf(e.getLineNumber());

        if (null == dump) {
            dump = e.getStackTraceString();
        }

        packageLogger.create(
            e.getMessage(),
            e.getTypeName(),
            location,
            dump);
    }

    public class StrikeException extends Exception {
        public override String getStackTraceString() {
            return super.getCause().getStackTraceString();
        }
    }
}
