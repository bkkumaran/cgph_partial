public class AALogExt_Event {
	public List<AA_Log_Entry__c> logList {get; set;}

    public AALogExt_Event(ApexPages.StandardController controller) {
        logList = [
            SELECT
            	Id,
            	Name,
            	Description_2__c,
            	Entry_Text__c,
            	Log_Date__c,
            	Staff__r.Name,
            	Staff__r.Id,
            	Staff_Initials__c
            FROM AA_Log_Entry__c
            WHERE Monitoring_Event__c = :ApexPages.currentPage().getParameters().get('id')
            ORDER BY Log_Date__c DESC, Name DESC ];
        IF (logList.size() == 0) {
            logList = NULL;
        }
    }
}