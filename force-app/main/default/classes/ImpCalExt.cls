public with sharing class ImpCalExt {
    public List<Case> listAll {get; set;}
    public Integer listSize {get; set;}

    
    public ImpCalExt(ApexPages.StandardController controller) {
    
    
    listAll = [SELECT Id, Subject, Planned_End_Date__c, Planned_Start_Date__c, Project_Doers__c, Owner.Name, Additional_Owners__c, Planned_Months__c, Priority_Num__c, List_Determination__c 
            FROM Case
            WHERE IsClosed = false AND (List_Determination__c = 'Scheduled' OR List_Determination__c = 'In Progress'  OR List_Determination__c = 'NEEDS DATE')
            ORDER BY Planned_End_Date__c, Planned_Start_Date__c, Priority_Num__c ASC];
    
     listSize = listAll.size();

    }
        public Integer[] getMod() {
        return new Integer[]{-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21, 22};
        }
        
  public pageReference save(){
         update listAll;
         PageReference pg = new PageReference('/apex/ImprovementCalendar');
         pg.setRedirect(true);
         return pg;
    }
}