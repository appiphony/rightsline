import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveData from '@salesforce/apex/setupAssistant.saveData';
import getData from '@salesforce/apex/fieldMappingStep.getData';
import getRightslineFields from '@salesforce/apex/fieldMappingStep.getRightslineFields';
import getSalesforceFields from '@salesforce/apex/fieldMappingStep.getSalesforceFields';
import saveContactMapping from '@salesforce/apex/fieldMappingStep.saveContactMapping';
import deleteContactMapping from '@salesforce/apex/fieldMappingStep.deleteContactMapping';
import emptyState from '@salesforce/resourceUrl/emptyState';

export default class FieldMappingStep extends LightningElement {

    @track mappingList = [];
    @track objList = [];
    @track templateList = [];
    @track objRecordTypeList = [];
    @track objFieldList = [];
    @track templateFieldList = [];
    //Empty state
    @track emptyState = emptyState;
    @track hasMappings = '';

    @track activeMappingObject = [
        {
        Label: '',
        Salesforce_Object__c: '',
        Salesforce_Object_Record_Type__c: '',
        Rightsline_Template_Id__c: '',
        Outbound_Mapping__c: ''
        }
    ];

    @track activeMapping = [
        {
        rightslineField: '',
        rightslineApi: '',
        sfField: '',
        required: false
        }
    ];

    @track templateValue = '';
    @track objValue = '';
    @track objRecordTypeValue = '';

    @track loadMaps = false;
    @track disableNewMappingButton = false;
    @track isTemplateUpdate = false;
    @track isObjectUpdate = false;
    @track hasMappingList = false;

    get disableRecordType() {
        return this.objRecordTypeList.length < 2;
    }

    @track setupData;

    /*constructor() {
        super()
        this.template.addEventListener('next', this.next.bind(this))
    }*/

