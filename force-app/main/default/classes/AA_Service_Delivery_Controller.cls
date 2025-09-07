public class AA_Service_Delivery_Controller {
    public Integer CaseAvg {get; set;}
    public String testString {get; set;}
    
    
    public AA_Service_Delivery_Controller (){
        
        List<Random_Drawing__c> LotteryList = new List<Random_Drawing__c>();
        List<Case> CasesList = new List<Case>();
        List<HOMEtracker__Service_File__c> AppPickupList = new List<HOMEtracker__Service_File__c>();
        List<HOMEtracker__Service_File__c> CertAfterPickupList = new List<HOMEtracker__Service_File__c>();
        List<HOMEtracker__Service_File__c> TermAfterPickupList = new List<HOMEtracker__Service_File__c>();
        List<HOMEtracker__Service_File__c> CertOrTermAfterPickupList = new List<HOMEtracker__Service_File__c>();
        
        CasesList = [SELECT Id, Age_Adj_Hours__c, Owner.Name, Case_Response_Time__c
                    FROM Case
                    WHERE
                        CreatedDate = LAST_N_DAYS:30
                        AND Status = 'Closed' AND
                        Age_Adj_Hours__c <= 120 AND
                        Age_Adj_Hours__c >= 2 AND
                        (OwnerID = '005Uq000006JgbDIAS' OR OwnerID='0053m00000CQWJXAA5')
                    ORDER BY CreatedDate ASC];
        
        IF (CasesList.size() == 0) {
        CaseAvg = 0;
        testString = 'NULL';
        } ELSE {
        Integer CasesListCount = CasesList.size();
        CaseAvg = Integer.valueOf(CasesList[(CasesListCount/2)-1].Case_Response_Time__c);
        testString = CasesList[(CasesListCount/2)-1].Id;
        }
        
    }
    
}