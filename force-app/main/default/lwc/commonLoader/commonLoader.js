import { LightningElement, api } from 'lwc';

export default class CommonLoader extends LightningElement {
    @api loaderText ;
    @api loaderSize = 'medium';

    get hasLoaderText() {
        return !!this.loaderText;
    }
}