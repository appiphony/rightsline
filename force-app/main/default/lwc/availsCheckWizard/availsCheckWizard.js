import { LightningElement, track, api } from 'lwc';

import getDimensionDataOptions from '@salesforce/apex/DimensionDataApi.getDimensionDataOptions';

export default class AvailsCheckWizard extends LightningElement {

    @track loading = true;

    @track territoryOptions = [];
    @track languageOptions = [];
    @track mediaOptions = [];

    @track selectedMediaOption;
    @track selectedLanguageOption;
    @track selectedTerritoryOption;

    /* Data structure example for options arrays
    [
        {
            "label": "somelabel",
            "value": 5
        }
    ]
    */

    connectedCallback(){
        getDimensionDataOptions()
        .then(res => {
            const parsedRes = JSON.parse(res);
            console.log(parsedRes);
            
            parsedRes.results.dimensionData.territory[0].childValues.forEach(element => {
                this.territoryOptions.push({
                    label: element.label,
                    value: ''+element.id
                });
            });

            parsedRes.results.dimensionData.media[0].childValues.forEach(element => {
                this.mediaOptions.push({
                    label: element.label,
                    value: ''+element.id
                });
            });

            parsedRes.results.dimensionData.language[0].childValues.forEach(element => {
                this.languageOptions.push({
                    label: element.label,
                    value: ''+element.id
                });
            });

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

    handleCancelClicked(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSearchClicked(){
        console.log('searching');
        
    }

    updateMediaSelection(event){
        this.selectedMediaOption = event.detail.value;        
    }

    updateLanguageSelection(event){
        this.selectedLanguageOption = event.detail.value;
    }

    updateTerritorySelection(event){
        this.selectedTerritoryOption = event.detail.value;
    }


}