public with sharing class TimeClockTrackerLWCCls{
    
    @AuraEnabled(cacheable=true)
     public static List<WorkerInfoWrapper> getWorkerInfo() {
    List<WorkerInfoWrapper> workerInfoList = new List<WorkerInfoWrapper>();

    // Fetch current user's ID
    String currentUserId = UserInfo.getUserId();

    if (currentUserId != null) {
        // Query to get the worker's name and location based on the current user's ID
        List<HRMSUS__Person__c> empOptions = [SELECT HRMSUS__First_Name__c, HRMSUS__Last_Name__c, HRMSUS__Location__r.Name FROM HRMSUS__Person__c  WHERE HRMSUS__User__c = :currentUserId];

        // Process the retrieved data
        for (HRMSUS__Person__c emp : empOptions) {
            WorkerInfoWrapper workerInfo = new WorkerInfoWrapper();
            workerInfo.workerName = emp.HRMSUS__First_Name__c + ' ' + emp.HRMSUS__Last_Name__c;
            workerInfo.workerLocation = emp.HRMSUS__Location__r != null ? emp.HRMSUS__Location__r.Name : 'No Location';
            workerInfoList.add(workerInfo);
        }
    }

    return workerInfoList;
}

    @AuraEnabled(cacheable=true)
public static List<String> getAllLocations() {
    List<String> allLocations = new List<String>();       
    List<HRMSUS__Location__c> locations = [SELECT id,Name FROM HRMSUS__Location__c];    
    if (!locations.isEmpty()) {
        for (HRMSUS__Location__c loc : locations) {            
            allLocations.add(loc.Name);
        }
    }
    system.debug('allLocations-->'+allLocations);
    return allLocations;
    
}

@AuraEnabled(cacheable=true)
    public static Boolean getEnableLocationOnTimeClock() {
        // Assuming HRMSUS__Enablelocationontimeclock__c is the API name of your custom setting
        HRMSUS__Trigger__c trg = HRMSUS__Trigger__c.getInstance();
        return trg != null ? trg.HRMSUS__Enablelocationontimeclock__c : false;
    }

@AuraEnabled(cacheable=false)
public static Id  createDailyTimecard(String workerName, String locationName) {
    Boolean enableLocation = getEnableLocationOnTimeClock();
    system.debug('workerName-->'+workerName);
    system.debug('locationName-->'+locationName);
    String currentUserId = UserInfo.getUserId();
    List<HRMSUS__Person__c> employees = [SELECT Id,HRMSUS__User__c,HRMSUS__Location__c,HRMSUS__Scheduled_Shift__c,
    HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Time__c,HRMSUS__Scheduled_Shift__r.HRMSUS__End_Time__c,
    HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Times__c,HRMSUS__Scheduled_Shift__r.HRMSUS__End_Times__c FROM HRMSUS__Person__c  WHERE HRMSUS__User__c = :currentUserId  LIMIT 1];   
    List<HRMSUS__Location__c> locations = [SELECT id,Name FROM HRMSUS__Location__c where Name=:locationName];     
    HRMSUS__Person__c employee =new HRMSUS__Person__c();
    HRMSUS__Location__c loc= new HRMSUS__Location__c();
    for (HRMSUS__Person__c emp : employees) {
        employee = emp;
        break; 
    }

    for (HRMSUS__Location__c location : locations) {
        loc = location;
        break; 
    }

    Time starttime; 
    Time endtime;

    if( employee.HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Time__c !=null){
        list<string> sttimeLst = employee.HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Time__c.split(':');
        Integer stHR = integer.valueof(sttimeLst[0]);
        Integer stMN = integer.valueof(sttimeLst[1].split(' ')[0]);
        String stMR = (sttimeLst[1].split(' ')[1]);
        if(stHR!=12 && stMR.contains('PM')){
            stHR+=12;
        }
        
        starttime = time.newInstance(stHR, stMN, 0, 0);
    }
    if(employee.HRMSUS__Scheduled_Shift__r.HRMSUS__End_Time__c!=null){
        list<string> ettimeLst = employee.HRMSUS__Scheduled_Shift__r.HRMSUS__End_Time__c.split(':');
        Integer etHR = integer.valueof(ettimeLst[0]);
        Integer etMN = integer.valueof(ettimeLst[1].split(' ')[0]);
        String etMR = (ettimeLst[1].split(' ')[1]);
        if(etHR!=12 && etMR.contains('PM')){
            etHR+=12;
        }
        
        endtime = time.newInstance(etHR, etMN, 0, 0);
    }   
    
    
    Datetime scstarttimes;
    Datetime scendtimes;
    if(starttime!=null){
        scstarttimes = datetime.newInstance(date.today(), starttime);
    }
    if(endtime!=null){ 
        scendtimes = datetime.newInstance(date.today(), endtime);  
    }

    if (employee != null) {       
        HRMSUS__Daily_Timecard__c newTimecard = new HRMSUS__Daily_Timecard__c();
        newTimecard.HRMSUS__Timecard_Date__c = System.Today();
        newTimecard.HRMSUS__Employee__c = employee.Id;
        newTimecard.HRMSUS__Punch_In__c =System.now();
        newTimecard.HRMSUS__Punch_In_HH_MM__c = newTimecard.HRMSUS__Punch_In__c.format('hh:mm a'); 
        if (enableLocation) {       
        newTimecard.HRMSUS__Location__c = loc.id;
        }
        if(starttime !=null && endtime!=null){
            newTimecard.HRMSUS__End_Time__c = scendtimes;
            newTimecard.HRMSUS__Start_Time__c= scstarttimes;
            newTimecard.HRMSUS__Start_Time_HH_MM__c = newTimecard.HRMSUS__Start_Time__c.format('hh:mm a');
            newTimecard.HRMSUS__End_Time_HH_MM__c = newTimecard.HRMSUS__End_Time__c.format('hh:mm a');
        } 
               

        try {
            insert newTimecard;  
            return newTimecard.Id;                      
        } catch (Exception ex) {           
            System.debug('Error creating timecard: ' + ex.getMessage());
            throw new AuraHandledException('Error creating timecard: ' + ex.getMessage());
        }
    } else {
        System.debug('No employee found with the provided name at the specified location.');
        throw new AuraHandledException('No employee found with the provided name at the specified location.');
    }    
}



@AuraEnabled(cacheable=false)
public static void updatePunchOutTime(Id dailyTimecardId) {
    System.debug('dailyTimecardId' + dailyTimecardId);
    
   List<HRMSUS__Daily_Timecard__c> timecardToUpdate = [SELECT Id, HRMSUS__Punch_In__c,HRMSUS__Punch_Out__c,HRMSUS__Punch_Out_HH_MM__c FROM HRMSUS__Daily_Timecard__c
                                          WHERE Id = :dailyTimecardId and HRMSUS__Punch_Out__c=null ];
    
        for (HRMSUS__Daily_Timecard__c updatedtc : timecardToUpdate) {
        /*updatedtc.HRMSUS__Punch_Out__c = System.now();
        updatedtc.HRMSUS__Punch_Out_HH_MM__c = updatedtc.HRMSUS__Punch_Out__c.format('hh:mm a');
        System.debug('punchout time ' + updatedtc.HRMSUS__Punch_Out_HH_MM__c);*/
            DateTime inTime = updatedtc.HRMSUS__Punch_In__c;
            updatedtc.HRMSUS__Punch_Out__c = System.now();
            updatedtc.HRMSUS__Punch_Out_HH_MM__c =string.valueOf((updatedtc.HRMSUS__Punch_Out__c).format('hh:mm a'));

            Long time1 = intime.GetTime();//Punch-In Time
            Long Time2 = updatedtc.HRMSUS__Punch_Out__c.GetTime();//Punch-Out Time
            system.debug('time1==='+time1);
            system.debug('time2==='+time2);
            Long Time3  = Time2-time1;//Subtraction(PunchIn - PunchOut)
            system.debug('time3==='+time3);
            Decimal TotalTime =  (Decimal.ValueOf(Time3)/(1000*60*60)); // Total Working Hours in Mins as 1hr/100parts
            system.debug('TotalTime===1'+TotalTime.setScale(2)); 
            updatedtc.HRMSUS__Total_Hours__c = TotalTime.setScale(2);
       
        try {
            update updatedtc;
        } catch (Exception ex) {
            System.debug('Error updating punch-out time: ' + ex.getMessage());
            throw new AuraHandledException('Error updating punch-out time: ' + ex.getMessage());
        }
    }  /*if (timecardToUpdate.isEmpty()) {
        System.debug('No daily timecard found with the provided ID.');
        throw new AuraHandledException('No daily timecard found with the provided ID.');
    }*/
}

@AuraEnabled(cacheable=true)
public static List<HRMSUS__Daily_Timecard__c> getDailyTimecards(date tdate) {   
    System.debug('tdate ' + tdate);
    String currentUserId = UserInfo.getUserId(); 
    //Date selectedDate = (tdate != null) ? tdate : System.Today();   
    List<HRMSUS__Daily_Timecard__c> timecards = [SELECT Id, Name,HRMSUS__Punch_Out__c,HRMSUS__Start_Time__c,HRMSUS__End_Time__c,HRMSUS__Punch_In__c,HRMSUS__Start_Time_HH_MM__c,HRMSUS__End_Time_HH_MM__c,HRMSUS__Punch_In_HH_MM__c,
    HRMSUS__Punch_Out_HH_MM__c,HRMSUS__Total_Hours__c,HRMSUS__Total_Break_Length__c,HRMSUS__Total_Lunch_Length__c,HRMSUS__Timecard_Date__c, HRMSUS__Employee__r.HRMSUS__First_Name__c, HRMSUS__Employee__r.HRMSUS__Last_Name__c, HRMSUS__Location__r.Name
        FROM HRMSUS__Daily_Timecard__c WHERE HRMSUS__Employee__r.HRMSUS__User__c = :currentUserId  AND HRMSUS__Timecard_Date__c = :tdate];
        System.debug('timecards ' +timecards.size()); 
    return timecards;
}


@AuraEnabled(cacheable=false)
public static List<Id> createBreakRecordsForTimecard(String workerName, Id dailyTimecardId) {
    System.debug('dailyTimecardId-->' + dailyTimecardId);
    System.debug('workerName-->' + workerName);
    
    String currentUserId = UserInfo.getUserId(); 
    
    // Fetch the current user's information
    List<HRMSUS__Person__c> employees = [
        SELECT Id, HRMSUS__User__c, HRMSUS__Location__c, HRMSUS__Scheduled_Shift__c,HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Time__c, HRMSUS__Scheduled_Shift__r.HRMSUS__End_Time__c,
               HRMSUS__Scheduled_Shift__r.HRMSUS__Start_Times__c, HRMSUS__Scheduled_Shift__r.HRMSUS__End_Times__c 
        FROM HRMSUS__Person__c WHERE HRMSUS__User__c = :currentUserId LIMIT 1];    
    
    /*if(employees.isEmpty()) {
        throw new AuraHandledException('No employee found for the current user.');
    }*/
    
    //HRMSUS__Person__c employee = employees[0]; 
    HRMSUS__Person__c employee =new HRMSUS__Person__c();
    for (HRMSUS__Person__c emp : employees) {
        employee = emp;
        break; 
    }
    
    // Query all the daily timecards associated with the provided ID
    List<HRMSUS__Daily_Timecard__c> timecards = [SELECT Id, HRMSUS__Punch_Out__c, HRMSUS__Punch_Out_HH_MM__c 
        FROM HRMSUS__Daily_Timecard__c WHERE Id = :dailyTimecardId AND HRMSUS__Punch_Out__c = null];
    
    /*if(timecards.isEmpty()) {
        throw new AuraHandledException('No matching daily timecard found for the provided ID.');
    }*/
    
    List<Id> createdBreakRecordIds = new List<Id>();
    List<HRMSUS__Break__c> breakRecordsToInsert = new List<HRMSUS__Break__c>();       
    for(HRMSUS__Daily_Timecard__c dtc : timecards) {
        // Create a new break record
        HRMSUS__Break__c breakRecord = new HRMSUS__Break__c();
        breakRecord.HRMSUS__Timecard__c = dtc.Id;
        breakRecord.HRMSUS__Date__c = System.today();
        breakRecord.HRMSUS__Type__c = 'Break';
        breakRecord.HRMSUS__Worker__c = employee.Id;
        breakRecord.HRMSUS__Start_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), 0, 0);
        Datetime myDateTime = Datetime.newInstance(Date.today(), breakRecord.HRMSUS__Start_Time__c);
        breakRecord.HRMSUS__Start_Time_HH_MM__c = myDateTime.format('h:mm a');
        
        breakRecordsToInsert.add(breakRecord);
    }
    
    try {
        insert breakRecordsToInsert;
        for (HRMSUS__Break__c createdBreak : breakRecordsToInsert) {
            createdBreakRecordIds.add(createdBreak.Id);
        }
        return createdBreakRecordIds;
    } catch (Exception ex) {
        System.debug('Error creating break records: ' + ex.getMessage());
        throw new AuraHandledException('Error creating break records: ' + ex.getMessage()+'Line Number-->'+ex.getlinenumber());
    }
}



