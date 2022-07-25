public with sharing class syncSchedulerStep {

    @AuraEnabled
    public static String getScheduledApexJobList() {
        ResponseData rd = new ResponseData();
        try {
            List<CronTrigger> scheduledJobList = [SELECT Id, FORMAT(NextFireTime) nextFireTime, CronJobDetail.Name 
                                                FROM CronTrigger 
                                                WHERE NextFireTime != null 
                                                ORDER BY NextFireTime];
            
            List<Map<String,Object>> scheduledJobMapList = new List<Map<String,Object>>();

            for (CronTrigger scheduledJob : scheduledJobList) {
                scheduledJobMapList.add(new Map<String, Object> {
                    'id' => scheduledJob.Id,
                    'name' => scheduledJob.CronJobDetail.Name,
                    'nextFireTime' => scheduledJob.nextFireTime
                });
            }

            rd.put('scheduledJobMapList', scheduledJobMapList);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String scheduleInitialContactSyncJob(String syncTime) {
        ResponseData rd = new ResponseData();
        try {
            //
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }
}