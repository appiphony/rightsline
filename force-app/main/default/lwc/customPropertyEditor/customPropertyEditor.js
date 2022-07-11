import { LightningElement, track, api } from 'lwc';
// import getTemplates from '@salesforce/apex/makeCallout.getTemplates'

export default class InboundConnectorStep extends LightningElement {
    @api objectAPI;
    @api recordID;
    @api operation;

    picklistOptions = [
        {
            label: '1',
            value: '1'
        }
    ]
}
