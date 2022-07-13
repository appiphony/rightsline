import { LightningElement, track, api } from 'lwc';
// import getTemplates from '@salesforce/apex/makeCallout.getTemplates'

export default class customPropertyEditor extends LightningElement {
    @api operation;

    picklistOptions = [
        {
            label: 'Create',
            value: 'Create'
        },
        {
            label: 'Update',
            value: 'Update'
        },
        {
            label: 'Delete',
            value: 'Delete'
        }
    ]
    
    connectedCallback(){
        //
    }

    handleActionSelect(event) {
        event.currentTarget.value = event.detail.value;
        let newValue = {
            operation: event.currentTarget.value,
            recordId: '{!$Record.Id}'
        };

        const valueChangedEvent = new CustomEvent(
            'configuration_editor_input_value_changed',
            {
                bubbles: true,
                cancelable: false,
                composed: true,
                detail: {
                    name: 'data',
                    newValue: JSON.stringify(newValue),
                    newValueDataType: 'String'
                }
            }
        );
        debugger;

        this.dispatchEvent(valueChangedEvent);
    }
}
