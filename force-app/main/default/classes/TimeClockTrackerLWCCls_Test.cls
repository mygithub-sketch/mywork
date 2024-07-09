@isTest
public class TimeClockTrackerLWCCls_Test {
    
     static testMethod void TimeClockTrackerLWCCls_TestMethod1() 
    {
        test.starttest();
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
       insert trg;
        User u= new user(Firstname = 'tttt', Lastname= 'lname',Alias = 'tessst',email = 'hrmssoft@yahoo.com',username = 'hrmssoft@yahoo.com',CommunityNickname ='testtes' ,ProfileId=[select id from Profile where name=:'System Administrator'].id,EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u; 
        system.runas(u){
        String latitudes='14.1234611';
        String longitudes='-13.0987651';
        String types;
            
        HRMSUS__Company__c com=new HRMSUS__Company__c(Name='Testcomp',HRMSUS__Week_Start_Day__c='Monday');
        insert com;
            
        HRMSUS__Location__c loc=new HRMSUS__Location__c(Name='Location1',HRMSUS__Company__c=com.id);
        insert loc;
        
        HRMSUS__Projects__c proj =new HRMSUS__Projects__c(Name='Testproj');
        insert proj;
                                
        HRMSUS__Time_Shifts__c timesht = new HRMSUS__Time_Shifts__c(Name='Shift A', HRMSUS__Company__c=com.Id,HRMSUS__Shift_Length__c=8.00,HRMSUS__Break_Length__c=0.50,
                                                                    HRMSUS__Lunch_Length__c=0.50,HRMSUS__LnchDedctTme__c=7.00,HRMSUS__Total_Time__c=8.50);
        insert timesht;
        
        system.debug('timesht===='+timesht);
        
        HRMSUS__Schedule__c sch = new HRMSUS__Schedule__c(HRMSUS__Scheduled_Shift__c='1st-A',HRMSUS__Company__c=com.Id,HRMSUS__Shift__c=timesht.Id,
                                                          HRMSUS__Start_Time__c='08:00 AM',HRMSUS__End_Time__c='05:00 PM',HRMSUS__Active__c=true);
        
        insert sch;
        
        HRMSUS__Person__c supervisor=new HRMSUS__Person__c(Name='sup Person',HRMSUS__IsSupervisor__c=true,HRMSUS__Scheduled_Shift__c= sch.id, HRMSUS__EMT_Pay__c=true);
        insert supervisor;
        system.debug('sch===='+sch);
        // inserted values for HRMSUS__Person__c Object
        HRMSUS__Person__c person=new HRMSUS__Person__c(Name='Test Person',HRMSUS__Supervisor__c= supervisor.id, HRMSUS__Scheduled_Shift__c= sch.id,HRMSUS__IsSupervisor__c=true,HRMSUS__EMT_Pay__c=true
                                                    //    HRMSUS__User__c=u.id
                                                        );
        insert person;
        
        
        
        HRMSUS__Person__c person1=new HRMSUS__Person__c(Name='Test P',
                                                        HRMSUS__IsSupervisor__c=true,HRMSUS__Employee_ID__c='Test Emp',
                                                        HRMSUS__Company__c=com.Id,
                                                        HRMSUS__Shift__c=timesht.Id,
                                                        HRMSUS__Scheduled_Shift__c =sch.Id,
                                                        HRMSUS__Job_Title__c='Manager',
                                                        HRMSUS__Location__c=loc.id,
                                                        HRMSUS__Is_Active__c=true,HRMSUS__Supervisor__c=person.Id,
                                                        HRMSUS__FLSA__c='Test',HRMSUS__User__c=u.id,
                                                        HRMSUS__Middle__c='test',HRMSUS__EMT_Pay__c=true);
        insert person1;
        
           
        
        HRMSUS__Daily_Timecard__c objDailyTimecard = new HRMSUS__Daily_Timecard__c();            
        objDailyTimecard.HRMSUS__Timecard_Date__c = System.Today();
        
        objDailyTimecard.HRMSUS__Employee__c = person1.id;
        objDailyTimecard.HRMSUS__Supervisor__c=person1.HRMSUS__Supervisor__c;
        objDailyTimecard.HRMSUS__Start_Time__c= system.now();
        objDailyTimecard.HRMSUS__Location__c=loc.id;
        objDailyTimecard.HRMSUS__Start_Time_HH_MM__c = objDailyTimecard.HRMSUS__Start_Time__c.format('hh:mm a');
        objDailyTimecard.HRMSUS__End_Time__c = system.now()+8;
        objDailyTimecard.HRMSUS__End_Time_HH_MM__c = objDailyTimecard.HRMSUS__End_Time__c.format('hh:mm a');
        objDailyTimecard.HRMSUS__Total_Hours__c=8;
        objDailyTimecard.HRMSUS__Punch_In__c =System.now()+1;
      
        objDailyTimecard.HRMSUS__Punch_In_HH_MM__c = objDailyTimecard.HRMSUS__Punch_In__c.format('hh:mm a');
        
        insert objDailyTimecard;
            
            HRMSUS__Attendance_Points__c ap=new HRMSUS__Attendance_Points__c(HRMSUS__Active__c=True,
                                                                             HRMSUS__NCNS__c=True,
                                                                             HRMSUS__Daily_Timecard__c=objDailyTimecard.id,
                                                                             HRMSUS__Employee_Name__c=person1.id,
                                                                             HRMSUS__Worker__c=person1.id);
            insert ap;
            
        String objDailyTimecards = JSON.serialize(objDailyTimecard);  

        Id dailyTimecardId = objDailyTimecard.id;
        HRMSUS__Break__c ObjBreaks = new HRMSUS__Break__c();             
        ObjBreaks.HRMSUS__Date__c = system.toDay();
        ObjBreaks.HRMSUS__Timecard__c =dailyTimecardId;
        ObjBreaks.HRMSUS__Type__c = 'Break';
        ObjBreaks.HRMSUS__Start_Time__c =Time.newInstance(Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[0]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[1]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[2]),0);
        Datetime myDateTime = Datetime.newInstance(Date.today(),  ObjBreaks.HRMSUS__Start_Time__c);
        ObjBreaks.HRMSUS__Start_Time_HH_MM__c = myDateTime.format('h:mm a');                
        
        insert ObjBreaks; 
               
        
        Date testDate = Date.today();
        
        String workerName = 'Test Worker';
        String locationName = 'Test Location';

        List<TimeClockTrackerLWCCls.WorkerInfoWrapper> workerInfoList = TimeClockTrackerLWCCls.getWorkerInfo();
        List<String> allLocations = TimeClockTrackerLWCCls.getAllLocations();
        TimeClockTrackerLWCCls.updatePunchOutTime(dailyTimecardId);
        Id newTimecardId = TimeClockTrackerLWCCls.createDailyTimecard(workerName, locationName);       
        List<HRMSUS__Daily_Timecard__c> timecards = TimeClockTrackerLWCCls.getDailyTimecards(testDate);

        /*Break Method to pass in controller  */
            try{
        List<Id> createdBreakRecordIds = TimeClockTrackerLWCCls.createBreakRecordsForTimecard(workerName, objDailyTimecard.id);        
        System.assertNotEquals(null, createdBreakRecordIds, 'Break record creation failed');
            }catch(exception ex){}
            List<HRMSUS__Break__c> Listbreak = TimeClockTrackerLWCCls.getBreaktimecards(testDate);
        TimeClockTrackerLWCCls.updateBreakOutTime(workerName,dailyTimecardId);
       /*Lunch Method to pass in controller 
            try{
        List<Id> createdLunchRecordIds = timeclocktracker_lwc_cls.createlunchRecordsForTimecard(dailyTimecardId, workerName);         
            }catch(exception ex){}
        List<HRMSUS__Break__c> Listlunch = timeclocktracker_lwc_cls.getlunchtimecards(testDate);
        timeclocktracker_lwc_cls.updatelunchOutTime(workerName,dailyTimecardId); */
        

        test.stoptest();
        }
    }





