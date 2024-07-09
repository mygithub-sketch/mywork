import { LightningElement,track,wire,api  } from 'lwc';
import getTimeoffType from '@salesforce/apex/TimeOffEntitlementsLwcCls.getTimeoffType';
import createAbsenceEntitlements from '@salesforce/apex/TimeOffEntitlementsLwcCls.createAbsenceEntitlements';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/TimeOffEntitlementCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class TimeOffEntitlementsLWC extends LightningElement {

@api recordId;
@track timeOffList = [];
@track selectedTimeOffList=[];

@wire(getTimeoffType, { wrkrid: '$recordId'})
wiredAbsenceTypes({ error, data }) {
    if (data) {
        this.timeOffList = data;
        console.log('Timeofflst:', this.timeOffList);
        console.log('First Timeoff:', this.timeOffList[0]);
    } else if (error) {
        console.error('Error fetching absence types', error);
    }
}

connectedCallback(){

loadStyle(this, modal);

getTimeoffType({ wrkrid: this.recordId })
    .then(result => {
        this.timeOffList = result;
        this.error = undefined;
    })
    .catch(error => {
        this.error = error;
        this.accounts = undefined;
    });

}

handleHeaderChange(event) {    
    const isChecked = event.target.checked;
    console.log('Header Checkbox Checked:', isChecked);
    const updatedList = this.timeOffList.map(item => ({ ...item, isSelected: isChecked }));
    this.timeOffList = updatedList;
    console.log('Updated Time Off List:', this.timeOffList);
}

handleChange(event) {
    const selectedId = event.currentTarget.dataset.id;
    console.log(' this.timeOffList ID:',  this.timeOffList);
    
    console.log('Selected ID:', selectedId);
    const updatedList = this.timeOffList.map(item => {
        if (item.Id === selectedId) {
            return { ...item, isSelected: event.target.checked };
        }
        return item;
    });
    this.timeOffList = updatedList;
    console.log('Updated Time Off List:', this.timeOffList);

    const allSelected = this.timeOffList.every(item => item.isSelected);
    const headerCheckbox = this.template.querySelector('lightning-input[data-id="headerCheckbox"]');
    if (headerCheckbox) {
        headerCheckbox.checked = allSelected;
    }
}

handleStartDateChange(event) {
    const selectedId = event.currentTarget.dataset.id;
    const updatedList = this.timeOffList.map(item => {
        if (item.Id === selectedId) {
            return { ...item, HRMSUS__Time_Off_Start__c: event.target.value };
        }
        return item;
    });
    this.timeOffList = updatedList;
}

handleEndDateChange(event) {
    const selectedId = event.currentTarget.dataset.id;
    const updatedList = this.timeOffList.map(item => {
        if (item.Id === selectedId) {
            return { ...item, HRMSUS__Time_Off_End__c: event.target.value };
        }
        return item;
    });
    this.timeOffList = updatedList;
}

handleNumberChange(event) {
    const selectedId = event.currentTarget.dataset.id;
    const updatedList = this.timeOffList.map(item => {
        if (item.Id === selectedId) {
            return { ...item, HRMSUS__Available_Hours__c: event.target.value };
        }
        return item;
    });
    this.timeOffList = updatedList;
}
    
handleSave() {
    const selectedTimeOffList = this.timeOffList.filter(item => item.isSelected);
    if (selectedTimeOffList.length === 0) {
        // Show toast message if no checkbox is selected
        this.showToast('Error', 'Please Select atleast one time off type', 'error');
        return;
    }
    console.log('item.isSelected', this.isSelected);
    this.selectedTimeOffList = selectedTimeOffList;
    console.log('Selected Time Off List:', this.selectedTimeOffList);
    createAbsenceEntitlements({ selectedTimeOffList: this.selectedTimeOffList, recordId: this.recordId })
        .then(result => {
            // Handle the result as needed
            console.log('Time off Entitlements has been Created successfully', result);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Success',
                message: 'Time off Entitlements has been Created successfully',
                variant: 'success'
                
                })
                
        );            
        })
        .catch(error => {
            // Handle error and display the error message in the UI
            this.showToast('Error', error.body.message, 'error');
        });
}

showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(evt);
}

handleCancel(event){
    var url = window.location.href; 
    var value = url.substr(0,url.lastIndexOf('/') + 1);
    window.history.back();
    return false;
}
}