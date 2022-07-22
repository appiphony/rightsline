import { LightningElement, track, api } from 'lwc';

import getDimensionDataOptions from '@salesforce/apex/DimensionDataApi.getDimensionDataOptions';
import getAvailableCatalogItems from '@salesforce/apex/AvailableCatalogItemsApi.getAvailableCatalogItems';
import getTemplateList from '@salesforce/apex/GetTemplateListApi.getTemplateList';
import getTemplate from '@salesforce/apex/GetDealTemplateApi.getTemplate';

export default class ApiPoc extends LightningElement {

    @track loading = true;
    @track toast = {};
    @track offset = 0;

    @track availableCatalogItems = [];

    connectedCallback() {
        this.loading = false;
    }

    handleGetAvailableCatalogItemsClick(){
        console.log('offset:' + JSON.parse(JSON.stringify(this.offset)));
        this.loading = true;
        getAvailableCatalogItems({
            offset: this.offset
        })
        .then(res => {

            const parsedRes = JSON.parse(res);
            console.log(parsedRes);

            const availableCatalogItemsResponse = parsedRes.results.availableCatalogItems;
            this.availableCatalogItems.push(...availableCatalogItemsResponse.rows);            
            this.offset += ( availableCatalogItemsResponse.rows.length );
            
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

    handleGetDealTemplatesClick(){
        this.loading = true;
        getTemplateList({
            entity: 'deal'
        })
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

    handleGetTemplateClick(){
        this.loading = true;
        getTemplate({
            templateId: 11
        })
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

    handleGetDimensionsOptionsClick(){
        getDimensionDataOptions()
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