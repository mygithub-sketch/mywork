import { LightningElement, wire,track,api } from 'lwc';
import getWorkerInfo from '@salesforce/apex/TimeClockTrackerLWCCls.getWorkerInfo';
import getWorkerLocations from '@salesforce/apex/TimeClockTrackerLWCCls.getAllLocations';
import createDailyTimecard from '@salesforce/apex/TimeClockTrackerLWCCls.createDailyTimecard';
import updatePunchOutTime from '@salesforce/apex/TimeClockTrackerLWCCls.updatePunchOutTime';
import getDailyTimecards from '@salesforce/apex/TimeClockTrackerLWCCls.getDailyTimecards';
import createBreakRecordsForTimecard from '@salesforce/apex/TimeClockTrackerLWCCls.createBreakRecordsForTimecard';
import updateBreakOutTime from '@salesforce/apex/TimeClockTrackerLWCCls.updateBreakOutTime';
import updatelunchOutTime from '@salesforce/apex/TimeClockTrackerLWCCls.updatelunchOutTime';
import createlunchRecordsForTimecard from '@salesforce/apex/TimeClockTrackerLWCCls.createlunchRecordsForTimecard';
import getBreaktimecards from '@salesforce/apex/TimeClockTrackerLWCCls.getBreaktimecards';
import getlunchtimecards from '@salesforce/apex/TimeClockTrackerLWCCls.getlunchtimecards';
import punchin from '@salesforce/resourceUrl/RoundedIconsV1';
import punchout from '@salesforce/resourceUrl/RoundedIconsV1';
import breakin from '@salesforce/resourceUrl/RoundedIconsV1';
import lunchin from '@salesforce/resourceUrl/RoundedIconsV1';
import breakout from '@salesforce/resourceUrl/RoundedIconsV1';
import lunchout from '@salesforce/resourceUrl/RoundedIconsV1';
import { refreshApex } from '@salesforce/apex';
import getEnableLocationOnTimeClock from '@salesforce/apex/TimeClockTrackerLWCCls.getEnableLocationOnTimeClock';
//import modal from "@salesforce/resourceUrl/Timeclockcss";
//import { loadStyle } from "lightning/platformResourceLoader";
export default class Timeclocktracker_lwc extends LightningElement {      
   // @api dailyTimecardId; 
    @api enablecustomsettingtimeclock;
    @track wiredResult;
    @track timecards =[]; 
    @track timecardId;
    @track ListBreak = []; 
    @track listLunch = []; 
    @track empOptions = '';   
    @track selectedDate;
    @track locationOptions = [];
    @track selectedLocation='';    
    @track showPunchinButton =true;
    @track showPunchOutButton = false;
    @track showbreakinButton = false;
    @track showlunchinButton = false;
    @track showbreakoutButton = false;
    @track showlunchoutButton = false;
    @track isToday = true;
    HRMSUS__Enablelocationontimeclock__c;
   // @track todayDate = new Date().toISOString().split('T')[0]; // Set today's date
  //  @track selectedDate = new Date().toISOString().split('T')[0]; // Set selected date
    // Define your icon names here for different actions
    punchInImageUrl;
    punchOutImageUrl;
    breakInImageUrl;
    lunchInImageUrl;
    breakOutImageUrl;
    lunchOutImageUrl;    
    
    /*get datesAreNotEqual() {
        return this.todayDate !== this.selectedDate;
    } */   
    connectedCallback() {

        this.punchInImageUrl = punchin + '/NewIcons/punchin.png';
        this.punchOutImageUrl = punchout + '/NewIcons/punchout.png';
        this.breakInImageUrl = breakin + '/NewIcons/breakin.png';
        this.lunchInImageUrl = lunchin + '/NewIcons/lunchin.png';
        this.breakOutImageUrl = breakout + '/NewIcons/breakout.png';
        this.lunchOutImageUrl = lunchout + '/NewIcons/lunchout.png';
                
       // loadStyle(this, modal);
       /* var today = new Date();
        this.selectedDate=today.toISOString(); */
        const today = new Date().toISOString().split('T')[0];
        this.selectedDate = today; 
        //this.showDate({ target: { value: this.selectedDate } }); 
        
        getEnableLocationOnTimeClock()
            .then(result => {
                this.HRMSUS__Enablelocationontimeclock__c = result;
            })
            .catch(error => {
                console.error('Error fetching custom setting:', error);
            });
    }

