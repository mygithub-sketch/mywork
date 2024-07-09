@isTest
public class CustomLookupLwcControllerTest {
  /**
* @Method Name   GetLookupvalueTestMethod3
* @description : This Method is used  GetLookupvalueTestMethod3
 */
 static testmethod void fetchLookUpValuesTestMethod1(){
        Test.startTest();
      HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        account acc =new account(name='accs');
        insert acc;
        system.assertEquals(acc.Name,'accs','null');
        string fields1= 'Name';
     string fields= 'Name';
        string ObjectName ='Account';
        string searchKeyWord = '';
        string whereCondition = ' ';
        list<sObject> results = new list<sObject>();
      HRMSUS__Trigger__c  ct = new HRMSUS__Trigger__c ();
        ct.HRMSUS__EnableTimeoffandHolidayProjects__c =false;
       
       // insert ct;
     //CustomLookupLwcController.getLookupValues(searchKeyWord,ObjectName,fields,whereCondition,'',1);
      CustomLookupLwcController.getinitRecord(acc.id, ObjectName, fields1);
     CustomLookupLwcController.getRecentlyCreatedRecords(ObjectName, fields1, whereCondition,'', 1);
        Test.stopTest();
    }
     static testmethod void fetchLookUpValuesTestMethod(){
        Test.startTest();
      HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        account acc =new account(name='accs');
        insert acc;
        system.assertEquals(acc.Name,'accs','null');
        string fields1= 'Name';
    // string fields = ' Name ';
        string ObjectName ='Account';
        string searchKeyWord = '';
        string whereCondition = ' ';
        list<sObject> results = new list<sObject>();
      HRMSUS__Trigger__c  ct = new HRMSUS__Trigger__c ();
        ct.HRMSUS__EnableTimeoffandHolidayProjects__c =false;
       
       // insert ct;
         try{
    // CustomLookupLwcController.getLookupValues(searchKeyWord,ObjectName,fields1,whereCondition,'',1);
         }catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
         }
        Test.stopTest();
    }
    /**
* @Method Name   GetLookupvalueTestMethod3
* @description : This Method is used  GetLookupvalueTestMethod3
 */
 static testmethod void fetchLookUpValuesTestMethod2(){
        
        
        Test.startTest();
      HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        account acc =new account(name='accs');
        insert acc;
        system.assertEquals(acc.Name,'accs','null');
        
        string fields1= '';
        string ObjectName ='Account';
        string searchKeyWord =  'GenePo';
        string Condition = ' AnnualRevenue >10000';
        list<sObject> results = new list<sObject>();
       // results= CustomLookupLwcController.fetchLookUpValues(searchKeyWord,ObjectName,Condition,fields1);
        Test.stopTest();
        
    }
  
    
 /**
* @Method Name   GetLookupvalueTestMethod3
* @description : This Method is used  GetLookupvalueTestMethod3
 */
    static testmethod void GetLookupvalueTestMethod3(){
        Test.startTest();
         HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        account acc =new account(name='acc');
        insert acc;
        system.assert(acc!=null,'null');
        string RecordId = acc.id;
        string ObjectName = 'Account';
        string fields1= 'AccountNumber' ;
        //<sObject> results = new list<sObject>();
      //  sObject results = CustomLookupLwcController.GetLookupvalue(RecordId,ObjectName,fields1);
        Test.stopTest();
    }
    
}