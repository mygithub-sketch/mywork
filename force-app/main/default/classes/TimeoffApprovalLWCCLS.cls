public with sharing class TimeoffApprovalLWCCLS { 
    @AuraEnabled(cacheable=true)
    public static object getTimeOffRequestInfo() 
    {  
        List<HRMSUS__Absence_Requests__c> absentrequest = new List<HRMSUS__Absence_Requests__c>();
        HRMSUS__Person__c person = new HRMSUS__Person__c();
        
        user u2= new user();
        profile pro =new profile();
        
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT id,lastname,email,managerid,profileid  FROM USER WHERE id=:UserInfo.getUserId()]);
        u2=(user)securityDecision.getRecords()[0];
        System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
        
        // user u2 = [];
        //  profile pro = [];  
        SObjectAccessDecision securityDecisionProfile  = Security.stripInaccessible(AccessType.READABLE, [SELECT id,name FROM Profile WHERE id=:u2.profileid]);
        pro=(profile)securityDecisionProfile.getRecords()[0];
        System.debug('Fields removed by stripInaccessible: '+securityDecisionProfile.getRemovedFields());
        try
        {
            SObjectAccessDecision securityDecisionPer = Security.stripInaccessible(AccessType.READABLE,
                                                                                   [SELECT Id, Name, HRMSUS__Name__c, HRMSUS__Approver__c FROM HRMSUS__Person__c Where HRMSUS__user__c=:u2.id]);
            person=(HRMSUS__Person__c)securityDecisionPer.getRecords()[0];
            System.debug('Fields removed by stripInaccessible: '+securityDecisionPer.getRemovedFields());
            // person = [];
        }
        Catch(Exception ex){system.debug(ex.getmessage());}
        List<HRMSUS__Person__c> u1 = new List<HRMSUS__Person__c>();
        try
        {
            SObjectAccessDecision securityDecisionPerson = Security.stripInaccessible(AccessType.READABLE,
                                                                                      [SELECT id,name ,HRMSUS__user__c,HRMSUS__Supervisor__c FROM HRMSUS__Person__c WHERE HRMSUS__Supervisor__c =:person.id]);
            u1=securityDecisionPerson.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecisionPerson.getRemovedFields()); 
            // u1 =  [];
        }
        Catch(Exception ex)
        {
            System.debug('No Employee is connected to this User. '  + ex.getMessage()); 
        }
        Set<String> personId = new Set<String>();
        for(HRMSUS__Person__c per:u1)
        {
            PersonId.add(per.id); 
        }
        List<PermissionSetAssignment> permissionsetAcc =new List<PermissionSetAssignment> ();
        SObjectAccessDecision securityDecisionPerSetAssign = Security.stripInaccessible(AccessType.READABLE, [SELECT id,AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()]);
        PermissionsetAcc=securityDecisionPerSetAssign.getRecords();
        System.debug('Fields removed by stripInaccessible: '+securityDecisionPerSetAssign.getRemovedFields()); 
        // List<PermissionSetAssignment> PermissionsetAcc = [];
        
        Boolean iSHR;
        for(PermissionSetAssignment per : PermissionsetAcc){ 
            if(per.PermissionSet.Name=='BZ_Operations' || per.PermissionSet.Name=='BZ_Operations_Salesforce' 
               || per.PermissionSet.Name=='BZ_Operations_Salesforce_Platform' || per.PermissionSet.Name=='BZ_Admin' 
               || per.PermissionSet.Name=='BZ_Admin_Salesforce' || per.PermissionSet.Name=='BZ_Admin_Salesforce_Platform'){
                   ISHR = true;     
               }
        }
        
        for(PermissionSetAssignment per : PermissionsetAcc){ 
            if(per.PermissionSet.Name=='BZ_Operations' || per.PermissionSet.Name=='BZ_Operations_Salesforce' 
               || per.PermissionSet.Name=='BZ_Operations_Salesforce_Platform' || per.PermissionSet.Name=='BZ_Admin' 
               || per.PermissionSet.Name=='BZ_Admin_Salesforce' || per.PermissionSet.Name=='BZ_Admin_Salesforce_Platform'){
                   ISHR = true;     
               }
        }
        if(pro.name=='System Administrator' || pro.name=='IS System Administrator - Corp' || pro.name=='IS System Administrator Ltd' || ISHR == true)
        {
            SObjectAccessDecision securityDecisionAbsenceRequests= Security.stripInaccessible(AccessType.READABLE, [Select Id, Name, HRMSUS__worker__c, HRMSUS__Worker__r.HRMSUS__Associate_Name__c,HRMSUS__worker__r.Name, 
                                                                                                                    HRMSUS__Start_Time__c, HRMSUS__End_Time__c, HRMSUS__Total_Hours__c, HRMSUS__full_name__c,
                                                                                                                    HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.name, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, 
                                                                                                                    HRMSUS__Loss_of_Pay_LOP__c, HRMSUS__Approved__c, HRMSUS__Notes__c, HRMSUS__Rejection_Comments__c,HRMSUS__Total_Absence_Requested__c
                                                                                                                    FROM HRMSUS__Absence_Requests__c
                                                                                                                    WHERE HRMSUS__Approved__c ='Submitted' AND HRMSUS__Absence_Type__c!=null 
                                                                                                                    ORDER BY HRMSUS__Start_Date__c DESC limit 9999]);
            absentrequest=securityDecisionAbsenceRequests.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecisionAbsenceRequests.getRemovedFields()); 
            //absentrequest = [];
        } 
        else{
            system.debug('coming in 83 else');
            SObjectAccessDecision securityDecisionAbsReq = Security.stripInaccessible(AccessType.READABLE, [Select Id, Name, HRMSUS__worker__c, HRMSUS__Worker__r.HRMSUS__Associate_Name__c,HRMSUS__worker__r.Name,
                                                                                                            HRMSUS__Start_Time__c,HRMSUS__End_Time__c, HRMSUS__Total_Hours__c, HRMSUS__full_name__c,
                                                                                                            HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.name, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, 
                                                                                                            HRMSUS__Loss_of_Pay_LOP__c, HRMSUS__Approved__c, HRMSUS__Notes__c, HRMSUS__Rejection_Comments__c,HRMSUS__Total_Absence_Requested__c  
                                                                                                            FROM HRMSUS__Absence_Requests__c 
                                                                                                            WHERE HRMSUS__Approved__c ='Submitted' AND HRMSUS__Absence_Type__c!=null 
                                                                                                            AND HRMSUS__worker__c IN: PersonId ORDER by HRMSUS__Start_Date__c, HRMSUS__worker__c DESC limit 9999]);
                                                                                                            system.debug('ableave'+securityDecisionAbsReq);
            absentrequest=securityDecisionAbsReq.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecisionAbsReq.getRemovedFields()); 
            //absentrequest = ];
        }
        
        return new map<string, object>{
            'absentrequest' => absentrequest,   
                'ISHR' => ISHR     
                };
                    
                    // return  JSON.Serialize(absentrequest);       
                    }   
  @AuraEnabled(cacheable=true)
  public static List<HRMSUS__Absence_Requests__c>  getrequest() {    
    List<HRMSUS__Absence_Requests__c> absentrequest = new List<HRMSUS__Absence_Requests__c>();
    HRMSUS__Person__c person = new HRMSUS__Person__c();
    
    user u2= new user();
    profile pro =new profile();
    
    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT id,lastname,email,managerid,profileid  FROM USER WHERE id=:UserInfo.getUserId()]);
    u2=(user)securityDecision.getRecords()[0];
    System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
    
    // user u2 = [];
    //  profile pro = [];  
    SObjectAccessDecision securityDecisionProfile  = Security.stripInaccessible(AccessType.READABLE, [SELECT id,name FROM Profile WHERE id=:u2.profileid]);
    pro=(profile)securityDecisionProfile.getRecords()[0];
    System.debug('Fields removed by stripInaccessible: '+securityDecisionProfile.getRemovedFields());
    try
    {
        SObjectAccessDecision securityDecisionPer = Security.stripInaccessible(AccessType.READABLE,
                                                                               [SELECT Id, Name, HRMSUS__Name__c, HRMSUS__Approver__c FROM HRMSUS__Person__c Where HRMSUS__user__c=:u2.id]);
        person=(HRMSUS__Person__c)securityDecisionPer.getRecords()[0];
        System.debug('Fields removed by stripInaccessible: '+securityDecisionPer.getRemovedFields());
        // person = [];
    }
    Catch(Exception ex){system.debug(ex.getmessage());}
    List<HRMSUS__Person__c> u1 = new List<HRMSUS__Person__c>();
    try
    {
        SObjectAccessDecision securityDecisionPerson = Security.stripInaccessible(AccessType.READABLE,
                                                                                  [SELECT id,name ,HRMSUS__user__c,HRMSUS__Supervisor__c FROM HRMSUS__Person__c WHERE HRMSUS__Supervisor__c =:person.id]);
        u1=securityDecisionPerson.getRecords();
        System.debug('Fields removed by stripInaccessible: '+securityDecisionPerson.getRemovedFields()); 
        // u1 =  [];
    }
    Catch(Exception ex)
    {
        System.debug('No Employee is connected to this User. '  + ex.getMessage()); 
    }
    Set<String> personId = new Set<String>();
    for(HRMSUS__Person__c per:u1)
    {
        PersonId.add(per.id); 
    }
    List<PermissionSetAssignment> permissionsetAcc =new List<PermissionSetAssignment> ();
    SObjectAccessDecision securityDecisionPerSetAssign = Security.stripInaccessible(AccessType.READABLE, [SELECT id,AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()]);
    PermissionsetAcc=securityDecisionPerSetAssign.getRecords();
    System.debug('Fields removed by stripInaccessible: '+securityDecisionPerSetAssign.getRemovedFields()); 
    // List<PermissionSetAssignment> PermissionsetAcc = [];
    
    Boolean iSHR;
    for(PermissionSetAssignment per : PermissionsetAcc){ 
        if(per.PermissionSet.Name=='BZ_Operations' || per.PermissionSet.Name=='BZ_Operations_Salesforce' 
           || per.PermissionSet.Name=='BZ_Operations_Salesforce_Platform' || per.PermissionSet.Name=='BZ_Admin' 
           || per.PermissionSet.Name=='BZ_Admin_Salesforce' || per.PermissionSet.Name=='BZ_Admin_Salesforce_Platform'){
               ISHR = true;     
           }
    }
    
    for(PermissionSetAssignment per : PermissionsetAcc){ 
        if(per.PermissionSet.Name=='BZ_Operations' || per.PermissionSet.Name=='BZ_Operations_Salesforce' 
           || per.PermissionSet.Name=='BZ_Operations_Salesforce_Platform' || per.PermissionSet.Name=='BZ_Admin' 
           || per.PermissionSet.Name=='BZ_Admin_Salesforce' || per.PermissionSet.Name=='BZ_Admin_Salesforce_Platform'){
               ISHR = true;     
           }
    }
    if(pro.name=='System Administrator' || pro.name=='IS System Administrator - Corp' || pro.name=='IS System Administrator Ltd' || ISHR == true)
    {
        SObjectAccessDecision securityDecisionAbsenceRequests= Security.stripInaccessible(AccessType.READABLE, [Select Id, Name, HRMSUS__worker__c, HRMSUS__Worker__r.HRMSUS__Associate_Name__c,HRMSUS__worker__r.Name, 
                                                                                                                HRMSUS__Start_Time__c, HRMSUS__End_Time__c, HRMSUS__Total_Hours__c, HRMSUS__full_name__c,
                                                                                                                HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.name, HRMSUS__Start_Date__c, HRMSUS__End_Date__c, 
                                                                                                                HRMSUS__Loss_of_Pay_LOP__c, HRMSUS__Approved__c, HRMSUS__Notes__c, HRMSUS__Rejection_Comments__c,HRMSUS__Total_Absence_Requested__c
                                                                                                                FROM HRMSUS__Absence_Requests__c
                                                                                                                WHERE HRMSUS__Approved__c ='Submitted' AND HRMSUS__Absence_Type__c!=null 
                                                                                                                ORDER BY HRMSUS__Start_Date__c DESC limit 9999]);
        absentrequest=securityDecisionAbsenceRequests.getRecords();
        System.debug('Fields removed by stripInaccessible: '+securityDecisionAbsenceRequests.getRemovedFields()); 
        //absentrequest = [];
    }
    else{
        system.debug('coming in else');
      List<HRMSUS__Absence_Requests__c> lstAbr = [SELECT id,name,HRMSUS__Absence_Type__c,HRMSUS__Start_Time__c,HRMSUS__End_Date__c,HRMSUS__Total_Hours__c,HRMSUS__Start_Date__c,
                                                  HRMSUS__Year__c,HRMSUS__Leave_Hours__c,HRMSUS__Total_Absence_Requested__c, HRMSUS__Notes__c,HRMSUS__Approved__c,HRMSUS__Approver__c,
                                                  HRMSUS__Worker__r.HRMSUS__Associate_Name__c,HRMSUS__Absence_Type__r.Name,HRMSUS__Hours1__c FROM HRMSUS__Absence_Requests__c   WHERE HRMSUS__worker__c IN: PersonId and HRMSUS__Approved__c ='Submitted' AND HRMSUS__Absence_Type__c!=null   limit 9999];  
                                                  System.debug('lstAbrsize : '+lstAbr.size()); 
                                                  System.debug('lstAbrs : '+lstAbr);
            
  }
  return absentrequest;
}
  /*@AuraEnabled(cacheable=true)
  public static list<HRMSUS__Absence_Entitlement__c>  getentitlement(string temp){
    
      //Only Object permission for FieldLevelSecurity is able to remove  issue listing on PMD report instead of above code  
    
      HRMSUS__Absence_Requests__c abreq =new  HRMSUS__Absence_Requests__c();
      SObjectAccessDecision securityDecisionAbsRequests = Security.stripInaccessible(AccessType.READABLE, [Select id,name,HRMSUS__worker__c,HRMSUS__Absence_Type__c
                                                                                                           from HRMSUS__Absence_Requests__c where id=:temp]);
      abreq=(HRMSUS__Absence_Requests__c)securityDecisionAbsRequests.getRecords()[0];
      System.debug('Fields removed by stripInaccessible: '+securityDecisionAbsRequests.getRemovedFields()); 
      
     
      list<HRMSUS__Absence_Entitlement__c> ent =[SELECT id,name,HRMSUS__Absence_Type__c,HRMSUS__Absence_Taken__c,HRMSUS__ToT_Allowed_Hours__c,
                                                                                                HRMSUS__Absence_Entitlement1__c,HRMSUS__Year__c,HRMSUS__Time_off_Taken_Hours__c,
                                                                                                HRMSUS__Absence_Available__c, HRMSUS__Absence_Type__r.Name,HRMSUS__Time_off_Balance_Hours__c
                                                                                                 FROM HRMSUS__Absence_Entitlement__c  WHERE  HRMSUS__worker__c=:abreq.HRMSUS__worker__c  AND  HRMSUS__Active__c =true  WITH SECURITY_ENFORCED];    
      return ent;
  } */                         
   

 


  @AuraEnabled()
    public static void approveWorkerAbsenceRequest(HRMSUS__Absence_Requests__c abreq) {   
        System.debug('abreq-->'+abreq); 
        HRMSUS__Person__c per = [SELECT Id, HRMSUS__user__c FROM HRMSUS__Person__c WHERE Id = :abreq.HRMSUS__worker__c  WITH SECURITY_ENFORCED];
    
        if (per.HRMSUS__user__c != null) {  
            ProcessInstance[] pi;
            Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
                SObjectAccessDecision securityDecisionPInstance  = Security.stripInaccessible(AccessType.READABLE,
                                                                                              [ Select ID, Status, TargetObject.Name, 
                                                                                               (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                                                                               (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                                                                               Where TargetObjectID=:abreq.id AND  Status = 'Pending']);
            pi=securityDecisionPInstance.getRecords();
             for (ProcessInstance instance : pi) {
                for (ProcessInstanceWorkItem workItem : instance.WorkItems) {
                    Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();
                    prWkItem.setWorkItemID(workItem.id);
                    prWkItem.setComments('Approved by User: ' + UserInfo.getName());
                    prWkItem.setAction('Approve');
                    prWkItems.add(prWkItem);
                }
            }
                        
            if (!prWkItems.isEmpty()) {
                Approval.ProcessResult[] appResult = Approval.process(prWkItems);
            }
        } else {            
            throw new AuraHandledException('Worker not found or user not specified for the absence request.');
        }
    }
     @AuraEnabled
    //  Rejection process starts here
    public static object rejectWorkerAbsenceRequest(HRMSUS__Absence_Requests__c abreq,string comments) 
    {
       // List<HRMSUS__Absence_Entitlement__c> TimeRej = new List<HRMSUS__Absence_Entitlement__c>();
        HRMSUS__Person__c per;
        ProcessInstance[] pi;
        if(!Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
            system.debug('User has insufficient access to HRMSUS__Person__c object/s!');
             return null;
        } 
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT id,name,HRMSUS__user__c FROM HRMSUS__Person__c WHERE id=:abreq.HRMSUS__worker__c]);
        per=(HRMSUS__Person__c)securityDecision.getRecords()[0];
        System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
        if(per.HRMSUS__user__c!=null){
           
            Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
                SObjectAccessDecision securityDecisionPInst  = Security.stripInaccessible(AccessType.READABLE,
                                                                                          [Select ID, Status, TargetObject.Name, 
                                                                                           (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                                                                           (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                                                                           Where TargetObjectID=:abreq.id AND  Status = 'Pending']);
            pi=securityDecisionPInst.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecisionPInst.getRemovedFields());
            for(ProcessInstance instance : pi){
                for(ProcessInstanceWorkItem workItem : instance.WorkItems){
                    Approval.ProcessWorkitemRequest prWkItem  = new Approval.ProcessWorkitemRequest();
                    prWkItem.setWorkItemID(workItem.id);
                    prWkItem.setComments(comments);
                    prWkItem.setAction('Reject');
                    prWkItems.add(prWkItem);
                }
            }
            if(!prWkItems.isEmpty()){
                Approval.ProcessResult[] appResult = Approval.process(prWkItems);
            }
        } 
        return null;
    }
       
}