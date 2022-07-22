import { LightningElement, api, track } from "lwc";
import saveData from '@salesforce/apex/setupAssistant.saveData';

export default class DataMapper extends LightningElement {
    showRemove = false;
    @api step
    @api defaultMapping = {
        rows: [
            {
                sfOptions: [],
                tpOptions: []
            }
        ]
    }
    @api sfColumnName
    @api tpColumnName
    @api hasNoUnique
    @track mapping
    @track sfOptions
    @track tpOptions

    @track _outboundMapping;

    @track outboundMap = [];

    set outboundMapping(value) {
        this._outboundMapping = JSON.parse(JSON.stringify(value));
    }

    @api
    get outboundMapping() {
        return this._outboundMapping;
    }

    get hasMapping() {
        return this.outboundMapping.length > 1;
    }

    @api 
    get sfObject() {
        return this.mapping ? this.mapping.sfObject : null
    }

    set sfObject(value) {
        this._sfObject = value
        if(this.sfOptions && this.tpOptions) this.setOptions()
    }

    @api 
    get tpFields() {
        return this.tpFields
    }

    set tpFields(fields) {
        if(fields) {
            if(fields.length && !fields[0].label) this.hasStaticTp = true
            this.tpOptions = fields
            if(this.sfOptions) this.setOptions()
        }
    }

    @api
    get sfFields() {
        return this.sfFields
    }

    set sfFields(fields) {
        if(fields) {
            if(fields.length && !fields[0].label) this.hasStaticSf = true
            this.sfOptions = fields
            if(this.tpOptions) this.setOptions()
        }
    }

    @api
    get setupData() {
        return this.setupData
    }

    set setupData(setupData) {
        if(setupData) {
            this.mappings = setupData.Data_Mappings__c ? JSON.parse(setupData.Data_Mappings__c) : {}
            if(this.mappings[this.step]) {
                let mapping = JSON.parse(JSON.stringify(this.mappings[this.step]))
                mapping.rows.forEach(row => {
                    row.id = Math.random()
                    row.sfOptions = this.sfOptions
                    row.tpOptions = this.tpOptions
                })
                this.mapping = mapping
            }
            if(this.tpOptions || this.sfOptions) this.setOptions()
        }
    }

    @api
    get showHeader() {
        return this._showHeader !== false;
    }
    set showHeader(showHeader) {
        this._showHeader = showHeader && showHeader !== "false";
    }

    get header() {
        return this.showHeader ? "" : "slds-hide";
    }

    // CB EDIT
    get headerStyle() {
        return "width: " + 100.0 / 2 + "%;";
    }

    get colSpan() {
        return this.showRemove ? 3 : 2;
    }

    get addButton() {
        return this.mapping && !this.hasStaticSf && !this.hasStaticTp ? this.showRemove && this.mapping.rows.length < this.maxMappings : false
    }

    get hasMappings() {
        return this.mapping ? this.mapping.rows.length : false
    }

    // CB EDIT
    get showRemove() {
        return this._sfObject
    }

    selectField(event) {
        debugger;
        let fieldValue = event.detail;
        let index = parseInt(event.currentTarget.dataset.mapindex, 10);
        this._outboundMapping[index].sfField = fieldValue.value;
    }

    @api
    retrieveOutboundMapping() {
        debugger;
        let valid = true;
        for(let i = 0; i < this._outboundMapping.length; i++) {
            if(this._outboundMapping[i].required === true && this._outboundMapping[i].sfField === '') {
                valid = false;
                break;
            }
        }

        return {
            outboundMapping : this._outboundMapping,
            valid : valid
        };
    }

    @api
    handleObjectChange(fields) {
        delete this.mappings[this.step]
        this.saveMappings()
    }

    @api
    validate() {
        return new Promise((resolve, reject) => {
            if(!this.getRequiredRows().length && (this.hasStaticSf || this.hasStaticTp) || this.getCompleteRows().length) {
                if(!this.hasStaticSf && !this.hasStaticTp && !this.mappings[this.step]) {
                    this.mappings[this.step] = JSON.parse(JSON.stringify(this.mapping))
                    this.removeIncompleteRows()
                    this.saveMappings().then(() => {
                        resolve()
                    }).catch(error => {
                        reject(error)
                    })
                } else {
                    this.removeIncompleteRows()
                    resolve()
                }
            } else {
                reject('No rows Mapped or Missing Required Fields')
            }
        })
    }

    setDefaultMapping() {
        this.mapping = JSON.parse(JSON.stringify(this.defaultMapping))
        let required = this.getRequiredRows()

        if(required.length) this.mapping = JSON.stringify(this.defaultMapping) !== JSON.stringify({rows: [{sfOptions:[], tpOptions:[]}]}) ? this.mapping : {rows: []}
        let allRequired = [...this.tpOptions, ...this.sfOptions].filter(option => option.required === true)
    
        this.mapping.rows.forEach(row => {
            row.id = Math.random()
            row.sfOptions = this.sfOptions
            row.tpOptions = this.tpOptions
            row.deletable = this.hasStaticSf || this.hasStaticTp || allRequired.filter(requiredField => requiredField.value === row.tpField || requiredField.value === row.sfField).length
            row.sfReq = allRequired.filter(requiredField => requiredField.value === row.sfField).length
            row.tpReq = allRequired.filter(requiredField => requiredField.value === row.tpField).length
        })
        if(required.length) {
            required.forEach(option => {
                this.mapping.rows.push({
                    id: Math.random(),
                    sfField: option.column === 'sf' ? option.value : null,
                    tpField: option.column === 'tp' ? option.value : null,
                    sfReq: option.column === 'sf',
                    tpReq: option.column === 'tp',
                    fieldType: option.fieldType,
                    sfOptions: this.sfOptions,
                    tpOptions: this.tpOptions,
                    deletable: true
                })
            })
        }
        this.updateOptions()
    }

