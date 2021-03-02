import { LightningElement, api, track } from 'lwc';

import getGiftAidDeclaration from '@salesforce/apex/GAC_Helper.getGiftAidDeclaration';
import deactiveActiveGAD from '@salesforce/apex/GAC_Helper.deactiveActiveGAD';
import GIFTAID_LOGO from '@salesforce/resourceUrl/GiftAidLogo';
import addNewText from '@salesforce/label/c.GiftAidAddNewText';

export default class ContactGACLWCComponent extends LightningElement {
    @api recordId;
    @track loading = true;
    @track displayGAD;
    @track giftAidDeclaration;
    @track errors;
    @track createNew = false;
    giftaidURL = GIFTAID_LOGO;

    label = {
        addNewText
    };

    // intial call back get out data
    connectedCallback() {
        this.handleGetGiftAidDeclaration();        
    }

    // handle errors no output for it back handling anyway
    errorCallback(error) {
        this.errors = error;
    }

    // get the current contacts active declaration
    handleGetGiftAidDeclaration(){
        getGiftAidDeclaration({
            recordId: this.recordId
        })
        .then((results) => {
            if(results == null){
                this.displayGAD = false;
                this.giftAidDeclaration = null;
                this.loading = false;
            } else {
                this.displayGAD = true;
                this.giftAidDeclaration = results;
                this.loading = false;
            }
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.displayGAD = false;
            this.giftAidDeclaration = null;
            this.loading = false;
        });  
    }

    // deactivate current gac
    handleDeactivateClick(event){
        this.loading = true;
        deactiveActiveGAD({
            recordId: this.giftAidDeclaration.Id
        })
        .then((results) => {
            if(results == 'Success'){
                this.displayGAD = false;
                this.giftAidDeclaration = null;
                this.loading = false;
            } else {
                this.displayGAD = true;
                this.loading = false;
            }
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.displayGAD = false;
            this.giftAidDeclaration = null;
            this.loading = false;
        });  

    }

    handleAddClick(event){
        window.console.log('click add clicked');
        this.createNew = true;
    }

    handleSaveClick(event){
        this.createNew = false;
        this.displayGAD = false;
        this.giftAidDeclaration = null;
        this.loading = false;
        this.handleGetGiftAidDeclaration();
    }
}