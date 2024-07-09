import { LightningElement,api, wire,track } from 'lwc';
import getWorkers from '@salesforce/apex/DailySheetCntrlLWC.getWorkers';
import fetchDailySheetDetails from '@salesforce/apex/DailySheetCntrlLWC.fetchDailySheetDetails';
import saveDailySheetDetails from '@salesforce/apex/DailySheetCntrlLWC.saveDailySheetDetails';
import deleteRow from '@salesforce/apex/DailySheetCntrlLWC.deleteRow';
import getProjTask from '@salesforce/apex/DailySheetCntrlLWC.getProjTask';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import timeSheetIcon from '@salesforce/resourceUrl/HRMSUS__HRMSFiles';

export default class DailySheetLWC extends LightningElement {
    timeSheetIcon = timeSheetIcon + '/HRMSFiles/markers/time_sheet.png';
    workers =[];
    @track selectedWorkerId;
    @track records;
    @track data = [ ];
    @track commentslist =[];
    @track  dailysheets = [];
    @track index;
    lstResult=[];
    customerId;
    @track selectedDate = '';
  //  dynamicWhereCondition = 'HRMSUS__Account__c = null';
   // dynamicWhereConditionTask ='HRMSUS__Project__c = null';
    @track isShowComments = false;
    @track isShowModal = false;
    @track totalHoursEntry= false;
    @track timeFormatCustomSetting= false;
    @track selectedValue = '';
    @api totalsum='00.00';
    @track selectedComments ='';
    DailysheetConfigCustomeSetting ;
    productOptions = [
        {   label: 'None',
            value: 'None',
        },
        {   label: 'AM',
            value: 'AM',
        },
        {   label: 'PM',
            value: 'PM',
        },
    ];
    connectedCallback() {
        // Load the CSS file when the component is connected to the DOM
      
    }
  /*  connectedCallback() {
        // Set the default value of selectedDate to today's date
        const today = new Date();
        const formattedDate = today.toISOString().slice(0, 10); // Format: YYYY-MM-DD
        this.selectedDate = formattedDate;
    }*/
   
    @wire(getWorkers)
    wiredWorkers({ error, data }) {
        if (data) {      
            console.log('data:', data);  
            if(data.lstPer){
            this.workers = data.lstPer.map(worker => ({
                label: worker.Name,
                value: worker.Id
            }));
          
        }
            if( data.per){
            this.selectedWorkerId = data.per[0].Id;
            if (this.workers.length === 0) {
                this.workers = data.per.map(worker => ({
                    label: worker.Name,
                    value: worker.Id
                }));
            }
            }  
            
        } else if (error) {
            console.error('Error fetching worker records:', error);
        }
        console.log('workers:', this.workers);
        const today = new Date();
        const formattedDate = today.toISOString().slice(0, 10); // Format: YYYY-MM-DD
        this.selectedDate = formattedDate;
        if(this.selectedWorkerId && this.selectedDate){ 
        this.retrieveDailySheetDetails();
        }
    }

    handleWorkerChange(event){
            this.selectedWorkerId =event.target.value;
             console.log('selectedWorkerId:', this.selectedWorkerId);
             if(this.selectedWorkerId && this.selectedDate){ 
                this.retrieveDailySheetDetails();
                }
    }

    changedate(event){
        this.selectedDate = event.target.value;
            // You can perform any further actions with the selectedDate here
            console.log('Selected date:', this.selectedDate);   
            this.data=[];     
            if(this.selectedWorkerId && this.selectedDate){ 
                this.retrieveDailySheetDetails();
                }    
    }
    handleDayPrevious(){
        const selectedDatePrevious = this.selectedDate; // Replace this with your actual date
        // Parse the selectedDate string into a Date object
        const currentDate = new Date(selectedDatePrevious);
        // Subtract one day
        currentDate.setDate(currentDate.getDate() - 1);
        // Format the new date as a string (YYYY-MM-DD)
        const formattedDatePrevious = currentDate.toISOString().slice(0, 10);
        // Update selectedDate with the new value
        this.selectedDate = '';
        this.selectedDate = formattedDatePrevious;
        this.data=[];
        if(this.selectedWorkerId && this.selectedDate){ 
            this.retrieveDailySheetDetails(); 
            } 
    }
    handleDayNext(){
        const selectedDateNext = this.selectedDate; // Replace this with your actual date
        // Parse the selectedDate string into a Date object
        const currentDate = new Date(selectedDateNext);
        // Subtract one day
        currentDate.setDate(currentDate.getDate() + 1);
        // Format the new date as a string (YYYY-MM-DD)
        const formattedDateNext = currentDate.toISOString().slice(0, 10);
        // Update selectedDate with the new value
        this.selectedDate = '';
        this.selectedDate = formattedDateNext;
        this.data=[];
        if(this.selectedWorkerId && this.selectedDate){ 
           this.retrieveDailySheetDetails(); 
            }   
    }
  
