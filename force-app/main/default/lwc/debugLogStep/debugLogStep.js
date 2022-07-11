import { LightningElement, api, track } from 'lwc'

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
}