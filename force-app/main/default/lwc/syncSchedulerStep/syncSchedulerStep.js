import { LightningElement, api, track, wire } from 'lwc';
import saveData from "@salesforce/apex/SetupAssistant.saveData";
import getScheduledApexJobList from "@salesforce/apex/syncSchedulerStep.getScheduledApexJobList";
import scheduleInitialContactSyncJob from "@salesforce/apex/syncSchedulerStep.scheduleInitialContactSyncJob";


export default class syncSchedulerStep extends LightningElement {

    @track modalTitle;
    @track modalButtonVariant;
    @track modalButtonLabel;
    @track isActive = false;
    @track syncTime = '';
    @track scheduledJobList = [];
    @track scheduledJobsListEmpty = true;

    openBatchModal() {
        if(this.isActive) {
            this.modalTitle = 'Deactivate Job';
            this.modalButtonVariant = 'destructive'
            this.modalButtonLabel = 'Deactivate'
        } else {
            this.modalTitle = 'Activate Job';
            this.modalButtonVariant = 'brand'
            this.modalButtonLabel = 'Activate'
        }
        this.template.querySelector('.batchModal').show();
    }

    confirmBatchModal(event) {
        this.template.querySelector('.batchModal').hide();
        this.isActive = true;
    }

    get options() {
        return [
            {
                label: 'Select an option',
                value: '',
                disabled: true
            },
            {
                label: 'Run Job Now',
                value: 'now'
            },
            {
                label: '12:00 AM',
                value: '00:00:00'
            },
            {
                label: '1:00 AM',
                value: '01:00:00'
            },
            {
                label: '2:00 AM',
                value: '02:00:00'
            },
            {
                label: '3:00 AM',
                value: '03:00:00'
            },
            {
                label: '4:00 AM',
                value: '04:00:00'
            },
            {
                label: '5:00 AM',
                value: '05:00:00'
            },
            {
                label: '6:00 AM',
                value: '06:00:00'
            },
            {
                label: '7:00 AM',
                value: '07:00:00'
            },
            {
                label: '8:00 AM',
                value: '08:00:00'
            },
            {
                label: '9:00 AM',
                value: '09:00:00'
            },
            {
                label: '10:00 AM',
                value: '10:00:00'
            },
            {
                label: '11:00 AM',
                value: '11:00:00'
            },
            {
                label: '12:00 PM',
                value: '12:00:00'
            },
            {
                label: '1:00 PM',
                value: '13:00:00'
            },
            {
                label: '2:00 PM',
                value: '14:00:00'
            },
            {
                label: '3:00 PM',
                value: '15:00:00'
            },
            {
                label: '4:00 PM',
                value: '16:00:00'
            },
            {
                label: '5:00 PM',
                value: '17:00:00'
            },
            {
                label: '6:00 PM',
                value: '18:00:00'
            },
            {
                label: '7:00 PM',
                value: '19:00:00'
            },
            {
                label: '8:00 PM',
                value: '20:00:00'
            },
            {
                label: '9:00 PM',
                value: '21:00:00'
            },
            {
                label: '10:00 PM',
                value: '22:00:00'
            },
            {
                label: '11:00 PM',
                value: '23:00:00'
            }
        ]
    }

    @track otherJobs = [
        {
            Id: 1,
            Name: 'Error Retry Job',
            nextFireTime: '12:00 AM',
        }
    ]

    updateValue(event){
        let value = event.detail.value;

        this.syncTime = value;
    }

    @api
    show() {
        debugger;
        return new Promise((resolve, reject) => {
            getScheduledApexJobList().then(res => {
                debugger;
                let parsedRes = JSON.parse(res);
                if (parsedRes.isSuccess) {
                    if (parsedRes.scheduledJobMapList) {
                        this.scheduledJobsListEmpty = false;
                        for (let i = 0; i < parsedRes.scheduledJobMapList.length; i++) {
                            this.scheduledJobList.add(parsedRes.scheduledJobMapList.scheduledJobMapList[i]);
                        }
                    } else {
                        this.scheduledJobsListEmpty = true;
                    }
                } else {
                    this.showToast('error', parsedRes.error);
                }
            }).catch(error => {
                this.showToast('error', error.message ? error.message : error.body.message);
            }).finally(() => {
                resolve()
            })
        })
    }

    scheduleInitialContactSyncJob() {
        scheduleInitialContactSyncJob({syncTime:syncTime}).then(res => {
            debugger;
            let parsedRes = JSON.parse(res)
            if (parsedRes.isSuccess) {
                //
            } else {
                this.showToast('error', parsedRes.error);
            }
        }).catch(error => {
            this.showToast('error', error.message ? error.message : error.body.message);
        })
    }

    handleNext() {
        debugger;
        let setupMetadata = {
            Steps_Completed__c : JSON.stringify({'C-EDITOR-CONFIG-STEP' : 1,'C-SYNC-SCHEDULER-STEP' : 1})
        };

        saveData({setupMetadata:setupMetadata}).then(res => {
            let parsedRes = JSON.parse(res);
            if (parsedRes.isSuccess) {
                //let results = responseData.results;
            } else {
                this.showToast('error', parsedRes.error);
            }
        }).catch(error => {
            this.showToast('error', error.message ? error.message : error.body.message);
        });
    }

    showToast(type, message) {
        this.dispatchEvent(new CustomEvent('showtoast', {
            detail: {
                message : message,
                variant : type
            },
            bubbles: true,
            composed: true
        }));
    }
}