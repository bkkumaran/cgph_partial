public with sharing class IncomeWorksheetHRext {

    public List<HOMEtracker__Income_Source__c> listIS {get; set;}
    public List<Hometracker__Service_File__c> sFileList {get; set;}
    public String sFileName {get; set;} 
    public String sFileID {get; set;}
    public String rowStyle {get; set;}  
    public String showRefresh {get; set;}

    public Hometracker__Service_File__c SerFile {get; set;}
    
    public IncomeWorksheetHRext(ApexPages.StandardController controller) {
    rowStyle='lockRow';
    showRefresh='false';
    sFileList = [SELECT Name, Tax_Return_Gross_Income_1__c from HOMEtracker__Service_File__c WHERE ID=:ApexPages.currentPage().getParameters().get('Id')];
    sFileName = sFileList[0].name;
    sFileID = sFileList[0].id;
    SerFile = (Hometracker__Service_File__c )controller.getRecord();
    
         
    listIS=[SELECT  id, 
                    PHA__Household_Member_Name__c,
                    Source_Text__c,
                    HR_Asset_Value__c,
                        PHA__Income_Source_Status__c,
                        PHA__Income_Source_Name_Internal__c,
                        PHA__Explanation__c,
                    Lock_Income_Source__c,
                    IAW_Income_Earner__c,
                    IAW_Income_Name__c,
                    HOMEtracker__Wage_Earner__c,
                    HOMEtracker__Employer_Business_Name__c,
                    Order__c,
                    HOMEtracker__Income_Type__c,
                    HOMEtracker__Pretax_Income_This_Year__c,
                    HOMEtracker__Eligibility_Adjustments__c,
                    HOMEtracker__Do_Not_Include_In_Rollup__c,
                    HOMEtracker__Income_Calculations__c,
            		Income_Calcs_Count__c,
                    IAW_Verification_Type__c
            FROM HOMEtracker__Income_Source__c
            WHERE (HOMEtracker__Service_File__c =: sFileID)
            ORDER BY Order__c ASC, Name ASC];
    } 
    
    public pageReference saveIS(){
        update listIS;
        PageReference pg = new PageReference('/apex/IncomeWorksheetHR?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
        
            }
    
        public pageReference save(){
         update SerFile;
         PageReference pg = new PageReference('/apex/IncomeWorksheetHR?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
    }

}