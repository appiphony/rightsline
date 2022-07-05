import { LightningElement, api, track } from 'lwc';
import companyLogo from '@salesforce/resourceUrl/companyLogo';
import getData from '@salesforce/apex/setupAssistant.getData';
import getPackageVersion from '@salesforce/apex/setupAssistant.getPackageVersion';

export default class Landing extends LightningElement {
    @track companyLogo = companyLogo;
    @track loading = true;
    @track started = false;
    @track wizards = [];
    @track packageVersion = '';

    @api
    get sequential() {
        return this._sequential !== false;
    }

    set sequential(sequential) {
        this._sequential = !sequential && sequential !== 'false';
    }

    get showStartButton() {
        return this.sequential && !this.started;
    }

    connectedCallback() {
        getPackageVersion()
        .then(responseDataString => {
            const responseData = JSON.parse(responseDataString).results;

            this.packageVersion = responseData.major + '.' + responseData.minor;
        })
        .catch(error => {
            this.packageVersion = 'Unavailable';
        })
    }

    @api
    init(wizards) {
        getData()
        .then(responseDataString => {
            const responseData = JSON.parse(responseDataString);
            const completedSteps = JSON.parse(responseData.results.setupData.Steps_Completed__c);

            this.showButton = !this.showStartButton;

            wizards.forEach((wizard, i) => {
                wizard.init(completedSteps);
                this.updateWizard(wizard, i, true);
            })

            this.wizards = wizards;
            this.show(this.wizards);
            this.loading = false;
        })
    }

    @api
    show(wizards) {
        wizards.forEach((wizard, i) => {
            this.updateWizard(wizard, i);
        })

        this.wizards = wizards;
        this.classList.remove('slds-hide');

        window.setTimeout(() => {
            this.template.querySelectorAll('.slds-progress-ring_complete').forEach(element => {
                if (element.dataset.previouslyCompleted === 'true') {
                    element.classList.add('strike-not-animated');
                } else {
                    element.classList.add('strike-animated');
                }
            })
        }, 1)
    }

    updateWizard(wizard, i, init = false) {
        wizard.index = i;
        wizard.isComplete = wizard.progress === 1;

        if (init) {
            wizard.previouslyCompleted = wizard.isComplete;
        } else {
            window.setTimeout(() => {
                wizard.previouslyCompleted = wizard.isComplete;
            }, 500)
        }

        if (wizard.progress > 0) {
            this.started = true;
            this.showButton = true;
            wizard.buttonLabel = wizard.progress === 1 ? 'Edit' : 'Continue';
            wizard.buttonVariant = 'neutral';
            wizard.showButton = true;
        } else {
            wizard.buttonLabel = 'Start';
            if (this.sequential) {
                wizard.buttonVariant = 'brand';
            }
            wizard.showButton = this.showButton;
        }

        if (wizard.progress !== 1 && this.sequential) {
            this.showButton = false;
        }
    }

    showWizard(event) {
        const index = event.index || event.target.dataset.index;
        let targetWizard;

        if (!isNaN(parseInt(index, 10))) {
            targetWizard = this.wizards[index];
        } else {
            targetWizard = this.wizards.find(wizard => {
                return wizard.progress !== 1;
            })

            if (targetWizard === undefined) {
                targetWizard = this.wizards[0];
            }
        }

        this.classList.add('slds-hide');
        targetWizard.show();
    }
}
