import { LightningElement,wire,track } from 'lwc';
import getWorkers from '@salesforce/apex/TimeoffRequestHoursLWCCls.getWorkers';
import getTimeoffType from '@salesforce/apex/TimeoffRequestHoursLWCCls.getTimeoffType';
import getEntitlements from '@salesforce/apex/TimeoffRequestHoursLWCCls.getEntitlements';
import getLeaveHistory from '@salesforce/apex/TimeoffRequestHoursLWCCls.getLeaveHistory';
import createTimeoffRequest from '@salesforce/apex/TimeoffRequestHoursLWCCls.createTimeoffRequest';
import showTimeoffRequest from '@salesforce/apex/TimeoffRequestHoursLWCCls.showTimeoffRequest';
import getWorkerName from '@salesforce/apex/TimeoffRequestHoursLWCCls.getWorkerName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeoffRequestHoursLWC extends LightningElement {
    workers = [];
    timeoffTypes =[];
    entitlements =[];
    leaveHistory =[];
    timeoffRequest =[];
    selectedWorkerId;
    selectedTimeoffTypeId;
    selectStartDate;
    selectEndDate;
    notes;
    workerName;
    @track startDate;
   // @track formattedStartDate;
    endDate;
    note;
    @track displayLeaveCards = false;
    @track displayLeaveCardButton = false; 

    @wire(getWorkers)
    wiredWorkers({ error, data }) {
        if (data) {      
            console.log('data:', data);  
            if(data.lstPer){
            this.workers = data.lstPer.map(worker => ({
                label: worker.HRMSUS__Associate_Name__c,
                value: worker.Id
            }));
        }
            if( data.per){
            this.selectedWorkerId = data.per[0].Id;
            if (this.workers.length === 0) {
                this.workers = data.per.map(worker => ({
                    label: worker.HRMSUS__Associate_Name__c,
                    value: worker.Id
                }));
            }
            }
            if( this.selectedWorkerId){
                this.handleWorkerName();
                this.loadEntitelementsByWorker();  
                this.loadLeaveHistoryByWorker();
            }
            
        } else if (error) {
            console.error('Error fetching worker records:', error);
        }
        console.log('workers:', this.workers);
       
    }
    @wire(getTimeoffType)
    wiredTimeoffType({ error, data }) {
        if (data) {
            this.timeoffTypes = data.map(type => ({
                label: type.Name,
                value: type.Id
            }));
        } else if (error) {
            console.error('Error fetching Time off Type records:', error);
        }
    }
    handleWorkerChange(event) {
        this.selectedWorkerId = event.target.value; 
        console.log('selectedWorkerId:- '+ this.selectedWorkerId);
        if( this.selectedWorkerId){
            this.handleWorkerName();
            this.loadEntitelementsByWorker();  
            this.loadLeaveHistoryByWorker();
        }
    }
    handleTimeoffTypeChange(event) {
        this.selectedTimeoffTypeId = event.target.value;      
            this.loadShowTimeoffRequest();
    }
    handleStartDate(event){
        this.selectStartDate=event.target.value;
        this.loadShowTimeoffRequest(); 
    }
    handleEndtDate(event){
        this.selectEndDate=event.target.value;
        this.loadShowTimeoffRequest();  
            
    }
    handleNotesChange(event) {
        this.notes = event.target.value;
    }
    handleWorkerName(){
    if (this.selectedWorkerId) {
        getWorkerName({ workerId: this.selectedWorkerId })
            .then(result => {
                this.workerName = result;
                console.log('workerName:- '+ this.workerName);
                // Handle the returned workerName data as needed
            })
            .catch(error => {
                console.error('Error fetching workerName:', error);
            });
    }
    
  }
    loadShowTimeoffRequest(){
        if (this.selectStartDate &&this.selectEndDate) {
            if(!this.selectedTimeoffTypeId){
                this.showToast('Error', 'Please Select Time Off Type', 'error'); 
                return false;
            }
            if(this.selectStartDate > this.selectEndDate){
                this.showToast('Error', 'Start Date Should be less than End Date', 'error'); 
                return false;
            }
    }
        if (this.selectedWorkerId && this.selectedTimeoffTypeId && this.selectStartDate &&this.selectEndDate) {
               this.displayLeaveCards =true;
               this.displayLeaveCardButton =true;
            showTimeoffRequest({ workerId: this.selectedWorkerId,typeId:this.selectedTimeoffTypeId,startDate:this.selectStartDate,endDate:this.selectEndDate})
            .then(result => {
                console.log('result:- '+ result);
                this.timeoffRequest = result;
                console.log('timeoffRequest:- '+ this.timeoffRequest);
            })
            .catch(error => {
                // Handle error or display error message
                console.error('Error inserting TimeoffRequest:', error);
                this.showToast('Error', error.body.message, 'error');
            });
            
        }
       
       
    }
  
    handleChange(event){
        const selectedIndex = event.target.dataset.index; // Get the index of the changed select element
        const newValue = event.target.value; // Get the new selected value

        // Update the specific item in timeoffRequest array
        this.timeoffRequest = this.timeoffRequest.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Hours1__c: newValue };
            }  
            return item;
        });
       /* const selectElements = this.template.querySelectorAll('select');

        this.timeoffRequest.forEach((item, index) => {
            if (selectElements[index] && item.HRMSUS__Hours1__c) {
                selectElements[index].value = item.HRMSUS__Hours1__c;
            }
        });
        console.log('timeoffRequest:- '+ timeoffRequest);*/
    }
    loadEntitelementsByWorker() {
        if (this.selectedWorkerId) {
            getEntitlements({ workerId: this.selectedWorkerId })
                .then(result => {
                    this.entitlements = result;
                    console.log('entitlements:- '+ this.entitlements);
                    // Handle the returned Entitlemets data as needed
                })
                .catch(error => {
                    console.error('Error fetching Entitlemets:', error);
                });
        }
    }
    loadLeaveHistoryByWorker() {
        if (this.selectedWorkerId) {
            getLeaveHistory({ workerId: this.selectedWorkerId })
                .then(result => {
                    if (result !== null) {
                    this.leaveHistory = result;
                    }
                    // Handle the returned leaveHistory data as needed
                })
                .catch(error => {
                    console.error('Error fetching leaveHistory:', error);
                });
        }
    }
    handleDeleteRow(event) {
        var value = event.target.dataset.index;
        console.log('--delete row--' + value);
        var timeOffReqInsert1 = [];

        this.timeoffRequest.forEach((item, index) => {
            console.log('item==', item, 'index==', index);
            if (index != value) {
                timeOffReqInsert1.push(item);
            }
        });
        

        if (this.timeoffRequest.length !== 1) {
            if (value === '0') {
                const nextIndex = parseInt(value, 10) + 1;
                if (this.timeoffRequest.length >= nextIndex) {
                const d = new Date(this.timeoffRequest[nextIndex].HRMSUS__Start_Date__c);
                if (!isNaN(d.getTime())) {
                    // If d is a valid date
                    const vnewDate = d.toISOString().slice(0, 10);
                    this.startDate = vnewDate;
                } else {
                    console.error('Invalid date format');
                }
            }
        }
       var myNumber  =this.timeoffRequest.length;
        var  toeSize  =''+ myNumber-1 +'';
    
        if (value === toeSize) {
            const nextIndex1 = parseInt(value, 10) - 1;
            console.log('Value:', value);
            console.log('Next Index:', nextIndex1);
            console.log('Array Length:', this.timeoffRequest.length);
            
            if (this.timeoffRequest.length >= nextIndex1) {
                const d = new Date(this.timeoffRequest[nextIndex1].HRMSUS__End_Date__c);
                if (!isNaN(d.getTime())) {
                    // If d is a valid date
                    const vnewDate = d.toISOString().slice(0, 10);
                    this.endDate = vnewDate;
                } else {
                    console.error('Invalid date format');
                }
            }
        }
        
        /* else {
            const d = new Date(this.startDate);
            const vnewDate = new Date(d.setDate(d.getDate())).toISOString().slice(0, 10);
            this.startDate = vnewDate;
            this.endDate = vnewDate;
        }*/
    }
    this.timeoffRequest=timeOffReqInsert1;
}
    handleCancel(){
        location.reload();
    }
    insertRecord(){
        createTimeoffRequest({ lstABR:this.timeoffRequest, absenceRequest:this.timeoffRequestList, workerId: this.selectedWorkerId,typeId:this.selectedTimeoffTypeId,startDate:this.selectStartDate,endDate:this.selectEndDate,notes:this.notes})
        .then(result => {
           
            console.log('TimeoffRequest inserted successfully:', result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Time off Request submitted successfully',
                    variant: 'success'
                })
            );
            location.reload();
        }) 
        .catch(error => {
            // Handle error or display error message
            console.error('Error inserting TimeoffRequest:', error);
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

}