public with sharing class GoalCreationClsLWC {
    /*public GoalCreationClsLWC() {

    }*/
    @AuraEnabled(cacheable=true)
    public static  HRMSUS__Goal__c getGoal(Id goalId) {
        return [SELECT Id, Name, HRMSUS__Goal_Description__c,  HRMSUS__Start_Date__c,  HRMSUS__Due_Date__c,  HRMSUS__Worker__c,  HRMSUS__Manager__c,  HRMSUS__Status__c FROM  HRMSUS__Goal__c WHERE Id = :goalId];
    }
    
    @AuraEnabled
    public static void saveGoal( HRMSUS__Goal__c goal) {
        upsert goal;
    }

    @AuraEnabled(cacheable=true)
    public static List< HRMSUS__Milestone__c> getMilestones(Id goalId) {
        return [SELECT Id, Name,  HRMSUS__Milestone_Description__c,  HRMSUS__Start_Date__c,  HRMSUS__Due_Date__c,  HRMSUS__Status__c FROM  HRMSUS__Milestone__c WHERE  HRMSUS__Goal__c = :goalId];
    }

    @AuraEnabled
    public static void saveMilestone( HRMSUS__Milestone__c milestone) {
        upsert milestone;
    }
}