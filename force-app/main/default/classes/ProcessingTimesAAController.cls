public class ProcessingTimesAAController {
    public List<Case> list1 {get; set;}
    public Decimal oldestCaseAge {get; set;}

    public ProcessingTimesAAController() {

//  list1 OLDEST CASE AGE    
    list1 = [
        SELECT ID, Age_Adj_Hours__c 
        FROM CASE 
        WHERE 
            Status = 'New' AND 
            RecordTypeId != '0121N000000ybeIQAQ' AND 
            RecordTypeId != '0123m000000UAZkAAO' AND 
            RecordTypeId != '0126O000001rNttQAE' AND 
            RecordTypeId != '' AND 
            (NOT Subject LIKE '%mentioned you in a post%') AND 
            (NOT Subject LIKE '%commented on your post%') AND 
            (OwnerId = '005o00000016olqAAA' OR  
            OwnerId = '0056O00000CSPZkQAP' OR  
            OwnerId = '0053m00000CQWJXAA5' ) AND 
            Origin != 'Lease Related' AND 
            Origin != 'Outreach' 
        ORDER BY Age_Adj_Hours__c DESC 
        LIMIT 1 
            ];
    
    oldestCaseAge = list1[0].Age_Adj_Hours__c;
    
    }

}