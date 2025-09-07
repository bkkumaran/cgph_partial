public class ImpTickExt {

    public List<Case> listAll {get; set;}
    public List<Case> listX {get; set;}
    public Integer sizeAll {get; set;}
    public Integer sizeX {get; set;}
    public String getX {get; set;}


    public ImpTickExt(ApexPages.StandardController controller) {
    
    getX = apexpages.currentpage().getparameters().get('x');
    
    listAll = [SELECT Id,CaseNumber,Description,Subject,Planned_End_Date__c,Planned_Start_Date__c,Type,Priority,Priority_Number__c,Priority_Num__c,Project_Size__c,Followup_Date_Cases__c,Action_Taken__c,Action_Notes__c,Comments,OwnerId,IsClosed,Reason,ClosedDate,CreatedDate
                FROM CASE
                WHERE RecordTypeId='0121N000000ybeI' AND IsClosed = false AND Project_Size__c != ''
                ORDER BY Priority_Num__c ASC];
    sizeAll = listAll.size();
    
    listX = [SELECT Id,CaseNumber,Description,Planned_End_Date__c,Planned_Start_Date__c,Subject,Type,Priority,Priority_Number__c,Priority_Num__c,Project_Size__c,Followup_Date_Cases__c,Action_Taken__c,Action_Notes__c,Comments,OwnerId,IsClosed,Reason,ClosedDate,CreatedDate
                FROM CASE
                WHERE RecordTypeId='0121N000000ybeI' AND IsClosed = false AND Project_Size__c LIKE :getX+'%'
                ORDER BY Priority_Num__c ASC];
    sizeX = listX.size();
 
    }
    
    public pageReference save(){
         IF (getX == '1'){
         update listX;
         } ELSE
         IF (getX == '2'){
         update listX;
         } ELSE
         IF (getX == '3'){
         update listX;
         } ELSE
         IF (getX == '4'){
         update listX;
         } ELSE {
         update listAll;
         }
         PageReference pg = new PageReference('/apex/ImprovementTickets?x='+getX);
         pg.setRedirect(true);
         return pg;
    }

}