   static testMethod void TimeClockTrackerLWCClsTestMethod2() 
    {
        test.starttest();
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
       insert trg;
        User u= new user(Firstname = 'tttt', Lastname= 'lname',Alias = 'tessst',email = 'hrmssoft@yahoo.com',username = 'hrmssoft@yahoo.com',CommunityNickname ='testtes' ,ProfileId=[select id from Profile where name=:'System Administrator'].id,EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u; 
        system.runas(u){
        String latitudes='14.1234611';
        String longitudes='-13.0987651';
        String types;
            
            HRMSUS__Company__c com=new HRMSUS__Company__c(Name='Testcomp',HRMSUS__Week_Start_Day__c='Monday');
            insert com;
            
            HRMSUS__Location__c loc=new HRMSUS__Location__c(Name='Location1',HRMSUS__Company__c=com.id);
            insert loc;
        
            HRMSUS__Projects__c proj =new HRMSUS__Projects__c(Name='Testproj');
            insert proj;
        
        

        
        
        HRMSUS__Time_Shifts__c timesht = new HRMSUS__Time_Shifts__c(Name='Shift A', HRMSUS__Company__c=com.Id,HRMSUS__Shift_Length__c=8.00,HRMSUS__Break_Length__c=0.50,
                                                                    HRMSUS__Lunch_Length__c=0.50,HRMSUS__LnchDedctTme__c=7.00,HRMSUS__Total_Time__c=8.50);
        insert timesht;
        
        system.debug('timesht===='+timesht);
        
        HRMSUS__Schedule__c sch = new HRMSUS__Schedule__c(HRMSUS__Scheduled_Shift__c='1st-A',HRMSUS__Company__c=com.Id,HRMSUS__Shift__c=timesht.Id,
                                                          HRMSUS__Start_Time__c='08:00 AM',HRMSUS__End_Time__c='05:00 PM',HRMSUS__Active__c=true);
        
        insert sch;
        
        HRMSUS__Person__c supervisor=new HRMSUS__Person__c(Name='sup Person',HRMSUS__IsSupervisor__c=true,HRMSUS__Scheduled_Shift__c= sch.id, HRMSUS__EMT_Pay__c=true);
        insert supervisor;
        system.debug('sch===='+sch);
        // inserted values for HRMSUS__Person__c Object
        HRMSUS__Person__c person=new HRMSUS__Person__c(Name='Test Person',HRMSUS__Supervisor__c= supervisor.id, HRMSUS__Scheduled_Shift__c= sch.id,HRMSUS__IsSupervisor__c=true,HRMSUS__EMT_Pay__c=true
                                                    //    HRMSUS__User__c=u.id
                                                        );
        insert person;
        
        
        
        HRMSUS__Person__c person1=new HRMSUS__Person__c(Name='Test P',
                                                        HRMSUS__IsSupervisor__c=true,HRMSUS__Employee_ID__c='Test Emp',
                                                        HRMSUS__Company__c=com.Id,
                                                        HRMSUS__Shift__c=timesht.Id,
                                                        HRMSUS__Scheduled_Shift__c =sch.Id,
                                                        HRMSUS__Job_Title__c='Manager',
                                                        HRMSUS__Location__c=loc.id,
                                                        HRMSUS__Is_Active__c=true,HRMSUS__Supervisor__c=person.Id,
                                                        HRMSUS__FLSA__c='Test',HRMSUS__User__c=u.id,
                                                        HRMSUS__Middle__c='test',HRMSUS__EMT_Pay__c=true);
        insert person1;
        
           
        
        HRMSUS__Daily_Timecard__c objDailyTimecard = new HRMSUS__Daily_Timecard__c();            
        objDailyTimecard.HRMSUS__Timecard_Date__c = System.Today();
        
        objDailyTimecard.HRMSUS__Employee__c = person1.id;
        objDailyTimecard.HRMSUS__Supervisor__c=person1.HRMSUS__Supervisor__c;
        objDailyTimecard.HRMSUS__Start_Time__c= system.now();
        objDailyTimecard.HRMSUS__Location__c=loc.id;
        objDailyTimecard.HRMSUS__Start_Time_HH_MM__c = objDailyTimecard.HRMSUS__Start_Time__c.format('hh:mm a');
        objDailyTimecard.HRMSUS__End_Time__c = system.now()+8;
        objDailyTimecard.HRMSUS__End_Time_HH_MM__c = objDailyTimecard.HRMSUS__End_Time__c.format('hh:mm a');
        objDailyTimecard.HRMSUS__Total_Hours__c=8;
        objDailyTimecard.HRMSUS__Punch_In__c =System.now()+1;
      
        objDailyTimecard.HRMSUS__Punch_In_HH_MM__c = objDailyTimecard.HRMSUS__Punch_In__c.format('hh:mm a');
        
        insert objDailyTimecard;
            
            HRMSUS__Attendance_Points__c ap=new HRMSUS__Attendance_Points__c(HRMSUS__Active__c=True,
                                                                             HRMSUS__NCNS__c=True,
                                                                             HRMSUS__Daily_Timecard__c=objDailyTimecard.id,
                                                                             HRMSUS__Employee_Name__c=person1.id,
                                                                             HRMSUS__Worker__c=person1.id);
            insert ap;
            
        String objDailyTimecards = JSON.serialize(objDailyTimecard);   
     
        HRMSUS__Break__c ObjBreaks = new HRMSUS__Break__c();             
        ObjBreaks.HRMSUS__Date__c = system.toDay();
        ObjBreaks.HRMSUS__Timecard__c = objDailyTimeCard.Id;
        ObjBreaks.HRMSUS__Type__c = 'Break';
        ObjBreaks.HRMSUS__Start_Time__c =Time.newInstance(Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[0]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[1]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[2]),0);
        Datetime myDateTime = Datetime.newInstance(Date.today(),  ObjBreaks.HRMSUS__Start_Time__c);
        ObjBreaks.HRMSUS__Start_Time_HH_MM__c = myDateTime.format('h:mm a');                
        
        insert ObjBreaks; 


        HRMSUS__Break__c ObjLunch = new HRMSUS__Break__c();             
        ObjLunch.HRMSUS__Date__c = system.toDay();
        ObjLunch.HRMSUS__Timecard__c = objDailyTimeCard.Id;
        ObjLunch.HRMSUS__Type__c = 'Lunch';
        ObjLunch.HRMSUS__Start_Time__c =Time.newInstance(Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[0]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[1]),Integer.ValueOf(String.valueOf(System.now()).Split(' ')[1].split(':')[2]),0);
        Datetime myDateTime1 = Datetime.newInstance(Date.today(),  ObjLunch.HRMSUS__Start_Time__c);
        ObjLunch.HRMSUS__Start_Time_HH_MM__c = myDateTime1.format('h:mm a');                
        
        insert ObjLunch; 
        
        Date testDate = Date.today();
        Id dailyTimecardId = objDailyTimecard.id;
        String workerName = 'Test Worker';
        String locationName = 'Test Location';

        List<TimeClockTrackerLWCCls.WorkerInfoWrapper> workerInfoList = TimeClockTrackerLWCCls.getWorkerInfo();
        List<String> allLocations = TimeClockTrackerLWCCls.getAllLocations();
        TimeClockTrackerLWCCls.updatePunchOutTime(dailyTimecardId);
        Id newTimecardId = TimeClockTrackerLWCCls.createDailyTimecard(workerName, locationName);       
        List<HRMSUS__Daily_Timecard__c> timecards = TimeClockTrackerLWCCls.getDailyTimecards(testDate);

        /*Break Method to pass in controller  
        List<Id> createdBreakRecordIds = timeclocktracker_lwc_cls.createBreakRecordsForTimecard(workerName, dailyTimecardId);
        List<HRMSUS__Break__c> Listbreak = timeclocktracker_lwc_cls.getBreaktimecards(testDate);
        timeclocktracker_lwc_cls.updateBreakOutTime(workerName,dailyTimecardId);*/

        /*Lunch Method to pass in controller  */
        try{
        List<Id> createdLunchRecordIds = TimeClockTrackerLWCCls.createlunchRecordsForTimecard(dailyTimecardId, workerName);
        }catch(exception ex){}
        List<HRMSUS__Break__c> Listlunch = TimeClockTrackerLWCCls.getlunchtimecards(testDate);
        TimeClockTrackerLWCCls.updatelunchOutTime(workerName,dailyTimecardId);

        test.stoptest();
        }
    }

}