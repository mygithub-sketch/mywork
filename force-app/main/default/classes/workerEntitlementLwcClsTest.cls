@isTest
public with sharing class workerEntitlementLwcClsTest {
    public static testmethod void unitTest()
    {
        User u= new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',CommunityNickname ='testtes' ,ProfileId=[select id from Profile where name=:'System Administrator'].id,EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
        Account acc=new Account(Name='Test');
        insert acc;
        HRMSUS__Company__c comp = new HRMSUS__Company__c(name='Hillpheonix',HRMSUS__Week_Start_Day__c='Monday');
        insert comp;
        HRMSUS__Location__c location = new HRMSUS__Location__c(name='TestLocation',HRMSUS__Account__c=acc.id,HRMSUS__Company__c=comp.id);
        insert location;
        HRMSUS__Department__c dept=new HRMSUS__Department__c(name='testdept',HRMSUS__Dept__c='23423',HRMSUS__Company__c=comp.id,HRMSUS__Location__c=location.id);
        insert dept;
        
        HRMSUS__Trigger__c tr= new HRMSUS__Trigger__c(HRMSUS__Skip_Onboarding_Process__c=true);
        insert tr;
        HRMSUS__Person__c per=new HRMSUS__Person__c(name='testsup', HRMSUS__Last_Name__c='lname',
                                                    HRMSUS__Location__c =location.id,HRMSUS__Company__c=comp.id,
                                                    HRMSUS__Department__c=dept.id,HRMSUS__User__c=u.id);
        insert per;
        
        HRMSUS__Absence_Type__c testAbsenceType = new HRMSUS__Absence_Type__c(Name = 'Test Absence Type',
                                                                              HRMSUS__Company__c=comp.id,
                                                                              HRMSUS__Current_State__c='Active',
                                                                              HRMSUS__Time_Off_Start__c=system.today()+2,
                                                                              HRMSUS__Time_Off_End__c=system.today()+10,
                                                                              HRMSUS__Available_Hours__c=40);
        insert testAbsenceType;
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=per.id,
                                                                             HRMSUS__Absences_Start_Date__c=system.today(),
                                                                             HRMSUS__Absence_Type__c=testAbsenceType.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        HRMSUS__Time_off_Entitlement_Line__c te=new HRMSUS__Time_off_Entitlement_Line__c(HRMSUS__Time_Off_Entitlement__c=ae.id,
                                                                                        HRMSUS__Date__c=system.today());
 
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        
        workerEntitlementLwcCls SchPay=new workerEntitlementLwcCls();
        list<workerEntitlementLwcCls.WorkerWrapper> wpq= new list<workerEntitlementLwcCls.WorkerWrapper> ();
        workerEntitlementLwcCls.WorkerWrapper wp= new workerEntitlementLwcCls.WorkerWrapper ();        
        wp.id = per.Id;
        wp.Name='Asm Asma';
        wp.typeName='PTO';
        wp.typeId = testAbsenceType.Id;
        wp.hours = 8;
        wp.StartDate = Date.today();
        wp.EndDate = Date.today().addDays(1);
        wp.check = true;
        wpq.add(wp);
        
        Date startDate =system.today();
        Date endDate = system.today()+30; 
        
        Test.startTest();
        try{
            String result = workerentitlementlwccls.saveWorkers(wpq);
        }catch(Exception e){}
        
        Test.stopTest();                    
        
        workerEntitlementLwcCls.getAlldepartments(location.Name);
        workerEntitlementLwcCls.getAllLocations();
        workerEntitlementLwcCls.getWorkersByDepartment(location.Name,dept.Name);
    }
    
    public static testmethod void unitTest1()
    {
        User u= new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',email = 'hrmssoft@gmail.com',username = 'hrms@yahoo.com',CommunityNickname ='testtes' ,ProfileId=[select id from Profile where name=:'System Administrator'].id,EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
        Account acc=new Account(Name='Test');
        insert acc;
        HRMSUS__Company__c comp = new HRMSUS__Company__c(name='Hillpheonix',HRMSUS__Week_Start_Day__c='Monday');
        insert comp;
        HRMSUS__Location__c location = new HRMSUS__Location__c(name='TestLocation',HRMSUS__Account__c=acc.id,HRMSUS__Company__c=comp.id);
        insert location;
        HRMSUS__Department__c dept=new HRMSUS__Department__c(name='testdept',HRMSUS__Dept__c='23423',HRMSUS__Company__c=comp.id,HRMSUS__Location__c=location.id);
        insert dept;
        
        HRMSUS__Trigger__c tr= new HRMSUS__Trigger__c(HRMSUS__Skip_Onboarding_Process__c=true);
        insert tr;
        HRMSUS__Person__c per=new HRMSUS__Person__c(name='testsup', HRMSUS__Last_Name__c='lname',
                                                    HRMSUS__Location__c =location.id,HRMSUS__Company__c=comp.id,
                                                    HRMSUS__Department__c=dept.id,HRMSUS__User__c=u.id);
        insert per;
        
        HRMSUS__Absence_Type__c testAbsenceType = new HRMSUS__Absence_Type__c(Name = 'Test Absence Type',
                                                                              HRMSUS__Company__c=comp.id,
                                                                              HRMSUS__Current_State__c='Active',
                                                                              HRMSUS__Time_Off_Start__c=system.today()+2,
                                                                              HRMSUS__Time_Off_End__c=system.today()+10,
                                                                              HRMSUS__Available_Hours__c=40);
        insert testAbsenceType;
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=per.id,
                                                                             HRMSUS__Absences_Start_Date__c=date.newInstance(2015, 12, 15),
                                                                             HRMSUS__Absence_Type__c=testAbsenceType.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        HRMSUS__Time_off_Entitlement_Line__c te=new HRMSUS__Time_off_Entitlement_Line__c(HRMSUS__Time_Off_Entitlement__c=ae.id,
                                                                                        HRMSUS__Date__c=system.today());
 
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        
        workerentitlementlwccls SchPay=new workerentitlementlwccls();
        list<workerentitlementlwccls.WorkerWrapper> wpq= new list<workerentitlementlwccls.WorkerWrapper> ();
        workerentitlementlwccls.WorkerWrapper wp= new workerentitlementlwccls.WorkerWrapper ();        
        wp.id = per.Id;
        wp.Name='Asm Asma';
        wp.typeName='PTO';
        wp.typeId = testAbsenceType.Id;
        wp.hours = 8;
        wp.StartDate = Date.today();
        wp.EndDate = Date.today().addDays(1);
        wp.check = true;
        wpq.add(wp);
        
        Date startDate =system.today();
        Date endDate = system.today()+30; 
        
        Test.startTest();
        try{
            String result = workerEntitlementLwcCls.saveWorkers(wpq);
        }catch(Exception e){}
        
        Test.stopTest();                    
        
        workerEntitlementLwcCls.getAlldepartments(location.Name);
        workerEntitlementLwcCls.getAllLocations();
        workerEntitlementLwcCls.getWorkersByDepartment(location.Name,dept.Name);
    }
}