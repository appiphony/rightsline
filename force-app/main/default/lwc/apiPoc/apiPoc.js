import { LightningElement, track, api } from 'lwc';

import getAvailableCatalogItems from '@salesforce/apex/AvailableCatalogItemsApi.getAvailableCatalogItems';

export default class ApiPoc extends LightningElement {

    @track loading = true;
    @track toast = {};

    connectedCallback() {
        this.loading = false;
    }

    handleGetAvailableCatalogItemsClick(){
        getAvailableCatalogItems()
        .then(res => {

            const parsedRes = JSON.parse(res);
            console.log(parsedRes);
            
        }).catch(error => {
            //error toast
            const errMsg = error.body ? error.body.message : error.toString();
            this.dispatchEvent(new CustomEvent('toast', {
                bubbles: true,
                detail: {
                    type: 'error',
                    title: errMsg
                }
            })); 
        }).finally(() => {
            //hide spinner
            this.loading = false;
        }) 
    }

}