@AuraEnabled(cacheable=true)
public static List<HRMSUS__Break__c> getBreaktimecards(date tdate) {
    //System.debug('dailyTimecardId ' +dailyTimecardId);
   String currentUserId = UserInfo.getUserId(); 
    List<HRMSUS__Break__c> ListBreak = [SELECT id, Name,HRMSUS__Timecard__c,HRMSUS__Timecard__r.Name,HRMSUS__Type__c,HRMSUS__Date__c,HRMSUS__Start_Time__c,
    HRMSUS__Start_Time_HH_MM__c,HRMSUS__End_Time__c,HRMSUS__End_Time_HH_MM__c,HRMSUS__Hours__c FROM HRMSUS__Break__c
      where HRMSUS__Worker__r.HRMSUS__User__c = :currentUserId and HRMSUS__Date__c=:tdate and HRMSUS__Type__c='Break' ];
        System.debug('ListBreak ' +ListBreak); 
    return ListBreak;
}

@AuraEnabled(cacheable=false)
public static void updateBreakOutTime(String workerName,Id dailyTimecardId) {
    System.debug('dailyTimecardId ' + dailyTimecardId +'workerName'+workerName);
    List<HRMSUS__Break__c> breakRecordsToUpdate = [SELECT Id, HRMSUS__Start_Time__c, HRMSUS__End_Time__c,HRMSUS__Type__c FROM HRMSUS__Break__c
        WHERE HRMSUS__Timecard__c = :dailyTimecardId  AND HRMSUS__End_Time__c = null and HRMSUS__Type__c = 'Break' ];
    
        for (HRMSUS__Break__c breakRecord : breakRecordsToUpdate) {
           /* breakRecord.HRMSUS__End_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), 0, 0);
            Datetime myDateTime = Datetime.newInstance(Date.today(), breakRecord.HRMSUS__End_Time__c);
            breakRecord.HRMSUS__End_Time_HH_MM__c = myDateTime.format('h:mm a');
            System.debug('breakendtime ' + breakRecord.HRMSUS__End_Time_HH_MM__c);*/

               Datetime StartTime = Datetime.newInstance(Date.today(),  breakRecord.HRMSUS__Start_Time__c);         
               breakRecord.HRMSUS__End_Time__c =Time.newInstance(System.now().hour(),System.now().minute(),0,0);
                Datetime EndTime = Datetime.newInstance(Date.today(),  breakRecord.HRMSUS__End_Time__c);
                breakRecord.HRMSUS__End_Time_HH_MM__c = EndTime.format('h:mm a');               
                Long Time1 = StartTime.GetTime();
                Long Time2 = EndTime.GetTime();
                Long Time3  = Time2-Time1;
                Decimal TotalTime =  (Decimal.ValueOf(Time3)/(1000*60*60)); 
                // TotalTime = TotalTime.setScale(2);
                //system.debug('TotalTime===='+TotalTime);
                breakRecord.HRMSUS__Hours__c = TotalTime.setScale(2);
    
            try {
                update breakRecord;
            } catch (Exception ex) {
                System.debug('Error updating break record: ' + ex.getMessage()+'line number'+ex.getlinenumber());
                throw new AuraHandledException('Error updating break record: ' + ex.getMessage()+'line number'+ex.getlinenumber());
            }           
            //break;
        }
    
        /*if (breakRecordsToUpdate.isEmpty()) {
            throw new AuraHandledException('No eligible break records found for update.');
        }*/
    }


    @AuraEnabled(cacheable=false)
    public static List<Id> createlunchRecordsForTimecard(Id dailyTimecardId, String workerName) {
    System.debug('dailyTimecardId-->' + dailyTimecardId);
    System.debug('workerName-->' + workerName);
    
    String currentUserId = UserInfo.getUserId();
    
    // Fetch the current user's information
    List<HRMSUS__Person__c> employees = [SELECT Id, Name, HRMSUS__Full_Name__c, HRMSUS__User__c, HRMSUS__Location__c 
        FROM HRMSUS__Person__c WHERE HRMSUS__User__c = :currentUserId];
    
    /*if(employees.isEmpty()) {
        throw new AuraHandledException('No employee found for the current user.');
    }*/
    
    //HRMSUS__Person__c employee = employees[0]; 
    HRMSUS__Person__c employee =new HRMSUS__Person__c();
    for (HRMSUS__Person__c emp : employees) {
        employee = emp;
        break; 
    }
        
    List<HRMSUS__Daily_Timecard__c> timecards = [SELECT Id, HRMSUS__Punch_Out__c, HRMSUS__Punch_Out_HH_MM__c FROM HRMSUS__Daily_Timecard__c WHERE Id = :dailyTimecardId AND HRMSUS__Punch_Out__c = null];
    
    /*if(timecards.isEmpty()) {
        throw new AuraHandledException('No matching daily timecard found for the provided ID.');
    }*/
    
    List<Id> createdlunchRecordIds = new List<Id>();
    List<HRMSUS__Break__c> lunchRecordsToInsert = new List<HRMSUS__Break__c>();  
    
    // Iterate over all the matching daily timecards
    for(HRMSUS__Daily_Timecard__c dtc : timecards) {
        // Create a new lunch record
        HRMSUS__Break__c lunchRecord = new HRMSUS__Break__c();
        lunchRecord.HRMSUS__Timecard__c = dtc.Id;
        lunchRecord.HRMSUS__Date__c = System.today();
        lunchRecord.HRMSUS__Type__c = 'Lunch';
        lunchRecord.HRMSUS__Worker__c = employee.Id;
        lunchRecord.HRMSUS__Start_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), 0, 0);
        Datetime myDateTime = Datetime.newInstance(Date.today(), lunchRecord.HRMSUS__Start_Time__c);
        lunchRecord.HRMSUS__Start_Time_HH_MM__c = myDateTime.format('h:mm a');
        
        lunchRecordsToInsert.add(lunchRecord);
    }
    
    // Insert all lunch records outside the loop
    try {
        insert lunchRecordsToInsert;
        for(HRMSUS__Break__c record : lunchRecordsToInsert) {
            createdlunchRecordIds.add(record.Id);
        }
    } catch (Exception ex) {
        // Handle exceptions for bulk insert
        System.debug('Error creating lunch records: ' + ex.getMessage());
    }
    
    return createdlunchRecordIds;
}
  

