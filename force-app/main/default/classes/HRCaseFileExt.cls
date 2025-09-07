public with sharing class HRCaseFileExt {

    public List<HR_Case_File__c> listHRCF {get; set;}
    public Integer countHRCF {get; set;}
    public List<HR_Case_File__c> listHRCFo {get; set;}
    public Integer countHRCFo {get; set;}
    public List<HR_Case_File__c> listHRCFt {get; set;}
    public Integer countHRCFt {get; set;}
    public List<HR_Case_File__c> listHRCFtr {get; set;}
    public Integer countHRCFtr {get; set;}
    public List<HR_Case_File__c> listHRCFc {get; set;}
    public Integer countHRCFc {get; set;}
    public String logName {get; set;}
    public String dataSet {get; set;}
    
    public HRCaseFileExt(ApexPages.StandardController controller) {
    
    logName = apexpages.currentpage().getparameters().get('name');
    dataSet = apexpages.currentpage().getparameters().get('d');
    
    listHRCF = [SELECT
                	Name,
                	HR_Homeowners__c,
                	Property__r.Name, Property__c,
                	Case_Log_Status__c,
                	Contract_Date__c,
                	Contractor_Biz_Name__r.Name,
                	Case_Log_Notes__c,
                	Municipality__c,
                	Municipality__r.Name,
                	HR_Case_Terminated_Date__c,
                	Case_File_Phase__c,
                	Application_Received__c,
                	Reason_for_Termination__c,
                	Cert_of_Eligibility__c,
                	Last_Case_Log_Entry_Record__r.Name,
                	Last_Case_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Case_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Case_Log_Entry_Record__r.Description__c,
                	Last_Case_Log_Entry_Record__r.Entry_Text__c,
                	Last_Insp_Log_Entry_Record__r.Name,
                	Last_Insp_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Date__c,
                	Last_Insp_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Insp_Log_Entry_Record__r.Description__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                	Last_Case_Log_Entry_Record__r.Entry_Date__c
                FROM HR_Case_File__c
                WHERE HR_Case_Manager__r.Name = :logName AND Case_Log_Entry__c = true
                ORDER BY Municipality__r.Name ASC, Name ASC];
                
    listHRCFo = [SELECT
                 	Name,
                	HR_Homeowners__c,
                	Property__r.Name, Property__c,
                	Case_Log_Status__c,
                	Contract_Date__c,
                	Contractor_Biz_Name__r.Name,
                	Case_Log_Notes__c,
                	Municipality__c,
                	Municipality__r.Name,
                	HR_Case_Terminated_Date__c,
                	Case_File_Phase__c,
                	Application_Received__c,
                	Reason_for_Termination__c,
                	Cert_of_Eligibility__c,
                	Last_Case_Log_Entry_Record__r.Name,
                	Last_Case_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Date__c,
                	Last_Case_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Case_Log_Entry_Record__r.Description__c,
                	Last_Insp_Log_Entry_Record__r.Name,
                	Last_Insp_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Date__c,
                	Last_Insp_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Insp_Log_Entry_Record__r.Description__c,
                 	Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                 	Last_Case_Log_Entry_Record__r.Entry_Text__c
                FROM HR_Case_File__c
                WHERE HR_Case_Manager__r.Name = :logName AND Case_Log_Status__c = 'On Hold'
                ORDER BY Municipality__r.Name ASC, Name ASC];
                
    listHRCFt = [SELECT 
                	Name,
                	HR_Homeowners__c,
                	Property__r.Name, Property__c,
                	Case_Log_Status__c,
                	Contract_Date__c,
                	Contractor_Biz_Name__r.Name,
                	Case_Log_Notes__c,
                	Municipality__c,
                	Municipality__r.Name,
                	HR_Case_Terminated_Date__c,
                	Case_File_Phase__c,
                	Application_Received__c,
                	Reason_for_Termination__c,
                	Cert_of_Eligibility__c,
                	Last_Case_Log_Entry_Record__r.Name,
                	Last_Case_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Date__c,
                	Last_Case_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Case_Log_Entry_Record__r.Description__c,
                	Last_Insp_Log_Entry_Record__r.Name,
                	Last_Insp_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Date__c,
                	Last_Insp_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Insp_Log_Entry_Record__r.Description__c,
                 	Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                	Last_Case_Log_Entry_Record__r.Entry_Text__c
                FROM HR_Case_File__c
                WHERE HR_Case_Manager__r.Name = :logName AND Case_Log_Status__c = 'Terminated'
                ORDER BY HR_Case_Terminated_Date__c DESC, Name ASC];
                
    listHRCFc = [SELECT
                	Name,
                	HR_Homeowners__c,
                	Property__r.Name, Property__c,
                	Case_Log_Status__c,
                	Contract_Date__c,
                	Contractor_Biz_Name__r.Name,
                	Case_Log_Notes__c,
                	Municipality__c,
                	Municipality__r.Name,
                	HR_Case_Terminated_Date__c,
                	Case_File_Phase__c,
                	Application_Received__c,
                	Reason_for_Termination__c,
                	Cert_of_Eligibility__c,
                	Last_Case_Log_Entry_Record__r.Name,
                	Last_Case_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Date__c,
                	Last_Case_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Case_Log_Entry_Record__r.Description__c,
                	Last_Insp_Log_Entry_Record__r.Name,
                	Last_Insp_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Date__c,
                	Last_Insp_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Insp_Log_Entry_Record__r.Description__c,
                 	Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                	Last_Case_Log_Entry_Record__r.Entry_Text__c
                FROM HR_Case_File__c
                WHERE HR_Case_Manager__r.Name = :logName AND Case_Log_Status__c = 'Complete: Remove from Log'
                ORDER BY Final_Inspection__c DESC, Name ASC];
                
    listHRCFtr = [SELECT
                Name,
                	HR_Homeowners__c,
                	Property__r.Name, Property__c,
                	Case_Log_Status__c,
                	Contract_Date__c,
                	Contractor_Biz_Name__r.Name,
                	Case_Log_Notes__c,
                	Municipality__c,
                	Municipality__r.Name,
                	HR_Case_Terminated_Date__c,
                	Case_File_Phase__c,
                	Application_Received__c,
                	Reason_for_Termination__c,
                	Cert_of_Eligibility__c,
                	Last_Case_Log_Entry_Record__r.Name,
                	Last_Case_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Case_Log_Entry_Record__r.Entry_Date__c,
                	Last_Case_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Case_Log_Entry_Record__r.Description__c,
                	Last_Insp_Log_Entry_Record__r.Name,
                	Last_Insp_Log_Entry_Record__r.Case_Log_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Staff_Type__c,
                	Last_Insp_Log_Entry_Record__r.Entry_Date__c,
                	Last_Insp_Log_Entry_Record__r.Staff_Member__r.Staff_Initials__c,
                	Last_Insp_Log_Entry_Record__r.Description__c,
                  	Last_Insp_Log_Entry_Record__r.Entry_Text__c,
                	Last_Case_Log_Entry_Record__r.Entry_Text__c
                FROM HR_Case_File__c
                WHERE HR_Case_Manager__r.Name = :logName AND Case_Log_Status__c = 'Transferred to Different Admin'
                ORDER BY Application_Received__c DESC, Name ASC];         
                
    countHRCF = listHRCF.size();
    countHRCFo = listHRCFo.size();
    countHRCFt = listHRCFt.size();
    countHRCFtr = listHRCFtr.size();
    countHRCFc = listHRCFc.size();

}

     public pageReference save(){
         IF (dataSet == 'C'){
         update listHRCFc;
         } ELSE
         IF (dataSet == 'O'){
         update listHRCFo;
         } ELSE
         IF (dataSet == 'Tr'){
         update listHRCFtr;
         } ELSE
          IF (dataSet == 'T'){
         update listHRCFt;
         } ELSE {
         update listHRCF;
         }
         PageReference pg = new PageReference('/apex/HRCaseLog?d='+dataSet+'&name='+logName);
         pg.setRedirect(true);
         return pg;
    }
}