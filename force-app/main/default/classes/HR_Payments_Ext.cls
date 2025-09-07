public class HR_Payments_Ext {
    public List<HR_Contractor_Payment__c> listPays {get; set;}
    public String hrcfID {get; set;}


    public HR_Payments_Ext(ApexPages.StandardController controller) {
    
        hrcfID= controller.getId();
        
        listPays = [
            SELECT
                Id,
                Generate_Request_Letter__c,
                Imported_for_Records__c,
                HR_Case_File__c, 
                Inspection_Date__c,
                Payment_Amount__c,
                Payment_Number__c,
                Payment_Type__c,
                Request_Sent_to_Muni__c,
                Muni_ID__c,
                Request_To_Muni__c,
                Request_to_Muni_Deadline__c,
                Approval_Date__c
            FROM HR_Contractor_Payment__c
            WHERE HR_Case_File__c = :hrcfID
            ORDER BY Payment_Number__c ASC
            ];

    }
    public pageReference save(){
        update listPays;
        PageReference pg = new PageReference('/'+hrcfId);
        pg.setRedirect(true);
        return pg;
        
    }  

}