      showDate (event) {
        this.selectedDate = event.target.value; 
        
        const currentDate = new Date().toISOString().split('T')[0];
        console.log('currentDate: ', currentDate);
        if (this.selectedDate === currentDate) {
            // If the selected date is today, show the Punch In button
            console.log('Today! Show Punch In button.');
            this.showPunchinButton = true;
            this.isToday = true;
        } else {
            // For dates other than today, hide the Punch In button
            console.log('Not today. Hide Punch In button.');
            this.showPunchinButton = false;
            this.isToday = false;
        }
                       
        this.showPunchOutButton = false;
        this.showbreakinButton = false;
        this.showlunchinButton = false;
        this.showbreakoutButton = false;
        this.showlunchoutButton = false;
    }
       
                    
    @wire(getWorkerInfo)
    workerInfo({ error, data }) {
    if (data) {
        const defaultWorker = data[0];
        if (defaultWorker && defaultWorker.workerLocation) {
            this.empOptions = defaultWorker.workerName;
            this.selectedLocation = defaultWorker.workerLocation;
            console.log('Selected Location: ', this.selectedLocation);

            // Check if there's a record for today with no Punch Out value
            const currentDate = new Date().toISOString().split('T')[0];
            console.log('currentDate-->',currentDate);
            getDailyTimecards({ tdate: currentDate })
                .then(result => {
                    const todayRecord = result.find(record => !record.HRMSUS__Punch_Out__c);
                    console.log('todayRecord-->', todayRecord);
                    if (todayRecord) {    
                    const hasPunchIn = todayRecord.HRMSUS__Punch_In__c;                                                         
                    const hasPunchOut = todayRecord.HRMSUS__Punch_Out__c;
                    console.log('hasPunchOut:', hasPunchOut);                    
                    if (hasPunchIn && hasPunchOut) {
                        // If there's a record for today with both Punch In and Punch Out, hide other buttons except punchin button
                        this.showPunchinButton = true;
                        this.showbreakinButton = false;
                        this.showlunchinButton = false;
                        this.showPunchOutButton = false;
                        this.showlunchoutButton = false;
                        this.showbreakoutButton = false;
                    } else {
                        // If there's a record for today with no Punch Out, hide the PI,LO,BO button
                        this.showPunchinButton = false;
                        this.showbreakinButton = true; 
                        this.showlunchinButton = true;
                        this.showPunchOutButton = true;
                        this.showlunchoutButton = false;
                        this.showbreakoutButton = false;
                    }
                } else {
                    // If no such record, show the Punch In button
                    this.showPunchinButton = true;
                    this.showbreakinButton = false; 
                    this.showlunchinButton = false;
                    this.showPunchOutButton = false;
                    this.showlunchoutButton = false;
                    this.showbreakoutButton = false;
                }
                })
                .catch(error => {
                    console.error('Error fetching timecards for today:', error);
                });

// Check if there's a break record for today with no Break Out value
getBreaktimecards({ tdate: currentDate })
.then(result => {
    const todayBreakRecord = result.find(record => !record.HRMSUS__End_Time_HH_MM__c);
    console.log('todayBreakRecord-->', todayBreakRecord);
    if (todayBreakRecord) {
        const hasBreakIn = todayBreakRecord.HRMSUS__Start_Time_HH_MM__c;
        const hasBreakOut = todayBreakRecord.HRMSUS__End_Time_HH_MM__c;
        console.log('hasBreakOut:', hasBreakOut);
        if (hasBreakIn && hasBreakOut) {
            // If there's a record for today with both Break In and Break Out, hide other buttons except BI,LI,PO
            this.showPunchinButton = false;
            this.showbreakinButton = true;
            this.showlunchinButton = true;
            this.showPunchOutButton = true;
            this.showlunchoutButton = false;
            this.showbreakoutButton = false;
        } else {
            // If there's a record for today with no Break Out, hide other buttons except Break Out button
            this.showPunchinButton = false;
            this.showbreakinButton = false;
            this.showlunchinButton = false;
            this.showPunchOutButton = false;
            this.showlunchoutButton = false;
            this.showbreakoutButton = true;
        }
    } /*else {
        // If no such record, show the Punch In button
        this.showPunchinButton = true;
        this.showbreakinButton = false;
        this.showlunchinButton = false;
        this.showPunchOutButton = false;
        this.showlunchoutButton = false;
        this.showbreakoutButton = false;
    }*/
})
.catch(error => {
    console.error('Error fetching break records for today:', error);
});


// Check if there's a lunch record for today with no Lunch Out value
getlunchtimecards({ tdate: currentDate })
.then(result => {
    const todayLunchRecord = result.find(record => !record.HRMSUS__End_Time_HH_MM__c);
    console.log('todayLunchRecord-->', todayLunchRecord);
   // if (todayLunchRecord) {
        const hasLunchIn = todayLunchRecord.HRMSUS__Start_Time_HH_MM__c;
        const hasLunchOut = todayLunchRecord.HRMSUS__End_Time_HH_MM__c;
        console.log('hasLunchOut:', hasLunchOut);
        if (todayLunchRecord && hasLunchIn && hasLunchOut) {
            // If there's a record for today with both Lunch In and Lunch Out, hide other buttons except BI,LI,PO
            this.showPunchinButton = false;
            this.showbreakinButton = true;
            this.showlunchinButton = true;
            this.showPunchOutButton = true;
            this.showlunchoutButton = false;
            this.showbreakoutButton = false;
        } else {
            // If there's a record for today with no Lunch Out, hide other buttons except Lunch Out button
            this.showPunchinButton = false;
            this.showbreakinButton = false;
            this.showlunchinButton = false;
            this.showPunchOutButton = false;
            this.showlunchoutButton = true;
            this.showbreakoutButton = false;
        }
    //} 
    /*else {
        // If no such record, show the Punch In button
        this.showPunchinButton = true;
        this.showbreakinButton = false;
        this.showlunchinButton = false;
        this.showPunchOutButton = false;
        this.showlunchoutButton = false;
        this.showbreakoutButton = false;
    }*/
})
.catch(error => {
    console.error('Error fetching lunch records for today:', error);
});

        } else {
            this.selectedLocation = 'Default Location ID or No Location found';
        }
    } else if (error) {
        // Handle errors
        console.error('Error fetching worker info: ', error);
        this.selectedLocation = 'No location found';
    }
}

