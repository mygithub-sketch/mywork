public with sharing class workerEntitlementLwcCls {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllLocations() {
    List<String> allLocations = new List<String>();
    List<HRMSUS__Location__c> locations = [SELECT id,Name FROM HRMSUS__Location__c];
    if (!locations.isEmpty()) {
        for (HRMSUS__Location__c loc : locations) {
            allLocations.add(loc.Name);
        }
    }
    system.debug('allLocations-->'+allLocations);
    return allLocations;    
}

@AuraEnabled(cacheable=true)
public static List<String> getAlldepartments(String locationName) {
    system.debug('locationName-->'+locationName);   
List<String> alldep = new List<String>();
List<HRMSUS__Department__c> departments = [select Id, Name, HRMSUS__Company__c, HRMSUS__Location__r.Name,  HRMSUS__Location__r.HRMSUS__Company__c
                                                   from HRMSUS__Department__c where HRMSUS__Location__r.Name = :locationName];
system.debug('departments-->'+departments);
if (!departments.isEmpty()) {
    for (HRMSUS__Department__c dep : departments) {
        alldep.add(dep.Name);
    }
}
return alldep;
}

@AuraEnabled(cacheable=true)
public static List<WorkerWrapper> getWorkersByDepartment(String locationName,String departmentName) {
    system.debug('locationName '+locationName);
    system.debug('departmentName '+departmentName);
    List<WorkerWrapper> workersList = new List<WorkerWrapper>();

    List<HRMSUS__Person__c> workers=[select id, name,HRMSUS__Location__c,HRMSUS__Location__r.Name,HRMSUS__Company__c,HRMSUS__Department__c,HRMSUS__Department__r.Name, 
                                                        HRMSUS__Supervisor__c,HRMSUS__Supervisor__r.Name, HRMSUS__Worker_ID__c from HRMSUS__Person__c where HRMSUS__Department__r.Name =:departmentName AND HRMSUS__Location__r.Name =:locationName];
    
    system.debug('workers '+workers);
    list<HRMSUS__Absence_Type__c> timeOfType =[select id, Name,HRMSUS__Time_Off_Start__c,HRMSUS__Time_Off_End__c,HRMSUS__Available_Hours__c,
                                               HRMSUS__Company__c,HRMSUS__Available_Days__c,HRMSUS__Current_State__c from HRMSUS__Absence_Type__c
                                                where HRMSUS__Current_State__c='Active'];
    
    system.debug('timeOfType '+timeOfType);
    for (HRMSUS__Person__c worker : workers) {
        for(HRMSUS__Absence_Type__c ab:timeOfType){
        WorkerWrapper wrapper = new WorkerWrapper();
        wrapper.check=false;
        wrapper.Id = worker.Id;
        wrapper.Name = worker.Name;
        wrapper.typeName = ab.Name;
        wrapper.typeId =ab.Id;
        wrapper.hours =ab.HRMSUS__Available_Hours__c;
        workersList.add(wrapper);
       
        }
        system.debug('workersList'+workersList);
    }

    return workersList;
}

public class WorkerWrapper {
    @AuraEnabled public Id Id { get; set; }
    @AuraEnabled public boolean check{get;set;}
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String typeName { get; set; }
    @AuraEnabled public String typeId { get; set; }
    @AuraEnabled public Decimal hours { get; set; }
    @AuraEnabled public Date startDate {get;set;}
    @AuraEnabled public Date endDate {get;set;}
    
}

@AuraEnabled
    public static string saveWorkers(List<WorkerWrapper> workersToSave) {
        system.debug('workersToSave'+workersToSave);
        List<HRMSUS__Absence_Entitlement__c> recordsToInsert = new List<HRMSUS__Absence_Entitlement__c>();
        List<HRMSUS__Time_off_Entitlement_Line__c> ToELineList = new List<HRMSUS__Time_off_Entitlement_Line__c>();
        Map<string,HRMSUS__Absence_Entitlement__c> totmap= new Map<string,HRMSUS__Absence_Entitlement__c>();  
        List<HRMSUS__Absence_Entitlement__c> lstABN = [SELECT Id, HRMSUS__Worker__c, HRMSUS__Absence_Type__c, HRMSUS__Absences_Start_Date__c, HRMSUS__End_Date__c
                                                       FROM HRMSUS__Absence_Entitlement__c where HRMSUS__Active__c =True];     
        for(HRMSUS__Absence_Entitlement__c a:lstABN)
        {
            String key = String.valueOf(a.HRMSUS__Worker__c) + String.valueOf(a.HRMSUS__Absence_Type__c) + String.valueOf(a.HRMSUS__Absences_Start_Date__c.year());
            system.debug('key103  '+key);
            totmap.put(key,a);
        }

          Map<Id, String> absenceTypeNames = new Map<Id, String>();
          List<HRMSUS__Absence_Type__c> timeOfType = [select Id, Name,HRMSUS__Time_Off_Start__c,HRMSUS__Time_Off_End__c,HRMSUS__Available_Hours__c,
                                                    HRMSUS__Company__c,HRMSUS__Available_Days__c,HRMSUS__Current_State__c from HRMSUS__Absence_Type__c where  HRMSUS__Current_State__c='Active'];
          for (HRMSUS__Absence_Type__c ab : timeOfType) {
           absenceTypeNames.put(ab.Id, ab.Name);
          }

          Map<Id, String> workerNames = new Map<Id, String>();
          List<HRMSUS__Person__c> workers=[select id, name,HRMSUS__Location__c,HRMSUS__Location__r.Name,HRMSUS__Company__c,HRMSUS__Department__c,HRMSUS__Department__r.Name, 
                                                        HRMSUS__Supervisor__c,HRMSUS__Supervisor__r.Name, HRMSUS__Worker_ID__c from HRMSUS__Person__c ];
          for (HRMSUS__Person__c worker : workers) {
          workerNames.put(worker.Id, worker.Name);
          }

        for (WorkerWrapper worker : workersToSave) {
            system.debug('worker'+worker);
            String keyset = worker.id  + worker.typeId + worker.startDate.year(); 
            system.debug('key110  '+keyset);             
           if(totmap.containskey(keyset)){
            String typeName = absenceTypeNames.get(worker.typeId);
            String workerName = workerNames.get(worker.Id);
             return 'The '+typeName+' Timeoffentitlement already exist for the selected Year for '+workerName;          
                    
            }else{
            HRMSUS__Absence_Entitlement__c record = new HRMSUS__Absence_Entitlement__c();
            record.HRMSUS__Worker__c = worker.Id;
            record.HRMSUS__Absence_Type__c = worker.typeId;
            record.HRMSUS__ToT_Allowed_Hours__c = worker.hours;
            record.HRMSUS__Absences_Start_Date__c = worker.startDate;
            record.HRMSUS__End_Date__c = worker.endDate;
            record.HRMSUS__Active__c =True;
            recordsToInsert.add(record);
            
            }
        }
        if (!recordsToInsert.isEmpty()) {
            try {
                insert recordsToInsert;
                
            } catch (Exception e) {
                return 'Error inserting records: ' + e.getMessage();
            }
        }

        /*for (HRMSUS__Absence_Entitlement__c entitlement : recordsToInsert) {
            HRMSUS__Absence_Type__c absenceType = [SELECT Name
                                                   FROM HRMSUS__Absence_Type__c
                                                   WHERE Id = :entitlement.HRMSUS__Absence_Type__c
                                                   LIMIT 1];
            HRMSUS__Time_off_Entitlement_Line__c timeOffEntitlementLine = new HRMSUS__Time_off_Entitlement_Line__c();
            
            timeOffEntitlementLine.HRMSUS__Time_Off_Entitlement__c = entitlement.Id;           
            timeOffEntitlementLine.Name = absenceType.Name;
            timeOffEntitlementLine.HRMSUS__Add_Hours__c=entitlement.HRMSUS__ToT_Allowed_Hours__c;
            timeOffEntitlementLine.HRMSUS__Date__c = system.today();        
            ToELineList.add(timeOffEntitlementLine);
            
        }*/
        Set<Id> absenceTypeIds = new Set<Id>();
for (HRMSUS__Absence_Entitlement__c entitlement : recordsToInsert) {
    absenceTypeIds.add(entitlement.HRMSUS__Absence_Type__c);
}

// Query the Absence Types outside the loop
Map<Id, HRMSUS__Absence_Type__c> absenceTypeMap = new Map<Id, HRMSUS__Absence_Type__c>(
    [SELECT Id, Name
     FROM HRMSUS__Absence_Type__c
     WHERE Id IN :absenceTypeIds]
);

for (HRMSUS__Absence_Entitlement__c entitlement : recordsToInsert) {
    HRMSUS__Absence_Type__c absenceType = absenceTypeMap.get(entitlement.HRMSUS__Absence_Type__c);

    if (absenceType != null) {
        HRMSUS__Time_off_Entitlement_Line__c timeOffEntitlementLine = new HRMSUS__Time_off_Entitlement_Line__c();
        timeOffEntitlementLine.HRMSUS__Time_Off_Entitlement__c = entitlement.Id;           
        timeOffEntitlementLine.Name = absenceType.Name;
        timeOffEntitlementLine.HRMSUS__Add_Hours__c = entitlement.HRMSUS__ToT_Allowed_Hours__c;
        timeOffEntitlementLine.HRMSUS__Date__c = System.today();        
        ToELineList.add(timeOffEntitlementLine);
    }
}
if (!ToELineList.isEmpty()) {
            try {
                insert ToELineList;
                return 'success';
            } catch (Exception e) {
                // Handle insert failure (if needed)
               //throw new AuraHandledException('Error inserting records: ' + e.getMessage());
                return 'Error inserting records: ' + e.getMessage();
            }
        }
        return null;
    }

}