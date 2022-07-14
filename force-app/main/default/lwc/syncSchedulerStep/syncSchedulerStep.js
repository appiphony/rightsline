import { LightningElement, api, track, wire } from 'lwc';


export default class syncSchedulerStep extends LightningElement {

    @track modalTitle;
    @track modalButtonVariant;
    @track modalButtonLabel;
    @track isActive = false;
    @track value = '';

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
                value: '12:00 AM'
            },
            {
                label: '1:00 AM',
                value: '1:00 AM'
            },
            {
                label: '2:00 AM',
                value: '2:00 AM'
            },
            {
                label: '3:00 AM',
                value: '3:00 AM'
            },
            {
                label: '4:00 AM',
                value: '4:00 AM'
            },
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
        let label = event.detail.label;

        this.value = value;
        this.label = label;
    }
}