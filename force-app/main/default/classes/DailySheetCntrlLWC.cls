public with sharing class DailySheetCntrlLWC {
   /* public DailySheetCntrlLWC() {

    }*/
    @AuraEnabled(cacheable=true)
    public static Map<String,List<HRMSUS__Person__c>> getWorkers() {
        Map<String,List<HRMSUS__Person__c>> mapPer = new Map<String,List<HRMSUS__Person__c>>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (userProfile == 'System Administrator') { 
            List<HRMSUS__Person__c> lstPer = [SELECT Id, Name FROM HRMSUS__Person__c   WITH SECURITY_ENFORCED];
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__User__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
            mapPer.put('lstPer',lstPer);
            mapPer.put('per',per); 
        }else {
            List<HRMSUS__Person__c> per = [SELECT Id, Name,HRMSUS__User__c FROM HRMSUS__Person__c Where HRMSUS__User__c =:UserInfo.getUserId()   WITH SECURITY_ENFORCED limit 1];
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
    @AuraEnabled (cacheable=true) 
    public static HRMSUS__Dailysheet_config__c getDailysheetCSInfo()
    {
        Profile p;
        HRMSUS__Dailysheet_config__c ds;
        try{
            ds= HRMSUS__Dailysheet_config__c.getOrgDefaults();
            system.debug(ds.name+'daisheet ===config'+ds);
            if(ds!=null)
            {
                system.debug(ds);
                return ds;
            }
            else
            {
                String userId = userinfo.getUserId();
                // retrieve Custom Setting status, for running user
                ds = HRMSUS__Dailysheet_config__c.getInstance(userId);     
                if(ds==null)
                {
                    if(Schema.sObjectType.Profile.isAccessible())
                    {
                        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                                            [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]);
                        p =(Profile)securityDecision.getRecords()[0];
                        System.debug('Fields removed by stripInaccessible: '+securityDecision.getRemovedFields());
                        //  p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                    }
                    else
                    {
                        system.debug('Insufficient access to Profile');
                    }
                    ds = HRMSUS__Dailysheet_config__c.getInstance(p.Id);
                    return ds;
                }
                system.debug(ds); 
                return ds;           
            }            
        }
        catch(exception e)
        {
            system.debug('exception found'+e.getmessage());
            return null;
        }
    }  

    @AuraEnabled
    public static string fetchDailySheetDetails(string emp , string dates) {
        System.Debug('----Emp----'+emp+' Dates:'+dates); 
        Map<String,List<Sobject>>  mapDailysheets = new Map<String,List<Sobject>>();
        Map<string,object> allData = new Map<string,object>();    
        List<HRMSUS__Daily_Sheet__c> dailySheet= [SELECT id,Name,HRMSUS__Date__c,HRMSUS__Start_time__c,HRMSUS__Start_Time_Hrs__c,HRMSUS__Start_Time_Mns__c,HRMSUS__End_Time_Hrs__c,HRMSUS__End_Time_Mns__c,HRMSUS__End_Time__c,
                                                    HRMSUS__St_Min__c,HRMSUS__St_Meridian__c,HRMSUS__En_min__c,HRMSUS__En_Meridian__c,HRMSUS__Type__c,HRMSUS__Start_Times__c,HRMSUS__End_Times__c,HRMSUS__Billable__c,
                                                    HRMSUS__Total__c, HRMSUS__Employee__c,HRMSUS__Comments__c,HRMSUS__Project__c,HRMSUS__Project__r.Name,HRMSUS__Customer__c,HRMSUS__Customer__r.Name,HRMSUS__Task__c
                                                     FROM HRMSUS__Daily_Sheet__c 
                                                     WHERE HRMSUS__Employee__c=:emp AND HRMSUS__Date__c=:Date.ValueOf(dates) WITH SECURITY_ENFORCED
                                                    ORDER BY HRMSUS__Start_Times__c asc];
       /* List<HRMSUS__Daily_Sheet__c> dailySheet = new List<HRMSUS__Daily_Sheet__c>(); 
        list<HRMSUS__Daily_Sheet__c> dsheetlst=new list<HRMSUS__Daily_Sheet__c>();
        SObjectAccessDecision securityDecisionDSheet = Security.stripInaccessible(AccessType.READABLE,
                                                                                  [SELECT id,Name,HRMSUS__Date__c,HRMSUS__Start_time__c,HRMSUS__Start_Time_Hrs__c,HRMSUS__Start_Time_Mns__c,HRMSUS__End_Time_Hrs__c,HRMSUS__End_Time_Mns__c,HRMSUS__End_Time__c,
                                                                                   HRMSUS__St_Min__c,HRMSUS__St_Meridian__c,HRMSUS__En_min__c,HRMSUS__En_Meridian__c,HRMSUS__Type__c,HRMSUS__Start_Times__c,HRMSUS__End_Times__c,HRMSUS__Billable__c,
                                                                                   HRMSUS__Total__c, HRMSUS__Employee__c,HRMSUS__Comments__c,HRMSUS__Project__c,HRMSUS__Project__r.Name,HRMSUS__Customer__c,HRMSUS__Customer__r.Name,HRMSUS__Task__c
                                                                                   FROM HRMSUS__Daily_Sheet__c 
                                                                                   WHERE HRMSUS__Employee__c=:emp AND HRMSUS__Date__c=:Date.ValueOf(dates) 
                                                                                   ORDER BY HRMSUS__Start_Times__c asc]);
        dsheetlst=securityDecisionDSheet.getRecords();
        System.debug('Fields removed by stripInaccessible: '+securityDecisionDSheet.getRemovedFields());
        dailySheet.AddAll(dsheetlst);*/
        system.debug('dailySheet::'+dailySheet);  
        system.debug('dailySheet::'+dailySheet.size());                              
        mapDailysheets.put('HRMSUS__Daily_Sheet__c',dailySheet);
        system.debug('mapDailys::'+mapDailysheets.size());
    
     /*   list<HRMSUS__Absence_Requests__c> lstAbs =[select id,Name,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Total_Absence_Requested__c,HRMSUS__Total_Hours__c,HRMSUS__Absence_Type__c,
                                                   HRMSUS__Personal_Time_Off__c,HRMSUS__Worker__c,HRMSUS__Sequence__c,HRMSUS__Approved__c,HRMSUS__Notes__c,HRMSUS__Rejection_Comments__c, 
                                                   (select id,Name,HRMSUS__Date__c,HRMSUS__Time_Off_Entitlement__c,HRMSUS__Time_Off_Request__c,HRMSUS__Time_Off_Hours__c,HRMSUS__Time_Off_Days__c
                                                    from Time_Off_Dates__r where HRMSUS__Date__c =:Date.ValueOf(dates)) from HRMSUS__Absence_Requests__c 
                                                   where HRMSUS__Worker__c =:emp and HRMSUS__Start_Date__c<=:Date.ValueOf(dates) and HRMSUS__End_Date__c>=:Date.ValueOf(dates) and (HRMSUS__Approved__c ='Submitted' or HRMSUS__Approved__c ='Approved' )  ]; 
       
        set<id> timeoffTypeIds = new set<id>();
        for(HRMSUS__Absence_Requests__c abs:lstAbs){
           timeoffTypeIds.add(abs.HRMSUS__Absence_Type__c);  
        }
        list<HRMSUS__Projects__c> listPro = [select id, Name,HRMSUS__Company__c,HRMSUS__Account__c,HRMSUS__ProjectID__c,HRMSUS__Time_Off_Type__c,HRMSUS__Active__c,HRMSUS__Time_Off__c from HRMSUS__Projects__c where HRMSUS__Time_Off_Type__c IN:timeoffTypeIds];     
        mapDailysheets.put('HRMSUS__Projects__c',listPro);
*/
        allData.put('MapSo', mapDailysheets);
        allData.put('dsConfig', DailySheetCntrlLWC.getDailysheetCSInfo());
       
        return JSON.serialize(allData);     
    }
    @AuraEnabled
    public static list<HRMSUS__Project_Comments__c> getProjTask(String projectId){
        list<HRMSUS__Project_Comments__c> commentsLst = new list<HRMSUS__Project_Comments__c>();
        commentsLst = [select Id,Name,HRMSUS__Comments__c,HRMSUS__Project_Task__r.Name from HRMSUS__Project_Comments__c where (HRMSUS__Project_Task__c=:projectId OR HRMSUS__Project_Task__c=null) WITH SECURITY_ENFORCED order by NAME, HRMSUS__Project_Task__c ASC NULLS LAST];
        return commentsLst;
    }
   /* @AuraEnabled
    public static String startDayDate(String weekStartDate,String selectedDates)
    {
        Date dayOfDate;
        Date selectedDate = Date.valueOf(selectedDates);
        //system.debug('weekStartDate===='+weekStartDate+'===selectedDates===='+selectedDates);
        //system.debug('selectedDate'+selectedDate);
        Map<String,Integer> mapWeek = new Map<String,Integer>{'Monday'=>0,'Tuesday'=>1,'Wednesday'=>2,'Thursday'=>3,'Friday'=>4,'Saturday'=>5,'Sunday'=>6};
            System.debug(mapWeek.get(weekStartDate)-mapWeek.get(DateTime.Parse(selectedDate.format() +' 05:00 AM').format('EEEE')));
        integer diff = mapWeek.get(weekStartDate)-mapWeek.get(DateTime.Parse(selectedDate.format() +' 05:00 AM').format('EEEE'));
       system.debug('dayOfDate==='+mapWeek.get(DateTime.Parse(selectedDate.format() +' 05:00 AM').format('EEEE')));
        dayOfDate = (diff<=0) ? selectedDate.AddDays(diff) : selectedDate.AddDays(diff-7); 
        //  system.debug('dayOfDate==='+dayOfDate);
        return string.valueOf(dayOfDate);
    }*/
    
    @AuraEnabled
    public static List<HRMSUS__Daily_Sheet__c> saveDailySheetDetails(List<HRMSUS__Daily_Sheet__c> data)
    {
        system.debug('records'+ data);
        system.debug('records'+ data.size());
        List<HRMSUS__Daily_Sheet__c > dailySheet = new List<HRMSUS__Daily_Sheet__c>();
        string weekStartDay;
        
      /*  if(!data.isEmpty()){
        HRMSUS__Person__c person = [select id,Name,HRMSUS__Company__c,HRMSUS__Company__r.Name,HRMSUS__Company__r.HRMSUS__Week_Start_Day__c from HRMSUS__Person__c where id=:data[0].HRMSUS__Employee__c];
        system.debug('Date'+string.ValueOf(data[0].HRMSUS__Date__c));
            weekStartDay = DailySheetCntrlLWC.startDayDate(person.HRMSUS__Company__r.HRMSUS__Week_Start_Day__c,string.ValueOf(data[0].HRMSUS__Date__c)); 
        system.debug('weekStart'+weekStartDay);
            
                list<HRMSUS__Employee_Timesheet__c> lstwrkts= new list<HRMSUS__Employee_Timesheet__c>();
                    lstwrkts=[SELECT Id, Name, HRMSUS__Status__c, HRMSUS__Timesheet_Date__c, HRMSUS__Person__c FROM HRMSUS__Employee_Timesheet__c where HRMSUS__Person__c =:data[0].HRMSUS__Employee__c and HRMSUS__Timesheet_Date__c=:Date.ValueOf(weekStartDay) WITH SECURITY_ENFORCED limit 1];
            
        system.debug('wrkts'+lstwrkts);   
            if(!lstwrkts.isEmpty()){
            if(lstwrkts[0].HRMSUS__Status__c == 'Approved'){
                throw new AuraHandledException('The weeklytimesheet status is already approved');   
                
            }  
            }
        }*/
        list<HRMSUS__Daily_Sheet__c> dsheetAfter = new list<HRMSUS__Daily_Sheet__c>();
   /*     for(HRMSUS__Daily_Sheet__c ds:data){
            ds.HRMSUS__Type__c='Travel';
            system.debug('Type***'+ds.HRMSUS__Type__c);
        } */
     
        if(HRMSUS__Dailysheet_config__c.getOrgDefaults().HRMSUS__Total_Hour_Entry__c){
            upsert data;
            return data;
        }else{
        // List<HRMSUS__Daily_Sheet__c> sheets = (List<HRMSUS__Daily_Sheet__c>)System.JSON.deserializeStrict(dsheets,List<HRMSUS__Daily_Sheet__c>.Class);
        system.debug('data====from Js====='+data);      
      //  Boolean istotalnull =   HRMSUS__Dailysheet_config__c.getOrgDefaults().HRMSUS__Total_Hour_Entry__c;
        set<Id> setIds = new set<Id>();
        for(HRMSUS__Daily_Sheet__c ds : data)
        { 
            setIds.add(ds.HRMSUS__Project__c);   
        }
        list<HRMSUS__projects__c> pro=new list<HRMSUS__projects__c>();

          string condition = 'SELECT id,HRMSUS__Holiday__c,HRMSUS__Time_Off__c,HRMSUS__Account__c FROM HRMSUS__projects__c where  ID IN: setIds';
           if(!HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c )
    	{
            condition+= ' AND HRMSUS__Holiday__c=false AND HRMSUS__Time_Off__c=false';
        }
        if(HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c)
    	{
            condition+= ' AND HRMSUS__Active__c=true';
        }
         pro =  Database.query(condition); 
            map<id,HRMSUS__projects__c> mapPrjs;
            if(!pro.isEmpty()){
        mapPrjs = new map<id,HRMSUS__projects__c>(pro);
            }
            
        for(HRMSUS__Daily_Sheet__c ds : data)
        {   
            HRMSUS__projects__c prj;
            DateTime stDt;
            DateTime enDt;  
            if(HRMSUS__Dailysheet_config__c.getOrgDefaults().HRMSUS__Time_Format__c)
            {
                if(ds.HRMSUS__Customer__c!= mapPrjs.get(ds.HRMSUS__Project__c).HRMSUS__Account__c)
                {
                    throw new AuraHandledException('Invalid Customer For the Selected Project');    
                }
                if(ds.HRMSUS__Start_Time_Hrs__c>23||ds.HRMSUS__End_Time_Hrs__c>23||ds.HRMSUS__Start_Time_Mns__c>=60||ds.HRMSUS__End_Time_Mns__c>=60) {
                    throw new AuraHandledException('Invalid time'); 
                }           
                stDt = DateTime.newInstanceGmt(ds.HRMSUS__Date__c.year(), ds.HRMSUS__Date__c.month(), ds.HRMSUS__Date__c.day(),integer.valueof(ds.HRMSUS__Start_Time_Hrs__c), integer.valueof(ds.HRMSUS__Start_Time_Mns__c), 0);
                enDt = DateTime.newInstanceGmt(ds.HRMSUS__Date__c.year(), ds.HRMSUS__Date__c.month(), ds.HRMSUS__Date__c.day(),integer.valueof(ds.HRMSUS__End_Time_Hrs__c), integer.valueof(ds.HRMSUS__End_Time_Mns__c), 0);
                system.debug('StDt   708  '+stDt);
                system.debug('EnDt   709  '+enDt);
                ds.HRMSUS__Start_Times__c = Time.newInstance(integer.valueof(ds.HRMSUS__Start_Time_Hrs__c), integer.valueof(ds.HRMSUS__Start_Time_Mns__c), 00, 00);
                ds.HRMSUS__End_Times__c  = Time.newInstance(integer.valueof(ds.HRMSUS__End_Time_Hrs__c), integer.valueof(ds.HRMSUS__End_Time_Mns__c), 00, 00);
                system.debug('HRMSUS__Start_Times__c-->'+ds.HRMSUS__Start_Times__c);
                system.debug('HRMSUS__End_Times__c-->'+ds.HRMSUS__End_Times__c);
                if( ds.HRMSUS__Start_Time_Hrs__c <12 && (ds.HRMSUS__St_Meridian__c==''||ds.HRMSUS__St_Meridian__c=='AM'))
                {
                    ds.HRMSUS__St_Meridian__c = 'AM';
                }
                else
                {
                    ds.HRMSUS__St_Meridian__c = 'PM';
                }
                if( ds.HRMSUS__End_Time_Hrs__c <12&&(ds.HRMSUS__En_Meridian__c==''||ds.HRMSUS__En_Meridian__c=='AM')){
                    ds.HRMSUS__En_Meridian__c = 'AM';
                }
                else{
                    ds.HRMSUS__En_Meridian__c = 'PM';
                }       
            }
            else
            {
            
                if(ds.HRMSUS__Start_Time_Hrs__c>23||ds.HRMSUS__End_Time_Hrs__c>23||ds.HRMSUS__Start_Time_Mns__c>=60||ds.HRMSUS__End_Time_Mns__c>=60)
                {
                    throw new AuraHandledException('Invalid time'); 
                }
                
                if( ds.HRMSUS__Start_Time_Hrs__c <12 && ds.HRMSUS__St_Meridian__c=='PM'){
                    ds.HRMSUS__Start_Time_Hrs__c = ds.HRMSUS__Start_Time_Hrs__c + 12;
                }
                //Added by Aravind on 12th january
                if( ds.HRMSUS__Start_Time_Hrs__c ==12 && ds.HRMSUS__St_Meridian__c=='AM')
                   {
                    ds.HRMSUS__Start_Time_Hrs__c = ds.HRMSUS__Start_Time_Hrs__c - 12;
                }
                   if( ds.HRMSUS__End_Time_Hrs__c == 12 && ds.HRMSUS__En_Meridian__c=='AM'){
                    ds.HRMSUS__End_Time_Hrs__c = ds.HRMSUS__End_Time_Hrs__c - 12;
                }
                // ends here
                if( ds.HRMSUS__End_Time_Hrs__c <12 && ds.HRMSUS__En_Meridian__c=='PM'){
                    ds.HRMSUS__End_Time_Hrs__c = ds.HRMSUS__End_Time_Hrs__c + 12;
                }
                system.debug('Ds.HRMSUS__Date__c======'+ds.HRMSUS__Date__c);
                system.debug('Ds.HRMSUS__Start_Time_Hrs__c======'+ds.HRMSUS__Start_Time_Hrs__c);
                system.debug('DS.HRMSUS__Start_Time_Mns__c====='+ds.HRMSUS__Start_Time_Mns__c);
                system.debug('Ds.HRMSUS__End_Time_Hrs__c======'+ds.HRMSUS__End_Time_Hrs__c);
                system.debug('DS.HRMSUS__End_Time_Mns__c====='+ds.HRMSUS__End_Time_Mns__c);
                stDt = DateTime.newInstanceGmt(ds.HRMSUS__Date__c.year(), ds.HRMSUS__Date__c.month(), ds.HRMSUS__Date__c.day(),integer.valueof(ds.HRMSUS__Start_Time_Hrs__c), integer.valueof(ds.HRMSUS__Start_Time_Mns__c), 0);
                enDt = DateTime.newInstanceGmt(ds.HRMSUS__Date__c.year(), ds.HRMSUS__Date__c.month(), ds.HRMSUS__Date__c.day(),integer.valueof(ds.HRMSUS__End_Time_Hrs__c), integer.valueof(ds.HRMSUS__End_Time_Mns__c), 0);
                ds.HRMSUS__Start_Times__c = Time.newInstance(integer.valueof(ds.HRMSUS__Start_Time_Hrs__c), integer.valueof(ds.HRMSUS__Start_Time_Mns__c), 00, 00);
                ds.HRMSUS__End_Times__c  = Time.newInstance(integer.valueof(ds.HRMSUS__End_Time_Hrs__c), integer.valueof(ds.HRMSUS__End_Time_Mns__c), 00, 00);
               system.debug('HRMSUS__Start_Times__c-->'+ds.HRMSUS__Start_Times__c);
                system.debug('HRMSUS__End_Times__c-->'+ds.HRMSUS__End_Times__c);
                if(ds.HRMSUS__Customer__c!=  mapPrjs.get(ds.HRMSUS__Project__c).HRMSUS__Account__c)
                    //   if(DS.HRMSUS__Customer__c!= prj.HRMSUS__Account__c)
                {
                    system.debug('Invalid Customer For the Selected Project');    
                }
            }
            
            
           if(stDt!=null&&enDt!=null)
            {
                 system.debug('StDt'+stDt);
                system.debug('EnDt'+enDt);
                if(stDt>enDt){
                    enDt = enDt.AddDays(1);
                }  
                ds.HRMSUS__Total__c = (Decimal.valueOf(enDt.getTime() - stDt.getTime())/(1000*60*60)).SetSCale(2);
                 system.debug('total'+Decimal.valueOf(enDt.getTime() - stDt.getTime())/(1000*60*60));
                 system.debug('StDt'+stDt);
                system.debug('EnDt'+enDt);
            }    
            if( ds.HRMSUS__Start_Time_Hrs__c >12 && ds.HRMSUS__St_Meridian__c=='PM')
            {
                ds.HRMSUS__Start_Time_Hrs__c = ds.HRMSUS__Start_Time_Hrs__c-12;
            }
            if( ds.HRMSUS__End_Time_Hrs__c >12 && ds.HRMSUS__En_Meridian__c=='PM')
            {
                Ds.HRMSUS__End_Time_Hrs__c = ds.HRMSUS__End_Time_Hrs__c-12;
            }    
            if( ds.HRMSUS__Start_Time_Hrs__c == 0 && ds.HRMSUS__St_Meridian__c=='AM')
            {
                ds.HRMSUS__Start_Time_Hrs__c = ds.HRMSUS__Start_Time_Hrs__c+12;
            }        
            if( ds.HRMSUS__End_Time_Hrs__c == 0 && ds.HRMSUS__En_Meridian__c=='AM'){
                ds.HRMSUS__End_Time_Hrs__c = ds.HRMSUS__End_Time_Hrs__c+12;
                }      
            dailySheet.add(ds);
            system.debug('Dsheet  778  ++'+dailySheet);
        }
            
        if (Schema.sObjectType.HRMSUS__Daily_Sheet__c.isCreateable()&& Schema.sObjectType.HRMSUS__Daily_Sheet__c.isUpdateable()){
            system.debug('Dsheet  778  ++'+dailySheet);
            system.debug('Dsheet  778  ++'+dailySheet.size());
            upsert dailySheet;
        }else{   
            system.debug('Inefficient access to DailySheet '); 
        }
        
    }

        return dailySheet;
    }
    @AuraEnabled
    public static void deleteRow(HRMSUS__Daily_Sheet__c record)
    {
        //System.Debug(record);
        if (Schema.sObjectType.HRMSUS__Daily_Sheet__c.isDeletable())
        {
            delete record;
        }
        else
        {
            system.debug('Insufficient access to Daily Sheet');
        }
    }
   
}