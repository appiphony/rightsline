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
        initialCall().then(response => {
            const responseData = JSON.parse(response);
            if (responseData.isSuccess) {
                let results = responseData.results;
            } else {
                //
            }

        }).catch(error => {
            const message = error.message ? error.message : error.body.message;
        });
    }
}