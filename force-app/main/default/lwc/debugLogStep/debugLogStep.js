import { LightningElement, api, track } from 'lwc'
import executeDeleteBatch from '@salesforce/apex/debugLogStep.executeDeleteBatch';
import getData from '@salesforce/apex/setupAssistant.getData';
import saveData from '@salesforce/apex/setupAssistant.saveData';

export default class DebugLogStep extends LightningElement {

    @track logType = 'errorsOnly';
    @track currentLogRecordCount = 0;
    @track logLimit = 10000;
    @track isLoading = false;
    

    @track logTypeOptions = [
        {
            label:'Errors Only',
            value:'errorsOnly'
        },
        {
            label:'All Activity',
            value:'allActivity'
        }
    ];

    @api
    show() {
        debugger;
        return new Promise((resolve, reject) => {
            getData().then(res => {
                let parsedRes = JSON.parse(res)
                if(parsedRes.isSuccess) {
                    let setupMetadata = parsedRes.results.setupMetadata;
                    debugger;
                    this.currentLogRecordCount = parsedRes.results.currentLogRecordCount;
                    if(setupMetadata.Package_Log_Limit__c) {
                        this.logLimit = setupMetadata.Package_Log_Limit__c;
                        this.logType = setupMetadata.Package_Log_Type__c;
                    } else {
                        this.logLimit = 10000;
                        this.logType = 'allActivity';
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

    changeLogType(event) {
        this.logType = event.currentTarget.value;
    }

    changeLogLimit(event) {
        this.logLimit = event.currentTarget.value;
    }

    handleNext() {
        debugger;
        let setupMetadata = {
            Steps_Completed__c : JSON.stringify({'C-DEBUG-LOG-STEP' : 1}),
            Package_Log_Limit__c: this.logLimit,
            Package_Log_Type__c: this.logType
        }

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

    handleDeleteLogModal(event) {
        let currentClick = event.currentTarget.label;
        if (currentClick === 'Delete All') {
            this.template.querySelector('c-modal').show();
        } else {
            if (currentClick === 'Confirm') {
                executeDeleteBatch().then(res => {
                    let parsedRes = JSON.parse(res);
                    if (parsedRes.isSuccess) {
                        this.showToast('success', 'Deletion batch job has been queued.');
                    } else {
                        this.showToast('error', parsedRes.error);
                    }
                }).catch(error => {
                    this.showToast('error', error.message ? error.message : error.body.message);
                });
                this.currentLogRecordCount = 0;
            }
            this.template.querySelector('c-modal').hide();
        }
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