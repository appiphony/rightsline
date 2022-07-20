import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveData from '@salesforce/apex/setupAssistant.saveData';
import getData from '@salesforce/apex/setupAssistant.getData';
import initialCall from '@salesforce/apex/fieldMappingStep.initialCall';
import getRightslineTemplates from '@salesforce/apex/fieldMappingStep.getRightslineTemplates';

export default class FieldMappingStep extends LightningElement {

    @track templateList = {};
    @track activeSection = 'group'; //Selected Vertical Nav Tab. Defaults to first available section

    // Delete modal
    
    openDeleteModal() {
        this.template.querySelector('.delete-modal').show();
    }

    closeDeleteModal() {
        this.template.querySelector('.delete-modal').hide();
    }

    get isGroup() {
        return this.activeSection === "group";
    }
    get isClient() {
        return this.activeSection === "client";
    }

    @track mappingName = 'Account - Customer Account';


    get objectOptions() {
        return [
            {
                label: 'Account',
                value: 'account',
            },
            {
                label: 'Contact',
                value: 'contact',
            }
        ];
    }

    @track objectValue = 'account';
    @track objectLabel = 'Account';

    updateObjectValue(event){
        debugger;
        let value = event.detail.value;
        this.objectValue = value;
    }

    @track recordTypeValue = 'customerAccount';
    get recordTypeOptions() {
        return [
            {
                label: 'Customer Account',
                value: 'customerAccount',
            },
            {
                label: 'Sales Account',
                value: 'salesAccount',
            }
        ];
    }

    updateRecordValue(event) {
        debugger;
        let value = event.detail.value;
        this.recordTypeValue = value;
    }

    @track rlValue = 'customer';

    get rlOptions() {
        //return this.templateList;
        return [
            {
                label: 'Customer',
                value: 'customer',
            },
            {
                label: 'Sales',
                value: 'sales',
            }
        ];
    }
    
    handleSectionSelect(event) {
        this.activeSection = event.detail.name;
        this.activeMapping = this[this.activeSection + 'Mapping'];
    }

    updateRlValue(event){
        debugger;
        let value = event.detail.value;
        this.rlValue = value;
    } 


    @track selectedObject = 'Account';
    @track setupData;
    @track defaultMapping = {
        rows: [
            {
                tpField: 'salutation',
                sfField: 'sfield1'
            },
            {
                tpField: 'phonePrimary',
                sfField: 'sfield1'
            },
            {
                tpField: 'email',
                sfField: 'sfield1'
            },
            {
                tpField: 'addressLine1',
                sfField: 'sfield1'
            },
            {
                tpField: 'hAddressLine1',
                sfField: 'sfield1'
            },
            {
                tpField: 'birthYear',
                sfField: 'sfield1'
            },
            {
                tpField: 'shippingCarrierName',
                sfField: 'sfield1'
            },
            {
                tpField: 'rlContactId',
                sfField: 'sfield1'
            },
            {
                tpField: 'firstName',
                sfField: 'sfield1'
            },
            {
                tpField: 'phoneOther',
                sfField: 'sfield1'
            }
        ]
    };

    @track tpFields = [
        {
            label: 'Salutation',
            value: 'salutation',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'Phone (Primary)',
            value: 'phonePrimary',
            required: true,
            column: 'tp',
            fieldType: 'integer'
        },

        {
            label: 'Email',
            value: 'email',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'Address Line 1',
            value: 'addressLine1',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: '(H) Address Line 1',
            value: 'hAddressLine1',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'Birth Year',
            value: 'birthYear',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'Shipping Carrier Name',
            value: 'shippingCarrierName',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'RL Contact ID',
            value: 'rlContactId',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'First Name',
            value: 'firstName',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
        {
            label: 'Phone (Other)',
            value: 'phoneOther',
            required: true,
            column: 'tp',
            fieldType: 'string'
        },
    ];

    @track sfFields = [
        {
            label: 'SF String 1',
            value: 'sfield1',
            column: 'sf',
            fieldType: 'string'
        },
        {
            label: 'SF Integer 1',
            value: 'sfield3',
            column: 'sf',
            fieldType: 'integer'
        },
        {
            label: 'SF Integer 2',
            value: 'sfield4',
            column: 'sf',
            fieldType: 'integer'

        },
        {
            label: 'SF Boolean 1',
            value: 'sfield5',
            column: 'sf',
            fieldType: 'boolean'
        }
    ];

    // constructor() {
    //     super()
    //     this.template.addEventListener('next', this.next.bind(this))
    // }

    connectedCallback () {
        getRightslineTemplates().then(res => {
            let parsedRes = JSON.parse(res);
            debugger;
            if (parsedRes.isSuccess) {
                debugger;
                this.templateList = parsedRes.results.templateList;
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
        })
    }

    @api
    show() {
        return new Promise((resolve, reject) => {
            getData().then(response => {
                let responseData = JSON.parse(response)
                if(responseData.isSuccess) {
                    this.setupData = responseData.results.setupMetadata
                    this.loading = false
                    resolve()
                } else {
                    console.log(response)
                }
            })
        })
    }

    next(event) {
        debugger;
        event.stopPropagation();
        this.template.querySelector('c-data-mapper').validate().then(() => {
            saveData({
                setupData: {
                    Steps_Completed__c: JSON.stringify({
                        'C-DATA-MAPPER-STEP': 1
                    })
                }
            }).then(response => {
                let responseData = JSON.parse(response);
                if(responseData.isSuccess) {
                    this.dispatchEvent(new CustomEvent('next', {
                        bubbles: true,
                        composed: true
                    }));
                } else {
                    this.showToast(responseData.error, 'error', 'pester')
                }
            })
        }).catch(error => {
            console.log(error)
        })
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