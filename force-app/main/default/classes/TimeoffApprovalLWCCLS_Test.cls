/*@istest(SeeAllData=true)

/**
* @author      : Biznussoft
* @modifiedBy  :  
* @version     :
* @create date :
* @modify date :
* @description : This class shows public class TimeOffRequestApprovals_Test
*/
@istest()
public class TimeoffApprovalLWCCLS_Test
{
  /**
* @MethodName  : TimeOffRequestApprovals_Test1
* @description : This method used TimeOffRequestApprovals_Test1
 */
   public testmethod static void TimeoffApprovalLWCCLS_Test1()
    {
        
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        User u = new user(Firstname = 'testfn', Lastname= 'testln',Alias = 'ttest',email = 'hrmssoft@gmail.com',
                          username = 'hrms@yahoo.com',CommunityNickname ='testtes' ,
                          ProfileId=[select id from Profile where name=:'System Administrator'].id,
                          EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US'); 
        insert u;
        User u1= new user(Firstname = 'testfen1', 
                          Lastname= 'testlenn1',
                          Alias = 'tteest1',
                          email = 'fieldconnect1TesteUser@gmail.com',
                          username = 'fconnect1@yahoo.com',
                          CommunityNickname='testtes1' ,
                          ProfileId=[select id from Profile where name=:'System Administrator'].id,EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',Managerid=u.id); 
        insert u1;
        
        System.runAs(u)
        {
            Account acc = new Account(Name='Test',CurrencyIsoCode='USD');
            insert acc;
            HRMSUS__Projects__c Proj =new HRMSUS__Projects__c(Name='Test Project',
                                                              HRMSUS__Account__c=acc.Id,
                                                              HRMSUS__Active__c=true);
            Insert Proj;
            
            HRMSUS__Company__c com = new HRMSUS__Company__c(name='Biznussoft',HRMSUS__Week_Start_Day__c='Monday');
            insert com;
            HRMSUS__Location__c loc=new HRMSUS__Location__c(Name='Test Location',HRMSUS__Company__c = com.id);
            insert loc;
            HRMSUS__Person__c per1=new HRMSUS__Person__c(name='jhjmhk',HRMSUS__Role__c='Employee', 
                                                         HRMSUS__Soc_Sec_Num__c ='17623',
                                                         HRMSUS__first_Name__c='jhrfbuhvf',
                                                         HRMSUS__Email__c= 'sudeephgjhk@hyd.com',
                                                         HRMSUS__Commencement_Date__c=System.today(),
                                                         HRMSUS__Company__c=com.id,
                                                         HRMSUS__User__c = u.id); 
            insert per1;
             system.assert(per1!=null,'Not null');
            HRMSUS__Person__c person=new HRMSUS__Person__c(name='poouu4',HRMSUS__Role__c='Employee', 
                                                           HRMSUS__Soc_Sec_Num__c ='123',
                                                           
                                                           HRMSUS__first_Name__c='jhrfbpuhvf',
                                                           HRMSUS__Email__c= 'sudeep@hyd.com',
                                                           HRMSUS__Supervisor__c=per1.id,
                                                           HRMSUS__Commencement_Date__c=System.today(),
                                                           HRMSUS__Company__c=com.id,
                                                           HRMSUS__User__c =u1.id); 
            
            person.HRMSUS__last_Name__c = person.name;
            insert person;
            
            HRMSUS__Daily_Sheet__c objDailySheet=new HRMSUS__Daily_Sheet__c(HRMSUS__Customer__c=acc.id,
                                                                         HRMSUS__Project__c=proj.id,
                                                                         HRMSUS__Type__c='Travel',
                                                                        HRMSUS__Billable__c=true,HRMSUS__Date__c=date.today(),
                                                                         HRMSUS__Employee__c=person.id);
        insert objDailySheet;
            
            HRMSUS__Absence_Type__c atype=new HRMSUS__Absence_Type__c(name='Paid Leave',
                                                                      HRMSUS__Max_Absent_Entitlement__c=5,
                                                                      HRMSUS__Exclude__c='Saturdays;Sundays',HRMSUS__Company__c =com.id,
                                                                      HRMSUS__Location__c =loc.id,
                                                                      HRMSUS__Time_Off_End__c =system.today().adddays(1), 
                                                                      HRMSUS__Time_Off_Start__c=system.today());
            insert atype;
            system.assert(atype!=null,'Not null');
            HRMSUS__Absence_Entitlement__c ae=new HRMSUS__Absence_Entitlement__c(HRMSUS__Absence_Entitlement1__c=4,
                                                                                 HRMSUS__Absence_Taken__c=10,
                                                                                 HRMSUS__Absence_Type__c=atype.id,
                                                                                 HRMSUS__Carry_Forward__c=5,
                                                                                 HRMSUS__Worker__c=person.id);
            insert ae;
            
            HRMSUS__Holidays__c hol=new HRMSUS__Holidays__c (name='Christmas',
                                                             HRMSUS__Holiday_Date__c=System.today());
           // insert hol;
            
            
            
            
            HRMSUS__Absence_Requests__c ar=new HRMSUS__Absence_Requests__c (name='xyz',HRMSUS__Absence_Type__c=atype.id,
                                                                            HRMSUS__Total_Absence_Requested__c=20,
                                                                            HRMSUS__Worker__c=person.id,
                                                                            HRMSUS__Approved__c='pending',
                                                                            HRMSUS__Rejection_Comments__c=' Test Data',
                                                                            HRMSUS__Start_Date__c=System.today(),
                                                                            HRMSUS__End_Date__c=System.today()+6);
            insert ar;
            
            HRMSUS__Absence_Requests__c ar1=new HRMSUS__Absence_Requests__c (name='xyzq',HRMSUS__Absence_Type__c=atype.id,
                                                                             HRMSUS__Total_Absence_Requested__c=20,
                                                                             HRMSUS__Worker__c=person.id,
                                                                              HRMSUS__Approved__c='Rejected',
                                                                             HRMSUS__Rejection_Comments__c=' Test Data',
                                                                             HRMSUS__Start_Date__c=System.today(),
                                                                             HRMSUS__End_Date__c=System.today()+6);
            insert ar1;
            
            system.assert(ar1!=null,'Not null');
            
      HRMSUS__Absence_Requests__c ar2 = new HRMSUS__Absence_Requests__c(HRMSUS__worker__c = person.Id,
                                                                        HRMSUS__Approved__c='pending', 
                                                                        HRMSUS__Total_Hours__c=4,
                                                                        HRMSUS__Absence_Type__c=atype.Id, 
                                                                        HRMSUS__Start_Date__c = system.today()+9,
                                                                        HRMSUS__End_Date__c = system.today().AddDays(13));
        insert ar2;
            
            List<HRMSUS__Absence_Requests__c> applyLst = new List<HRMSUS__Absence_Requests__c>();
            applyLst.add(ar);
            set<Id> applyIds = new set<Id>();
            for(HRMSUS__Absence_Requests__c apps:applyLst)
            {
                applyIds.add(apps.id);
            }
            
              test.startTest();
        try{
            Approval.ProcessSubmitRequest timeOffRequest = new Approval.ProcessSubmitRequest();
            timeOffRequest.setObjectId(ar.ID);
            timeOffRequest.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     
            Approval.ProcessResult timeOffRequestResult = Approval.Process(timeOffRequest);
                System.assert(timeOffRequestResult.isSuccess(),'Not null');
                System.assertEquals('Pending', timeOffRequestResult.getInstanceStatus(),'Instance Status'+timeOffRequestResult.getInstanceStatus());
    
            ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
            pworkItem.ActorId = userinfo.getuserId();
            pworkItem.OriginalActorId = userinfo.getuserId();
            pworkItem.ProcessInstanceId = ar.Id;
            insert pworkItem;
            
            
            Approval.ProcessSubmitRequest timeOffRequest1 = new Approval.ProcessSubmitRequest();
            timeOffRequest1.setObjectId(ar1.ID);
            timeOffRequest1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     
            Approval.ProcessResult timeOffRequestResult1 = Approval.Process(timeOffRequest1);
            ProcessInstanceWorkitem pworkItem1 = new ProcessInstanceWorkitem();
            pworkItem1.ActorId = userinfo.getuserId();
            pworkItem1.OriginalActorId = userinfo.getuserId();
            pworkItem1.ProcessInstanceId = ar1.Id;
            insert pworkItem1;
        }
        catch(exception e)
        {
            system.debug('>>>> APPROVAL PROCESS ISSUES!');
        }
      
       
            
            Test.setCurrentPageReference(new PageReference('Page.leavesystem')); 
            System.currentPageReference().getParameters().put('leavesystemcontroller',ar.id);
            
            TimeoffApprovalLWCCLS.getTimeOffRequestInfo();
            TimeoffApprovalLWCCLS.getrequest();
            TimeoffApprovalLWCCLS.approveWorkerAbsenceRequest(ar2);
            TimeoffApprovalLWCCLS.rejectWorkerAbsenceRequest(ar2,'test');
}
}
}