public with sharing class AALogExt_Muni {

    public List<AA_Log_Entry__c> logList {get; set;}

    public AALogExt_Muni(ApexPages.StandardController controller) {
        logList = [
            SELECT
                Id,
                Name,
                Description_2__c,
                Invoice_Entry__c,
                Entry_Text__c,
                Log_Date__c,
                Staff__r.Name,
                Staff__r.Id,
                Staff_Initials__c,
                Record_Link__c,
                Relevant_Record_ID__c,
                Time_Spent__c
            FROM AA_Log_Entry__c
            WHERE Municipality__c = :ApexPages.currentPage().getParameters().get('id')
            ORDER BY Log_Date__c DESC, Name DESC ];
        IF (logList.size() == 0) {
            logList = NULL;
        }
    }

}