    @api
    show() {
        debugger;
        return new Promise((resolve, reject) => {
            getData().then(res => {
                let parsedRes = JSON.parse(res);
    
                if (parsedRes.isSuccess) {
                    debugger;
                    
                    this.objList = parsedRes.results.objList;
                    this.templateList = parsedRes.results.templateList;

                    this.loadMaps = true;

                    if (parsedRes.results.contactMappingList.length === 0) {
                        this.createNewMapping();
                    } else {
                          //debugger;
                        this.mappingList = parsedRes.results.contactMappingList;
                        this.hasMappingList = true;
                        
                        this.activeMappingObject = this.mappingList[0];
                        this.templateValue = this.activeMappingObject.Rightsline_Template_Id__c;
                        this.objValue = this.activeMappingObject.Salesforce_Object__c;

                        this.updateSalesforceFields();
                        this.objRecordTypeValue = this.activeMappingObject.Salesforce_Object_Record_Type__c;
                        this.updateRightslineFields();
                        this.activeMapping = JSON.parse(this.activeMappingObject.Outbound_Mapping__c);
                    }
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

    updateSalesforceFields() {
          //debugger;
        getSalesforceFields({objName:this.objValue, getLookups:true}).then(res => {
            let parsedRes = JSON.parse(res);
              //debugger;
            if (parsedRes.isSuccess) {
                  //debugger;
                this.objFieldList = parsedRes.results.fields[0].options;
                this.objRecordTypeList = parsedRes.results.recordTypeOptions;
                if (this.objRecordTypeList.length === 1) {
                    this.objRecordTypeValue = this.objRecordTypeList[0].value;
                }
                if (this.isObjectUpdate) {
                    this.isObjectUpdate = false;
                    let templateLabel = '';
                    for (let i = 0; i < this.templateList.length; i++) {
                        if (this.templateList[i].value === this.templateValue) {
                            templateLabel = this.templateList[i].label;
                            break;
                        }
                    }
                }
            } else {
                this.showToast('error', parsedRes.error);
            }
        }).catch(error => {
            this.showToast('error', error.message ? error.message : error.body.message);
        });
    }

    updateRightslineFields() {
          //debugger;
        getRightslineFields({templateId:this.templateValue}).then(res => {
            let parsedRes = JSON.parse(res);
              //debugger;
            if (parsedRes.isSuccess) {
                  //debugger;
                this.templateFieldList = parsedRes.results.templateFieldList;

                if (this.isTemplateUpdate) {
                    let templateLabel = '';
                    for (let i = 0; i < this.templateList.length; i++) {
                        if (this.templateList[i].value === this.templateValue) {
                            templateLabel = this.templateList[i].label;
                            break;
                        }
                    }
                    
                    this.isTemplateUpdate = false;

                    this.activeMapping = [];

                    for (let i = 0; i < this.templateFieldList.length; i++) {
                        this.activeMapping.push({
                            'rightslineField': this.templateFieldList[i].label,
                            'rightslineApi': this.templateFieldList[i].value,
                            'sfField': '',
                            'required': this.templateFieldList[i].required
                        })
                    }
                }

                console.log(this.activeMapping);
            } else {
                this.showToast('error', parsedRes.error);
            }
        });
    }

    updateTemplate(event) {
        event.currentTarget.value = event.detail.value;
        let value = event.detail.value;
        this.templateValue = value;
        this.isTemplateUpdate = true;
        this.updateRightslineFields();
    }

    updateObject(event){
        event.currentTarget.value = event.detail.value;
        let value = event.detail.value;
        this.objValue = value;
        this.isObjectUpdate = true;
        this.updateSalesforceFields();
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
          //debugger;
        let recordValue = event.detail.value;
        this.recordTypeValue = recordValue;
    }

    handleSectionSelect(event) {
        console.log('event.detail: ' + event.detail.name);
        if(this.loadMaps && this.activeMappingObject.Label !== 'New Mapping') {
            let selectedMapping = event.detail.name;
            var mappingSelectionObject;
            for(let i = 0; i < this.mappingList.length; i++) {
                if (this.mappingList[i].Label === selectedMapping) {
                    //this.activeMappingObject = this.mappingList[i];
                    mappingSelectionObject = this.mappingList[i];
                    break;
                }
            }//array.find
            this.objValue = mappingSelectionObject.Salesforce_Object__c;
            this.objRecordTypeValue = mappingSelectionObject.Salesforce_Object_Record_Type__c;
            this.templateValue = mappingSelectionObject.Rightsline_Template_Id__c;
            this.updateSalesforceFields();
            this.updateRightslineFields();
            this.activeMapping = JSON.parse(mappingSelectionObject.Outbound_Mapping__c);
        }
    }

    createNewMapping() {
        this.disableNewMappingButton = true;
        debugger;
        this.activeMappingObject = {
            Outbound_Mapping__c: [],
            Salesforce_Object__c:'',
            Salesforce_Object_Record_Type__c:'',
            Rightsline_Template_Id__c:'',
            Label:'New Mapping'
        };

        this.activeMapping = [];

        this.objRecordTypeList = [];
        this.templateFieldList = [];
        this.objValue = '';
        this.templateValue = '';
        this.objRecordTypeValue = '';
        this.mappingList.push(this.activeMappingObject);
        this.hasMappingList = true;
    }

    deleteMapping(event) {
          //debugger;
        if(this.activeMappingObject.Label === 'New Mapping'){
            this.disableNewMappingButton = false;
            if (this.mappingList.length === 1) {
                this.showToast('error', 'You have no mappings saved to delete!');
                this.disableNewMappingButton = true;
            } else {
                for (let i = 0; i < this.mappingList.length; i++) {
                    if (this.mappingList[i] === this.activeMappingObject) {
                        this.mappingList.splice(i,1);
                        break;
                    }
                }
                if (this.mappingList.length === 0) {
                    this.createNewMapping();
                } else {
                    this.activeMappingObject = this.mappingList[0];
                    this.objValue = this.activeMappingObject.Salesforce_Object__c;
                    this.objRecordTypeValue = this.activeMappingObject.Salesforce_Object_Record_Type__c;
                    this.templateValue = this.activeMappingObject.Rightsline_Template_Id__c;
                    this.updateSalesforceFields();
                    this.updateRightslineFields();
                    this.activeMapping = JSON.parse(this.activeMappingObject.Outbound_Mapping__c);
                }
            }
        } else {
            deleteContactMapping({contactMappingLabel: this.activeMappingObject.Label}).then(res => {
                let parsedRes = JSON.parse(res);
                  //debugger;
                if (parsedRes.isSuccess) {
                    this.showToast('success', 'Mapping deleted successfully!');
                    for (let i = 0; i < this.mappingList.length; i++) {
                        if (this.mappingList[i] === this.activeMappingObject) {
                            this.mappingList.splice(i,1);
                            break;
                        }
                    }
                    if (this.mappingList.length === 0) {
                        this.createNewMapping();
                    } else {
                        this.activeMappingObject = this.mappingList[0];
                        this.objValue = this.activeMappingObject.Salesforce_Object__c;
                        this.objRecordTypeValue = this.activeMappingObject.Salesforce_Object_Record_Type__c;
                        this.templateValue = this.activeMappingObject.Rightsline_Template_Id__c;
                        this.updateSalesforceFields();
                        this.updateRightslineFields();
                        this.activeMapping = JSON.parse(this.activeMappingObject.Outbound_Mapping__c);
                    }
                } else {
                    this.showToast('error', parsedRes.error);
                    if(this.activeMappingObject.Label === 'New Mapping'){
                        this.disableNewMappingButton = true;
                    }
                }
            }).catch(error => {
                this.showToast('error', error.message ? error.message : error.body.message);
                if(this.activeMappingObject.Label === 'New Mapping'){
                    this.disableNewMappingButton = true;
                }
            })
        }

        this.template.querySelector('c-modal').hide();
    }

    saveMapping (event) {
        debugger;

        let resObj = this.template.querySelector('c-data-mapper').retrieveOutboundMapping();

        if (this.objValue === '' || this.templateValue === '') {
            resObj.valid = false;
        }

        if (resObj.valid === true) {
            let templateLabel = '';
            for (let i = 0; i < this.templateList.length; i++) {
                if (this.templateList[i].value === this.templateValue) {
                    templateLabel = this.templateList[i].label;
                    break;
                }
            }

            let savePayload = {
                DeveloperName: this.objValue + '_' + templateLabel,
                Label: this.objValue + ' - ' + templateLabel,
                Outbound_Mapping__c: JSON.stringify(resObj.outboundMapping),
                Salesforce_Object__c: this.objValue,
                Salesforce_Object_Record_Type__c: this.objRecordTypeValue,
                Rightsline_Template_Id__c: this.templateValue
            };

            let count = 0;
            for (let i = 0; i < this.mappingList.length; i++) {
                if (this.mappingList[i].Label === this.activeMappingObject.Label) {
                    count++;
                    if (count === 2) {
                        break;
                    }
                    debugger;
                    this.activeMappingObject = savePayload;
                    this.mappingList[i] = savePayload;
                    this.activeMapping = resObj.outboundMapping;
                    this.disableNewMappingButton = false;
                }
            }

            if (count < 2) {
    
                saveContactMapping({jsonString:JSON.stringify(savePayload)}).then(res => {
                    let parsedRes = JSON.parse(res);
                    debugger;
                    if (parsedRes.isSuccess) {
                        this.showToast('success', 'Mapping saved successfully!');
                    } else {
                        this.showToast('error', parsedRes.error);
                    }
                }).catch(error => {
                    this.showToast('error', error.message ? error.message : error.body.message);
                })
            } else {
                this.showToast('error', 'You already have this combination of objects mapped!')
            }
        } else {
            this.showToast('error', 'Please map all required fields.');
        }
    }

    next(event) {
          //debugger;
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
                    this.loadMaps = false;
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
          //debugger;
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