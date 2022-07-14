import { LightningElement, track } from 'lwc';

export default class PackageLogConfigStep extends LightningElement {

    @track loggedActivitySelection = 'errorsOnly';
    @track currentLogRecordCount = 500;
    @track logRecordsRetainedLimit = '1000'
    @track capturedActivityValue = 'errorsOnly';
    @track capturedActivityType = [
        {
            label:'Errors Only',
            value:'errorsOnly'
        },
        {
            label:'All Activity',
            value:'allActivity'
        }
    ]

    get disableDeletelogs() {
        return this.currentLogRecordCount === 0;
    }

    updateCapturedActivityValue(event) {
        this.capturedActivityValue = event.detail.value;
    }

    handleDeleteLogModal(event) {
        const currentClick = event.currentTarget.label;
        if (currentClick === 'Delete All') {
            this.template.querySelector('.strike-delete-logs').show();
        } else {
            if (currentClick === 'Confirm') {
                // Delete All Records
                this.currentLogRecordCount = 0;
            }
            this.template.querySelector('.strike-delete-logs').hide();
        }
    }
}