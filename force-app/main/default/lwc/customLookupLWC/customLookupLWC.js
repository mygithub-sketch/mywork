import { LightningElement,api,track,wire } from 'lwc';
import getLookupValues from '@salesforce/apex/CustomLookupLwcController.getLookupValues';
import getinitRecord from '@salesforce/apex/CustomLookupLwcController.getinitRecord';
import getRecentlyCreatedRecords from '@salesforce/apex/CustomLookupLwcController.getRecentlyCreatedRecords';
const DELAY = 500;
export default class CustomLookupLWC extends LightningElement {

   //public properties

   @api uniqueName = '';
   @api initialLookupValue = '';
   @api sObjectApiName = '';
   displayLabelField = 'Name';
   @api iconName = '';
   @api labelForComponent = ''
   @api placeHolder = ''
   @api recordLimit = 5;
   @api labelHidden = false;
   searchKeyWord = '';
   @api selectedRecord = {}; // Use, for store SELECTED sObject Record
   @api where = '';
   @api condition='';;

   // private properties
   selectedRecordLabel = '';
   searchRecordList = []; // Use,for store the list of search records which returns from apex class
   message = '';
   spinnerShow = false;
   error = '';
   noRecordFound = false;

   @wire(getLookupValues, { searchKeyWord: '$searchKeyWord', objectAPIName: '$sObjectApiName', whereCondition: '$where', fieldNames: '$displayLabelField', parentId:'$condition', customLimit: '$recordLimit' })

   wiredsearchRecordList({ error, data }) {
       this.spinnerShow = true;
       if (data) {
           this.spinnerShow = false;
           this.searchRecordList = JSON.parse(JSON.stringify(data));
           this.error = undefined;
           this.hasRecord();
       } else if (error) {
           console.log('getLookupValues Error 2 —> ' + JSON.stringify(error));
           this.hasRecord();
           this.error = error;
           this.searchRecordList = undefined;
       }
   }
   connectedCallback() {
       if (this.initialLookupValue != '') {
           getinitRecord({ recordId: this.initialLookupValue, 'objectAPIName': this.sObjectApiName, 'fieldNames': this.displayLabelField })
               .then((data) => {
                   if (data != null) {
                       console.log('getinitRecord —> ', JSON.stringify(data));
                       this.selectedRecord = data;
                       this.selectedRecordLabel = data.Name; //data[this.displayLabelField];
                       this.selectionRecordHelper();
                   } 
               })
               .catch((error) => {
                   console.log('getinitRecord Error —> ' + JSON.stringify(error));
                   this.error = error;
                   this.selectedRecord = {};
               });
       }
   }
   handleClickOnInputBox(event) {

       let container = this.template.querySelector('.custom-lookup-container');
       container.classList.add('slds-is-open');
       this.spinnerShow = true;
       console.log(this.where);
       console.log(this.condition);       
       if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length === 0) {
        getRecentlyCreatedRecords({ 'objectAPIName': this.sObjectApiName, 'fieldNames': this.displayLabelField, 'whereCondition': this.where, 'parentId':this.condition,  'customLimit': this.recordLimit })
               .then((data) => {
                   if (data != null) {
                       try {
                           console.log('getRecentlyCreatedRecords —> ', JSON.stringify(data));
                           this.spinnerShow = false;
                           this.searchRecordList = JSON.parse(JSON.stringify(data));
                           this.hasRecord();
                       } catch (error) {
                           console.log(error);
                           this.hasRecord();
                       }
                   }
               })
               .catch((error) => {
                   console.log('getRecentlyCreatedRecords Error —> ' + JSON.stringify(error));
                   this.error = error;
               });
       } else if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
           let temp = this.searchKeyWord
           this.searchKeyWord = temp;
           getLookupValues({ 'searchKeyWord': this.searchKeyWord, 'objectAPIName': this.sObjectApiName, 'whereCondition': this.where, 'fieldNames': this.displayLabelField,'parentId':this.condition, 'customLimit': this.recordLimit })
               .then((data) => {
                   if (data != null) {
                       console.log('getLookupValues —> ', JSON.stringify(data));
                       this.spinnerShow = false;
                       this.searchRecordList = JSON.parse(JSON.stringify(data));
                       this.error = undefined;
                       this.hasRecord();
                   }
               })
               .catch((error) => {
                console.log('getLookupValues Error —> ' + JSON.stringify(error));
                   this.error = error;
                   this.selectedRecord = {};
               });
       }     
   }
   handleKeyChange(event) {
       this.searchKeyWord = event.detail.value;
       console.log(this.searchKeyWord);
       if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
           this.searchRecordList = [];
       }

   }

   handleOnblur(event) {
       let container = this.template.querySelector('.custom-lookup-container');
       container.classList.remove('slds-is-open');
       this.spinnerShow = false;
       this.searchRecordList = [];
   }

   fireLookupUpdateEvent(value) {
    const oEvent = new CustomEvent('lookupupdate',
        { 'detail': {
                      'selectedRecord': value
                    }
        } );
    this.dispatchEvent(oEvent);
}

   handleSelectionRecord(event) {

       var recid = event.target.getAttribute('data-recid');
       console.log('recid : ', recid);

       let container = this.template.querySelector('.custom-lookup-container');
       container.classList.remove('slds-is-open');
       this.selectedRecord = this.searchRecordList.find(data => data.Id === recid);

       this.selectedRecordLabel = this.selectedRecord.Name;//this.selectedRecord[this.displayLabelField];
       console.log(this.selectedRecord);
       console.log(this.selectedRecordLabel);

       this.fireLookupUpdateEvent(this.selectedRecord);
       this.selectionRecordHelper();
   }
   selectionRecordHelper() {
       let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
       custom_lookup_pill_container.classList.remove('slds-hide');
       custom_lookup_pill_container.classList.add('slds-show');
       let search_input_container_container = this.template.querySelector('.search-input-container');
       search_input_container_container.classList.remove('slds-show');
       search_input_container_container.classList.add('slds-hide');
   }
   clearSelection() {
       let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
       custom_lookup_pill_container.classList.remove('slds-show');
       custom_lookup_pill_container.classList.add('slds-hide');
       let search_input_container_container = this.template.querySelector('.search-input-container');
       search_input_container_container.classList.remove('slds-hide');
       search_input_container_container.classList.add('slds-show');
       this.fireLookupUpdateEvent(undefined);
       this.clearSelectionHelper();
      
   }
   clearSelectionHelper() {
       this.selectedRecord = {};
       this.selectedRecordLabel = '';
       this.searchKeyWord = '';
       this.searchRecordList = [];
   }
   hasRecord() {
       if (this.searchRecordList && this.searchRecordList.length > 0) {
           this.noRecordFound = false;
       } else {
           this.noRecordFound = true;
       }
   }
}