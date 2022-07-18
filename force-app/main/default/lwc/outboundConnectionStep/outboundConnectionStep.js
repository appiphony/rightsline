import { LightningElement, track, api } from 'lwc'
import getTempCreds from "@salesforce/apex/outboundConnectionStep.getTempCreds";
import clearCreds from "@salesforce/apex/outboundConnectionStep.clearCreds";
import getData from "@salesforce/apex/SetupAssistant.getData";

export default class outboundConnectionStep extends LightningElement {
    @track isComplete = false;
    loading = false;
    setupMetadata = {};

    connectedCallback() {
        debugger;
        getData().then(res => {
            debugger;
            let parsedRes = JSON.parse(res);

            if (parsedRes.isSuccess) {
                debugger;
                this.setupMetadata = parsedRes.results.setupMetadata;
                this.isComplete = this.setupMetadata.Access_Key__c == '********';
            } else {
                //
            }
        })
    }

    valueChanged() {
        //
    }

    authorize() {
        debugger;
        let apiKey = this.template.querySelector('.js-apiKey').value;
        let accessKey = this.template.querySelector('.js-accessKey').value;
        let secretKey = this.template.querySelector('.js-secretKey').value;

        if(!apiKey || !accessKey || !secretKey){
            this.dispatchEvent(new CustomEvent('showtoast', {
                detail: {
                    message : 'Please fill in all required fields',
                    variant : 'error'
                },
                bubbles: true,
                composed: true
            }));
            //error toast
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
            debugger;
            if (parsedRes.isSuccess) {
                this.isComplete = true;
                //success toast
            } else {
                this.dispatchEvent(new CustomEvent('showtoast', {
                    detail: {
                        message : parsedRes.error,
                        variant : 'error'
                    },
                    bubbles: true,
                    composed: true
                }));
                this.isComplete = false;
                //error toast
            }
        })
    }

    deauthorize() {
        debugger;

        clearCreds().then(res => {
            let parsedRes = JSON.parse(res);
            debugger;
            if (parsedRes.isSuccess) {
                this.isComplete = false;
                //success toast
            } else {
                this.dispatchEvent(new CustomEvent('showtoast', {
                    detail: {
                        message : parsedRes.error,
                        variant : 'error'
                    },
                    bubbles: true,
                    composed: true
                }));
                this.isComplete = true;
                //error toast
            }
        })
    }

    handleNext() {
        debugger;
    }
}
