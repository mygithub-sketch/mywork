@isTest
public class DailySheetCntrlLWCTest {

    static testMethod void dailySheetCntrlMethod1() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
       
        HRMSUS__Company__c c = new HRMSUS__Company__c(name='Biznussoft',HRMSUS__Week_Start_Day__c='Monday');
        insert c;
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =c.id,Name='Test Location');
        insert loc;
        Account acc= new Account(name='test',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'test');
        insert acc;
        
        Account acc1= new Account(name='test2',BillingStreet = '17-A',BillingPostalCode = '74800',BillingState = 'Sindh',
                                  BillingCity = 'test2');
        insert acc1;
        
        HRMSUS__Time_Shifts__c tsh = new HRMSUS__Time_Shifts__c(HRMSUS__Lunch_Length__c = 1.30,
                                                                HRMSUS__Break_Length__c = 1.0,
                                                                HRMSUS__In_Time__c = '09:00 AM',
                                                                HRMSUS__Out_Time__c ='09:00 PM',
                                                                HRMSUS__Shift_Length__c=12);
        insert tsh;
        
        HRMSUS__Schedule__c sch = new HRMSUS__Schedule__c(HRMSUS__Scheduled_Shift__c='1st shift A',
                                                          HRMSUS__Company__c=c.id,
                                                          HRMSUS__Start_Time__c = '10:00 AM',
                                                          HRMSUS__End_Time__c ='8:00 PM',
                                                          HRMSUS__Shift__c=tsh.id
                                                          //  HRMSUS__Supervisor__c = supervisor.id
                                                         );
        insert sch;
        User u = new user(Firstname = 'testfn', 
                          Lastname= 'testln',
                          Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',
                          username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id from Profile where name=:'System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',
                   LanguageLocaleKey='en_US',
                   TimeZoneSidKey='America/Los_Angeles',
                          LocaleSidKey='en_US'); 
        insert u;
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'John Adams',
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Scheduled_Shift__c =sch.id,
                                                    HRMSUS__Required_Hours__c=8,
                                                    HRMSUS__Company__c=c.Id,
                                                    HRMSUS__Class_Group__c='');
        insert p;
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Bryan Adams',HRMSUS__Company__c = c.Id,
                                                     HRMSUS__Class_Group__c='Class 1',
                                                     HRMSUS__Scheduled_Shift__c =sch.id,
                                                     HRMSUS__User__c = u.id);
        // insert p1;
        HRMSUS__Tasks__c ts = new HRMSUS__Tasks__c(Name = 'Time Off');
        insert ts;
        HRMSUS__Daily_Task__c dt = new HRMSUS__Daily_Task__c();
        insert dt;
        HRMSUS__Projects__c pro = new HRMSUS__Projects__c(Name = 'test',HRMSUS__Account__c = acc1.id);
        insert pro;
    
        HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                         Name='Time Off Request1',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1));
    //    insert ar;
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        String ToR = JSON.serialize(TimeOffReqInsert1);
        HRMSUS__Absence_Type__c at = new HRMSUS__Absence_Type__c(name = 'test',HRMSUS__Available_Days__c=45,
                                                                 HRMSUS__Time_Off_Start__c=system.today(), HRMSUS__Time_Off_End__c=system.today()+1,
                                                                 HRMSUS__Company__c=c.id,HRMSUS__Location__c =loc.id );
        insert at;
        
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dt1 = DateTime.now();
        String dateString = dt1.format(dateFormat);
        HRMSUS__Absence_ENtitlement__c ae= new hrmsus__aBSENCE_Entitlement__c(HRMSUS__Worker__c=p.id,
                                                                              HRMSUS__aBSENCE_eNTITLEMENT1__c=20,
                                                                              HRMSUS__Absence_Taken__c=3,
                                                                              // Absence_Type__c=ToT.id,
                                                                              HRMSUS__Active__c=True,HRMSUS__Commited__c=0
                                                                             );
        insert Ae;
        
        List<HRMSUS__Employee_Timesheet__c > ETimeSheet = new List<HRMSUS__Employee_Timesheet__c>();
            Date myDate = Date.today();
            Date weekStart = myDate.toStartofWeek()+1;
            System.debug(weekStart);
            HRMSUS__Employee_Timesheet__c Et =new HRMSUS__Employee_Timesheet__c(HRMSUS__Status__c='Submitted',                                                                        
                                                                                HRMSUS__Person__c=p.id,
                                                                                HRMSUS__Timesheet_Date__c=weekStart
                                                                               );
         ETimeSheet.add(Et);
            insert ETimeSheet;  
      
        Test.startTest();
        DailySheetCntrlLWC cls = new DailySheetCntrlLWC();
        DailySheetCntrlLWC.getWorkers();
        DailySheetCntrlLWC.getDailysheetCSInfo();
        DailySheetCntrlLWC.fetchDailySheetDetails(p.id, dateString);
        DailySheetCntrlLWC.getProjTask(pro.id);
       
       
        
        HRMSUS__Dailysheet_config__c DSC = new HRMSUS__Dailysheet_config__c ();
        Dsc.HRMSUS__Display_workers__c =false;
        Dsc.HRMSUS__Total_Hour_Entry__c= true;
        insert DSC;
        //insert new HRMSUS__Dailysheet_config__c (HRMSUS__Display_workers__c= true);
        
        
        
        HRMSUS__Daily_Sheet__c DS = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                               HRMSUS__Start_Time__c='10',HRMSUS__Task__c=ts.id,
                                                               HRMSUS__Start_Time_Hrs__c=25,
                                                               HRMSUS__Start_Time_Mns__c=02,
                                                               HRMSUS__End_Time_Hrs__c=5,
                                                               HRMSUS__End_Time_Mns__c=2,
                                                               HRMSUS__St_Min__c='00',
                                                               HRMSUS__St_Meridian__c='AM',
                                                               HRMSUS__End_Time__c='5',
                                                               HRMSUS__Type__c='Work',
                                                               HRMSUS__En_Min__c='00',
                                                               HRMSUS__En_Meridian__c='PM',
                                                               HRMSUS__Employee__c = p.id,
                                                               HRMSUS__Project__c= pro.id,
                                                               HRMSUS__Customer__c = acc.id
                                                              );
        INSERT DS;
        
        HRMSUS__Daily_Sheet__c DS1 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=10,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                                //HRMSUS__Timesheet_Entry__c=Tentry.Id
                                                               );
        
        INSERT DS1;   
        
        HRMSUS__Daily_Sheet__c DS2 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=25,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                               );
        INSERT DS2;   
        
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        
        
        try{                                               
            list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1,DS,DS2};
                
            DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        }
        catch(exception e){
         system.debug('Exception has occured : '+e.getMessage());   
        }
        list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1};
            
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        
        Dsc.HRMSUS__Total_Hour_Entry__c= false;
        update DSC;
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
      
        Test.stopTest();
    }
    static testMethod void dailySheetCntrlMethod2() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
       
        HRMSUS__Company__c c = new HRMSUS__Company__c(name='Biznussoft',HRMSUS__Week_Start_Day__c='Monday');
        insert c;
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =c.id,Name='Test Location');
        insert loc;
        Account acc= new Account(name='test',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'test');
        insert acc;
        
        Account acc1= new Account(name='test2',BillingStreet = '17-A',BillingPostalCode = '74800',BillingState = 'Sindh',
                                  BillingCity = 'test2');
        insert acc1;
        
        HRMSUS__Time_Shifts__c tsh = new HRMSUS__Time_Shifts__c(HRMSUS__Lunch_Length__c = 1.30,
                                                                HRMSUS__Break_Length__c = 1.0,
                                                                HRMSUS__In_Time__c = '09:00 AM',
                                                                HRMSUS__Out_Time__c ='09:00 PM',
                                                                HRMSUS__Shift_Length__c=12);
        insert tsh;
        
        HRMSUS__Schedule__c sch = new HRMSUS__Schedule__c(HRMSUS__Scheduled_Shift__c='1st shift A',
                                                          HRMSUS__Company__c=c.id,
                                                          HRMSUS__Start_Time__c = '10:00 AM',
                                                          HRMSUS__End_Time__c ='8:00 PM',
                                                          HRMSUS__Shift__c=tsh.id
                                                          //  HRMSUS__Supervisor__c = supervisor.id
                                                         );
        insert sch;
        User u = new user(Firstname = 'testfn', 
                          Lastname= 'testln',
                          Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',
                          username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id from Profile where name=:'System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',
                   LanguageLocaleKey='en_US',
                   TimeZoneSidKey='America/Los_Angeles',
                          LocaleSidKey='en_US'); 
        insert u;
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'John Adams',
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Scheduled_Shift__c =sch.id,
                                                    HRMSUS__Required_Hours__c=8,
                                                    HRMSUS__Company__c=c.Id,
                                                    HRMSUS__Class_Group__c='');
        insert p;
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Bryan Adams',HRMSUS__Company__c = c.Id,
                                                     HRMSUS__Class_Group__c='Class 1',
                                                     HRMSUS__Scheduled_Shift__c =sch.id,
                                                     HRMSUS__User__c = u.id);
        // insert p1;
        HRMSUS__Tasks__c ts = new HRMSUS__Tasks__c(Name = 'Time Off');
        insert ts;
        HRMSUS__Daily_Task__c dt = new HRMSUS__Daily_Task__c();
        insert dt;
        HRMSUS__Projects__c pro = new HRMSUS__Projects__c(Name = 'test',HRMSUS__Account__c = acc1.id);
        insert pro;
    
        HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                         Name='Time Off Request1',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1));
    //    insert ar;
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        String ToR = JSON.serialize(TimeOffReqInsert1);
        HRMSUS__Absence_Type__c at = new HRMSUS__Absence_Type__c(name = 'test',HRMSUS__Available_Days__c=45,
                                                                 HRMSUS__Time_Off_Start__c=system.today(), HRMSUS__Time_Off_End__c=system.today()+1,
                                                                 HRMSUS__Company__c=c.id,HRMSUS__Location__c =loc.id );
        insert at;
        
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dt1 = DateTime.now();
        String dateString = dt1.format(dateFormat);
        HRMSUS__Absence_ENtitlement__c ae= new hrmsus__aBSENCE_Entitlement__c(HRMSUS__Worker__c=p.id,
                                                                              HRMSUS__aBSENCE_eNTITLEMENT1__c=20,
                                                                              HRMSUS__Absence_Taken__c=3,
                                                                              // Absence_Type__c=ToT.id,
                                                                              HRMSUS__Active__c=True,HRMSUS__Commited__c=0
                                                                             );
        insert Ae;
        
        List<HRMSUS__Employee_Timesheet__c > ETimeSheet = new List<HRMSUS__Employee_Timesheet__c>();
            Date myDate = Date.today();
            Date weekStart = myDate.toStartofWeek()+1;
            System.debug(weekStart);
            HRMSUS__Employee_Timesheet__c Et =new HRMSUS__Employee_Timesheet__c(HRMSUS__Status__c='Submitted',                                                                        
                                                                                HRMSUS__Person__c=p.id,
                                                                                HRMSUS__Timesheet_Date__c=weekStart
                                                                               );
         ETimeSheet.add(Et);
            insert ETimeSheet;  
      
        Test.startTest();
        DailySheetCntrlLWC cls = new DailySheetCntrlLWC();
        DailySheetCntrlLWC.getWorkers();
        DailySheetCntrlLWC.getDailysheetCSInfo();
        DailySheetCntrlLWC.fetchDailySheetDetails(p.id, dateString);
        DailySheetCntrlLWC.getProjTask(pro.id);
       
       
        
        HRMSUS__Dailysheet_config__c DSC = new HRMSUS__Dailysheet_config__c ();
        Dsc.HRMSUS__Display_workers__c =false;
        Dsc.HRMSUS__Time_Format__c= true;
        insert DSC;
        //insert new HRMSUS__Dailysheet_config__c (HRMSUS__Display_workers__c= true);
        
        
        
        HRMSUS__Daily_Sheet__c DS = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                               HRMSUS__Start_Time__c='10',HRMSUS__Task__c=ts.id,
                                                               HRMSUS__Start_Time_Hrs__c=25,
                                                               HRMSUS__Start_Time_Mns__c=02,
                                                               HRMSUS__End_Time_Hrs__c=5,
                                                               HRMSUS__End_Time_Mns__c=2,
                                                               HRMSUS__St_Min__c='00',
                                                               HRMSUS__St_Meridian__c='AM',
                                                               HRMSUS__End_Time__c='5',
                                                               HRMSUS__Type__c='Work',
                                                               HRMSUS__En_Min__c='00',
                                                               HRMSUS__En_Meridian__c='PM',
                                                               HRMSUS__Employee__c = p.id,
                                                               HRMSUS__Project__c= pro.id,
                                                               HRMSUS__Customer__c = acc.id
                                                              );
        INSERT DS;
        
        HRMSUS__Daily_Sheet__c DS1 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=10,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                                //HRMSUS__Timesheet_Entry__c=Tentry.Id
                                                               );
        
        INSERT DS1;   
        
        HRMSUS__Daily_Sheet__c DS2 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=25,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                               );
        INSERT DS2;   
        
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        
        
        try{                                               
            list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1,DS,DS2};
                
            DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        }
        catch(exception e){
         system.debug('Exception has occured : '+e.getMessage());   
        }
        list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1};
            
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        
        Dsc.HRMSUS__Total_Hour_Entry__c= true;
        update DSC;
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        DailySheetCntrlLWC.deleteRow(DS2);
        Test.stopTest();
    }
    static testMethod void dailySheetCntrlMethod3() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
       
        HRMSUS__Company__c c = new HRMSUS__Company__c(name='Biznussoft',HRMSUS__Week_Start_Day__c='Monday');
        insert c;
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =c.id,Name='Test Location');
        insert loc;
        Account acc= new Account(name='test',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'test');
        insert acc;
        
        Account acc1= new Account(name='test2',BillingStreet = '17-A',BillingPostalCode = '74800',BillingState = 'Sindh',
                                  BillingCity = 'test2');
        insert acc1;
        
        HRMSUS__Time_Shifts__c tsh = new HRMSUS__Time_Shifts__c(HRMSUS__Lunch_Length__c = 1.30,
                                                                HRMSUS__Break_Length__c = 1.0,
                                                                HRMSUS__In_Time__c = '09:00 AM',
                                                                HRMSUS__Out_Time__c ='09:00 PM',
                                                                HRMSUS__Shift_Length__c=12);
        insert tsh;
        
        HRMSUS__Schedule__c sch = new HRMSUS__Schedule__c(HRMSUS__Scheduled_Shift__c='1st shift A',
                                                          HRMSUS__Company__c=c.id,
                                                          HRMSUS__Start_Time__c = '10:00 AM',
                                                          HRMSUS__End_Time__c ='8:00 PM',
                                                          HRMSUS__Shift__c=tsh.id
                                                          //  HRMSUS__Supervisor__c = supervisor.id
                                                         );
        insert sch;
        User u = new user(Firstname = 'testfn', 
                          Lastname= 'testln',
                          Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',
                          username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id from Profile where name=:'Manager'].id,
                          EmailEncodingKey='ISO-8859-1',
                   LanguageLocaleKey='en_US',
                   TimeZoneSidKey='America/Los_Angeles',
                          LocaleSidKey='en_US'); 
        insert u;
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'John Adams',
                                                    HRMSUS__User__c=u.id,
                                                    HRMSUS__Scheduled_Shift__c =sch.id,
                                                    HRMSUS__Required_Hours__c=8,
                                                    HRMSUS__Company__c=c.Id,
                                                    HRMSUS__Class_Group__c='');
        insert p;
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Bryan Adams',HRMSUS__Company__c = c.Id,
                                                     HRMSUS__Class_Group__c='Class 1',
                                                     HRMSUS__Scheduled_Shift__c =sch.id,
                                                     HRMSUS__User__c = u.id);
        // insert p1;
        HRMSUS__Tasks__c ts = new HRMSUS__Tasks__c(Name = 'Time Off');
        insert ts;
        HRMSUS__Daily_Task__c dt = new HRMSUS__Daily_Task__c();
        insert dt;
        HRMSUS__Projects__c pro = new HRMSUS__Projects__c(Name = 'test',HRMSUS__Account__c = acc1.id);
        insert pro;
    
        HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                         Name='Time Off Request1',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1));
    //    insert ar;
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        String ToR = JSON.serialize(TimeOffReqInsert1);
        HRMSUS__Absence_Type__c at = new HRMSUS__Absence_Type__c(name = 'test',HRMSUS__Available_Days__c=45,
                                                                 HRMSUS__Time_Off_Start__c=system.today(), HRMSUS__Time_Off_End__c=system.today()+1,
                                                                 HRMSUS__Company__c=c.id,HRMSUS__Location__c =loc.id );
        insert at;
        
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dt1 = DateTime.now();
        String dateString = dt1.format(dateFormat);
        HRMSUS__Absence_ENtitlement__c ae= new hrmsus__aBSENCE_Entitlement__c(HRMSUS__Worker__c=p.id,
                                                                              HRMSUS__aBSENCE_eNTITLEMENT1__c=20,
                                                                              HRMSUS__Absence_Taken__c=3,
                                                                              // Absence_Type__c=ToT.id,
                                                                              HRMSUS__Active__c=True,HRMSUS__Commited__c=0
                                                                             );
        insert Ae;
        
        List<HRMSUS__Employee_Timesheet__c > ETimeSheet = new List<HRMSUS__Employee_Timesheet__c>();
            Date myDate = Date.today();
            Date weekStart = myDate.toStartofWeek()+1;
            System.debug(weekStart);
            HRMSUS__Employee_Timesheet__c Et =new HRMSUS__Employee_Timesheet__c(HRMSUS__Status__c='Submitted',                                                                        
                                                                                HRMSUS__Person__c=p.id,
                                                                                HRMSUS__Timesheet_Date__c=weekStart
                                                                               );
         ETimeSheet.add(Et);
            insert ETimeSheet;  
      
        Test.startTest();
        DailySheetCntrlLWC cls = new DailySheetCntrlLWC();
        DailySheetCntrlLWC.getWorkers();
        DailySheetCntrlLWC.getDailysheetCSInfo();
        DailySheetCntrlLWC.fetchDailySheetDetails(p.id, dateString);
        DailySheetCntrlLWC.getProjTask(pro.id);
       
       
        
        HRMSUS__Dailysheet_config__c DSC = new HRMSUS__Dailysheet_config__c ();
        Dsc.HRMSUS__Display_workers__c =false;
        Dsc.HRMSUS__Time_Format__c= true;
      //  insert DSC;
        //insert new HRMSUS__Dailysheet_config__c (HRMSUS__Display_workers__c= true);
        
        
        
        HRMSUS__Daily_Sheet__c DS = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                               HRMSUS__Start_Time__c='10',HRMSUS__Task__c=ts.id,
                                                               HRMSUS__Start_Time_Hrs__c=25,
                                                               HRMSUS__Start_Time_Mns__c=02,
                                                               HRMSUS__End_Time_Hrs__c=5,
                                                               HRMSUS__End_Time_Mns__c=2,
                                                               HRMSUS__St_Min__c='00',
                                                               HRMSUS__St_Meridian__c='AM',
                                                               HRMSUS__End_Time__c='5',
                                                               HRMSUS__Type__c='Work',
                                                               HRMSUS__En_Min__c='00',
                                                               HRMSUS__En_Meridian__c='PM',
                                                               HRMSUS__Employee__c = p.id,
                                                               HRMSUS__Project__c= pro.id,
                                                               HRMSUS__Customer__c = acc.id
                                                              );
        INSERT DS;
        
        HRMSUS__Daily_Sheet__c DS1 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=10,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                                //HRMSUS__Timesheet_Entry__c=Tentry.Id
                                                               );
        
        INSERT DS1;   
        
        HRMSUS__Daily_Sheet__c DS2 = New HRMSUS__Daily_Sheet__c(HRMSUS__Date__c=system.today(),
                                                                HRMSUS__Start_Time__c='10',
                                                                HRMSUS__Start_Time_Hrs__c=25,
                                                                HRMSUS__Start_Time_Mns__c=02,
                                                                HRMSUS__End_Time_Hrs__c=5,
                                                                HRMSUS__End_Time_Mns__c=2,
                                                                HRMSUS__St_Min__c='00',
                                                                HRMSUS__St_Meridian__c='AM',
                                                                HRMSUS__End_Time__c='5',
                                                                HRMSUS__Type__c='Work',
                                                                HRMSUS__En_Min__c='00',
                                                                HRMSUS__En_Meridian__c='PM',
                                                                HRMSUS__Employee__c = p.id,
                                                                HRMSUS__Project__c= pro.id,
                                                                HRMSUS__Customer__c = acc1.id
                                                               );
        INSERT DS2;   
        
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=DS2.Id,
                                     SobjectType='HRMSUS__Daily_Sheet__c',
                                     PermissionsRead=true,//Assignee.ID=u.id,
                                     PermissionsViewAllRecords=true));
        
        
        try{                                               
            list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1,DS,DS2};
                
            DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        }
        catch(exception e){
         system.debug('Exception has occured : '+e.getMessage());   
        }
        list<HRMSUS__Daily_Sheet__c> dsLst = new list<HRMSUS__Daily_Sheet__c>{DS1};
            
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        
        Dsc.HRMSUS__Total_Hour_Entry__c= true;
     //   update DSC;
        DailySheetCntrlLWC.saveDailySheetDetails(dsLst);
        DailySheetCntrlLWC.deleteRow(DS2);
        Test.stopTest();
    }
}