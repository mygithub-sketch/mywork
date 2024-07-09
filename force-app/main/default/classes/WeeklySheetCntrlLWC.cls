public with sharing class WeeklySheetCntrlLWC {
    public WeeklySheetCntrlLWC() {

    }
    @AuraEnabled (cacheable=true) 
    public static Map<String,List<HRMSUS__Person__c>> getWorkers() {
        Map<String,List<HRMSUS__Person__c>> mapPer = new Map<String,List<HRMSUS__Person__c>>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (userProfile == 'System Administrator') { 
            List<HRMSUS__Person__c> lstPer = [SELECT Id, Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c FROM HRMSUS__Person__c  Where  HRMSUS__Status__c =: 'Active'  WITH SECURITY_ENFORCED ORDER BY HRMSUS__First_Name__c ASC];
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c, HRMSUS__User__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
            mapPer.put('lstPer',lstPer);
            mapPer.put('per',per); 
        }else {
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__User__c,HRMSUS__First_Name__c,HRMSUS__Last_Name__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
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
    public static String startDayDate(String weekStartDate,String selectedDates)
    {   
        try {
            Date selectedDate = Date.valueOf(selectedDates);
            Map<String, Integer> mapWeek = new Map<String, Integer>{'Monday'=>0, 'Tuesday'=>1, 'Wednesday'=>2, 'Thursday'=>3, 'Friday'=>4, 'Saturday'=>5, 'Sunday'=>6};
            
            Datetime selectedDatetime = DateTime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
            String selectedDayOfWeek = selectedDatetime.format('EEEE');
    
            Integer diff = mapWeek.get(weekStartDate) - mapWeek.get(selectedDayOfWeek);
            System.debug('Day of the week: ' + selectedDayOfWeek);
    
            Date dayOfDate = (diff <= 0) ? selectedDate.addDays(diff) : selectedDate.addDays(diff - 7);    
            return String.valueOf(dayOfDate);

        } catch (Exception e) {
            System.debug('Error in startDayDate method: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static string fecthWeeklySheetDetails(String workerId,String weeklyDate)
    {
        
        system.debug('workerId'+ workerId);
        system.debug('date'+ weeklyDate);
        WeeklySheetCntrlLWC.Wrapper  wrp = new WeeklySheetCntrlLWC.Wrapper();
        string weekStartDay;
        string profile1 = userinfo.getProfileId();
        
        if(HRMSUS__Weekly_Time_Entry_Options__c.getInstance(profile1) !=null)        
        {  
            wrp.wtsCustSettings =  HRMSUS__Weekly_Time_Entry_Options__c.getInstance(userinfo.getProfileId());
            wrp.userStatus.put('Admin',false);
            list<PermissionSetAssignment> perSetAssigned=new list<PermissionSetAssignment>();
            if(Schema.sObjectType.PermissionSetAssignment.isAccessible()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id =:Userinfo.getUserId() order by PermissionSet.Name]);
                perSetAssigned=securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields()); 
                
            }else{
                system.debug('User has no Access to Object PermissionSetAssignment!');
                return null;
            }
            for(PermissionSetAssignment p :perSetAssigned){
                if (wrp.wtsCustSettings.HRMSUS__Permissions__c == p.PermissionSet.Name ){
                    wrp.userStatus.put('Admin',true);
                }
            } 
        }
       
       //     weekStartDay = WeeklySheetCntrlLWC.startDayDate(person.HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.ValueOf(weeklyDate));      
        String empId;      
        integer index=1;
        List<HRMSUS__Person__c> person = new List<HRMSUS__Person__c>();
        if(workerId == null)
        {   
            if(Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c,HRMSUS__User__c,HRMSUS__Supervisor__r.HRMSUS__User__c, HRMSUS__Company__c,HRMSUS__Company__r.HRMSUS__Week_Start_Day__c FROM HRMSUS__Person__c WHERE HRMSUS__User__c=: Userinfo.getUserId() LIMIT 1]);
                person=securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
            }else{
                system.debug('User has no Access to Object Worker!');
                return null; 
            }
            if(!person.isEmpty() )
            {
                empId= person[0].Id;
                //  system.debug('Check EEmp===='+EEmp);
                wrp.mapSo.put('Emps',person);
                wrp.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.valueOf(Date.today()));    
                
                if(weeklyDate == null){
                    wrp.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.valueOf(Date.today()));    
                }
                if(weeklyDate != null){
                    wrp.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,weeklyDate);
                }
            }                    
        }
        else{
            if(!Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                system.debug(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access for Worker'));
                // Throw an AuraHandledException with custom data and code
                
            }else{
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c,HRMSUS__Person__c.HRMSUS__User__c,HRMSUS__Supervisor__r.HRMSUS__User__c, HRMSUS__Company__c,HRMSUS__Company__r.HRMSUS__Week_Start_Day__c FROM HRMSUS__Person__c WHERE id=:workerId  LIMIT 1]);
                person=securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
            }
            if(!person.isEmpty() )
            {
                empId= person[0].Id;
                wrp.mapSo.put('Emps',person);
                if(weeklyDate == null){
                    System.debug('in date null');
                    wrp.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.valueOf(Date.today()));    
                    system.debug('WeekStartDay======'+wrp.weekStartDay);
                }
                if(weeklyDate != null){
                    wrp.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,weeklyDate);
                }
            } 
        } 
        wrp.companyStartDay = person[0].HRMSUS__Company__r.HRMSUS__Week_Start_Day__c;
        
        //To search for all of the permission sets assigned to a particular user
        //list<PermissionSetAssignment> lPerSetAssign = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId()];
        // checking the user designation and to hide/dispaly the approve /Reject buttons accordingly to users
        if(person[0].HRMSUS__Supervisor__r.HRMSUS__User__c == Userinfo.getUserId()){
            wrp.userStatus.put('Manager',true);// means Admin Or Manager
        } 
        else { wrp.userStatus.put('Manager',false); }
        
        if(person[0].HRMSUS__User__c==Userinfo.getUserId()){
            wrp.userStatus.put('Worker',true);//means one of the team member 
        }
        else { wrp.userStatus.put('Worker',false); }
        
        if(person[0].HRMSUS__User__c==Userinfo.getUserId() || person[0].HRMSUS__Supervisor__r.HRMSUS__User__c == Userinfo.getUserId()){
            wrp.userStatus.put('Others',false);
        }
        else { wrp.userStatus.put('Others',true); }
        
        wrp.Dates = string.valueOf(Date.ValueOf(wrp.weekStartDay)); 
        list<HRMSUS__Employee_Timesheet__c> emplyeeTimeSheet=new list<HRMSUS__Employee_Timesheet__c>();
        if(Schema.sObjectType.HRMSUS__Employee_Timesheet__c.isAccessible()){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                [Select Id,Name,HRMSUS__Status__c,HRMSUS__Customer__c,HRMSUS__Person__c,
                                                                                 HRMSUS__Project__c,HRMSUS__Project__r.Name,HRMSUS__Mon_Total__c,HRMSUS__Tue_Total__c,HRMSUS__Wed_Total__c,
                                                                                 HRMSUS__Thu_Total__c,HRMSUS__Fri_Total__c,HRMSUS__Sat_Total__c,
                                                                                 HRMSUS__Sun_Total__c,HRMSUS__Task__c,HRMSUS__Timesheet_Date__c FROM 
                                                                                 HRMSUS__Employee_Timesheet__c WHERE 
                                                                                 HRMSUS__Timesheet_Date__c = :Date.ValueOf(wrp.weekStartDay) AND 
                                                                                 HRMSUS__Person__c != null AND HRMSUS__Person__c = :empId LIMIT 1]);
            emplyeeTimeSheet=securityDecision.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
        }else{
            system.debug('User has no Access to Object Employee Timesheet!'); 
        }
        wrp.mapso.put('EmplyeeTimeSheet',emplyeeTimeSheet);
        if(emplyeeTimeSheet.size()>0){
            wrp.wekTimesStatus.put('No_records_found',false);
            if(emplyeeTimeSheet[0].HRMSUS__Status__c == 'Approved'){//Approved  Rejected   Submitted   Not Submitted
                wrp.wekTimesStatus.put('Approved',true);
            } 
            else{
                wrp.wekTimesStatus.put('Approved',false);
            }
            
            if(emplyeeTimeSheet[0].HRMSUS__Status__c =='Rejected'){
                wrp.wekTimesStatus.put('Rejected',true);
            }
            else{ 
                wrp.wekTimesStatus.put('Rejected',false);
                }
            if(emplyeeTimeSheet[0].HRMSUS__Status__c =='Submitted'){
                system.debug('emp Id : '+emplyeeTimeSheet[0].Id);
                wrp.wekTimesStatus.put('Submitted',true);
            }
            else{
                wrp.wekTimesStatus.put('Submitted',false);
            }
            
            if(emplyeeTimeSheet[0].HRMSUS__Status__c =='Not Submitted'){
                wrp.wekTimesStatus.put('Not_Submitted',true);
            }
            else {
                wrp.wekTimesStatus.put('Not_Submitted',false);
            }
        }
        else{
            wrp.wekTimesStatus.put('No_records_found',true);
        }
        Profile prof=new Profile();
        if(Schema.sObjectType.profile.isAccessible()){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                [select id,name from profile where id=:Userinfo.getProfileId() limit 1]);
            prof=(profile)securityDecision.getRecords()[0];
            System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
        }else{
            system.debug('User has no Access to Object profile!');
            return null;   
        }
          //if user is Admin pulling all workers to picklist
            if(!Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                // Throw an AuraHandledException with custom data and code
                system.debug('User has no Access to Object Worker!');
                return null;
            }
        //cheking if user's profile is Admin
        if(prof.Name == 'System Administrator'){
            System.debug('in if');
            //if user is Admin pulling all workers to picklist
            
            list<HRMSUS__Person__c> perslist = new list<HRMSUS__Person__c>();
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c 
                                                                                 FROM HRMSUS__Person__c Where  HRMSUS__Status__c =: 'Active' ORDER BY HRMSUS__First_Name__c ASC ]);
            perslist =securityDecision.getRecords();
            System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());                                
            wrp.MapSo.put('HRMSUS__Person__c',perslist );
        }else{
            System.debug('else');
            //if not pulling workers under the manager
            list<HRMSUS__Person__c> persons=new list<HRMSUS__Person__c>();
            if(Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c,
                                                                                     HRMSUS__Supervisor__r.HRMSUS__User__c,HRMSUS__User__c
                                                                                     FROM HRMSUS__Person__c Where  HRMSUS__Status__c =: 'Active' ORDER BY HRMSUS__First_Name__c ASC]);
                persons=securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
                
            }else{
                system.debug('User has no Access to Object Worker');
                return null;  
            }
            
            list<HRMSUS__Person__c> teamMembers = new list<HRMSUS__Person__c>();    
            for(HRMSUS__Person__c pe: persons ) {
                if(Userinfo.getUserId() == pe.HRMSUS__Supervisor__r.HRMSUS__User__c ||  pe.HRMSUS__User__c == Userinfo.getUserId()){
                    teamMembers.add(pe);
                }
            }
            //set picklist workers to map
            wrp.MapSo.put('HRMSUS__Person__c',teamMembers);
        } 
        if(!Schema.sObjectType.HRMSUS__Timesheet_Entry__c.isAccessible()){
            // Throw an AuraHandledException with custom data and code
            system.debug('User has no Access to Object Timesheet Entry!');
            return null;
        }
        list<HRMSUS__Timesheet_Entry__c> timeshtentry = new list<HRMSUS__Timesheet_Entry__c>();
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT id,Name,HRMSUS__Mon__c,HRMSUS__Tue__c,HRMSUS__Wed__c,HRMSUS__Thu__c,HRMSUS__Total_Time__c,HRMSUS__Project_Task__r.Name,
                                                                                                  HRMSUS__Fri__c,HRMSUS__Sat__c,HRMSUS__Sun__c,HRMSUS__Person__c,HRMSUS__Customer__c,HRMSUS__Customer__r.Name,HRMSUS__Project_Name__c,
                                                                                                  HRMSUS__Project_Name__r.Name,HRMSUS__Task__c,HRMSUS__Total__c,HRMSUS__Billable__c,HRMSUS__Week_Start_Date__c,HRMSUS__Comments__c ,HRMSUS__Fri_Comment__c,
                                                                                                  HRMSUS__Mon_Comment__c,HRMSUS__Project_Task__c,HRMSUS__Sat_Comment__c,HRMSUS__Sun_Comment__c,HRMSUS__Thu_Comment__c,HRMSUS__Tue_Comment__c,HRMSUS__Wed_Comment__c
                                                                                                  FROM HRMSUS__Timesheet_Entry__c WHERE HRMSUS__Person__c=:empId AND 
                                                                                                  HRMSUS__Week_Start_Date__c  =:Date.ValueOf(wrp.Dates) Order by HRMSUS__Mon__c]);
        timeshtentry = securityDecision.getRecords();
        System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
        wrp.MapSo.Put('Timesheets',timeshtentry );//Date.ValueOf(wr.Dates)
        wrp.Index = Index;
        //Added By Aravind Kumar date:19/07/2023 jira No-BHRB-1643
       Date nextweekDate = Date.ValueOf(wrp.weekStartDay).addDays(7);
        List<HRMSUS__Employee_Timesheet__c> nextweek = [Select Id,Name,HRMSUS__Status__c,HRMSUS__Customer__c,HRMSUS__Person__c,HRMSUS__Project__c,HRMSUS__Project__r.Name,HRMSUS__Mon_Total__c,
                                                        HRMSUS__Tue_Total__c,HRMSUS__Wed_Total__c, HRMSUS__Thu_Total__c,HRMSUS__Fri_Total__c,HRMSUS__Sat_Total__c,HRMSUS__Sun_Total__c,HRMSUS__Task__c,
                                                        HRMSUS__Timesheet_Date__c FROM HRMSUS__Employee_Timesheet__c WHERE HRMSUS__Timesheet_Date__c =:nextweekDate AND 
                                                        HRMSUS__Person__c != null AND HRMSUS__Person__c = :empId LIMIT 1];
        
        system.debug('nextweek' +nextweek);
        if(!nextweek.isEmpty()){
            if(nextweek[0].HRMSUS__Status__c =='Approved' ||nextweek[0].HRMSUS__Status__c =='Submitted'){
                 wrp.NextWeekStatus = true;
            }
        }
        //ended here
        return JSON.serialize(wrp);
        } 
    @AuraEnabled
    public static  string updateWeeklySheet(string  weeklySheet)
    {
        HRMSUS__Person__c person = new HRMSUS__Person__c();
        WeeklySheetCntrlLWC.wrapper wr = new WeeklySheetCntrlLWC.wrapper(); 
        List<HRMSUS__Timesheet_Entry__c > weeklyTimeSheet = new List<HRMSUS__Timesheet_Entry__c>(); 
        List<HRMSUS__Timesheet_Entry__c> lstWeeklysheet = new  List<HRMSUS__Timesheet_Entry__c>(); 
        list<id> projIds= new list<id>(); 
          System.debug('Weeklysheet: '+Weeklysheet);
        lstWeeklysheet = (List<HRMSUS__Timesheet_Entry__c>)JSON.deserialize(weeklySheet, List<HRMSUS__Timesheet_Entry__c>.class); 
        if(lstWeeklysheet.size() <= 0){
            if(Schema.sObjectType.HRMSUS__Person__c.isAccessible()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                    [SELECT id,Name,HRMSUS__First_Name__c,HRMSUS__Last_Name__c,HRMSUS__User__c,
                                                                                     HRMSUS__Supervisor__r.HRMSUS__User__c, HRMSUS__Company__c,HRMSUS__Company__r.HRMSUS__Week_Start_Day__c
                                                                                     FROM HRMSUS__Person__c WHERE HRMSUS__User__c=: Userinfo.getUserId() LIMIT 1]);
                person=(HRMSUS__Person__c)securityDecision.getRecords()[0];
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
            }else{
                system.debug('Insufficient access for worker');
                return null;
            }
            //to get the week start day by giving worker's company startday and todays date
            wr.weekStartDay = WeeklySheetCntrlLWC.startDayDate(person.HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.valueOf(Date.today()));
        }
        for(HRMSUS__Timesheet_Entry__c ws : lstWeeklysheet)
        {   
            if(wr.weekStartDay == null || wr.weekStartDay == '' ){
                wr.weekStartDay = string.valueOf(ws.HRMSUS__Week_Start_Date__c);
            }
            weeklyTimeSheet.add(ws);
        }
        try{
        
            if(Schema.sObjectType.HRMSUS__Timesheet_Entry__c.isCreateable() && Schema.sObjectType.HRMSUS__Timesheet_Entry__c.isUpdateable()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE,weeklyTimeSheet);
                //upsert securityDecision.getRecords();
                System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
                upsert weeklyTimeSheet;
                System.debug('weeklyTimeSheet: '+weeklyTimeSheet);
            }else{
                system.debug('User has no Access to Object Timesheet Entry!');  
                return null;    
            }
            wr.MapSo.Put('Timesheets', weeklyTimeSheet);
         //   wr.companyStartDay=companyStartDay;
            if(weeklyTimeSheet.size()> 1) {wr.successMsgs='The records have been updated/created succesfully!';}
            else if(weeklyTimeSheet.size()== 1) {wr.successMsgs='The record has been updated/created succesfully!';}
            else { wr.successMsgs='No records';}
        }
        catch(DmlException e) {
            wr.errorMsgs = 'The following exception has occurred: ' + e.getMessage();
        }
        return JSON.serialize(wr);  
      //return '';
    }
    public class Wrapper
    {   

        public Map<string,List<sObject>> mapSo;      
        public map<string, list<string>> info;
        public  map<string,sObject> mapObject;
        public string dates;
        public string weekStartDay;
        public string employee;
        public integer index; 
        public string errorMsgs; 
        public string successMsgs;
        public HRMSUS__Weekly_Time_Entry_Options__c wtsCustSettings; // custom settings 
        public map<string,boolean> userStatus; 
        public map<string,boolean>  wekTimesStatus;
        public string companyStartDay; 
        public Boolean nextWeekStatus; 
        public wrapper(){ 
            mapSo= new Map<string,List<sObject>>();
            mapObject=  new map<string,sObject>();
            info = new map<string, list<string>>();
            Dates = ''; 
            weekStartDay = '';
            Employee = ''; 
            Index =  0; 
            WTSCustSettings=new HRMSUS__Weekly_Time_Entry_Options__c();
            userStatus = new  map<string,boolean>(); 
            companyStartDay='';
            wekTimesStatus= new  map<string,boolean>();
            NextWeekStatus =false;
        }
    }
}