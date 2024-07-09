import { LightningElement,track,wire,api} from 'lwc';
import getrequest from '@salesforce/apex/TimeoffApprovalLWCCLS.getrequest';
//import getrequestdup from '@salesforce/apex/TimeoffApprovalLWCCLS.getTimeOffRequestInfo';
//import getentitlement from '@salesforce/apex/TimeoffApprovalLWCCLS.getentitlement';
import approveWorkerAbsenceRequest from '@salesforce/apex/TimeoffApprovalLWCCLS.approveWorkerAbsenceRequest';
import rejectWorkerAbsenceRequest from '@salesforce/apex/TimeoffApprovalLWCCLS.rejectWorkerAbsenceRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeoffApprovalLWCCLS extends LightningElement {    
    @track getlistrequests = [];
    //selectedDetail = null;
    @track getlistentitlements=[];
    approve=[];    
    @api recordId; 
    @track error;
    showForm = false;
    hidedetails=false;
    
    temp=[];
    notes;
    absencerequest;
    connectedCallback() {
        console.log('Record Id:', this.recordId);
    }
    
    hideModalBox() {  
        this.showForm = false
        //this.hidedetails=true;
    }
     @wire (getrequest) 
    wiredRequest({data,error}){ 
        if(error){
            console.log('error == '+JSON.stringify(error));
        }else if(data){
            
            console.log('data30== ', JSON.stringify(data));
            this.getlistrequests = JSON.parse(JSON.stringify(data));
            console.log('getdata===',this.getlistrequests);          
          //this.absencerequest=data.absentrequest;
        }
   }  
   /*@wire (getrequestdup) 
    wiredRequested({data,error}){ 
        if(error){
            console.log('error == '+JSON.stringify(error));
        }else if(data){
            
            this.absencerequest = JSON.parse(JSON.stringify(data));  
                   
         // this.absencerequest=data.absentrequest;
          console.log('data == ', this.absencerequest);
        }
   } 
   @wire (getentitlement,{ temp: 'temp'}) 
   wiredRequestabsence({data,error}){ 
       if(error){
           console.log('error == '+JSON.stringify(error));
       }else if(data){
           console.log('data == ', JSON.stringify(data));
           this.getlistentitlements = JSON.parse(JSON.stringify(data));   
           console.log('Timeofflst:', this.getlistentitlements);       

       }
  } */
  

   openModalBox(event) {
    this.showForm = true;
        const index = event.target.value;
        console.log('index == ', index);
        console.log('getlistrequests == ', this.getlistrequests); // Log the entire array
        this.recItem = this.getlistrequests[index];
        console.log('recItem == ', this.recItem);
        
    this.absencerequest=this.recItem;
    
                //this.hidedetails=false;
            
   // alert('this.absencerequest'+JSON.stringify(this.absencerequest));
       //this.getentitlement=this.recItems;
        
}
   

   handleApprove() {
    //alert('this.absencerequest1'+JSON.stringify(this.absencerequest));
     if (this.absencerequest !='') {
        approveWorkerAbsenceRequest({ abreq:this.absencerequest})
            .then(() => {
                this.showToast('Success', 'The TimeOffRequest  approved successfully', 'success');
                // Perform any other actions upon successful approval
                this.showForm = false;
                //this.hidedetails=true;
                //location.reload();
            })
            .catch(error => {
                console.error('Approval error:', error);
                this.showToast('Error', 'Failed to approve absence request', 'error');
            });
    } else {
        this.showToast('Error', 'Record Id not found', 'error');
    }
}
handleReject() {
    /*if (this.notes==null||this.notes=='') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please enter comments',
                variant: 'error'
            }) 
        );
        return;
    }
    else{*/
     if (this.absencerequest !='') {
        rejectWorkerAbsenceRequest({ abreq:this.absencerequest,comments:this.notes})
            .then(() => {
                this.showToast('Success', 'The TimeOffRequest  rejected successfully', 'success');
                // Perform any other actions upon successful approval
                this.showForm = false;
                //this.hidedetails=true;
                //location.reload();
            })
            .catch(error => {
                console.error('reject error:', error);
                this.showToast('Error', 'Failed to reject absence request', 'error');
            });
    } else {
        this.showToast('Error', 'Record Id not found', 'error');
    }
//}
}

showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant   
    });
    this.dispatchEvent(event);
}
   
}