    @wire(getWorkerLocations)
    wiredLocations({ error, data }) {
        if (data) {           
            this.locationOptions = data.map(location => {
            return { label: location, value: location };
            });
        } else if (error) {
            console.error('Error fetching locations:', error);
        }
    }

    handleLocationChange(event) {
        this.selectedLocation = event.detail.value;        
        console.log('Selected Location:', this.selectedLocation);
    }

    get isLocationEnabled() {
        // Assuming HRMSUS__Enablelocationontimeclock__c is a property on your component
        console.log('cs-->', this.HRMSUS__Enablelocationontimeclock__c);
        return this.HRMSUS__Enablelocationontimeclock__c === true;
        
    }



   /* @wire(getDailyTimecards)
    wiredTimecards(result) {   
        this.wiredResult = result;
        console.log('wiredResult', result);
        if (result.data) {
            this.timecards = result.data;                     
            console.log('success Timecard saved:', result.data);
        } else if (result.error) {
            console.error('Error saving timecard:', error);
        }
        
    } */

        punchinButtonClick(event) {        
        // if (this.empOptions && this.selectedLocation) {           
                createDailyTimecard({ 
                    workerName: this.empOptions,
                    locationName: this.selectedLocation 
                })
                .then(result => { 
                    this.timecards  =result;  
                    console.log('Timecard saved:', result);                     
                    //return refreshApex(this.getDailyTimecards); 
                    return refreshApex(this.wiredTimecards);                         
                                                    
                })
                .catch(error => {                
                    console.error('Error saving timecard:', error);               
                })           
                .finally(() => {
                    this.showbreakinButton = true; 
                    this.showlunchinButton = true;
                    this.showPunchOutButton = true;
                    this.showlunchoutButton=false;
                    this.showbreakoutButton=false;
                    this.showPunchinButton=false;
                });                              
        }


    punchoutButtonClick(event) {
        if (!this.timecards || !this.timecards.length) {
            console.error('No daily timecards available');
            return;
        }
        
        const timecardIds = this.timecards.map(timecard => timecard.Id);
        console.log('timecardIds-->',timecardIds);
        Promise.all(
            timecardIds.map(dailyTimecardId => 
                updatePunchOutTime({ dailyTimecardId })
                    .then(result => {
                        console.log('Success update punchout data:', result);
                        return refreshApex(this.wiredTimecards);
                    })
                    .catch(error => {
                        console.error('Error saving update punchout data:', error);
                    })
            )
        ).then(() => {
            // Update UI or perform actions after updating punch-out for all timecards
            this.showbreakinButton = false;
            this.showlunchinButton = false;
            this.showPunchOutButton = false;
            this.showlunchoutButton = false;
            this.showbreakoutButton = false;
            this.showPunchinButton = true;
        });
    }
    
    
    @wire(getDailyTimecards, { tdate: '$selectedDate' })
     wiredTimecards(result) {
         this.wiredTimecards = result;
         if (result.data) {          
             this.timecards = result.data;
             console.log('Timecards:', this.timecards);
         } else if (result.error) {
             console.error('Error fetching timecards:', result.error);
         }
     }

                                 
    breakinButtonClick(event) {
        if (!this.timecards || !this.timecards.length) {
            console.error('No daily timecards available');
            return;
        }
    
        const dailyTimecardIds = this.timecards.map(timecard => timecard.Id);
    
        Promise.all(
            dailyTimecardIds.map(dailyTimecardId =>
                createBreakRecordsForTimecard({ workerName: this.empOptions, dailyTimecardId })
                    .then(result => {
                        console.log('Break created for timecard:', dailyTimecardId, result);
                        return refreshApex(this.wiredBreakRecords);
                    })
                    .catch(error => {
                        console.error('Error creating break for timecard:', dailyTimecardId, error);
                    })
            )
        ).finally(() => {  
                this.showbreakinButton = false; 
                this.showlunchinButton = false;
                this.showPunchOutButton = false;
                this.showPunchinButton =false;
                this.showlunchoutButton=false;              
                this.showbreakoutButton=true;                
            });  
    }


