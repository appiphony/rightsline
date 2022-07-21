import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveData from '@salesforce/apex/setupAssistant.saveData';
import getSetupData from '@salesforce/apex/setupAssistant.getData';
import getData from '@salesforce/apex/fieldMappingStep.getData';
import getRightslineFields from '@salesforce/apex/fieldMappingStep.getRightslineFields';
import getSalesforceFields from '@salesforce/apex/fieldMappingStep.getSalesforceFields';
import saveContactMapping from '@salesforce/apex/fieldMappingStep.saveContactMapping';
import deleteContactMapping from '@salesforce/apex/fieldMappingStep.deleteContactMapping';

export default class FieldMappingStep extends LightningElement {

    @track mappingList = [];
    @track objList = [];
    @track templateList = [];
    @track objRecordTypeList = [];
    @track objFieldList = [];

    @track mappingName;
    @track activeMapping = {};

    @track templateValue = '';
    @track objValue = '';
    @track objRecordTypeValue = '';

    get disableRecordType() {
        return this.objRecordTypeList.length === 1;
    }

    @track objectValue = 'account';
    @track objectLabel = 'Account';

    @track recordTypeValue = 'customerAccount';

    @track rlValue = 'customer';

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

    get isClient() {
        return this.activeSection === "client";
    }

    // constructor() {
    //     super()
    //     this.template.addEventListener('next', this.next.bind(this))
    // }

    @api
    show() {
        return new Promise((resolve, reject) => {
            getData().then(res => {
                let parsedRes = JSON.parse(res);
    
                if (parsedRes.isSuccess) {
                    debugger;
                    this.mappingList = parsedRes.results.contactMappingList;
                    this.objList = parsedRes.results.objList;
                    this.templateList = parsedRes.results.templateList;
    
                    this.activeMapping = this.mappingList[0];
                    this.templateValue = this.activeMapping.Rightsline_Template_Id__c;
                    this.objValue = this.activeMapping.Salesforce_Object__c;

                    getSalesforceFields({objName:this.objValue,getLookups:true}).then(res => {
                        let parsedRes = JSON.parse(res);
                        debugger;
                        if (parsedRes.isSuccess) {
                            debugger;
                            this.objFieldList = parsedRes.fields[0].options;
                            this.objRecordTypeList = parsedRes.recordTypeOptions;
                            this.objRecordTypeValue = this.activeMapping.Salesforce_Object_Record_Type__c;
                        } else {
                            this.showToast('error', parsedRes.error);
                        }
                    }).catch(error => {
                        this.showToast('error', error.message ? error.message : error.body.message);
                    });
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

    updateTemplate(event) {
        event.currentTarget.value = event.detail.value;
        let value = event.detail.value;
        this.templateValue = value;
        getRightslineFields({templateId:this.templateValue}).then(res => {
            let parsedRes = JSON.parse(res);
            debugger;
            if (parsedRes.isSuccess) {
                debugger;
                this.templateFieldList = parsedRes.results.templateFieldList;
            } else {
                this.showToast('error', parsedRes.error);
            }
        });
    }

    updateObject(event){
        event.currentTarget.value = event.detail.value;
        let value = event.detail.value;
        this.objValue = value;
        getSalesforceFields({objName:this.objValue,getLookups:true}).then(res => {
            let parsedRes = JSON.parse(res);
            debugger;
            if (parsedRes.isSuccess) {
                debugger;
                this.objFieldList = parsedRes.fields[0].options;
                this.objRecordTypeList = parsedRes.recordTypeOptions;
            } else {
                this.showToast('error', parsedRes.error);
            }
        });
    }

    updateRecordType(event) {
        event.currentTarget.value = event.detail.value;
        let value = event.detail.value;
        this.objRecordTypeValue = value;
    }

    openDeleteModal() {
        this.template.querySelector('.delete-modal').show();
    }

    closeDeleteModal() {
        this.template.querySelector('.delete-modal').hide();
    }

    updateRecordValue(event) {
        debugger;
        let recordValue = event.detail.value;
        this.recordTypeValue = recordValue;
    }

    handleSectionSelect(event) {
        debugger;
        this.activeMapping = this.mappingList[event.detail.index];
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
        let setupMetadata = {
            Steps_Completed__c : JSON.stringify({'C-FIELD-MAPPING-STEP' : 1})
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