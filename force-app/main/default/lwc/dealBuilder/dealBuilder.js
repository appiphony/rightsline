import { LightningElement, api, track } from 'lwc';

import getDimensionDataOptions from '@salesforce/apex/DimensionDataApi.getDimensionDataOptions';

export default class DealBuilder extends LightningElement {
    
    @track loading = true;
    @track normalState = false;
    @track message = "";
    @track toast = {};
    @track showWizard = false;

    connectedCallback(){
        //TODO query db for related rights sets and render front end

        this.loading = false;
        this.normalState = true;
    }

    launchAvailsCheck(){
        this.template.querySelector('c-modal[data-type=addRightsSetCatalogItems]').show();
        this.showWizard = true;
    }

    handleCloseModal(){
        this.template.querySelector('c-modal[data-type=addRightsSetCatalogItems]').hide();
        this.showWizard = false;
    }


     //#region Toast

    showToast(event) {
        clearTimeout(this.toastTimeout);

        let iconName,
            type = event.detail.type;

        switch (type) {
            case 'error':
                iconName = 'utility:error';
                break;
            case 'warning':
                iconName = 'utility:warning';
                break;
            case 'success':
                iconName = 'utility:success';
                break;
            default:
                iconName = 'utility:info';
                break;
        }

        this.toast = {
            class: 'slds-notify slds-notify_toast slds-theme_' + type,
            dismissible: event.detail.mode !== 'sticky',
            icon: {
                class:
                    'slds-icon_container slds-m-right_small slds-no-flex slds-align-top slds-icon-utility-' +
                    type,
                name: iconName
            },
            title: event.detail.title
                ? event.detail.title
                : event.detail.message,
            message: event.detail.title ? event.detail.message : null,
            type: type
        };

        if(event.detail.mode !== 'pester') {
            let duration = event.detail.duration || 3000;

            this.toastTimeout = setTimeout(() => {
                this.toast = {};
            }, duration);
        }
    }

    hideToast() {
        this.toast = {};
    }

    //#endregion
}