    /*@wire(getBreaktimecards)
    wiredBreakRecords({ error, data }) {
        if (data) {
            console.error('data:', data);
            this.ListBreak = data;
            console.error('Success retrieving break records:', this.ListBreak);
        } else if (error) {
            console.error('Error retrieving break records:', error);
        }
    }*/
    @wire(getBreaktimecards, { tdate: '$selectedDate' })
    wiredBreakRecords(result) {
        this.wiredBreakRecords = result;
        if (result.data) {
            console.error('data:', result.data);            
            this.ListBreak = result.data;            
            console.error('Success retrieving break records:', this.ListBreak);
        } else if (result.error) {
            console.error('Error retrieving break records:', result.error);
        }
    }
    
    /*@wire(getBreaktimecards, { dailyTimecardId: '$dailyTimecardId' })
    wiredBreakRecords({ error, data }) {
        if (data) {
            this.ListBreak = data;
            console.error('Success retrieving break records:', this.ListBreak);
        } else if (error) {
            console.error('Error retrieving break records:', error);
        }
    }*/


    breakoutButtonClick(event) {
        if (!this.timecards || !this.timecards.length) {
            console.error('No daily timecards available');
            return;
        }
        
        const dailyTimecardIds = this.timecards.map(timecard => timecard.Id);  
        Promise.all(
            dailyTimecardIds.map(dailyTimecardId =>            
            updateBreakOutTime({  workerName: this.empOptions,dailyTimecardId})
             .then(result => { 
                 //this.ListBreak  =result;  
                 console.log('Success update breakout data:', dailyTimecardId, result); 
                 return refreshApex(this.wiredBreakRecords);                                                                                               
             })
             .catch(error => {                
                 console.error('Error saving update breakout data:', dailyTimecardId, result);               
             }) 
            )          
             ).finally(() => {
                this.showbreakinButton = true;                 
                this.showlunchinButton = true;
                this.showPunchOutButton = true; 
                this.showbreakoutButton=false; 
                this.showlunchoutButton=false;
                this.showPunchinButton =false;              
             });                              
     }
    

    lunchinButtonClick(event) {
        if (!this.timecards || !this.timecards.length) {
            console.error('No daily timecards available');
            return;
        }
        
        const dailyTimecardIds = this.timecards.map(timecard => timecard.Id);

    Promise.all(
        dailyTimecardIds.map(dailyTimecardId =>
            createlunchRecordsForTimecard({ dailyTimecardId, workerName: this.empOptions })
                .then(result => {
                    console.log('Lunch record created for timecard:', dailyTimecardId, result);
                    return refreshApex(this.wiredLunchRecords);
                })
                .catch(error => {
                    console.error('Error creating lunch record for timecard:', dailyTimecardId, error);
                })
        )
    ).finally(() => {  
                this.showbreakinButton = false;                 
                this.showlunchinButton = false;
                this.showPunchOutButton = false; 
                this.showbreakoutButton=false; 
                this.showPunchinButton =false;              
                this.showlunchoutButton=true;
             });  
    }


    lunchoutButtonClick(event) {
        if (!this.timecards || !this.timecards.length) {
            console.error('No daily timecards available');
            return;
        }
        
        const dailyTimecardIds = this.timecards.map(timecard => timecard.Id); 
        Promise.all(
            dailyTimecardIds.map(dailyTimecardId =>     
            updatelunchOutTime({ workerName: this.empOptions,dailyTimecardId })
             .then(result => { 
                 this.listLunch  =result;  
                 console.log('Success update lunchout data:', result);  
                 return refreshApex(this.wiredLunchRecords);                                                                                              
             })
             .catch(error => {                
                 console.error('Error saving update lunchout data:', error);               
             })
            )           
             ).finally(() => {
                this.showbreakinButton = true;             
                this.showlunchinButton = true;
                this.showPunchOutButton = true;
                this.showbreakoutButton=false; 
                this.showPunchinButton =false;              
                this.showlunchoutButton=false;                
             });                              
     }
     @wire(getlunchtimecards, { tdate: '$selectedDate' })
     wiredLunchRecords(result) {
        this.wiredLunchRecords = result;
        if (result.data) {
            console.error('data:', result.data);
            this.listLunch = result.data;
            console.error('Success retrieving break records:', this.ListBreak);
        } else if (result.error) {
            console.error('Error retrieving break records:', result.error);
        }     
     }
    
           
}