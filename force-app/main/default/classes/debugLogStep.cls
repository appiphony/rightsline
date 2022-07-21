public with sharing class debugLogStep {

    @AuraEnabled
    public static String executeDeleteBatch() {
        responseData rd = new responseData();
        try {
            Id jobId = Database.executeBatch(new batchDeletePackageLogs(), 2000);
            rd.put('jobId', jobId);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }
}