import { LightningElement, track, api } from 'lwc'
import getTempCreds from "@salesforce/apex/outboundConnectionStep.getTempCreds";
import clearCreds from "@salesforce/apex/outboundConnectionStep.clearCreds";
import getData from "@salesforce/apex/SetupAssistant.getData";
import saveData from "@salesforce/apex/SetupAssistant.saveData";

export default class outboundConnectionStep extends LightningElement {
    @track isComplete = false;
    loading = false;
    setupMetadata = {};

    @api
    show() {
        debugger;
        return new Promise((resolve, reject) => {
            getData().then(res => {
                let parsedRes = JSON.parse(res);
    
                if (parsedRes.isSuccess) {
                    this.setupMetadata = parsedRes.results.setupMetadata;
                    this.isComplete = this.setupMetadata.Access_Key__c == '********';
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

    authorize() {
        let apiKey = this.template.querySelector('.js-apiKey').value;
        let accessKey = this.template.querySelector('.js-accessKey').value;
        let secretKey = this.template.querySelector('.js-secretKey').value;

        if(!apiKey || !accessKey || !secretKey){
            this.showToast('error', 'Please fill in all required fields.');
            return;
        }

        let creds = {
            apiKey : apiKey,
            accessKey : accessKey,
            secretKey : secretKey
        };

        getTempCreds({
            jsonString : JSON.stringify(creds)
        }).then(res => {
            let parsedRes = JSON.parse(res);
            if (parsedRes.isSuccess) {
                this.isComplete = true;
                this.setupMetadata.Access_Key__c = '********';
                this.setupMetadata.Secret_Key__c = '********';
            } else {
                this.showToast('error', parsedRes.error);
                this.isComplete = false;
            }
        })
    }

    deauthorize() {
        clearCreds().then(res => {
            let parsedRes = JSON.parse(res);
            if (parsedRes.isSuccess) {
                this.isComplete = false;
                this.setupMetadata = {};
            } else {
                this.showToast('error', parsedRes.error);
                this.isComplete = true;
            }
        })
    }

    handleNext() {
        let setupMetadata = {
            Steps_Completed__c : JSON.stringify({'C-OUTBOUND-CONNECTION-STEP' : 1})
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
