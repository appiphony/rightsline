import { LightningElement, api, track } from 'lwc'
import initialCall from '@salesforce/apex/debugLogStep.initialCall';

export default class DebugLogStep extends LightningElement {

    @track logLevel = 'DEBUG'
    @track logCount = 0
    @track logLimit = 10000

    get options() {
        return [
            { label: 'All Activity', value: 'DEBUG' },
            { label: 'Errors Only', value: 'ERROR' }
        ]
    }

    openConfirmationModal() {
        this.confirmationModal.show();
    }
    closeConfirmationModal() {
        this.confirmationModal.hide();
    }

    handleNext() {
        debugger;
        initialCall().then(res => {
            let parsedRes = JSON.parse(res);
            if (parsedRes.isSuccess) {
                //let results = responseData.results;
            } else {
                this.dispatchEvent(new CustomEvent('showtoast', {
                    detail: {
                        message : parsedRes.error,
                        variant : 'error'
                    },
                    bubbles: true,
                    composed: true
                }));
            }
        }).catch(error => {
            let message = error.message ? error.message : error.body.message;
            this.dispatchEvent(new CustomEvent('showtoast', {
                detail: {
                    message : message,
                    variant : 'error'
                },
                bubbles: true,
                composed: true
            }));
        });
    }
}