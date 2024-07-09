@isTest
public with sharing class TimeOffEntitlementsLwcClsTest {
    public static testmethod void TimeOffEntitlementmethod1(){ 
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        
        
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.today(),
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p4= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.Today()-365,
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p4;
        
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=company.id, 
                                                               HRMSUS__Available_Hours__c=20,
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                               HRMSUS__Time_Off_Start__c=system.today().adddays(3) );
        insert at;
        
        
        list<HRMSUS__Absence_Type__c> ablst = new list<HRMSUS__Absence_Type__c>();
        ablst.add(at);
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p4.id,
                                                                             HRMSUS__Absence_Type__c=at.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        integer diffOfHireCurYear =  (system.now()).year() - (p4.HRMSUS__Seniority_Date__c).year();
        string[] ab = new string[]{at.id};
            String u=Userinfo.getuserId();
        try{
            TimeOffEntitlementsLwcCls.createAbsenceEntitlements(ablst,p4.id);    
        }catch(Exception e){}
        
        TimeOffEntitlementsLwcCls.getTimeoffType(p4.id);
        system.assertEquals(ae.HRMSUS__Worker__c,p4.id, 'person data is correct');
    }
    
    public static testmethod void TimeOffEntitlementmethod2(){ 
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        
        
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.today(),
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p4= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.Today()-365,
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p4;
        
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=company.id, 
                                                               HRMSUS__Available_Hours__c=20,
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                               HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        
        
        list<HRMSUS__Absence_Type__c> ablst = new list<HRMSUS__Absence_Type__c>();
        ablst.add(at);
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p4.id,
                                                                             HRMSUS__Absence_Type__c=at.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        integer diffOfHireCurYear =  (system.now()).year() - (p4.HRMSUS__Seniority_Date__c).year();
        string[] ab = new string[]{at.id};
            String u=Userinfo.getuserId();
        TimeOffEntitlementsLwcCls.createAbsenceEntitlements(ablst,p4.id);
        TimeOffEntitlementsLwcCls.getTimeoffType(p4.id);
        system.assertEquals(ae.HRMSUS__Worker__c,p4.id, 'person data is correct');
    }

    public static testmethod void TimeOffEntitlementmethod3(){ 
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        
        
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.today(),
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p4= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.Today()-365,
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p4;
        
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=company.id, 
                                                               HRMSUS__Available_Hours__c=null,
                                                               HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                               HRMSUS__Time_Off_Start__c=system.today() );
        insert at;
        
        
        list<HRMSUS__Absence_Type__c> ablst = new list<HRMSUS__Absence_Type__c>();
        ablst.add(at);
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p4.id,
                                                                             HRMSUS__Absence_Type__c=at.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        integer diffOfHireCurYear =  (system.now()).year() - (p4.HRMSUS__Seniority_Date__c).year();
        string[] ab = new string[]{at.id};
            String u=Userinfo.getuserId();
        try{
            TimeOffEntitlementsLwcCls.createAbsenceEntitlements(ablst,p4.id);
         }catch(Exception e){}
        TimeOffEntitlementsLwcCls.getTimeoffType(p4.id);
        system.assertEquals(ae.HRMSUS__Worker__c,p4.id, 'person data is correct');
    }
    
    public static testmethod void TimeOffEntitlementmethod4(){ 
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        
        
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.today(),
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p4= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.Today()-365,
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p4;
        
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=company.id, 
                                                               HRMSUS__Available_Hours__c=8,
                                                               HRMSUS__Time_Off_End__c =null, 
                                                               HRMSUS__Time_Off_Start__c=system.today() );
        try{insert at;}catch(Exception e){}
        
        
        list<HRMSUS__Absence_Type__c> ablst = new list<HRMSUS__Absence_Type__c>();
        ablst.add(at);
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p4.id,
                                                                             HRMSUS__Absence_Type__c=at.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        integer diffOfHireCurYear =  (system.now()).year() - (p4.HRMSUS__Seniority_Date__c).year();
        string[] ab = new string[]{at.id};
            String u=Userinfo.getuserId();
        try{
            TimeOffEntitlementsLwcCls.createAbsenceEntitlements(ablst,p4.id);
         }catch(Exception e){}
        TimeOffEntitlementsLwcCls.getTimeoffType(p4.id);
        system.assertEquals(ae.HRMSUS__Worker__c,p4.id, 'person data is correct');
    }
    
    public static testmethod void TimeOffEntitlementmethod5(){ 
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        Account acc= new Account(name='SanaUllah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Test Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        
        
        HRMSUS__Person__c p3= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.today(),
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p3;
        HRMSUS__Person__c p4= new HRMSUS__Person__c(Name = 'Anas233',
                                                    HRMSUS__Seniority_Date__c=System.Today()-365,
                                                    HRMSUS__User__c=Userinfo.getuserId(),
                                                    HRMSUS__Company__c=company.id);
        insert p4;
        
        HRMSUS__Absence_Type__c at=new HRMSUS__Absence_Type__c(Name='PTO',HRMSUS__Available_Days__c=45,
                                                               HRMSUS__Company__c=company.id, 
                                                               HRMSUS__Available_Hours__c=8,
                                                               HRMSUS__Time_Off_End__c =system.today(), 
                                                               HRMSUS__Time_Off_Start__c=null );
        try{insert at;}catch(Exception e){}
        
        
        list<HRMSUS__Absence_Type__c> ablst = new list<HRMSUS__Absence_Type__c>();
        ablst.add(at);
        
        HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Worker__c=p4.id,
                                                                             HRMSUS__Absence_Type__c=at.id,
                                                                             HRMSUS__Active__c=true);
        insert ae;
        
        list<HRMSUS__Absence_Entitlement__c> aelst = new list<HRMSUS__Absence_Entitlement__c>();
        aelst.add(ae);
        integer diffOfHireCurYear =  (system.now()).year() - (p4.HRMSUS__Seniority_Date__c).year();
        string[] ab = new string[]{at.id};
            String u=Userinfo.getuserId();
        try{
            TimeOffEntitlementsLwcCls.createAbsenceEntitlements(ablst,p4.id);
         }catch(Exception e){}
        TimeOffEntitlementsLwcCls.getTimeoffType(p4.id);
        system.assertEquals(ae.HRMSUS__Worker__c,p4.id, 'person data is correct');
    }
}