    retrieveDailySheetDetails() {
       /* if(this.selectedWorkerId && this.selectedDate){
            this.data =[];*/
            fetchDailySheetDetails({ emp:this.selectedWorkerId, dates: this.selectedDate })
                .then(result => {
                    // Process the result here
                    let res = JSON.parse(result).MapSo;
                    let values = JSON.parse(result).dsConfig;
                    this.data =JSON.parse(result).MapSo['HRMSUS__Daily_Sheet__c'];                 
                //    this.workers = person;
                    this.totalHoursEntry =values.HRMSUS__Total_Hour_Entry__c;
                    this.timeFormatCustomSetting = values.HRMSUS__Time_Format__c;
                    this.DailysheetConfigCustomeSetting = values;
                    
                    console.log('res:', res);
                    console.log('data:', this.data);
                    if(!this.totalHoursEntry){
                   let sumtotal = 0;
                    for (let i = 0; i < this.data.length; i++) {
                        sumtotal += this.data[i].HRMSUS__Total__c;
                        if (this.data[i].HRMSUS__Start_Time_Hrs__c && this.data[i].HRMSUS__Start_Time_Hrs__c < 10) {                      
                            this.data[i].HRMSUS__Start_Time_Hrs__c = '0' + this.data[i].HRMSUS__Start_Time_Hrs__c.toString();
                            console.log(this.data[i].HRMSUS__Start_Time_Hrs__c);
                        }else if(this.data[i].HRMSUS__Start_Time_Hrs__c == 0){
                            this.data[i].HRMSUS__Start_Time_Hrs__c = '00';
                        }
                        if (this.data[i].HRMSUS__Start_Time_Mns__c && this.data[i].HRMSUS__Start_Time_Mns__c < 10) {
                            this.data[i].HRMSUS__Start_Time_Mns__c = '0' + this.data[i].HRMSUS__Start_Time_Mns__c.toString();
                            console.log(this.data[i].HRMSUS__Start_Time_Mns__c);
                        }else if(this.data[i].HRMSUS__Start_Time_Mns__c == 0){
                            this.data[i].HRMSUS__Start_Time_Mns__c = '00';
                        }
                        if (this.data[i].HRMSUS__End_Time_Hrs__c && this.data[i].HRMSUS__End_Time_Hrs__c < 10) {
                            this.data[i].HRMSUS__End_Time_Hrs__c = '0' + this.data[i].HRMSUS__End_Time_Hrs__c.toString();
                            console.log(this.data[i].HRMSUS__End_Time_Hrs__c);
                        }else if(this.data[i].HRMSUS__End_Time_Hrs__c == 0){
                            this.data[i].HRMSUS__End_Time_Hrs__c = '00';
                        }
                        
                        if ( this.data[i].HRMSUS__End_Time_Mns__c && this.data[i].HRMSUS__End_Time_Mns__c < 10) {
                            this.data[i].HRMSUS__End_Time_Mns__c = '0' + this.data[i].HRMSUS__End_Time_Mns__c.toString();
                            console.log(this.data[i].HRMSUS__End_Time_Mns__c);
                        }else if(this.data[i].HRMSUS__End_Time_Mns__c == 0){
                            this.data[i].HRMSUS__End_Time_Mns__c = '00';
                        }
                        if(this.data[i].HRMSUS__Total__c >0){
                            this.data[i].HRMSUS__Total__c =this.data[i].HRMSUS__Total__c.toFixed(2)
                        }
                    }
                    this.totalsum = sumtotal;
                    console.log('totalsum:', this.totalsum);
                }
                })
                .catch(error => {
                    this.selectedDate = undefined;
                    this.data=undefined;
                    // Handle any errors
                    console.error('Error fetching daily sheet details:', error);
                });
    //    }
    }
    addRow() {
       /* const newRow = { id: '',
            // sobjectType:'HRMSUS__Daily_Sheet__c',
             HRMSUS__Employee__c:this.selectedWorkerId,
             HRMSUS__Date__c: this.selectedDate,
             HRMSUS__Customer__c: '',
             HRMSUS__Project__c :'',
             HRMSUS__Task__c:'',
             HRMSUS__Start_Time_Hrs__c:'', 
             HRMSUS__Start_Time_Mns__c:'',
             HRMSUS__St_Meridian__c:'',
             HRMSUS__End_Time_Hrs__c:'',
             HRMSUS__End_Time_Mns__c:'',                
             HRMSUS__En_Meridian__c:'',
             HRMSUS__Billable__c: '' ,
             HRMSUS__Start_Times__c:  '' ,
             HRMSUS__End_Times__c:  '' ,
             HRMSUS__Type__c:'',
             HRMSUS__Total__c:0}; // Create a new row

        // Update the data array
        this.data = [...this.data, newRow];*/
        let RowItemList = [...this.data];
        if (RowItemList.length > 0) {
            RowItemList.push({
                sobjectType: 'HRMSUS__Daily_Sheet__c',
                Id: '',
                HRMSUS__Employee__c: this.selectedWorkerId,
                HRMSUS__Date__c: this.selectedDate,
                HRMSUS__Customer__c: '',
                HRMSUS__Project__c: '',
                HRMSUS__Task__c: '',
                HRMSUS__Start_Time_Hrs__c: '',
                HRMSUS__Start_Time_Mns__c: '',
                HRMSUS__St_Meridian__c: 'None',
                HRMSUS__End_Time_Hrs__c: '',
                HRMSUS__End_Time_Mns__c: '',
                HRMSUS__En_Meridian__c: 'None',
                HRMSUS__Billable__c: this.DailysheetConfigCustomeSetting.HRMSUS__Default_Billable__c,
                HRMSUS__Start_Times__c: '',
                HRMSUS__End_Times__c: '',
                HRMSUS__Type__c:'',
                HRMSUS__Total__c: 0,
            });
        } else {
            RowItemList.push({
                sobjectType: 'HRMSUS__Daily_Sheet__c',
                HRMSUS__Employee__c: this.selectedWorkerId,
                HRMSUS__Date__c: this.selectedDate,
                HRMSUS__Customer__c: '',
                HRMSUS__Project__c: '',
                HRMSUS__Task__c: '',
                HRMSUS__Start_Time_Hrs__c: '',
                HRMSUS__Start_Time_Mns__c: '',
                HRMSUS__St_Meridian__c: 'None',
                HRMSUS__End_Time_Hrs__c: '',
                HRMSUS__End_Time_Mns__c: '',
                HRMSUS__En_Meridian__c: 'None',
                HRMSUS__Billable__c:this.DailysheetConfigCustomeSetting.HRMSUS__Default_Billable__c,
                HRMSUS__Start_Times__c: '',
                HRMSUS__End_Times__c: '',
                HRMSUS__Type__c:'',
                HRMSUS__Total__c: 0,
            });
        }

        this.data = RowItemList;

    }
    deleteRow(event) {  
        this.isShowModal = true;
        this.index = event.target.dataset.index; 
    }
    hideModalBox() {  
        this.isShowModal = false;
    }
    hideModalCommentsBox(){
        this.isShowComments= false;
    }
    updateCommentsBox(event){
        this.isShowComments = true;
        this.index = event.target.dataset.index; 
        this.selectedComments = this.data[this.index].HRMSUS__Comments__c;
        let taskId = this.data[this.index].HRMSUS__Task__c;

        getProjTask({ projectId:taskId })
                .then(result => {
                    // Process the result here
              this.commentslist = result;
                    console.log('result:', result);
                    
                    // Assign the result to a property if needed to display in the UI
                })
                .catch(error => {
                    // Handle any errors
                    console.error('Error fetching daily sheet details:', error);
                });

    }
    onCheck(event) {
        // Get the index from the event
        let index = event.target.dataset.index;
        console.log('index', index);

        let selectedCmts = [];
        let getAllId = this.template.querySelectorAll('[data-id="ckbox"]');

        getAllId.forEach((checkbox) => {
            if (checkbox.checked) {
                selectedCmts.push(checkbox.value);
            }
        });

        console.log('selected comments ***', selectedCmts);
        console.log('selected comments conversion from array to string', selectedCmts.toString());

        if (this.selectedComments !== null && this.selectedComments !== undefined) {
            this.selectedComments = this.selectedComments + ',' + selectedCmts.toString();
        } else {
            this.selectedComments = selectedCmts.toString();
        }

        console.log('selected comments', this.selectedComments);
    }
    handleChangeComments(event){
        this.selectedComments = event.target.value;
    }
    saveComments(){
        const comments = this.selectedComments;
        const selectedIndex = this.index;
        this.data[selectedIndex].HRMSUS__Comments__c = comments;
       /* this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item,  HRMSUS__Comments__c  : comments  };
            }  
            return item;
        }); */
        this.data = [...this.data];
        this.isShowComments= false;
        console.log( JSON.stringify(this.data));  
    }
    deleteSelectedRow(){
        const index = this.index;
        // Get the index of the row to delete
        let allRowsList = [...this.data];
        console.log('AllRowsList', allRowsList);
        if (allRowsList[index]['Id']) {
            let rec = {
                sobjectType: 'HRMSUS__Daily_Sheet__c',
                Id: allRowsList[index]['Id'],
                HRMSUS__Employee__c: this.selectedWorkerId,
                HRMSUS__Date__c: allRowsList[index]['HRMSUS__Date__c'],
                HRMSUS__Customer__c: allRowsList[index]['HRMSUS__Customer__c'],
                HRMSUS__Project__c: allRowsList[index]['HRMSUS__Project__c'],
                HRMSUS__Task__c: allRowsList[index]['HRMSUS__Task__c'],
                HRMSUS__Start_Time_Hrs__c: allRowsList[index]['HRMSUS__Start_Time_Hrs__c'],
                HRMSUS__St_Time__c: allRowsList[index]['HRMSUS__St_Time__c'],
                HRMSUS__St_Meridian__c: allRowsList[index]['HRMSUS__St_Meridian__c'],
                HRMSUS__End_Time__c: allRowsList[index]['HRMSUS__End_Time__c'],
                HRMSUS__En_min__c: allRowsList[index]['HRMSUS__En_min__c'],
                HRMSUS__En_Meridian__c: allRowsList[index]['HRMSUS__En_Meridian__c'],
                HRMSUS__Billable__c: allRowsList[index]['HRMSUS__Billable__c'],
                HRMSUS__Total__c: allRowsList[index]['HRMSUS__Total__c']
            };

            deleteRow({ record: rec })
                .then(result => {
                    console.log('data[index]', this.data[index]);
                    // Handle success
                   
                    allRowsList.splice(index, 1);
                    this.data = [...allRowsList];
                    let sumtotal = 0;
                    for (let i = 0; i < this.data.length; i++) {
                        sumtotal += this.data[i].HRMSUS__Total__c;
                    }
                    this.totalsum= sumtotal;
                   // this.dispatchEvent(new CustomEvent('deleterow', { detail: allRowsList }));
                    this.showToast('Success!', 'Record Deleted successfully','success');
                    this.isShowModal = false;
                    
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.showToast('Error!', error.body.message || 'Unknown error','error');
                    this.isShowModal = false;
                });
        }
        else{
        this.data.splice(index, 1); // Remove the row from the data array using splice
        this.data = [...this.data]; // Reassign the array to trigger reactivity 
        this.showToast('Success!', 'Record Deleted successfully','success'); 
        this.isShowModal = false;
       }
       
}
cloneRow(event) {
    let index =event.target.dataset.index;
    let AllRowsList = [...this.data];
    let stHH, stMM, stMR, sttm, edtm;

    if (AllRowsList.length > 0 && AllRowsList[AllRowsList.length - 1].HRMSUS__End_Time_Hrs__c !== undefined &&
        AllRowsList[AllRowsList.length - 1].HRMSUS__End_Time_Mns__c !== undefined &&
        AllRowsList[AllRowsList.length - 1].HRMSUS__En_Meridian__c !== undefined) {

        stHH = AllRowsList[AllRowsList.length - 1].HRMSUS__End_Time_Hrs__c;
        stMM = AllRowsList[AllRowsList.length - 1].HRMSUS__End_Time_Mns__c;
        stMR = AllRowsList[AllRowsList.length - 1].HRMSUS__En_Meridian__c;
        sttm = AllRowsList[AllRowsList.length - 1].HRMSUS__Start_Times__c;
        edtm = AllRowsList[AllRowsList.length - 1].HRMSUS__End_Times__c;
    }

    if (AllRowsList[index]) {
        if (this.timeFormatCustomSetting) {
            stMR = 0;
        }

        if (stHH === undefined && stMM === undefined) {
            stHH = 0;
            stMM = 0;
            stMR = 0;
        }

        let rec = {
            'sobjectType': 'HRMSUS__Daily_Sheet__c',
            'HRMSUS__Employee__c': this.selectedWorkerId,
            'HRMSUS__Date__c': AllRowsList[index].HRMSUS__Date__c,
            'HRMSUS__Customer__c': AllRowsList[index].HRMSUS__Customer__c,
            'HRMSUS__Project__c': AllRowsList[index].HRMSUS__Project__c,
            'HRMSUS__Task__c': AllRowsList[index].HRMSUS__Task__c,
            'HRMSUS__Start_Times__c': AllRowsList[index].HRMSUS__End_Times__c,
            'HRMSUS__Start_Time_Hrs__c': stHH >= 0 ? stHH : '',
            'HRMSUS__Start_Time_Mns__c': stMM >= 0 ? stMM : '',
            'HRMSUS__St_Meridian__c': stMR,
            'HRMSUS__End_Time__c': '',
            'HRMSUS__En_min__c': '',
            'HRMSUS__En_Meridian__c': '',
            'HRMSUS__Total__c': '0',
            'HRMSUS__Type__c' :  AllRowsList[index].HRMSUS__Type__c,
            'HRMSUS__Billable__c': AllRowsList[index].HRMSUS__Billable__c,
        };

        AllRowsList.push(rec);
        this.data = AllRowsList;
    }
}
    lookupRecord(event){
        try {
            console.log(event.detail.selectedRecord.Id);
      // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
      const selectedRecord = event.detail.selectedRecord;
      const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Customer__c: selectedRecord.Id };
            }  
            return item;
        });
        console.log('data',this.data);
            return 'Value successfully removed';
        } catch (error) {
            console.error('Error:', error);
            const selectedIndex = event.target.dataset.index;
            this.data = this.data.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Customer__c: ''};
                }  
                return item;
            });
            console.log('data',this.data);
            return 'Error occurred while removing value';
        }
       
    }
    lookupRecordProject(event){
        try {
            console.log(event.detail.selectedRecord.Id);
    // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
    const selectedRecord = event.detail.selectedRecord;
    const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Project__c: selectedRecord.Id };
            }  
            return item;
        });
    console.log(this.data);
            return 'Value successfully removed';
        } catch (error) {
            const selectedIndex = event.target.dataset.index;
            this.data = this.data.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Project__c: '' };
                }  
                return item;
            });
            console.error('Error:', error);
            return 'Error occurred while removing value';
        }
    }
    lookupRecordTask(event){
            try {
                console.log(event.detail.selectedRecord.Id);
        // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
        const selectedRecord = event.detail.selectedRecord;
        const selectedIndex = event.target.dataset.index;
            this.data = this.data.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Task__c: selectedRecord.Id,
                                    HRMSUS__Type__c:selectedRecord.Name
                        };
                }  
                return item;
            });
            console.log( this.data);
                return 'Value successfully removed';
            } catch (error) {
                const selectedIndex = event.target.dataset.index;
            this.data = this.data.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Task__c: '',
                                    HRMSUS__Type__c:''
                        };
                }  
                return item;
            });
                console.error('Error:', error);
                return 'Error occurred while removing value';
            }
            
    }
    handleStartDateTimeChange(event){
        const startTime = event.target.value;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Start_Times__c : startTime  };
            }  
            return item;
        });
    }
    handleEndDateTimeChange(event){
        const endTime = event.target.value;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__End_Times__c : endTime  };
            }  
            return item;
        });
    }
    handleChangeStartTimeHours(event){
        let inputValue = event.target.value;
        // Ensure the input value is a two-digit number
        if (inputValue.length > 2) {
            // If more than two digits, truncate to two digits
            inputValue = inputValue.slice(0, 2);
            
        }
        // Update the input value
        event.target.value = inputValue;
        const startTime = event.target.value;
        const selectedIndex = event.target.dataset.index;
      //  this.index= event.target.dataset.index;
        if (startTime.length === 2) {
            const currentInput = event.target;
            const nextInput = currentInput.closest('td').nextElementSibling.querySelector('input');
            if (nextInput) {
                nextInput.focus();
            }
        }
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Start_Time_Hrs__c : startTime  };
            }  
            return item;
        });
       
    }
    handleChangeStartTimeMns(event){
        let inputValue = event.target.value;
        // Ensure the input value is a two-digit number
        if (inputValue.length > 2) {
            // If more than two digits, truncate to two digits
            inputValue = inputValue.slice(0, 2);
        }
        // Update the input value
        event.target.value = inputValue;
        const startTimeMns = event.target.value;
        const selectedIndex = event.target.dataset.index;
        if (startTimeMns.length === 2) {
            const currentInput = event.target;
            const nextInput = currentInput.closest('td').nextElementSibling.querySelector('lightning-select');
            if (nextInput) {
                nextInput.focus();
            }
        }
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Start_Time_Mns__c : startTimeMns  };
            }  
            return item;
        });
    }
    handleChangeStartTimeMeridian(event){
        const startTimeMeridian = event.target.value;
        const selectedIndex = event.target.dataset.index;
        if (startTimeMeridian === 'AM' || startTimeMeridian === 'PM') {
            const currentInput = event.target;
            const nextInput = currentInput.closest('td').nextElementSibling.querySelector('input');
            if (nextInput) {
                nextInput.focus();
            }
        }
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__St_Meridian__c : startTimeMeridian  };
            }  
            return item;
        });
    }
    handleChangeEndTimeHours(event){
        let inputValue = event.target.value;
        // Ensure the input value is a two-digit number
        if (inputValue.length > 2) {
            // If more than two digits, truncate to two digits
            inputValue = inputValue.slice(0, 2);
        }
        // Update the input value
        event.target.value = inputValue;
        const endTime = event.target.value;
        const selectedIndex = event.target.dataset.index;
        if (endTime.length === 2) {
            const currentInput = event.target;
            const nextInput = currentInput.closest('td').nextElementSibling.querySelector('input');
            if (nextInput) {
                nextInput.focus();
            }
        }
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__End_Time_Hrs__c : endTime  };
            }  
            return item;
        });
    }
    handleChangeEndTimeMns(event){
        let inputValue = event.target.value;
        // Ensure the input value is a two-digit number
        if (inputValue.length > 2) {
            // If more than two digits, truncate to two digits
            inputValue = inputValue.slice(0, 2);
        }
        // Update the input value
        event.target.value = inputValue;
        const endTimeMns = event.target.value;
        const selectedIndex = event.target.dataset.index;
        if (endTimeMns.length === 2) {
            const currentInput = event.target;
            const nextInput = currentInput.closest('td').nextElementSibling.querySelector('lightning-select');
            if (nextInput) {
                nextInput.focus();
            }
        }
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__End_Time_Mns__c : endTimeMns  };
            }  
            return item;
        });
        
    }
    handleChangeEndTimeMeridian(event){
        const endTimeMeridian = event.target.value;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__En_Meridian__c : endTimeMeridian  };
            }  
            return item;
        });
    }

    updateTotal(event){
        const total =  event.target.value;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Total__c : total  };
            }  
            return item;
        });
    }
    updateBill(event){
        const bill =  event.target.checked;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item,  HRMSUS__Billable__c  : bill  };
            }  
            return item;
        });
    }
    updateComments(event){
        const comments =  event.target.value;
        const selectedIndex = event.target.dataset.index;
        this.data = this.data.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item,  HRMSUS__Comments__c  : comments  };
            }  
            return item;
        }); 
        console.log( JSON.stringify(this.data)); 
    }
    
    handleSave(){
        for (let i = 0; i < this.data.length; i++) {
            let row = 'row '+(i+1);
        if(this.data[i].HRMSUS__Customer__c === "" ||this.data[i].HRMSUS__Project__c === "" ||this.data[i].HRMSUS__Task__c === "" ){
            this.dispatchEvent( new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Customer, Project and Task on ' +row,
                    variant: 'Error'
                }));
            return false;
        }
        if(this.timeFormatCustomSetting){
        if(this.data[i].HRMSUS__Start_Times__c === "" ||this.data[i].HRMSUS__Start_Times__c === null){
            this.dispatchEvent( new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Start Time on '+row,
                    variant: 'Error'
                })  );
            return false;
        }
        if(this.data[i].HRMSUS__End_Times__c === "" || this.data[i].HRMSUS__End_Times__c === null ){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter End Time on '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
        if(this.data[i].HRMSUS__Start_Times__c === this.data[i].HRMSUS__End_Times__c){
                 this.dispatchEvent( new ShowToastEvent({
                    title: 'Error',
                    message: 'Start Time should not be equal to End Time on '+row,
                    variant: 'Error'
                })  );
             return false;
        }
        }
        if(this.DailysheetConfigCustomeSetting.HRMSUS__Number_Entry__c){
            if(this.data[i].HRMSUS__Start_Time_Hrs__c === "" ||this.data[i].HRMSUS__Start_Time_Hrs__c === null ||this.data[i].HRMSUS__Start_Time_Mns__c === "" ||this.data[i].HRMSUS__Start_Time_Mns__c === null){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter Start Time on '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
            if(this.data[i].HRMSUS__St_Meridian__c === "" || this.data[i].HRMSUS__St_Meridian__c === "None" ){
                this.dispatchEvent( new ShowToastEvent({
                   title: 'Error',
                   message: 'Please Select Start Time Meridian on '+row,
                   variant: 'Error'
               })  );
            return false;
       }
            if(this.data[i].HRMSUS__End_Time_Hrs__c === "" || this.data[i].HRMSUS__End_Time_Hrs__c === null || this.data[i].HRMSUS__End_Time_Mns__c === "" || this.data[i].HRMSUS__End_Time_Mns__c === null ){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter End Time on '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
            if(this.data[i].HRMSUS__En_Meridian__c === "" || this.data[i].HRMSUS__En_Meridian__c === "None" ){
                this.dispatchEvent( new ShowToastEvent({
                   title: 'Error',
                   message: 'Please Select End Time Meridian on '+row,
                   variant: 'Error'
               })  );
            return false;
           }
            if(this.data[i].HRMSUS__Start_Time_Hrs__c === this.data[i].HRMSUS__End_Time_Hrs__c && this.data[i].HRMSUS__Start_Time_Mns__c === this.data[i].HRMSUS__End_Time_Mns__c && this.data[i].HRMSUS__St_Meridian__c === this.data[i].HRMSUS__En_Meridian__c ){
                    this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Start Time should not equal End Time on '+row,
                        variant: 'Error'
                        })  );
                       return false;
                 }
            if(this.data[i].HRMSUS__Start_Time_Hrs__c > 12){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Start time hours should not be more than 12 at '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
            if(this.data[i].HRMSUS__Start_Time_Mns__c > 59){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'Start time minutes should not be more than 59 at '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
            if(this.data[i].HRMSUS__End_Time_Hrs__c > 12){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'End time hours should not be more than 12 at '+row,
                        variant: 'Error'
                    })  );
                return false;
            }
            if(this.data[i].HRMSUS__End_Time_Mns__c > 59){
                this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: 'End time minutes should not be more than 59 at '+row,
                        variant: 'Error'
                    })  );
                return false;
            }

        }
    }
        if(this.totalHoursEntry){
            let dsdevcode ='';
            const map = new Map();
            let sumHours=0;
    for (let i = 0; i < this.data.length; i++) {
       dsdevcode = this.selectedWorkerId +  this.selectedDate + this.data[i].HRMSUS__Customer__c + this.data[i].HRMSUS__Project__c  + this.data[i].HRMSUS__Task__c + this.data[i].HRMSUS__Billable__c;
        console.log('@@dsdevcode@@', dsdevcode);

        if (!map.has(dsdevcode)) {
            console.log('@@key check@@', map.has(dsdevcode));
            map.set(dsdevcode, dsdevcode);
        } else {
            const toastMsg = 'Multiple time entries are not allowed if they share the same Customer, Project, Task, and Billable values. Please review and consolidate, or change your conflicting time entry lines via one of the above aspects to save.';
            this.showToast('Error!', toastMsg ,'error');
            return false;
        }
        if(this.data[i].HRMSUS__Total__c === 0){
            const toastMsg = 'Total Hours should not be Zero';
            this.showToast('Error!', toastMsg ,'error');
            return false;
        }
        if(this.data[i].HRMSUS__Total__c=== "" || this.data[i].HRMSUS__Total__c=== null){
            const toastMsg = 'Total Hours cannot be null';
            this.showToast('Error!', toastMsg ,'error');
            return false;
        }
        let totalHours = parseInt(this.data[i].HRMSUS__Total__c, 10);
        // Add the converted value to sumHour
        sumHours += totalHours;
         if(sumHours > 24){
            const toastMsg = 'Total Hours should not more than 24 hours';
            this.showToast('Error!', toastMsg ,'error')
            return false;
        }
    }
            this.dailysheets =[];
            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].Id) {
                    console.log('Dailysheets If condition');
                    this.dailysheets.push({
                        Id: this.data[i].Id,
                        HRMSUS__Employee__c: this.selectedWorkerId,
                        HRMSUS__Date__c: this.selectedDate,
                        HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                        HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                        HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                        HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                        HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                        HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                        HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                    });
                } else {
                    console.log('Dailysheets else condition');
                    this.dailysheets.push({
                        HRMSUS__Employee__c: this.selectedWorkerId,
                        HRMSUS__Date__c: this.selectedDate,
                        HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                        HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                        HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                        HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                        HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                        HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                        HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                    });
                }
        }

    }else if(this.timeFormatCustomSetting){
        this.dailysheets =[];
        for (let i = 0; i < this.data.length; i++) {
            let sttm =  this.data[i].HRMSUS__Start_Times__c;
            let ettm =  this.data[i].HRMSUS__End_Times__c;
            let startHrs;let startmn;let startMD; let endhrs;let endmn;let endMd;
            if(sttm!=null && ettm!=null){
            startHrs=sttm.split(':')[0];
            startmn=sttm.split(':')[1];
            endhrs=ettm.split(':')[0];
            endmn=ettm.split(':')[1];
               
                if(startHrs < 12){          
                    this.data[i].HRMSUS__St_Meridian__c = 'AM';
                }		
                if(startHrs >= 12){                        
                        this.data[i].HRMSUS__St_Meridian__c = 'PM';
                }
                 if(endhrs < 12){                        
                    this.data[i].HRMSUS__En_Meridian__c = 'AM';                       
                }
                if(endhrs >= 12){
                    this.data[i].HRMSUS__En_Meridian__c = 'PM';
                }
            } 
            console.log('ST Mer',this.data[i].HRMSUS__St_Meridian__c);
            console.log('ET Mer',this.data[i].HRMSUS__En_Meridian__c);
            if (this.data[i].Id) {
                console.log('Dailysheets If condition');
                this.dailysheets.push({
                    Id: this.data[i].Id,
                    HRMSUS__Employee__c: this.selectedWorkerId,
                    HRMSUS__Date__c: this.selectedDate,
                    HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                    HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                    HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                    HRMSUS__Start_Time_Hrs__c: startHrs,
                    HRMSUS__Start_Time_Mns__c: startmn,                  
                    HRMSUS__End_Time_Hrs__c: endhrs,
                    HRMSUS__End_Time_Mns__c: endmn,                  
                    HRMSUS__St_Meridian__c: this.data[i].HRMSUS__St_Meridian__c,               
                    HRMSUS__En_Meridian__c: this.data[i].HRMSUS__En_Meridian__c,
                    HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                    HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                    HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                    HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                    HRMSUS__Start_Times__c:this.data[i].HRMSUS__Start_Times__c,
                    HRMSUS__End_Times__c:this.data[i].HRMSUS__End_Times__c,
                });
            } else {
                console.log('Dailysheets else condition');
                this.dailysheets.push({
                    HRMSUS__Employee__c: this.selectedWorkerId,
                    HRMSUS__Date__c: this.selectedDate,
                    HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                    HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                    HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                    HRMSUS__Start_Time_Hrs__c: startHrs,
                    HRMSUS__Start_Time_Mns__c: startmn,                  
                    HRMSUS__End_Time_Hrs__c: endhrs,
                    HRMSUS__End_Time_Mns__c: endmn,                  
                    HRMSUS__St_Meridian__c: this.data[i].HRMSUS__St_Meridian__c,               
                    HRMSUS__En_Meridian__c: this.data[i].HRMSUS__En_Meridian__c,
                    HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                    HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                    HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                    HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                    HRMSUS__Start_Times__c:this.data[i].HRMSUS__Start_Times__c,
                    HRMSUS__End_Times__c:this.data[i].HRMSUS__End_Times__c,
                });
            }
    }
    }else{      
        this.dailysheets =[];    
        for (let i = 0; i < this.data.length; i++) {               
        if (this.data[i].Id) {
            console.log('Dailysheets If condition');
            this.dailysheets.push({
                Id: this.data[i].Id,
                HRMSUS__Employee__c: this.selectedWorkerId,
                HRMSUS__Date__c: this.selectedDate,
                HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                HRMSUS__Start_Time_Hrs__c:  this.data[i].HRMSUS__Start_Time_Hrs__c,
                HRMSUS__Start_Time_Mns__c:  this.data[i].HRMSUS__Start_Time_Mns__c,                  
                HRMSUS__End_Time_Hrs__c:  this.data[i].HRMSUS__End_Time_Hrs__c,
                HRMSUS__End_Time_Mns__c:  this.data[i].HRMSUS__End_Time_Mns__c,                  
                HRMSUS__St_Meridian__c: this.data[i].HRMSUS__St_Meridian__c,               
                HRMSUS__En_Meridian__c: this.data[i].HRMSUS__En_Meridian__c,
                HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                HRMSUS__Start_Times__c:this.data[i].HRMSUS__Start_Times__c,
                HRMSUS__End_Times__c:this.data[i].HRMSUS__End_Times__c,
            });
        } else {
            console.log('Dailysheets else condition');
            this.dailysheets.push({
                HRMSUS__Employee__c: this.selectedWorkerId,
                HRMSUS__Date__c: this.selectedDate,
                HRMSUS__Customer__c: this.data[i].HRMSUS__Customer__c,
                HRMSUS__Project__c: this.data[i].HRMSUS__Project__c,
                HRMSUS__Task__c: this.data[i].HRMSUS__Task__c,
                HRMSUS__Start_Time_Hrs__c:  this.data[i].HRMSUS__Start_Time_Hrs__c,
                HRMSUS__Start_Time_Mns__c:  this.data[i].HRMSUS__Start_Time_Mns__c,                  
                HRMSUS__End_Time_Hrs__c:  this.data[i].HRMSUS__End_Time_Hrs__c,
                HRMSUS__End_Time_Mns__c:  this.data[i].HRMSUS__End_Time_Mns__c,                  
                HRMSUS__St_Meridian__c: this.data[i].HRMSUS__St_Meridian__c,               
                HRMSUS__En_Meridian__c: this.data[i].HRMSUS__En_Meridian__c,
                HRMSUS__Billable__c: this.data[i].HRMSUS__Billable__c,
                HRMSUS__Comments__c: this.data[i].HRMSUS__Comments__c,
                HRMSUS__Total__c: this.data[i].HRMSUS__Total__c,
                HRMSUS__Type__c:this.data[i].HRMSUS__Type__c,
                HRMSUS__Start_Times__c:this.data[i].HRMSUS__Start_Times__c,
                HRMSUS__End_Times__c:this.data[i].HRMSUS__End_Times__c,
            });
        }  } }
    
        let flag = false;
        let errorMsg = false;
        let fTimeArray1 = [];
    if(!this.totalHoursEntry){
        for (let i = 0; i < this.dailysheets.length; i++) {
            let sHour;
            let stMin;
            let stAmPm;
            let eHour;
            let etMin;
            let etAmPm;

            if (this.dailysheets[i].HRMSUS__Start_Time_Hrs__c != null) {
                sHour = this.dailysheets[i].HRMSUS__Start_Time_Hrs__c;
                stMin = this.dailysheets[i].HRMSUS__Start_Time_Mns__c;
                stAmPm = this.dailysheets[i].HRMSUS__St_Meridian__c;
                if (stAmPm == 'PM') {
                    if (sHour < 12)
                        sHour = parseInt(sHour) + 12;
                } else if (stAmPm == 'AM' && sHour == '12')
                    sHour = parseInt(sHour) - 12;
                else
                    sHour = parseInt(sHour);
            }

            if (this.dailysheets[i].HRMSUS__End_Time_Hrs__c != null) {
                eHour = this.dailysheets[i].HRMSUS__End_Time_Hrs__c;
                etMin = this.dailysheets[i].HRMSUS__End_Time_Mns__c;
                etAmPm = this.dailysheets[i].HRMSUS__En_Meridian__c;
                if (etAmPm == 'PM') {
                    if (eHour < 12)
                        eHour = parseInt(eHour) + 12;
                } else if (etAmPm == 'AM' && eHour == '12')
                    eHour = parseInt(eHour) - 12;
                else
                    eHour = parseInt(eHour);
            }
           
                let customer = this.dailysheets[i].HRMSUS__Customer__c;
               /* if (!DailysheetConfigCustomeSetting.HRMSUS__Customer_Enable__c ) {
                    customer = DailysheetConfigCustomeSetting.HRMSUS__Internal_Account_Id__c;
                }*/
                
                let project = this.dailysheets[i].HRMSUS__Project__c;
             /*   if (!DailysheetConfigCustomeSetting.HRMSUS__Project_Enable__c) {
                    project =  DailysheetConfigCustomeSetting.HRMSUS__Internal_Project_Id__c;
                }*/

                let total = this.dailysheets[i].HRMSUS__Total__c;
                console.log('total', total);
            console.log('this.data[i].HRMSUS__Date__c -->'+this.dailysheets[i].HRMSUS__Date__c );           
            const str = this.dailysheets[i].HRMSUS__Date__c;
            let sd = str.substr(0, 10);
            console.log('sd-->'+sd);                    
            let sdatetime = new Date(sd + ' ' + sHour + ':' + stMin + ':00.000');                                       
            console.log('sdatetime-->'+sdatetime);                                
            let edatetime = new Date(sd + ' ' + eHour + ':' + etMin + ':00.000');  
            console.log('edatetime-->'+edatetime);
            let task=this.dailysheets[i].HRMSUS__Task__c;         
            let starttimehrs=this.dailysheets[i].HRMSUS__Start_Time_Hrs__c;
            console.log('starttimehrs-->'+starttimehrs);
            let endtimehrs=this.dailysheets[i].HRMSUS__End_Time_Hrs__c;
            console.log('endtimehrs-->'+endtimehrs);
            //variables are pushed into the array           
            
            fTimeArray1.push({
                'starttime': sdatetime,
                'endtime': edatetime,
                'shours': sHour,
                'smns': stMin,
                'ehours': eHour,
                'emns': etMin,
                'cus': customer,
                'proj': project,
                'task': task,
                'total': total
            });

            console.log('fTimeArray1', fTimeArray1);
        }

        for (let i = 0; i < fTimeArray1.length; i++) {
            if (!fTimeArray1[i].cus || !fTimeArray1[i].proj || !fTimeArray1[i].task) {
                errorMsg = true;
                return true;
            } else {
                fTimeArray1.forEach((value, index) => {
                    if (index != i) {
                        if ((fTimeArray1[i].starttime >= fTimeArray1[i].endtime && fTimeArray1[i].etAmPm != fTimeArray1[i].stAmPm) ||
                            (fTimeArray1[i].starttime <= fTimeArray1[i].endtime && fTimeArray1[i].etAmPm != fTimeArray1[i].stAmPm) ||
                            (fTimeArray1[i].starttime < value.endtime && fTimeArray1[i].endtime > value.starttime) ||
                            fTimeArray1[i].starttime == value.starttime || fTimeArray1[i].endtime == value.endtime) {
                            flag = true;
                            return true;
                        }
                    } else if (index == i) {
                        if (fTimeArray1[i].starttime >= fTimeArray1[i].endtime) {
                            flag = true;
                            return true;
                        }
                    }
                });
            }
        }
    } 

        //console.log( JSON.stringify(this.data)); 
        console.log( 'data',this.data); 
        console.log( 'data',this.data.length);
        console.log( 'dailysheets',this.dailysheets); 
        console.log( 'dailysheets',this.dailysheets.length);
     if(!flag){   
        // Call the Apex method
        saveDailySheetDetails({ data: this.dailysheets })
            .then(result => {
                // Handle the result 
                this.dailysheets =[];
                this.fTimeArray1 =[];
                if(!this.totalHoursEntry){
                for (let i = 0; i < result.length; i++) {                            
                    let starttime =result[i].HRMSUS__Start_Times__c                                  
                    let stime=  new Date(starttime).toISOString().split('T')[1].substring(0,12)
                console.log('stime',stime);                               
                result[i].HRMSUS__Start_Times__c =stime                            
                let endtime =result[i].HRMSUS__End_Times__c                             
                let etime =  new Date(endtime).toISOString().split('T')[1].substring(0,12)
                console.log('etime',etime);                             
                result[i].HRMSUS__End_Times__c =etime 
                                                                                        
                }
                let sumtotal=0;
                for (let i = 0; i < result.length; i++) {
                    sumtotal += result[i].HRMSUS__Total__c;
                    if (result[i].HRMSUS__Start_Time_Hrs__c < 10) {
                        result[i].HRMSUS__Start_Time_Hrs__c = '0' + result[i].HRMSUS__Start_Time_Hrs__c.toString();
                        console.log(result[i].HRMSUS__Start_Time_Hrs__c);
                    }else if(result[i].HRMSUS__Start_Time_Hrs__c == 0){
                        result[i].HRMSUS__Start_Time_Hrs__c = '00';
                    }
                    if (result[i].HRMSUS__Start_Time_Mns__c < 10) {
                        result[i].HRMSUS__Start_Time_Mns__c = '0' + result[i].HRMSUS__Start_Time_Mns__c.toString();
                        console.log(result[i].HRMSUS__Start_Time_Mns__c);
                    }else if(result[i].HRMSUS__Start_Time_Mns__c == 0){
                        result[i].HRMSUS__Start_Time_Mns__c = '00';
                    }
                    if (result[i].HRMSUS__End_Time_Hrs__c < 10) {
                        result[i].HRMSUS__End_Time_Hrs__c = '0' + result[i].HRMSUS__End_Time_Hrs__c.toString();
                        console.log(result[i].HRMSUS__End_Time_Hrs__c);
                    }else if(result[i].HRMSUS__End_Time_Hrs__c == 0){
                        result[i].HRMSUS__End_Time_Hrs__c = '00';
                    }
                    
                    if (result[i].HRMSUS__End_Time_Mns__c < 10) {
                        result[i].HRMSUS__End_Time_Mns__c = '0' + result[i].HRMSUS__End_Time_Mns__c.toString();
                        console.log(result[i].HRMSUS__End_Time_Mns__c);
                    }else if(result[i].HRMSUS__End_Time_Mns__c == 0){
                        result[i].HRMSUS__End_Time_Mns__c = '00';
                    }
                }
                this.totalsum = sumtotal;
            }
                console.log(result);
                this.data =result;
                console.log(result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records saved successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                // Handle errors
                console.log(error);
                this.dailysheets =[];
                this.showToast('Error', error.body.message, 'error');
            });
        }
        if(flag){ 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please check the time values entered',
                    variant: 'error'
                })
            );
        } 
        if(errorMsg){
            his.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Customer,Project,Task,Start Time and End Time',
                    variant: 'error'
                })
            );
        }
    
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