import { LightningElement, api } from 'lwc'

export default class Connector extends LightningElement {
    @api
    get authDisabled() {
        return this._authDisabled
    }
    set authDisabled(authDisabled) {
        this._authDisabled = authDisabled && authDisabled !== 'false'
    }
    @api isComplete = false

    @api authLabel = 'Authorize'
    @api reauthLabel = 'Deauthorize'

    get authorizeLabel() {
        if (this.isComplete) {
            return this.reauthLabel
        }

        return this.authLabel
    }

    authorize() {
        if(this.isComplete) {
            this.dispatchEvent(new CustomEvent('deauth'));
        } else {
            this.dispatchEvent(new CustomEvent('auth'));
        }
    }
}
