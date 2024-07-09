import { LightningElement ,track,wire,api } from 'lwc';
import timeSheetIcon from '@salesforce/resourceUrl/HRMSUS__HRMSFiles';
import getWorkers from '@salesforce/apex/WeeklySheetCntrlLWC.getWorkers';
import fecthWeeklySheetDetails from '@salesforce/apex/WeeklySheetCntrlLWC.fecthWeeklySheetDetails';
export default class WeeklySheetLWC extends LightningElement {
    timeSheetIcon = timeSheetIcon + '/HRMSFiles/markers/time_sheet.png';
timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
@api startDayMap = {
    Monday: 'HRMSUS__Mon__c',
    Tuesday: 'HRMSUS__Tue__c',
    Wednesday: 'HRMSUS__Wed__c',
    Thursday: 'HRMSUS__Thu__c',
    Friday: 'HRMSUS__Fri__c',
    Saturday: 'HRMSUS__Sat__c',
    Sunday: 'HRMSUS__Sun__c' 
};

@track workers = [];
    @track selectedWorkerId;
    @track selectedDate = '';
    @track weekDayTable = [];
    @track totalWorkdays = [];
    @track custSettings;
    @track showPage = true;
    @track weekDayMap;
    @track weekDays;
    @track timesheets=[];
    @track tsheets=[];
    @track userStatus;
    @track totalMon;
    @track totalTuse;
    @track totalWednes;
    @track totalThurs;
    @track totalFri;
    @track totalSatur;
    @track totalSun;
    @track totalHours;
    saveDraftValues;
    @track RowItemList = [];
    
