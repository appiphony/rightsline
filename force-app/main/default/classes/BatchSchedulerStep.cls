public with sharing class BatchSchedulerStep {
    private static final String SETUP_STEP_NAME = 'C-BATCH-SCHEDULER-STEP';
    private static final String SCHEDULED_JOB_NAME = 'Scheduled Job'; //TODO: update name based on client

    @AuraEnabled
    public static String getData() {
        ResponseData rd = new ResponseData();

        try{
            DmlManager.checkAccess(getDataAccess);

            Setup_Data__c setupData = SetupAssistant.getSetupData();
            rd.put('jobId', setupData.Scheduled_Job_Id__c);
            rd.put('jobFrequency', setupData.Scheduled_Job_Frequency__c);
            rd.put('jobStartTime', setupData.Scheduled_Job_Start_Time__c);

            List<CronTrigger> otherJobs = [SELECT Id, FORMAT(NextFireTime) nextFireTime, CronJobDetail.Name
                                           FROM CronTrigger
                                           WHERE Id != :setupData.Scheduled_Job_Id__c
                                           AND NextFireTime != null
                                           ORDER BY NextFireTime];

            List<CronTrigger> syncJob = [SELECT FORMAT(NextFireTime) nextFireTime
                                         FROM CronTrigger
                                         WHERE Id = :setupData.Scheduled_Job_Id__c];

            String nextFireTime;
            if(!syncJob.isEmpty()) {
                nextFireTime = (String)syncJob.get(0).get('nextFireTime');
            }

            rd.put('otherJobs', otherJobs);
            rd.put('nextFireTime', nextFireTime);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String scheduleJob(String params) {
        ResponseData rd = new ResponseData();

        try{
            DmlManager.checkAccess(scheduleJobAccess);

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(params);

            String jobFrequency = (String)parsedParams.get('jobFrequency');
            String jobStartTime = (String)parsedParams.get('jobStartTime');

            String cronString;

            if(jobFrequency == 'daily') {
                //Daily at job start time
                cronString = '0 0 ' + jobStartTime + ' * * ?';
            } else {
                //schedule ASAP
                DateTime now = DateTime.now();
                Integer startHour = now.hour();
                Integer startMinute = now.minute() + 1;

                if(now.second() > 55) {
                    //bump to next minute if within 5 seconds of end of current minute
                    startMinute += 1;
                }

                if(startMinute >= 60) {
                    //bump to next hour if start minute >= 60
                    startMinute = startMinute - 60;
                    startHour += 1;
                }

                String hrCron = Math.mod(startHour, Integer.valueOf(jobFrequency)) + '/' + jobFrequency;

                cronString = '0 ' + startMinute + ' ' + hrCron + ' * * ?';
            }

            //schedule job
            String jobId = System.schedule(SCHEDULED_JOB_NAME, cronString, new ScheduledJobExecutor());

            //update setup with job info and mark step complete
            Setup_Data__c setupData = SetupAssistant.getSetupData();
            setupData.Scheduled_Job_Id__c = jobId;
            setupData.Scheduled_Job_Frequency__c = jobFrequency;
            setupData.Scheduled_Job_Start_Time__c = jobStartTime;

            Map<String, Object> stepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupData.Steps_Completed__c);
            stepsCompleted.put(SETUP_STEP_NAME, 1);
            setupData.Steps_Completed__c = JSON.serialize(stepsCompleted);

            upsert setupData;

            CronTrigger syncJob = [SELECT FORMAT(NextFireTime) nextFireTime
                                   FROM CronTrigger
                                   WHERE Id = :jobId];

            rd.put('nextFireTime', (String)syncJob.get('nextFireTime'));
            rd.put('jobId', jobId);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String cancelJob() {
        ResponseData rd = new ResponseData();

        try{
            DmlManager.checkAccess(cancelJobAccess);

            Setup_Data__c setupData = SetupAssistant.getSetupData();

            //abort job
            System.abortJob(setupData.Scheduled_Job_Id__c);

            //null out job id field on setup
            setupData.Scheduled_Job_Id__c = null;

            //mark step incomplete
            Map<String, Object> stepsCompleted = (Map<String, Object>)JSON.deserializeUntyped(setupData.Steps_Completed__c);
            stepsCompleted.remove(SETUP_STEP_NAME);
            setupData.Steps_Completed__c = JSON.serialize(stepsCompleted);

            update setupData;
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }


    /********** Access Check Maps **********/

    private static FINAL Map<String, Map<String, Set<String>>> getDataAccess = new  Map<String, Map<String, Set<String>>>{
        'CronTrigger' => new Map<String, Set<String>>{
            'Read' => new Set<String>{
                'Id', 'NextFireTime'
            }
        },
        'CronJobDetail' => new Map<String, Set<String>>{
            'Read' => new Set<String>{
                'Name'
            }
        }
    };

    private static FINAL Map<String, Map<String, Set<String>>> scheduleJobAccess = new  Map<String, Map<String, Set<String>>>{
        'Setup_Data__c' => new Map<String, Set<String>>{
            'Create' => new Set<String>{
                'Scheduled_Job_Id__c', 'Scheduled_Job_Frequency__c', 
                'Scheduled_Job_Start_Time__c', 'Steps_Completed__c'
            },
            'Update' => new Set<String>{
                'Scheduled_Job_Id__c', 'Scheduled_Job_Frequency__c', 
                'Scheduled_Job_Start_Time__c', 'Steps_Completed__c'
            }
        },
        'CronTrigger' => new Map<String, Set<String>>{
            'Read' => new Set<String>{
                'Id', 'NextFireTime'
            }
        }
    };

    private static FINAL Map<String, Map<String, Set<String>>> cancelJobAccess = new  Map<String, Map<String, Set<String>>>{
        'Setup_Data__c' => new Map<String, Set<String>>{
            'Update' => new Set<String>{
                'Scheduled_Job_Id__c', 'Steps_Completed__c'
            }
        },
        'CronJobDetail' => new Map<String, Set<String>>{
            'Read' => new Set<String>{
                'Name'
            }
        }
    };
}