public class HRCompInspTrackExt {
    public List<HR_Case_File__c> listHRCF {get; set;}
    public Integer countHRCF {get; set;}
    
    public HRCompInspTrackExt(ApexPages.StandardController controller) {
    
        listHRCF = [SELECT Name,
                Municipality__c,
                Property__r.Name,
                HR_Homeowners__c, 
                Property__c,
                HR_Case_Manager_Initials__c,
                Cert_of_Eligibility__c,
                Pre_Inspection_Q_sent_to_HMR__c,
                Pre_Inspection_Q_Rec_d_from_HMR__c,
                Inspector__r.Staff_Initials__c,
                Date_Request_Sent_to_Inspector__c,
                Comp_Inspection_Date__c,
                HR_Case_File_Comments__c,
                Case_Log_Notes__c,
                Inspector_Log_Notes__c,
                Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                Last_Case_Log_Entry_Record__r.Entry_Text__c
                FROM HR_Case_File__c
                WHERE Date_Request_Sent_to_Inspector__c != null AND Bid_Opening__c = null AND Case_Log_Entry__c = true
                ORDER BY Municipality__r.Name ASC, Name ASC];
                
        countHRCF = listHRCF.size();
                
    }
    
    public pageReference save(){
         update listHRCF;
         PageReference pg = new PageReference('/apex/HRCompInspectionTracker');
         pg.setRedirect(true);
         return pg;
    }

}