        @wire(getWorkers)
wiredWorkers({ error, data }) {
    if (data) {      
        console.log('data:', data);  
        if(data.lstPer){
        this.workers = data.lstPer.map(worker => ({
            label: worker.HRMSUS__First_Name__c+' '+ worker.HRMSUS__Last_Name__c,
            value: worker.Id
        }));
        
    }
        if( data.per){ 
        this.selectedWorkerId = data.per[0].Id;
        if (this.workers.length === 0) {
            this.workers = data.per.map(worker => ({
                label: worker.HRMSUS__First_Name__c+' '+ worker.HRMSUS__Last_Name__c,
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
    this.handleChange();
    }
    }
    handleworker(event) {
        this.selectedWorkerId = event.detail.value;
        if(this.selectedWorkerId && this.selectedDate){ 
            this.handleChange();
            }
    }
    handleChangeDate(event){
        this.selectedDate = event.detail.value;
        if(this.selectedWorkerId && this.selectedDate){ 
            this.handleChange();
            } 
    }

    handleChange() {    
            fecthWeeklySheetDetails({ workerId:this.selectedWorkerId,weeklyDate:this.selectedDate })
            .then(result => {
                // Process the result here
            
                console.log('result:', JSON.parse(result));
                var parsed = JSON.parse(result);
                const values = parsed.mapSo['Emps'];
                const person = parsed.mapSo['HRMSUS__Person__c'];
                console.log(values);
                console.log(person);
                this.weekDayMap = this.startDayMap;
                for (let i = 0; i < values.length; i++) {
                    this.weekDayMap[values[i].Id] = values[i].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c;
                }
                this.custSettings = parsed.wtsCustSettings;

                let weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                let workdays = [];
                let totalWorkdays = [];
        
                if (this.custSettings.HRMSUS__Customer__c) {
                    workdays.push('Customer', 'Project', 'Task');
                } else {
                     workdays.push('Project', 'Task');
                }
        
                let parts = parsed.weekStartDay.split('-');
                let dt1 = new Date(parts[0], parts[1] - 1, parts[2]);
                workdays.push(
                    weekdays[dt1.getDay()] + '-' + (dt1.getMonth() + 1) + '/' + dt1.getDate()
                );
                totalWorkdays.push(
                    weekdays[dt1.getDay()] + '-' + (dt1.getMonth() + 1) + '/' + dt1.getDate()
                );
        
                for (let i = 0; i < 6; i++) {
                    dt1.setDate(dt1.getDate() + 1);
                    let dd = dt1.getDate();
                    let mm = dt1.getMonth() + 1;
                    let y = dt1.getFullYear();
                    let day = weekdays[dt1.getDay()];
                    workdays.push(day + '-' + mm + '/' + dd);
                    totalWorkdays.push(day + '-' + mm + '/' + dd);
                }
        
                if (this.custSettings.HRMSUS__Billable__c) {
                    if (this.showPage) {
                        workdays.push('Billable', 'Total', 'Comments', 'Action');
                    } else if (!this.showPage) {
                        workdays.push('Billable', 'Total', 'Comments', 'Add', 'Action');
                    }
                } else {
                    workdays.push('Total', 'Action');
                }
        
                this.weekDayTable = workdays;
                this.totalWorkdays = totalWorkdays;
                /*  this.workers = parsed.mapSo['HRMSUS__Person__c'];
                var values = parsed.mapSo['Emps'];
                this.selectedWorkerId = values[0].Id;*/
                console.log('result:', this.weekDayTable);
                
            //   const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            console.log('parsed.weekStartDay', parsed.weekStartDay);
            const parts1 = parsed.weekStartDay.split('-');
            const dt = new Date(parts1[0], parts1[1] - 1, parts1[2]);
            console.log('dt', dt);

            const sunweek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            const monweek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            const tueweek = ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday'];
            const wedweek = ['Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday', 'Tuesday'];
            const thuweek = ['Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday'];
            const friweek = ['Friday', 'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
            const satweek = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
            let days = [];

            if (dt.getDay() == 0) {
                days = sunweek;
            }
            if (dt.getDay() == 1) {
                days = monweek;
            }
            if (dt.getDay() == 2) {
                days = tueweek;
            }
            if (dt.getDay() == 3) {
                days = wedweek;
            }
            if (dt.getDay() == 4) {
                days = thuweek;
            }
            if (dt.getDay() == 5) {
                days = friweek;
            }
            if (dt.getDay() == 6) {
                days = satweek;
            }

            console.log('days', days);
            this.weekDays = days;
            this.userStatus = parsed.userStatus;
            const SData = parsed.mapSo.Timesheets;
            const Data = [];
            //  const totalWorkdays = parsed.totalWorkdays;

            for (let i = 0; i < SData.length; i++) {
                let totalHours = 0;
                for (let j = 0; j < 7; j++) {
                    totalHours += Number(SData[i][this.weekDayMap[days[j]]]);
                }
                Data.push({
                    Id: SData[i].Id,
                    HRMSUS__Customer__c: SData[i].HRMSUS__Customer__c,
                    HRMSUS__Project_Name__c: SData[i].HRMSUS__Project_Name__c,
                    HRMSUS__Project_Task__c: SData[i].HRMSUS__Project_Task__c,
                    HRMSUS__Total__c: Number(totalHours.toFixed(2)),
                    values: [
                        Number(SData[i][this.weekDayMap[days[0]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[1]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[2]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[3]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[4]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[5]]]).toFixed(2),
                        Number(SData[i][this.weekDayMap[days[6]]]).toFixed(2)
                    ],
                    WeekSheets: totalWorkdays.map((day, index) => ({ Key: day, Value: Number(SData[i][this.weekDayMap[days[index]]]).toFixed(2) })),
                    HRMSUS__Billable__c: SData[i].HRMSUS__Billable__c,
                    HRMSUS__Comments__c: SData[i].HRMSUS__Comments__c,
                    values1: [{ [days[0]]: SData[i][this.weekDayMap[days[0]]], [days[1]]: SData[i][this.weekDayMap[days[1]]], [days[2]]: SData[i][this.weekDayMap[days[2]]], [days[3]]: SData[i][this.weekDayMap[days[3]]], [days[4]]: SData[i][this.weekDayMap[days[4]]], [days[5]]: SData[i][this.weekDayMap[days[5]]], [days[6]]: SData[i][this.weekDayMap[days[6]]] }]
                });
            }
            console.log('Data',Data);
            this.timesheets= Data;
            this.dailyTotal = parsed.companyStartDay;
            
            console.log('Data',this.timesheets);
            this.handleCount();
            })
            .catch(error => {
                // Handle any errors
                console.error('Error fetching daily sheet details:', error);
            });
            
    }
    handleWeeklyEntry(){
        this.showPage = false;
        if(this.selectedWorkerId && this.selectedDate){ 
            this.handleChange();
            } 
    }
    
    lookupRecord(event){
        try {
            console.log(event.detail.selectedRecord.Id);
        // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
        const selectedRecord = event.detail.selectedRecord;
        const selectedIndex = event.target.dataset.index;
        this.timesheets = this.timesheets.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Customer__c: selectedRecord.Id };
            }  
            return item;
        });
        console.log('timesheets',this.timesheets);
            return 'Value successfully removed';
        } catch (error) {
            console.error('Error:', error);
            const selectedIndex = event.target.dataset.index;
            this.timesheets = this.timesheets.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Customer__c: ''};
                }  
                return item;
            });
            console.log('timesheets',this.timesheets);
            return 'Error occurred while removing value';
        }
        
    }
    lookupRecordProject(event){
        try {
            console.log(event.detail.selectedRecord.Id);
    // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
    const selectedRecord = event.detail.selectedRecord;
    const selectedIndex = event.target.dataset.index;
        this.timesheets = this.timesheets.map((item, index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...item, HRMSUS__Project__c: selectedRecord.Id };
            }  
            return item;
        });
    console.log(this.timesheets);
            return 'Value successfully removed';
        } catch (error) {
            const selectedIndex = event.target.dataset.index;
            this.timesheets = this.timesheets.map((item, index) => {
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
            this.timesheets = this.timesheets.map((item, index) => {
                if (index === parseInt(selectedIndex, 10)) {
                    return { ...item, HRMSUS__Task__c: selectedRecord.Id,
                                    HRMSUS__Type__c:selectedRecord.Name
                        };
                }  
                return item;
            });
            console.log( this.dtimesheetsata);
                return 'Value successfully removed';
            } catch (error) {
                const selectedIndex = event.target.dataset.index;
            this.timesheets = this.timesheets.map((item, index) => {
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
    
    handleChangedHours(event){
        console.log('WeekSheets',this.timesheets);
        let count = 0;
        let cot = 0;
        let totalMondayA = 0;
        let totalTusedayA = 0;
        let totalWednesdayA = 0;
        let totalThursdayA = 0;
        let totalFridyA = 0;
        let totalSaturdayA = 0;
        let totalSundayA = 0;
        let fullTotalA = 0;
        let totalMonday = 0;
        let totalTuseday = 0;
        let totalWednesday = 0;
        let totalThursday = 0;
        let totalFridy = 0;
        let totalSaturday = 0;
        let totalSunday = 0;
        let fullTotal = 0;
        let daysOfWeek = this.weekDays;
        const index = event.target.dataset.index; // Get index from dataset
        const hrIndex = event.target.dataset.id;
        const value = event.target.value;
        let temp_Days = {'Monday': 0.00, 'Tuesday': 0.00, 'Wednesday': 0.00, 'Thursday': 0.00, 'Friday': 0.00, 'Saturday': 0.00, 'Sunday': 0.00};
       
        for (let i = 0; i < this.timesheets.length; i++) {
            this.timesheets[index].WeekSheets[hrIndex].Value=value;
            this.timesheets[index].values[hrIndex]=value;
        }
       
        for (let i = 0; i < this.timesheets.length; i++) {
            let total = 0;
                for (let k = 0; k < 7; k++) {
                    if (!isNaN(this.timesheets[i].WeekSheets[k].Value) ) {
                        temp_Days[daysOfWeek[k]] = this.timesheets[i].WeekSheets[k].Value;
                        total += parseFloat(this.timesheets[i].WeekSheets[k].Value);   
                        total = parseFloat(total.toFixed(2));
                    } else {
                        temp_Days[daysOfWeek[k]] = 0.00;
                    }
                    cot++;
                }
                this.timesheets[i].HRMSUS__Mon__c = temp_Days['Monday'];
                this.timesheets[i].HRMSUS__Tue__c = temp_Days['Tuesday'];
                this.timesheets[i].HRMSUS__Wed__c = temp_Days['Wednesday'];
                this.timesheets[i].HRMSUS__Thu__c = temp_Days['Thursday'];
                this.timesheets[i].HRMSUS__Fri__c = temp_Days['Friday'];
                this.timesheets[i].HRMSUS__Sat__c = temp_Days['Saturday'];
                this.timesheets[i].HRMSUS__Sun__c = temp_Days['Sunday'];
            
            totalMondayA += parseFloat(this.timesheets[i].HRMSUS__Mon__c);
            totalTusedayA += parseFloat(this.timesheets[i].HRMSUS__Tue__c);
            totalWednesdayA += parseFloat(this.timesheets[i].HRMSUS__Wed__c);
            totalThursdayA += parseFloat(this.timesheets[i].HRMSUS__Thu__c);
            totalFridyA += parseFloat(this.timesheets[i].HRMSUS__Fri__c);
            totalSaturdayA += parseFloat(this.timesheets[i].HRMSUS__Sat__c);
            totalSundayA += parseFloat(this.timesheets[i].HRMSUS__Sun__c);
        
            this.timesheets[i].HRMSUS__Total__c = parseFloat(total).toFixed(2);
        fullTotalA += Number( this.timesheets[i].HRMSUS__Total__c);

            }
        totalMonday = Number(totalMondayA).toFixed(2);
        totalTuseday = Number(totalTusedayA).toFixed(2);
        totalWednesday = Number(totalWednesdayA).toFixed(2); 
        totalThursday = Number(totalThursdayA).toFixed(2);
        totalFridy = Number(totalFridyA).toFixed(2);
        totalSaturday = Number(totalSaturdayA).toFixed(2);
        totalSunday = Number(totalSundayA).toFixed(2);
        fullTotal = fullTotalA.toFixed(2);

        this.totalMon = totalMonday;
        this.totalTuse = totalTuseday;
        this.totalWednes = totalWednesday;
        this.totalThurs = totalThursday;
        this.totalFri = totalFridy;
        this.totalSatur = totalSaturday;
        this.totalSun = totalSunday;
        this.totalHours = fullTotal;        
        //this.Timesheets=tsheets;
        console.log('WeekSheets',this.timesheets);
        } 

handleCount(){
    //    let hours = event.detail.value;
        //   let totalmon = cmp.get("v.TotalMon");
        
        let tsheets = this.timesheets;
        let tmsheet = this.tSheets;
        let tmlength = 0;
        let totalMondayA = 0;
        let totalTusedayA = 0;
        let totalWednesdayA = 0;
        let totalThursdayA = 0;
        let totalFridyA = 0;
        let totalSaturdayA = 0;
        let totalSundayA = 0;
        let fullTotalA = 0;
        let totalMonday = 0;
        let totalTuseday = 0;
        let totalWednesday = 0;
        let totalThursday = 0;
        let totalFridy = 0;
        let totalSaturday = 0;
        let totalSunday = 0;
        let fullTotal = 0;
        let count = 0;
        let cot = 0;
        let tSheetCount = tsheets ? tsheets.length : 0;
        let tmsheetcount = tmsheet ? tmsheet.length : 0;
        let daysOfWeek = this.weekDays;
        let temp_Days = {'Monday': 0.00, 'Tuesday': 0.00, 'Wednesday': 0.00, 'Thursday': 0.00, 'Friday': 0.00, 'Saturday': 0.00, 'Sunday': 0.00};
        tmlength = tmsheetcount > 0 ? tmsheetcount : tSheetCount;
        let inputValue = true;
        console.log('tmlength',tmlength);
        for (let i = 0; i < tmlength; i++) {
            let total = 0;
            if (tsheets[i].Id != null && tsheets.length > 0) {
                //  if (!$A.util.isUndefined(tsheets[i]['values1'])) {
                    for (let j = 0; j < 7; j++) {
                        let value1 = 0.00;
                        let dayCount = daysOfWeek[j];
                        
                            value1 = tsheets[i]['values1'][0][dayCount];
                        
                        if (value1) {
                            if (typeof value1 === 'string') {
                                value1 = parseFloat(value1);
                            }
                            total = total + value1;
                            total = parseFloat(total.toFixed(2));
                        } else {
                            total = parseFloat(total.toFixed(2));
                        }
                        count = count + 1;
                    }
            //    }
                for (let j = 0; j < 1; j++) {
                    if (inputValue) {
                        tsheets[i].HRMSUS__Mon__c = parseFloat(tsheets[i]['values1'][0]['Monday']);
                        cot++;
                        tsheets[i].HRMSUS__Tue__c = parseFloat(tsheets[i]['values1'][0]['Tuesday']);
                        cot++;
                        tsheets[i].HRMSUS__Wed__c = parseFloat(tsheets[i]['values1'][0]['Wednesday']);
                        cot++;
                        tsheets[i].HRMSUS__Thu__c = parseFloat(tsheets[i]['values1'][0]['Thursday']);
                        cot++;
                        tsheets[i].HRMSUS__Fri__c = parseFloat(tsheets[i]['values1'][0]['Friday']);
                        cot++;
                        tsheets[i].HRMSUS__Sat__c = parseFloat(tsheets[i]['values1'][0]['Saturday']);
                        cot++;
                        tsheets[i].HRMSUS__Sun__c = parseFloat(tsheets[i]['values1'][0]['Sunday']);
                        cot++;
                    } else {
                        for (let k = 0; k < 7; k++) {
                            if (!isNaN(cmp.find("auIds")[cot].get("v.value")) ) {
                                temp_Days[daysOfWeek[k]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                            } else {
                                temp_Days[daysOfWeek[k]] = 0.00;
                            }
                            cot++;
                        }
                        tsheets[i].HRMSUS__Mon__c = temp_Days['Monday'];
                        tsheets[i].HRMSUS__Tue__c = temp_Days['Tuesday'];
                        tsheets[i].HRMSUS__Wed__c = temp_Days['Wednesday'];
                        tsheets[i].HRMSUS__Thu__c = temp_Days['Thursday'];
                        tsheets[i].HRMSUS__Fri__c = temp_Days['Friday'];
                        tsheets[i].HRMSUS__Sat__c = temp_Days['Saturday'];
                        tsheets[i].HRMSUS__Sun__c = temp_Days['Sunday'];
                    }
                    totalMondayA += tsheets[i].HRMSUS__Mon__c;
                    totalTusedayA += tsheets[i].HRMSUS__Tue__c;
                    totalWednesdayA += tsheets[i].HRMSUS__Wed__c;
                    totalThursdayA += tsheets[i].HRMSUS__Thu__c;
                    totalFridyA += tsheets[i].HRMSUS__Fri__c;
                    totalSaturdayA += tsheets[i].HRMSUS__Sat__c;
                    totalSundayA += tsheets[i].HRMSUS__Sun__c;
                }
                tsheets[i].HRMSUS__Total__c = parseFloat(total).toFixed(2);
                fullTotalA += Number(tsheets[i].HRMSUS__Total__c);
            } else {
                for (let j = 0; j < 7; j++) {
                    let value1 = 0.00;
                    let dayCount = daysOfWeek[j];
                    if (inputValue && tsheets[i]['values1']) {
                        value1 = tsheets[i]['values1'][0][dayCount];
                    } else {
                        if (cmp.find("auIds")[count] && cmp.find("auIds")[count].get("v.value")) {
                            value1 = cmp.find("auIds")[count].get("v.value");
                        } else {
                            value1 = 0.00;
                        }
                    }
                    if (value1) {
                        if (typeof value1 === 'string') {
                            value1 = parseFloat(value1);
                        }
                        total = total + value1;
                        typeof total;
                        total = parseFloat(total.toFixed(2));
                        typeof total;
                    } else {
                        total = parseFloat(total.toFixed(2));
                    }
                    count = count + 1;
                }
                for (let j = 0; j < 1; j++) {
                    if (inputValue) {
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[0]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[0]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[1]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[1]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[2]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[2]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[3]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[3]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[4]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[4]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[5]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[5]] = 0;
                        }
                        cot++;
                        if (parseFloat(cmp.find("auIds")[cot].get("v.value"))) {
                            temp_Days[daysOfWeek[6]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                        } else {
                            temp_Days[daysOfWeek[6]] = 0;
                        }
                        cot++;
                    } else {
                        for (let k = 0; k < 7; k++) {
                            if (!isNaN(cmp.find("auIds")[cot].get("v.value"))  && cmp.find("auIds")[cot]) {
                                if (cmp.find("auIds")[cot].get("v.value")) {
                                    temp_Days[daysOfWeek[k]] = parseFloat(cmp.find("auIds")[cot].get("v.value"));
                                } else {
                                    temp_Days[daysOfWeek[k]] = 0.00;
                                }
                            } else {
                                if (!cmp.find("auIds")[cot]) {
                                    temp_Days[daysOfWeek[k]] = 0.00;
                                }
                            }
                            cot++;
                        }
                        if (temp_Days['Monday'] != null && temp_Days['Monday'] != 0)
                            tsheets[i].HRMSUS__Mon__c = temp_Days['Monday'];
                        else
                            tsheets[i].HRMSUS__Mon__c = 0.00;
                        if (temp_Days['Tuesday'] != null && temp_Days['Tuesday'] != 0)
                            tsheets[i].HRMSUS__Tue__c = temp_Days['Tuesday'];
                        else
                            tsheets[i].HRMSUS__Tue__c = 0.00;
                        if (temp_Days['Wednesday'] != null && temp_Days['Wednesday'] != 0)
                            tsheets[i].HRMSUS__Wed__c = temp_Days['Wednesday'];
                        else
                            tsheets[i].HRMSUS__Wed__c = 0.00;
                        if (temp_Days['Thursday'] != null && temp_Days['Thursday'] != 0)
                            tsheets[i].HRMSUS__Thu__c = temp_Days['Thursday'];
                        else
                            tsheets[i].HRMSUS__Thu__c = 0.00;
                        if (temp_Days['Friday'] != null && temp_Days['Friday'] != 0)
                            tsheets[i].HRMSUS__Fri__c = temp_Days['Friday'];
                        else
                            tsheets[i].HRMSUS__Fri__c = 0.00;
                        if (temp_Days['Saturday'] != null && temp_Days['Saturday'] != 0)
                            tsheets[i].HRMSUS__Sat__c = temp_Days['Saturday'];
                        else
                            tsheets[i].HRMSUS__Sat__c = 0.00;
                        if (temp_Days['Sunday'] != null && temp_Days['Sunday'] != 0)
                            tsheets[i].HRMSUS__Sun__c = temp_Days['Sunday'];
                        else
                            tsheets[i].HRMSUS__Sun__c = 0.00;
                    }
                    totalSaturdayA += tsheets[i].HRMSUS__Sat__c;
                    totalSundayA += tsheets[i].HRMSUS__Sun__c;
                    totalMondayA += tsheets[i].HRMSUS__Mon__c;
                    totalTusedayA += tsheets[i].HRMSUS__Tue__c;
                    totalWednesdayA += tsheets[i].HRMSUS__Wed__c;
                    totalThursdayA += tsheets[i].HRMSUS__Thu__c;
                    totalFridyA += tsheets[i].HRMSUS__Fri__c;
                }
                tsheets[i].HRMSUS__Total__c = parseFloat(total).toFixed(2);
                fullTotalA += Number(tsheets[i].HRMSUS__Total__c);
            }
        }
        totalMonday = Number(totalMondayA).toFixed(2);
        totalTuseday = Number(totalTusedayA).toFixed(2);
        totalWednesday = Number(totalWednesdayA).toFixed(2);
        totalThursday = Number(totalThursdayA).toFixed(2);
        totalFridy = Number(totalFridyA).toFixed(2);
        totalSaturday = Number(totalSaturdayA).toFixed(2);
        totalSunday = Number(totalSundayA).toFixed(2);
        fullTotal = fullTotalA.toFixed(2);
    
        this.totalMon = totalMonday;
        this.totalTuse = totalTuseday;
        this.totalWednes = totalWednesday;
        this.totalThurs = totalThursday;
        this.totalFri = totalFridy;
        this.totalSatur = totalSaturday;
        this.totalSun = totalSunday;
        this.totalHours = fullTotal;        
        this.Timesheets=tsheets;
    }
    
    saveRecord(event){
        this.showPage = true;
        console.log('WeekSheets',this.timesheets);
        this.RowItemList = [];
        console.log('WeekSheets',this.RowItemList);
        for(let i=0;i<this.timesheets.length;i++)
	        {     
                if (this.timesheets[i].Id) {
                    console.log('Weeklysheet If condition');
                    this.RowItemList.push({
                        sobjectType : HRMSUS__Timesheet_Entry__c,
                        Id: this.timesheets[i].Id,
                        HRMSUS__Employee__c: this.selectedWorkerId,
                        HRMSUS__Week_Start_Date__c: this.selectedDate,
                        HRMSUS__Customer__c: this.timesheets[i].HRMSUS__Customer__c,
                        HRMSUS__Project_Name__c: this.timesheets[i].HRMSUS__Project__c,
                        HRMSUS__Project_Task__c: this.timesheets[i].HRMSUS__Task__c,
                        HRMSUS__Comments__c: this.timesheets[i].HRMSUS__Comments__c,
                        HRMSUS__Mon__c: this.timesheets[i].HRMSUS__Mon__c,	
	                    HRMSUS__Tue__c: this.timesheets[i].HRMSUS__Tue__c,
	                    HRMSUS__Wed__c: this.timesheets[i].HRMSUS__Wed__c,
	                    HRMSUS__Thu__c: this.timesheets[i].HRMSUS__Thu__c,
	                    HRMSUS__Fri__c: this.timesheets[i].HRMSUS__Fri__c,
	                    HRMSUS__Sat__c: this.timesheets[i].HRMSUS__Sat__c, 
	                    HRMSUS__Sun__c: this.timesheets[i].HRMSUS__Sun__c, 
                        HRMSUS__Total__c: this.timesheets[i].HRMSUS__Total__c
                       
                    });
                } else {
                    console.log('Weeklysheet else condition');
                    this.dailysheets.push({
                        HRMSUS__Employee__c: this.selectedWorkerId,
                        HRMSUS__Week_Start_Date__c:'',
                        HRMSUS__Week_Start_Date__c: this.selectedDate,
                        HRMSUS__Customer__c: this.timesheets[i].HRMSUS__Customer__c,
                        HRMSUS__Project_Name__c: this.timesheets[i].HRMSUS__Project__c,
                        HRMSUS__Project_Task__c: this.timesheets[i].HRMSUS__Task__c,
                        HRMSUS__Comments__c: this.timesheets[i].HRMSUS__Comments__c,
                        HRMSUS__Mon__c: this.timesheets[i].HRMSUS__Mon__c,	
	                    HRMSUS__Tue__c: this.timesheets[i].HRMSUS__Tue__c,
	                    HRMSUS__Wed__c: this.timesheets[i].HRMSUS__Wed__c,
	                    HRMSUS__Thu__c: this.timesheets[i].HRMSUS__Thu__c,
	                    HRMSUS__Fri__c: this.timesheets[i].HRMSUS__Fri__c,
	                    HRMSUS__Sat__c: this.timesheets[i].HRMSUS__Sat__c, 
	                    HRMSUS__Sun__c: this.timesheets[i].HRMSUS__Sun__c, 
                        HRMSUS__Total__c: this.timesheets[i].HRMSUS__Total__c
                    });
                }
            }
            console.log('WeekSheets',this.RowItemList);
    }
}