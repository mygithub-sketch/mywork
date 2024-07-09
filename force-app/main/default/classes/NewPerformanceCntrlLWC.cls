public with sharing class NewPerformanceCntrlLWC {
    @AuraEnabled(cacheable=true)
    public static HRMSUS__Performance__c getPerformanceRecord(Id recordId) {
        return [SELECT Id, HRMSUS__Performance_Group__c, HRMSUS__Review_Start_Date__c, HRMSUS__Review_End_Date__c
            FROM HRMSUS__Performance__c WHERE Id = :recordId LIMIT 1];
    }

    @AuraEnabled
    public static void savePerformance(HRMSUS__Performance__c performance) {
        try {
            upsert performance;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   /* @AuraEnabled
    public static PageReference cancel(Id recordId) {
        return new PageReference('/' + recordId);
    }*/
}