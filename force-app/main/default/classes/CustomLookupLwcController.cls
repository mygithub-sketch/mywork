public with sharing  class CustomLookupLwcController {
    // Method to fetch lookup search result   
   
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupValues(  String searchKeyWord, String objectAPIName,String whereCondition, String fieldNames, string parentId, Integer customLimit ) {
        System.debug('objectAPIName'+objectAPIName+'fieldNames '+fieldNames +' whereCondition '+whereCondition +'parentId'+parentId);
        String searchKey = '%'+ searchKeyWord + '%';        
        List<sObject> returnList = new List<sObject>();
        String sQuery = 'SELECT Id, Name';
        if(String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')) {
            sQuery += ','+fieldNames;
        }
        if(String.isNotBlank(parentId)){
            whereCondition+= '\'' + parentId + '\'';  
        }
        if(!HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c && objectAPIName=='HRMSUS__Projects__c')
    	{
            whereCondition+= ' AND HRMSUS__Holiday__c=false AND HRMSUS__Time_Off__c=false';
        }
        if(HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c && objectAPIName=='HRMSUS__Projects__c')
    	{
            whereCondition+= ' AND HRMSUS__Active__c=true';
        }
        system.debug(whereCondition) ;
        if(String.isNotBlank(whereCondition) && whereCondition != null){
            sQuery +=  ' FROM ' +objectAPIName + ' WHERE ' + fieldNames + ' LIKE :searchKey AND '+ whereCondition + ' ORDER BY CreatedDate DESC limit '+ String.valueOf(customLimit);
        } else {
           sQuery +=  ' FROM ' +objectAPIName + ' WHERE '+ fieldNames + ' LIKE :searchKey  ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        }

        system.debug(sQuery) ;
        List<sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) { returnList.add(obj); }
        System.debug(lstOfRecords) ;
        return returnList;
    }
    @AuraEnabled(cacheable=true)
    public static sObject getinitRecord(String recordId, String objectAPIName, String fieldNames) {
        String sRecId = recordId;    
        String sQuery = 'SELECT id ';
        if(String.isNotBlank(fieldNames)) {
            sQuery += ','+fieldNames;
        }
        sQuery +=  ' FROM ' + objectAPIName + ' WHERE Id = : sRecId LIMIT 1 ';
        for (sObject obj: Database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecentlyCreatedRecords( String objectAPIName,  String fieldNames,  String whereCondition, string parentId,  Integer customLimit){
      System.debug('objectAPIName'+objectAPIName+'fieldNames '+fieldNames +' whereCondition '+whereCondition +'parentId'+parentId);
       List<sObject> returnList = new List<sObject>();
        String sQuery = 'SELECT Id, Name';
        if(String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')) {
            sQuery += ','+fieldNames;
        }
        if(String.isNotBlank(parentId)){
            whereCondition+= '\'' + parentId + '\'';
        }
        if(!HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c && objectAPIName=='HRMSUS__Projects__c')
    	{
            whereCondition+= ' AND HRMSUS__Holiday__c=false AND HRMSUS__Time_Off__c=false';
        }
        if(HRMSUS__Trigger__c.getOrgDefaults().HRMSUS__EnableTimeoffandHolidayProjects__c && objectAPIName=='HRMSUS__Projects__c')
    	{
            whereCondition+= ' AND HRMSUS__Active__c=true';
        }
        system.debug(whereCondition) ;
       if(String.isNotBlank(whereCondition) && whereCondition != null){
            sQuery +=  ' FROM ' +objectAPIName + ' WHERE ' + whereCondition + ' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        } else {
            sQuery +=  ' FROM ' +objectAPIName + ' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        }
        System.debug(sQuery);
        List<sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) { returnList.add(obj); }
        return returnList;
    }

}