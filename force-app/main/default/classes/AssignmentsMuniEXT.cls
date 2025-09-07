public with sharing class AssignmentsMuniEXT {
    Public List<Assignment__c> listAssign {get; set;}
    
    public AssignmentsMuniEXT(ApexPages.StandardController controller) {
        listAssign = [
            SELECT 
                Id,
                Name,
                Assigned_To__c,
                Assigned_To__r.Name,
                Assigned_To__r.Id,
                Assigned_To__r.Staff_Initials__c,
                Assignment__c,
                Done_By_Date__c,
                Follow_Up_Date__c,
                Municipality__c,
                Municipality__r.Id,
                Municipality__r.Name,
                Record_ID__c,
                Record_Link__c,
                Record_Object__c,
                Status__c
            FROM Assignment__c
            WHERE Municipality__c = :ApexPages.currentPage().getParameters().get('id')
            ORDER BY Status__c ASC, Follow_Up_Date__c DESC, Record_Object__c ASC
        ];
        IF (listAssign.size() == 0) {
            listAssign = NULL;
        }
    }
}