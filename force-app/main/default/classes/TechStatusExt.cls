public with sharing class TechStatusExt {
    Public List<Case> techList {get; set;}

    public TechStatusExt(ApexPages.StandardController controller) {

    techList = [SELECT Id, Flag__c, Tech_Status_Notes__c FROM Case WHERE Subject='TECH STATUS' LIMIT 1];

    }

}