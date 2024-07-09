@isTest
public with sharing class TimeoffRequestHoursLWCClsTest {
  
      @isTest  static  void TimeOffRequestAuraTestMethod() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        User u = new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id, name from Profile where name='System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
         System.runAs(u)
        {
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =company.id,Name='Test Location');
        insert loc;
            system.assert(loc!=null,'loc is null');
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Anas',HRMSUS__User__c=Userinfo.getuserId());
        insert p1;
        system.assert(p1!=null,'p1  is null');
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId());
        insert p;
        list<HRMSUS__Person__c> perlist=new list<HRMSUS__Person__c>();
        perlist.add(p);
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId(),HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p2 = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId());
       // insert p2;
        system.assert(p!=null,'p is null');
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                        HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        HRMSUS__Absence_Type__c at1=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today() );
       // insert at1;
       HRMSUS__Absence_Type__c at2=new HRMSUS__Absence_Type__c(Name='PTO Level erew1',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=p3.HRMSUS__Company__c,HRMSUS__Location__c =loc.id, 
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today(),HRMSUS__Allotment_Allowed__c=false );
       // insert at2;
        system.assert(at!=null,'at is null');
       
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p.id,HRMSUS__Absence_Type__c=at.id,HRMSUS__active__c=true,HRMSUS__End_Date__c=system.today()+7 ,HRMSUS__Carry_Over_Hours__c=10,HRMSUS__Time_off_Taken_Hours__c=3);
        insert ae;
        list<HRMSUS__Absence_Entitlement__c> aelist=new list<HRMSUS__Absence_Entitlement__c>();
        aelist.add(ae);
         HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1),HRMSUS__Personal_Time_Off__c=ae.id);
        insert ar;
        HRMSUS__Absence_Requests__c ar1 = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c =null,
                                                                         HRMSUS__End_Date__c = null,HRMSUS__Personal_Time_Off__c=ae.id);
      //  insert ar1;
        
        string recId = ar.Id;
        string recId1 = ar1.Id;
       // string recId2 = ar2.Id;
        list<HRMSUS__Absence_Requests__c> arlst=new list<HRMSUS__Absence_Requests__c>();
        arlst.add(ar);
        arlst.add(ar1);
        HRMSUS__Absence_Requests__c absentRequest;
          
            absentRequest = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId ];
        
    
       
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        HRMSUS__Person__c Person11 = [select Id,Name,HRMSUS__User__c from HRMSUS__Person__c where Id=:p.Id];
        system.assert(Person11!=null,'Person11 is null');
             HRMSUS__Time_Off_Dates__c td = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today(),
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
      //  insert td;
                 
     HRMSUS__Time_Off_Dates__c td1 = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today()+1,
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
      //  insert td1;
               
        HRMSUS__Holidays__c holidays = new HRMSUS__Holidays__c(name='Christmas',HRMSUS__Holiday_Date__c=system.today()+2,HRMSUS__Company__c=company.id);
        insert holidays;
     
        Id recordId;
        string notes ='';
       test.starttest();
       TimeoffRequestHoursLWCCls.getWorkers();
       TimeoffRequestHoursLWCCls.getWorkerName(p.id);
       TimeoffRequestHoursLWCCls.getLeaveHistory(p.id);
       TimeoffRequestHoursLWCCls.getTimeoffType();
       TimeoffRequestHoursLWCCls.getEntitlements(p.id);
       
        try{            
      TimeoffRequestHoursLWCCls.createTimeoffRequest(arlst, P.id, at.Id, ar.HRMSUS__Start_Date__c, ar.HRMSUS__End_Date__c, notes);
        }catch(Exception e){}
        test.stoptest();
     
        
        }
    }
    @isTest  static  void TimeOffRequestAuraTestMethod1() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        User u = new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id, name from Profile where name='System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
         System.runAs(u)
        {
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =company.id,Name='Test Location');
        insert loc;
            system.assert(loc!=null,'loc is null');
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Anas',HRMSUS__User__c=Userinfo.getuserId());
        insert p1;
        system.assert(p1!=null,'p1  is null');
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId());
        insert p;
        list<HRMSUS__Person__c> perlist=new list<HRMSUS__Person__c>();
        perlist.add(p);
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId(),HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p2 = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId());
       // insert p2;
        system.assert(p!=null,'p is null');
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                        HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        HRMSUS__Absence_Type__c at1=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today() );
       // insert at1;
       HRMSUS__Absence_Type__c at2=new HRMSUS__Absence_Type__c(Name='PTO Level erew1',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=p3.HRMSUS__Company__c,HRMSUS__Location__c =loc.id, 
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today(),HRMSUS__Allotment_Allowed__c=false );
       // insert at2;
        system.assert(at!=null,'at is null');
       
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p.id,HRMSUS__Absence_Type__c=at.id,HRMSUS__active__c=true,HRMSUS__End_Date__c=system.today()+7 ,HRMSUS__Carry_Over_Hours__c=10,HRMSUS__Time_off_Taken_Hours__c=3);
        insert ae;
        list<HRMSUS__Absence_Entitlement__c> aelist=new list<HRMSUS__Absence_Entitlement__c>();
        aelist.add(ae);
         HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1),HRMSUS__Personal_Time_Off__c=ae.id);
        insert ar;
        HRMSUS__Absence_Requests__c ar1 = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c =null,
                                                                         HRMSUS__End_Date__c = null,HRMSUS__Personal_Time_Off__c=ae.id);
      //  insert ar1;
        
        string recId = ar.Id;
        string recId1 = ar1.Id;
       // string recId2 = ar2.Id;
        list<HRMSUS__Absence_Requests__c> arlst=new list<HRMSUS__Absence_Requests__c>();
        arlst.add(ar);
        arlst.add(ar1);
        HRMSUS__Absence_Requests__c absentRequest;
          
            absentRequest = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId ];
        
    /*  HRMSUS__Absence_Requests__c  absentRequest1 = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId1 ];*/
       
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        HRMSUS__Person__c Person11 = [select Id,Name,HRMSUS__User__c from HRMSUS__Person__c where Id=:p.Id];
        system.assert(Person11!=null,'Person11 is null');
             HRMSUS__Time_Off_Dates__c td = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today(),
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td;
                 
     HRMSUS__Time_Off_Dates__c td1 = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today()+1,
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td1;
               
        HRMSUS__Holidays__c holidays = new HRMSUS__Holidays__c(name='Christmas',HRMSUS__Holiday_Date__c=system.today()+2,HRMSUS__Company__c=company.id);
        insert holidays;
     /*  String ToR1 = JSON.serialize(arlst);
        String ToR = JSON.serialize(TimeOffReqInsert1);
        String abR= JSON.serialize(absentRequest);
        String abR1= JSON.serialize(absentRequest1);
        String abR2= JSON.serialize(absentRequest);
        String abp= JSON.serialize(Person11); 
        String abp1= JSON.serialize(at); 
        String person= JSON.serialize(p); 
       string absense=JSON.serialize(absentRequest1);*/
        Id recordId;
        string notes ='';
       test.starttest();
       TimeoffRequestHoursLWCCls.getWorkers();
       TimeoffRequestHoursLWCCls.getWorkerName(p.id);
       TimeoffRequestHoursLWCCls.getLeaveHistory(p.id);
       TimeoffRequestHoursLWCCls.getTimeoffType();
       TimeoffRequestHoursLWCCls.getEntitlements(p.id);
       
        try{            
      TimeoffRequestHoursLWCCls.createTimeoffRequest(arlst, P.id, at.Id, ar.HRMSUS__Start_Date__c, ar.HRMSUS__End_Date__c, notes);
        }catch(Exception e){}
        test.stoptest();
     
        
        }
    }
    @isTest  static  void TimeOffRequestAuraTestMethod2() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        
        User u = new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id, name from Profile where name='Manager'].id,
                          EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
        System.runAs(u)
        {
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =company.id,Name='Test Location');
        insert loc;
            system.assert(loc!=null,'loc is null');
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Anas',HRMSUS__User__c=u.id,HRMSUS__Company__c=company.id,HRMSUS__Status__c ='Active');
        insert p1;
        system.assert(p1!=null,'p1  is null');
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=u.id,HRMSUS__Status__c ='Active',HRMSUS__Company__c=company.id);
        insert p;
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId(),HRMSUS__Status__c ='Active',HRMSUS__Company__c=company.id);
        insert p3;
        
        system.assert(p!=null,'p is null');
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Allotment_Allowed__c=true,HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        HRMSUS__Absence_Type__c at1=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today() );
       // insert at1;
       HRMSUS__Absence_Type__c at2=new HRMSUS__Absence_Type__c(Name='PTO Level erew1',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=p3.HRMSUS__Company__c,HRMSUS__Location__c =loc.id, 
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today(),HRMSUS__Allotment_Allowed__c=false );
        insert at2;
        system.assert(at!=null,'at is null');
       
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Absences_Start_Date__c=system.today()+1,HRMSUS__End_Date__c=system.today()+10,HRMSUS__Worker__c=p.id,HRMSUS__Absence_Type__c=at.id,HRMSUS__active__c=true,HRMSUS__Carry_Over_Hours__c=10,HRMSUS__Time_off_Taken_Hours__c=0);
        insert ae;
        list<HRMSUS__Absence_Entitlement__c> aelist=new list<HRMSUS__Absence_Entitlement__c>();
        aelist.add(ae);
         HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=1,HRMSUS__Hours1__c='4',HRMSUS__Leave_Hours__c=8,
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='Approved',
                                                                         HRMSUS__Start_Date__c =system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1));//HRMSUS__Personal_Time_Off__c=ae.id
        insert ar;
        HRMSUS__Absence_Requests__c ar1 = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=1,HRMSUS__Hours1__c='4',HRMSUS__Leave_Hours__c=8,
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c = system.today()+1,
                                                                         HRMSUS__End_Date__c = system.today().AddDays(2));//HRMSUS__Personal_Time_Off__c=ae.id
        insert ar1;
       
        string recId = ar1.Id;
        string recId1 = ar.Id;
        list<HRMSUS__Absence_Requests__c> arlst=new list<HRMSUS__Absence_Requests__c>();
        arlst.add(ar);
        arlst.add(ar1); 
        HRMSUS__Absence_Requests__c absentRequest;
            absentRequest = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name,HRMSUS__Approved__c, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId ];
       
      HRMSUS__Absence_Requests__c  absentRequest1 = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId1 ];
       
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__End_Date__c,HRMSUS__Hours1__c,HRMSUS__Approved__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert2= [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__End_Date__c,HRMSUS__Hours1__c,HRMSUS__Approved__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        

        
     HRMSUS__Time_Off_Dates__c td = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today(),
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td;
                 
     HRMSUS__Time_Off_Dates__c td1 = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today()+1,
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td1;
               
        HRMSUS__Holidays__c holidays = new HRMSUS__Holidays__c(name='Christmas',HRMSUS__Holiday_Date__c=system.today()+2,HRMSUS__Company__c=company.id);
        insert holidays;
        HRMSUS__Person__c Person11 = [select Id,Name,HRMSUS__User__c from HRMSUS__Person__c where Id=:p.Id];
        system.assert(Person11!=null,'Person11 is null');
       String ToR1 = JSON.serialize(absentRequest);
        String ToR = JSON.serialize(TimeOffReqInsert1);
        String abR= JSON.serialize(absentRequest);
       String abR1= JSON.serialize(TimeOffReqInsert2);
        String abR2= JSON.serialize(absentRequest);
        String abp= JSON.serialize(Person11); 
        String abp1= JSON.serialize(at); 
        String person= JSON.serialize(p); 
       string absense=JSON.serialize(absentRequest1);
        Id recordId;
       test.starttest();
            try{
       TimeoffRequestHoursLWCCls.getWorkers();
       TimeoffRequestHoursLWCCls.getWorkerName(p.id);
       TimeoffRequestHoursLWCCls.getLeaveHistory(p.id);
       TimeoffRequestHoursLWCCls.getTimeoffType();
       TimeoffRequestHoursLWCCls.getEntitlements(p.id);
      // TimeoffRequestHoursLWCCls.createTimeoffRequest(lstABR, P.id, typeId, startDate, endDate, notes);
        }catch(Exception e){}
       test.stoptest();
        }
    }
    
     @isTest  static  void TimeOffRequestAuraTestMethod3() 
    {
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
         User u = new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',
                          email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',
                          CommunityNickname ='testtes' ,
                          ProfileId=[select id, name from Profile where name='System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =company.id,Name='Test Location');
        insert loc;
            system.assert(loc!=null,'loc is null');
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Anas',HRMSUS__User__c=Userinfo.getuserId());
        insert p1;
        system.assert(p1!=null,'p1  is null');
        HRMSUS__Person__c p=new HRMSUS__Person__c(name='hhh',HRMSUS__Business_Entity__c=company.id,HRMSUS__Company__c =company.id,HRMSUS__Role__c='Employee', HRMSUS__Soc_Sec_Num__c ='1283',HRMSUS__first_Name__c='jjs',HRMSUS__IsSupervisor__c=true,HRMSUS__Email__c = 'sudeep@hyde123.com',HRMSUS__Approver__c=u.id,HRMSUS__Commencement_Date__c=System.today(),HRMSUS__User__c=u.id,HRMSUS__Last_Name__c='Last');
            insert p;
        list<HRMSUS__Person__c> perlist=new list<HRMSUS__Person__c>();
        perlist.add(p);
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId(),HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p2 = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId());
       // insert p2;
        system.assert(p!=null,'p is null');
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                        HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        HRMSUS__Absence_Type__c at1=new HRMSUS__Absence_Type__c(Name='PTO Level 1',HRMSUS__Available_Days__c=45,HRMSUS__Company__c=company.id,HRMSUS__Location__c =loc.id, HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today() );
       // insert at1;
       HRMSUS__Absence_Type__c at2=new HRMSUS__Absence_Type__c(Name='PTO Level erew1',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=p3.HRMSUS__Company__c,HRMSUS__Location__c =loc.id, 
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today(),HRMSUS__Allotment_Allowed__c=false );
        insert at2;
        system.assert(at!=null,'at is null');
       
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p.id,HRMSUS__Absence_Type__c=at.id,HRMSUS__active__c=true,HRMSUS__End_Date__c =system.today()+7  ,HRMSUS__Carry_Over_Hours__c=10,HRMSUS__Time_off_Taken_Hours__c=3);
        insert ae;
        list<HRMSUS__Absence_Entitlement__c> aelist=new list<HRMSUS__Absence_Entitlement__c>();
        aelist.add(ae);
         HRMSUS__Absence_Requests__c ar = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c = system.today(),
                                                                         HRMSUS__End_Date__c = system.today().AddDays(1),HRMSUS__Personal_Time_Off__c=ae.id);
        insert ar;
        HRMSUS__Absence_Requests__c ar1 = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = p.Id,
                                                                          HRMSUS__Total_Hours__c=4,HRMSUS__Hours1__c='4',
                                                                         HRMSUS__Absence_Type__c=at.Id,HRMSUS__Approved__c='submitted',
                                                                         HRMSUS__Start_Date__c =system.today()+1,
                                                                         HRMSUS__End_Date__c = system.today()+2,HRMSUS__Personal_Time_Off__c=ae.id);
        insert ar1;
    
     HRMSUS__Time_Off_Dates__c td = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today(),
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td;
        HRMSUS__Time_Off_Dates__c td1 = new HRMSUS__Time_Off_Dates__c(HRMSUS__Date__c=system.today()+1,
                                                                 HRMSUS__Time_Off_Request__c =ar.Id,
                                                                 HRMSUS__Time_Off_Entitlement__c =ae.Id);
        
        insert td1;
        string recId = ar.Id;
        string recId1 = ar1.Id;
       // string recId2 = ar2.Id;
        list<HRMSUS__Absence_Requests__c> arlst=new list<HRMSUS__Absence_Requests__c>();
        arlst.add(ar);
        arlst.add(ar1);
        HRMSUS__Absence_Requests__c absentRequest;
          
            absentRequest = [ SELECT Id, Name, HRMSUS__Worker__c,HRMSUS__Worker__r.Name, HRMSUS__Absence_Type__c, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, HRMSUS__Notes__c, HRMSUS__Total_Hours__c
                                 FROM HRMSUS__Absence_Requests__c WHERE Id = :recId ];
        
   
       
        list<HRMSUS__Absence_Requests__c> TimeOffReqInsert1 = [select Id,Name,HRMSUS__worker__c,
                                                               HRMSUS__Start_Date__c,HRMSUS__End_Date__c
                                                               from HRMSUS__Absence_Requests__c where Id=:ar.Id];
        HRMSUS__Person__c Person11 = [select Id,Name,HRMSUS__User__c from HRMSUS__Person__c where Id=:p.Id];
        system.assert(Person11!=null,'Person11 is null');
          HRMSUS__Holidays__c holidays = new HRMSUS__Holidays__c(name='Christmas',HRMSUS__Holiday_Date__c=system.today()+2,HRMSUS__Company__c=company.id);
        insert holidays;
        
       test.starttest();
       TimeoffRequestHoursLWCCls.getWorkers();
       TimeoffRequestHoursLWCCls.getWorkerName(p.id);
       TimeoffRequestHoursLWCCls.getLeaveHistory(p.id);
       TimeoffRequestHoursLWCCls.getTimeoffType();
       TimeoffRequestHoursLWCCls.getEntitlements(p.id);
       
        try{
            TimeoffRequestHoursLWCCls.showTimeoffRequest(p.id,at.Id, ar.HRMSUS__Start_Date__c, ar.HRMSUS__End_Date__c);
      
        }catch(Exception e){}
        test.stoptest();
     
        
    }
}