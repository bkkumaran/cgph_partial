public class HR_Case_Log_Ext {

    public List<Log_Entry__c> logList {get; set;}

    public HR_Case_Log_Ext(ApexPages.StandardController controller) {
        logList = [SELECT
                                Id,
                                Name,
                                HR_Case_File__c,
                                HR_Case_File__r.Id,
                                HR_Case_File__r.Name,
                                HR_Case_File__r.Inspector_Log_Notes__c,
                                HR_Case_File__r.Case_Log_Notes__c,
                                Staff_Member__c,
                                Staff_Member__r.Id,
                                Staff_Member__r.Name,
                                Staff_Member__r.Team__c,
                                Staff_Member__r.Resume_Title__c,
                                Staff_Member__r.Staff_Initials__c,
                                Entry_Date__c,
                                Description__c
                   FROM Log_Entry__c
                   WHERE HR_Case_File__r.Id = :ApexPages.currentPage().getParameters().get('id')
                   ORDER BY Entry_Date__c Desc, CreatedDate DESC
                  ];
        IF (logList.size() == 0) {
            logList = NULL;
        }
    }
    
}