    setOptions() {
        if(this.sfOptions.length && this.tpOptions.length) {
            this.maxMappings = this.sfOptions.length < this.tpOptions.length ? this.sfOptions.length : this.tpOptions.length
        } else if(this.sfOptions.length) {
            this.maxMappings = this.sfOptions.length
        } else if(this.tpOptions.length) {
            this.maxMappings = this.tpOptions.length
        }

        if(this.mappings && !this.mappings[this.step] && this._sfObject) {
            this.setDefaultMapping()
        } else if(this.mapping) {
            this.mapping.rows.forEach(row => {
                row.sfOptions = this.sfOptions
                row.tpOptions = this.tpOptions
            })
            this.updateOptions()
        }
    }

    updateOptions(event) {
        let selected = []
        let rowIndex = event ? parseInt(event.currentTarget.dataset.rowindex) : null
        let fieldType = event ? event.currentTarget.dataset.fieldType : null

        this.mapping.rows.forEach(row => {
            if(row.sfField) selected.push(row.sfField)
            if(row.tpField) selected.push(row.tpField)
        })

        if(!this.hasNoUnique) {
            this.sfOptions.forEach(option => {
                debugger;
                if(option.label) option.disabled = selected.includes(option.value)
            })

            this.tpOptions.forEach(option => {
                debugger;
                if(option.label) option.disabled = selected.includes(option.value)
            })
        }

        if(fieldType) {
            this.mapping.rows[rowIndex].sfOptions = !this.hasStaticSf ? this.sfOptions.filter(option => option.fieldType === fieldType) : this.sfOptions
            this.mapping.rows[rowIndex].tpOptions = !this.hasStaticTp ? this.tpOptions.filter(option => option.fieldType === fieldType) : this.tpOptions
        } else if(rowIndex !== null) {
            this.mapping.rows[rowIndex].sfOptions = this.sfOptions
            this.mapping.rows[rowIndex].tpOptions = this.tpOptions
        }
        this.sfOptions = [...this.sfOptions]
        this.tpOptions = [...this.tpOptions]
    }

    updateRow(event) {
        let rowIndex = parseInt(event.currentTarget.dataset.rowindex)
        let column = event.currentTarget.dataset.column
        let options = [...this.tpOptions, ...this.sfOptions].filter(option => option.value === event.detail.value || option.value === event.target.value)
        let fieldType = options.length ? options[0].fieldType : null
        let currentSfField = this.mapping.rows[rowIndex].sfField
        let currentTpField = this.mapping.rows[rowIndex].tpField
        let previousFieldValue = column === 'sf' ? currentSfField : currentTpField

        let sfField = column === 'sf' ? event.detail.value ? event.detail.value : event.target.value : currentSfField
        let tpField = column === 'tp' ? event.detail.value ? event.detail.value : event.target.value : currentTpField

        this.mapping.rows[rowIndex].sfField = sfField
        this.mapping.rows[rowIndex].tpField = tpField
        this.mapping.rows[rowIndex].fieldType = fieldType

        if(!this.getRequiredRows().length && sfField && tpField) {
            this.mappings[this.step] = JSON.parse(JSON.stringify(this.mapping))
            this.mappings[this.step].sfObject = this._sfObject
            this.removeIncompleteRows()
            this.saveMappings()
        }
    }

    removeRow(event) {
        let rowIndex = parseInt(event.currentTarget.dataset.rowindex)
        this.mapping.rows.splice(rowIndex, 1)
        this.mappings[this.step] = JSON.parse(JSON.stringify(this.mapping))
        this.removeIncompleteRows()

        if(!this.getRequiredRows().length && this.mappings[this.step].rows.length) {
            this.saveMappings()
        } else if(!this.mappings[this.step].rows.length && this.mapping.rows.length) {
            delete this.mappings[this.step]
            this.saveMappings() 
        } else if(!this.mapping.rows.length) {
            delete this.mappings[this.step]
            this.saveMappings()
            this.setDefaultMapping()
        }
    }

    addRow() {
        this.mapping.rows.push({
            id: Math.random(),
            sfField: null,
            tpField: null,
            sfOptions: this.sfOptions,
            tpOptions: this.tpOptions
        })
        this.updateOptions()
    }

    getRequiredRows() {
        let required = [...this.tpOptions, ...this.sfOptions].filter(option => option.required === true)
        return required.filter(requiredField => !this.mapping.rows.filter(mappedRow => (mappedRow.tpField === requiredField.value && mappedRow.sfField) || (mappedRow.sfField === requiredField.value && mappedRow.tpField)).length)
    }

    saveMappings() {
        this.cleanMapping()
        return new Promise((resolve, reject) => {
            saveData({
                setupData: {
                    Data_Mappings__c: JSON.stringify(this.mappings) !== '{}' ? JSON.stringify(this.mappings) : null
                }
            }).then(response => {
                let responseData = JSON.parse(response);
                if(responseData.isSuccess) {
                    resolve()
                } else {
                    this.showToast(responseData.error, 'error', 'pester')
                    reject(responseData.error)
                }
            })
        })
    }

    getCompleteRows() {
        return this.mapping.rows.filter(row => row.sfField && row.tpField)
    }

    removeIncompleteRows() {
        if(this.hasStaticSf || this.hasStaticTp) return
        this.mappings[this.step].rows = this.mappings[this.step].rows.filter(row => (row.sfField && row.tpField) || row.required)
    }

    cleanMapping() {
        if(this.mappings[this.step]) {
            this.mappings[this.step].rows.forEach(row => {
                delete row['id']
                delete row['fieldType']
                delete row['sfOptions']
                delete row['tpOptions']
            })
        }
    }
}