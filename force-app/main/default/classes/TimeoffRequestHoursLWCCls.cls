public with sharing class TimeoffRequestHoursLWCCls {
   /* public TimeoffRequestHoursLWCCls() {

    }*/
    @AuraEnabled(cacheable=true)
    public static Map<String,List<HRMSUS__Person__c>> getWorkers() {
        Map<String,List<HRMSUS__Person__c>> mapPer = new Map<String,List<HRMSUS__Person__c>>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (userProfile == 'System Administrator') { 
            List<HRMSUS__Person__c> lstPer = [SELECT Id, Name,HRMSUS__Associate_Name__c FROM HRMSUS__Person__c   WITH SECURITY_ENFORCED];
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__Associate_Name__c,HRMSUS__User__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
            mapPer.put('lstPer',lstPer);
            mapPer.put('per',per); 
        }else {
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__Associate_Name__c,HRMSUS__User__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
            list<HRMSUS__Person__c> persons=new list<HRMSUS__Person__c>();
            if(Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c,
                                                                                     HRMSUS__Supervisor__r.HRMSUS__User__c,HRMSUS__User__c,HRMSUS__Associate_Name__c
                                                                                     FROM HRMSUS__Person__c Where  HRMSUS__Status__c =: 'Active' ORDER BY HRMSUS__First_Name__c ASC]);
                persons=securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
                
            }else{
                system.debug('User has no Access to Object Worker');
                return null;  
            }
            
            list<HRMSUS__Person__c> teamMembers = new list<HRMSUS__Person__c>();    
            for(HRMSUS__Person__c pe: per ) {
                if(pe.HRMSUS__User__c == Userinfo.getUserId()){
                    teamMembers.add(pe);
                }
            }
            for(HRMSUS__Person__c pe: persons ) {
                if(Userinfo.getUserId() == pe.HRMSUS__Supervisor__r.HRMSUS__User__c){
                    teamMembers.add(pe);
                }
            }
            mapPer.put('per',teamMembers);  
        }
        return mapPer; 
        
    }
    @AuraEnabled(cacheable=true)
    public static List<HRMSUS__Absence_Type__c> getTimeoffType() {
        
        List<HRMSUS__Absence_Type__c> lstAbt = [SELECT Id, Name FROM HRMSUS__Absence_Type__c WITH SECURITY_ENFORCED];
        
        return lstAbt; 
    }
    @AuraEnabled(cacheable=true)
    public static String getWorkerName(string workerId) {
        String workerName ='';
        HRMSUS__Person__c per = [SELECT Id, Name,HRMSUS__Associate_Name__c FROM HRMSUS__Person__c where id=:workerId  WITH SECURITY_ENFORCED];
        workerName =per.Name;
        return workerName;
    }
    @AuraEnabled(cacheable=true)
    public static List<HRMSUS__Absence_Entitlement__c> getEntitlements(string workerId) {
        System.debug('workerId'+workerId);   
        List<HRMSUS__Absence_Entitlement__c> lstAbe = [select id,name,HRMSUS__Worker__r.Name,HRMSUS__Active__c,HRMSUS__Absence_Type__r.Name,HRMSUS__Absences_Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Year__c,
                                                        HRMSUS__Time_Off_Balance__c,HRMSUS__ToT_Allowed_Hours__c,HRMSUS__Time_off_Balance_Hours__c,HRMSUS__Time_off_Taken_Hours__c from HRMSUS__Absence_Entitlement__c
                                                        where  HRMSUS__Worker__c=:workerId AND HRMSUS__Active__c=true WITH SECURITY_ENFORCED];
        
        return lstAbe; 
    }
    @AuraEnabled(cacheable=true)
    public static List<HRMSUS__Absence_Requests__c> getLeaveHistory(string workerId) {
        System.debug('workerId'+workerId);   
        Date currentDate = Date.today();
        Integer currentYear = currentDate.year();
        List<HRMSUS__Absence_Requests__c> lstAbr = [SELECT id,name,HRMSUS__Absence_Type__c,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,
                                                    HRMSUS__Total_Absence_Requested__c, HRMSUS__Approved__c, HRMSUS__Absence_Type__r.Name
                                                     FROM HRMSUS__Absence_Requests__c WHERE HRMSUS__worker__c=:workerId and 
                                                     (CALENDAR_YEAR(HRMSUS__Start_Date__c) = :currentYear OR HRMSUS__Start_Date__c = LAST_N_DAYS:90 )  WITH SECURITY_ENFORCED ORDER BY HRMSUS__Start_Date__c  desc];
        
        return lstAbr; 
    }
    @AuraEnabled
    public static void createTimeoffRequest( list<HRMSUS__Absence_Requests__c> lstABR,string workerId,string typeId,Date startDate,Date endDate, String notes) {
        System.debug('lstABR'+lstABR); 
        String numberDaysReqSequence='';
        Decimal totalHours=0 ;
        list<Date> inComingDates = new list<Date> ();
        date [] arrayOfdates = new List<date>();
        Map<date,decimal> dailyHoursMap = new map<date,decimal>(); 
        if(!lstABR.isEmpty())
        {
            system.debug(' @@@TOR hours @@@ '+lstABR);
            integer lstsize = lstABR.size();
            for(integer i=0;i<lstsize;i++){
                if(string.isblank(numberDaysReqSequence)){
                    numberDaysReqSequence = lstABR[i].HRMSUS__Hours1__c;
                }
                else{
                    numberDaysReqSequence+= ','+lstABR[i].HRMSUS__Hours1__c;
                }
                TotalHours+= decimal.valueof(lstABR[i].HRMSUS__Hours1__c);
                inComingDates.add(lstABR[i].HRMSUS__Start_Date__c);
                dailyHoursMap.put(lstABR[i].HRMSUS__Start_Date__c,decimal.valueof(lstABR[i].HRMSUS__Hours1__c));
            }
            for(HRMSUS__Absence_Requests__c absr: lstABR)
            {                   
                arrayOfdates.add(absr.HRMSUS__Start_Date__c); 
                
            }
        }
        else
        {
            throw new AuraHandledException('No Leave Cards available to save');                
        }
       
       
        /* HRMSUS__Absence_Entitlement__c aE = [select id,name,HRMSUS__Worker__c,HRMSUS__Active__c,HRMSUS__End_Date__c,HRMSUS__Absence_Type__c,HRMSUS__Absences_Start_Date__c,HRMSUS__Time_Off_Balance__c,HRMSUS__ToT_Allowed_Hours__c,
                                             HRMSUS__Time_off_Balance_Hours__c,HRMSUS__Time_off_Taken_Hours__c from HRMSUS__Absence_Entitlement__c where HRMSUS__Absence_Type__c=:typeId AND HRMSUS__Worker__c=:workerId AND HRMSUS__Active__c=true WITH SECURITY_ENFORCED];*/
    HRMSUS__Absence_Type__c abtype=[select id,HRMSUS__Available_Hours__c,HRMSUS__Warn_Negative_balances__c,(select id,name,HRMSUS__Worker__c,HRMSUS__Active__c,HRMSUS__End_Date__c,HRMSUS__Absence_Type__c,HRMSUS__Absences_Start_Date__c,HRMSUS__Time_Off_Balance__c,HRMSUS__ToT_Allowed_Hours__c,HRMSUS__Time_off_Balance_Hours__c,HRMSUS__Time_off_Taken_Hours__c
    from HRMSUS__Absence_Entitlemet__r where HRMSUS__Absence_Type__c=:typeId AND HRMSUS__Worker__c=:workerId  AND HRMSUS__Active__c=true AND CALENDAR_YEAR(HRMSUS__End_Date__c)=:endDate.year()  ), name from HRMSUS__Absence_Type__c where id=: typeId WITH SECURITY_ENFORCED];
    if(abtype.HRMSUS__Absence_Entitlemet__r.isEmpty()){
        throw new AuraHandledException('No active entitlements available for the selected year!');
        
    }
    if(!abtype.HRMSUS__Absence_Entitlemet__r.isEmpty() && abtype.HRMSUS__Absence_Entitlemet__r[0].HRMSUS__Time_off_Balance_Hours__c == 0){
        system.debug('@@@ balance hours @@@'+abtype.HRMSUS__Absence_Entitlemet__r[0].HRMSUS__Time_off_Balance_Hours__c);
        throw new AuraHandledException('The time off balance is zero !');
       
    }
    if(abtype.HRMSUS__Warn_Negative_balances__c=='Yes' && abtype.HRMSUS__Absence_Entitlemet__r[0].HRMSUS__Time_off_Balance_Hours__c < TotalHours){
        throw new AuraHandledException('You do not have enough time off balance!');
    }

    list<HRMSUS__Time_Off_Dates__c> existingReqDates= [select id,name,HRMSUS__Date__c,HRMSUS__Time_Off_Hours__c,HRMSUS__Time_Off_Request__c,HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c,HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c,HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c from HRMSUS__Time_Off_Dates__c where HRMSUS__Date__c IN :inComingDates and HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c=:workerId and( HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c='Submitted' or HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c='Approved') WITH SECURITY_ENFORCED]; 
     
        Map<date,decimal> existDTHoursMap = new map<date,decimal>();
        system.debug('existingReqDates'+existingReqDates.size()+'@@'+inComingDates);
        for(HRMSUS__Time_Off_Dates__c existDate :existingReqDates){
            if(!existDTHoursMap.containskey(existDate.HRMSUS__Date__c)){
                existDTHoursMap.put(existDate.HRMSUS__Date__c,existDate.HRMSUS__Time_Off_Hours__c);
            }else{
                existDTHoursMap.put(existDate.HRMSUS__Date__c,existDTHoursMap.get(existDate.HRMSUS__Date__c)+existDate.HRMSUS__Time_Off_Hours__c);
            }
        }     
        for(HRMSUS__Time_Off_Dates__c existDate :existingReqDates){
            
            if(existDate.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c == typeId && dailyHoursMap.containskey(existDate.HRMSUS__Date__c)){
                // time off request already exists with same time off type
                throw new AuraHandledException('Error : Already Time off request exists for the selected time Off Type..!!');
                    
             } 
            if(dailyHoursMap.containskey(existDate.HRMSUS__Date__c) && (dailyHoursMap.get(existDate.HRMSUS__Date__c)+existDTHoursMap.get(existDate.HRMSUS__Date__c) > 8)){
                // sum off total hours cannot be morethan 8 hours
                throw new AuraHandledException('Error : Cannot Apply the Time Off Request more than 8 Hours per a day..!');
             } 
        } 
        if(workerId == null || typeId == '-None-' || startDate == null  || endDate == null)
        {
            throw new AuraHandledException('Please select all the fields');
        }
        else if(startDate > endDate){
            throw new AuraHandledException('End Date should be greater than Start Date');        
        }



    HRMSUS__Person__c person = new HRMSUS__Person__c();
    list<HRMSUS__Time_Off_Dates__c> timeOffRequestLst = new list<HRMSUS__Time_Off_Dates__c>();
   
    person = [SELECT id,Name,HRMSUS__User__c,HRMSUS__User__r.isactive,HRMSUS__Supervisor__c,HRMSUS__Supervisor__r.HRMSUS__User__c  FROM HRMSUS__Person__c WHERE id=:workerId WITH SECURITY_ENFORCED];  
   
    if(person.HRMSUS__Supervisor__r.HRMSUS__User__c !=null)
    {

        HRMSUS__Absence_Requests__c absentRequest = new  HRMSUS__Absence_Requests__c();
        absentRequest.HRMSUS__Total_Absence_Requested__c=totalHours;
        absentRequest.HRMSUS__Worker__c = workerId;
        absentRequest.HRMSUS__Absence_Type__c =typeId;
        absentRequest.HRMSUS__Start_Date__c =startDate;
        absentRequest.HRMSUS__End_Date__c =endDate;
        absentRequest.HRMSUS__Sequence__c=numberDaysReqSequence;
        absentRequest.HRMSUS__Personal_Time_Off__c=abtype.HRMSUS__Absence_Entitlemet__r[0].id;
        absentRequest.Name=abtype.Name;
        absentRequest.HRMSUS__Notes__c=notes;
        absentRequest.OwnerId=person.HRMSUS__User__r.isactive ?person.HRMSUS__User__c:person.HRMSUS__Supervisor__r.HRMSUS__User__c;
        absentRequest.HRMSUS__Approved__c = 'Submitted';
        if (!Schema.sObjectType.HRMSUS__Absence_Requests__c.isCreateable()) {
            throw new AuraHandledException('User has insufficient access to HRMSUS__Absence_Requests__c object/s!');
            // return null;
        }
        ProcessDefinition p=[SELECT DeveloperName,LockType,Name,State,TableEnumOrId,Type,Id FROM ProcessDefinition where Name='Time off Request' WITH SECURITY_ENFORCED];
     if(p.state=='Active')
     {
        insert absentRequest;

              for(Integer i=0;i<arrayOfdates.size();i++)
                    {
                        HRMSUS__Time_Off_Dates__c createtofdate = new HRMSUS__Time_Off_Dates__c();
                        createtofdate.HRMSUS__Time_Off_Request__c = absentRequest.id;
                        createtofdate.HRMSUS__Time_Off_Entitlement__c = abtype.HRMSUS__Absence_Entitlemet__r[0].id;
                        
                        createtofdate.HRMSUS__Date__c = arrayOfdates[i];
                        createtofdate.HRMSUS__Time_Off_Hours__c = dailyHoursMap.get(createtofdate.HRMSUS__Date__c);
                        timeOffRequestLst.add(createtofdate);
                    }
        if(!timeOffRequestLst.isEmpty()){
          
            insert timeOffRequestLst;

            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(absentRequest.Id);
            req1.setSubmitterId(person.HRMSUS__User__c);
            req1.setNextApproverIds(new Id[] {person.HRMSUS__Supervisor__r.HRMSUS__User__c});
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            System.assert(result.isSuccess());                   
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus()); 
        }
        else{
            system.debug('Approval is not connected');
            throw new AuraHandledException('Approval is not connected');
        }
        
    }

    }
    else {
        throw new AuraHandledException('No User is connected to the TO Approver');               
    }
}
@AuraEnabled(cacheable=true)
public static List<HRMSUS__Absence_Requests__c> showTimeoffRequest(string workerId,string typeId,Date startDate,Date endDate) {
    List<HRMSUS__Absence_Requests__c> abeList = new List<HRMSUS__Absence_Requests__c>();
    if(workerId == null || typeId == '-None-' || startDate == null  || endDate == null)
    {
        throw new AuraHandledException('Please select all the fields');
    }
    else if(startDate > endDate){
        throw new AuraHandledException('End Date should be greater than Start Date');        
    }
    HRMSUS__Absence_Type__c abtype=[select id,HRMSUS__Available_Hours__c,HRMSUS__Warn_Negative_balances__c,(select id,name,HRMSUS__Worker__c,HRMSUS__Active__c,HRMSUS__End_Date__c,HRMSUS__Absence_Type__c,HRMSUS__Absences_Start_Date__c,HRMSUS__Time_Off_Balance__c,HRMSUS__ToT_Allowed_Hours__c,HRMSUS__Time_off_Balance_Hours__c,HRMSUS__Time_off_Taken_Hours__c
    from HRMSUS__Absence_Entitlemet__r where HRMSUS__Absence_Type__c=:typeId AND HRMSUS__Worker__c=:workerId  AND HRMSUS__Active__c=true AND CALENDAR_YEAR(HRMSUS__End_Date__c)=:endDate.year()  ), name from HRMSUS__Absence_Type__c where id=: typeId WITH SECURITY_ENFORCED];
    System.debug('abtype'+abtype);
    if(abtype.HRMSUS__Absence_Entitlemet__r.isEmpty()){
        throw new AuraHandledException('No active entitlements available for the selected year!');
        
    }
   HRMSUS__Person__c person = [SELECT id,Name,HRMSUS__User__c,HRMSUS__Company__c,HRMSUS__Location__c,HRMSUS__User__r.isactive,HRMSUS__Supervisor__c,HRMSUS__Supervisor__r.HRMSUS__User__c  FROM HRMSUS__Person__c WHERE id=:workerId WITH SECURITY_ENFORCED];  
   string  absencTypeExclude =[select id,name ,HRMSUS__Exclude__c from HRMSUS__Absence_Type__c where id=:typeId limit 1].HRMSUS__Exclude__c;
   Map<Date,String> holidayCheck = new Map<Date,String>(); 
            set<Id> cid= new set<Id>();
            cid.add(person.HRMSUS__Company__c);
            for(HRMSUS__Holidays__c holy : [SELECT id,name,HRMSUS__Holiday_Date__c,HRMSUS__Company__c,HRMSUS__Location__c FROM HRMSUS__Holidays__c WHERE  HRMSUS__Company__c=:cid WITH SECURITY_ENFORCED])
            {
                if(holy.HRMSUS__Location__c==null){
                    holidayCheck.put(Holy.HRMSUS__Holiday_Date__c,Holy.name);
                }
                if(holy.HRMSUS__Location__c!=null && holy.HRMSUS__Location__c==person.HRMSUS__Location__c){
                    holidayCheck.put(Holy.HRMSUS__Holiday_Date__c,Holy.name);
                }
            }  
   for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
        Datetime dateGMT=datetime.newInstance(currentDate.year(), currentDate.month(),currentDate.day());// here we can use our dates e.g. StDate
                Datetime d1=Datetime.valueOf(dateGMT);
                //To get the day of the week
                String dayOfWeek = d1.format('E');
                System.debug(d1+': d1'+dayOfWeek);
                Boolean result;
                //only allow if the day of Dates not exists in exclude field of the time off type
                if(String.isNotEmpty(absencTypeExclude)){
                    result = absencTypeExclude.contains(dayOfWeek);
                }else{
                    result=false;
                }
                if( !holidayCheck.containsKey(currentDate) && !result)//StDate.toStartofWeek()!=StDate && StDate.toStartofWeek()+6!=StDate &&
                {
                    HRMSUS__Absence_Requests__c tor = new HRMSUS__Absence_Requests__c(HRMSUS__Worker__c = workerId,
                                                                                         HRMSUS__Absence_Type__c =typeId,
                                                                                         HRMSUS__Start_Date__c = currentDate,
                                                                                         HRMSUS__End_Date__c = currentDate,  
                                                                                         HRMSUS__Total_Hours__c = 8,
                                                                                         HRMSUS__Hours1__c = '8',
                                                                                         HRMSUS__Sequence__c=dayOfWeek);
                     abeList.add(tor);                
                     
                }
    }
    System.debug('abeList '+abeList); 
    return abeList;
}
}