@AuraEnabled(cacheable=false)
public static void updatelunchOutTime(String workerName,Id dailyTimecardId) {
    System.debug('dailyTimecardId ' + dailyTimecardId+'lunchworker'+workerName);   
    List<HRMSUS__Break__c> breakRecordsToUpdate = [SELECT Id, HRMSUS__Start_Time__c, HRMSUS__End_Time__c,HRMSUS__Type__c FROM HRMSUS__Break__c
        WHERE HRMSUS__Timecard__c = :dailyTimecardId  AND HRMSUS__End_Time__c = null and HRMSUS__Type__c = 'Lunch' LIMIT 1];
    
        for (HRMSUS__Break__c lunchRecord : breakRecordsToUpdate) {
            /*lunchRecord.HRMSUS__End_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), 0, 0);
            Datetime myDateTime = Datetime.newInstance(Date.today(), lunchRecord.HRMSUS__End_Time__c);
            lunchRecord.HRMSUS__End_Time_HH_MM__c = myDateTime.format('h:mm a');
            System.debug('lunchendtime ' + lunchRecord.HRMSUS__End_Time_HH_MM__c);  */
                Datetime StartTime = Datetime.newInstance(Date.today(),  lunchRecord.HRMSUS__Start_Time__c);         
                lunchRecord.HRMSUS__End_Time__c =Time.newInstance(System.now().hour(),System.now().minute(),0,0);
                Datetime EndTime = Datetime.newInstance(Date.today(),  lunchRecord.HRMSUS__End_Time__c);
                lunchRecord.HRMSUS__End_Time_HH_MM__c = EndTime.format('h:mm a');               
                Long Time1 = StartTime.GetTime();
                Long Time2 = EndTime.GetTime();
                Long Time3  = Time2-Time1;
                Decimal TotalTime =  (Decimal.ValueOf(Time3)/(1000*60*60)); 
                // TotalTime = TotalTime.setScale(2);
                //system.debug('TotalTime===='+TotalTime);
                lunchRecord.HRMSUS__Hours__c = TotalTime.setScale(2);
            try {
                update lunchRecord;
            } catch (Exception ex) {
                System.debug('Error updating lunch record: ' + ex.getMessage()+'line number'+ex.getlinenumber());
                throw new AuraHandledException('Error updating lunch record: ' + ex.getMessage()+'line number'+ex.getlinenumber());
            }
            // Limiting to one record, break out of loop after the update
            break;
        }
    
        /*if (breakRecordsToUpdate.isEmpty()) {
            throw new AuraHandledException('No eligible lunch records found for update.');
        }*/
    }

    @AuraEnabled(cacheable=true)
    public static List<HRMSUS__Break__c> getlunchtimecards(date tdate) {   
       String currentUserId = UserInfo.getUserId(); 
        List<HRMSUS__Break__c> listLunch = [SELECT Id,Name,HRMSUS__Timecard__c,HRMSUS__Timecard__r.Name,HRMSUS__Type__c,HRMSUS__Date__c,HRMSUS__Start_Time__c,
        HRMSUS__Start_Time_HH_MM__c,HRMSUS__End_Time__c,HRMSUS__End_Time_HH_MM__c,HRMSUS__Hours__c FROM HRMSUS__Break__c
          where HRMSUS__Worker__r.HRMSUS__User__c = :currentUserId and HRMSUS__Date__c=:tdate and HRMSUS__Type__c='Lunch' ];
            System.debug('listLunch ' +listLunch); 
        return listLunch;
    }

    
public class WorkerInfoWrapper {
    @AuraEnabled
    public String workerName { get; set; }
    
    @AuraEnabled
    public String workerLocation { get; set; }
}


}