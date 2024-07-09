public with sharing class TimeOffEntitlementsLwcCls {   
    @AuraEnabled(cacheable=true)
    public static List<HRMSUS__Absence_Type__c> getTimeoffType(String wrkrid) {
        System.debug('wrkrid'+wrkrid);
        HRMSUS__Person__c worker=[select id, name,HRMSUS__Company__c,HRMSUS__User__c from HRMSUS__Person__c where id=:wrkrid];
        
        List<HRMSUS__Absence_Type__c> lstAbt = [select id, name,HRMSUS__Time_Off_Start__c,HRMSUS__Time_Off_End__c,HRMSUS__Available_Hours__c,
                                                HRMSUS__Company__c,HRMSUS__Available_Days__c,HRMSUS__Current_State__c from HRMSUS__Absence_Type__c where HRMSUS__Company__c=:worker.HRMSUS__Company__c AND HRMSUS__Current_State__c='Active'];
        System.debug('lstAbt'+lstAbt);
        System.debug('lstAbt'+lstAbt.size());
        return lstAbt; 
    }
    @AuraEnabled(cacheable=false)
    public static String createAbsenceEntitlements(List<HRMSUS__Absence_Type__c> selectedTimeOffList, String recordId) {
        System.debug('selectedTimeOffList'+selectedTimeOffList);
        System.debug('selectedTimeOffList'+selectedTimeOffList.size());
        System.debug('recordId'+recordId);
        List<HRMSUS__Absence_Entitlement__c> newEntitlements = new List<HRMSUS__Absence_Entitlement__c>();
        System.debug('newEntitlements'+newEntitlements.size());
        List<HRMSUS__Absence_Entitlement__c> existingEntitlements=[select id, name,HRMSUS__Dev_Code__c,HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.Name,HRMSUS__Worker__c,
                                                                   HRMSUS__End_Date__c,HRMSUS__Absences_Start_Date__c,HRMSUS__Active__c
                                                                   from HRMSUS__Absence_Entitlement__c where HRMSUS__Absence_Type__c IN :selectedTimeOffList and HRMSUS__Worker__c=:recordId and HRMSUS__Active__c=true];
        System.debug('existingEntitlements'+existingEntitlements);  
        System.debug('existingEntitlements'+existingEntitlements.size());
        if(!existingEntitlements.isEmpty()){
            for (HRMSUS__Absence_Type__c selectedTimeOff1 : selectedTimeOffList) {
                for (HRMSUS__Absence_Entitlement__c existingEntitlement : existingEntitlements) {
                    
                    if(((selectedTimeOff1.HRMSUS__Time_Off_Start__c >= existingEntitlement.HRMSUS__Absences_Start_Date__c && selectedTimeOff1.HRMSUS__Time_Off_Start__c <= existingEntitlement.HRMSUS__End_Date__c) || 
                        (selectedTimeOff1.HRMSUS__Time_Off_End__c >= existingEntitlement.HRMSUS__Absences_Start_Date__c && selectedTimeOff1.HRMSUS__Time_Off_End__c <= existingEntitlement.HRMSUS__End_Date__c)))  {
                            throw new AuraHandledException('The '+selectedTimeOff1.Name+ ' Entitlement record is overlaping the previous entitlement record'); 
                        }
                }
            }
        }
        for (HRMSUS__Absence_Type__c selectedTimeOff : selectedTimeOffList) {           
            
            if (selectedTimeOff.HRMSUS__Time_Off_Start__c > selectedTimeOff.HRMSUS__Time_Off_End__c) {
                throw new AuraHandledException('The '+selectedTimeOff.Name+ ' Entitlement Start Date shouldnot be greater than End Date');
            }
            
            if (selectedTimeOff.HRMSUS__Time_Off_Start__c == null) {
                throw new AuraHandledException('The '+selectedTimeOff.Name+ ' Entitlement Start Date is empty');
            }
            
            if (selectedTimeOff.HRMSUS__Time_Off_End__c == null) {
                throw new AuraHandledException('The '+selectedTimeOff.Name+ ' Entitlement End Date is empty');
            }
            
            if (selectedTimeOff.HRMSUS__Available_Hours__c == null) {
                throw new AuraHandledException('The '+selectedTimeOff.Name+ ' Entitlement Allowed Hours is empty');
            }
            HRMSUS__Absence_Entitlement__c newEntitlement = new HRMSUS__Absence_Entitlement__c(
                HRMSUS__Absence_Type__c = selectedTimeOff.Id,
                HRMSUS__Company__c=selectedTimeOff.HRMSUS__Company__c,
                HRMSUS__Active__c=true,
                HRMSUS__ToT_Allowed_Hours__c = selectedTimeOff.HRMSUS__Available_Hours__c,
                HRMSUS__Absences_Start_Date__c= selectedTimeOff.HRMSUS__Time_Off_Start__c,
                HRMSUS__End_Date__c =selectedTimeOff.HRMSUS__Time_Off_End__c,
                HRMSUS__Worker__c = recordId
            );
            
            newEntitlements.add(newEntitlement);               
        }
        
        if (!newEntitlements.isEmpty()) {
            insert newEntitlements;
            // return 'Success';
            map<Id,String> absName =new map<Id,String>();
            List<HRMSUS__Time_off_Entitlement_Line__c> newEntitlementLines = new List<HRMSUS__Time_off_Entitlement_Line__c>();
            List<HRMSUS__Absence_Type__c> lstAbt = [select Id, Name,HRMSUS__Time_Off_Start__c,HRMSUS__Time_Off_End__c,HRMSUS__Available_Hours__c,
                                                    HRMSUS__Company__c,HRMSUS__Available_Days__c,HRMSUS__Current_State__c from HRMSUS__Absence_Type__c where  HRMSUS__Current_State__c='Active'];
            for(HRMSUS__Absence_Type__c abt: lstAbt){
                absName.put(abt.Id,abt.Name);
            }
            for (HRMSUS__Absence_Entitlement__c newEntitlement : newEntitlements) {
                HRMSUS__Time_off_Entitlement_Line__c newEntitlementLine = new HRMSUS__Time_off_Entitlement_Line__c();
                newEntitlementLine.HRMSUS__Time_Off_Entitlement__c=newEntitlement.Id;
                newEntitlementLine.HRMSUS__Add_Hours__c=newEntitlement.HRMSUS__ToT_Allowed_Hours__c;
                if(absName.containskey(newEntitlement.HRMSUS__Absence_Type__c)){
                    newEntitlementLine.Name=absName.get(newEntitlement.HRMSUS__Absence_Type__c); 
                }
                
                newEntitlementLine.HRMSUS__Date__c=system.today();   
                
                system.debug('Name--->'+newEntitlement.Name);
                
                newEntitlementLines.add(newEntitlementLine);
            }
            
            if (!newEntitlementLines.isEmpty()) {
                insert newEntitlementLines;
            }
            
            return 'Success';
        }
        
        return 'No records to create';
    }
}