public with sharing class IncomeWorksheetVPext {

    public List<HOMEtracker__Income_Source__c> listIS {get; set;}
    public List<Hometracker__Service_File__c> sFileList {get; set;}
    public List<HOMEtracker__Applicant_Asset__c> listAsset {get; set;}
    public String sFileName {get; set;} 
    public String sFileID {get; set;}  
    public String rowStyle {get; set;}  
    public String showRefresh {get; set;}

    public Hometracker__Service_File__c SerFile {get; set;}
    
    public IncomeWorksheetVPext(ApexPages.StandardController controller) {
    rowStyle='lockRow';
    showRefresh='false';
    sFileList = [SELECT Name, Tax_Return_Gross_Income_1__c from HOMEtracker__Service_File__c WHERE ID=:ApexPages.currentPage().getParameters().get('Id')];
    sFileName = sFileList[0].name;
    sFileID = sFileList[0].id;
    SerFile = (Hometracker__Service_File__c )controller.getRecord();
             
    listIS=[SELECT  id, 
                    Lock_Income_Source__c,
                    IAW_Income_Earner__c,
                    IAW_Income_Name__c,
                    Order__c,
                    HOMEtracker__Income_Type__c,
                    HOMEtracker__Pretax_Income_This_Year__c,
                    HOMEtracker__Eligibility_Adjustments__c,
                    HOMEtracker__Do_Not_Include_In_Rollup__c,
                    HOMEtracker__Income_Calculations__c,
                    IAW_Verification_Type__c
            FROM HOMEtracker__Income_Source__c
            WHERE (HOMEtracker__Service_File__c =: sFileID)
            ORDER BY Order__c ASC];
    
    listAsset=[SELECT id, 
                    Lock_Asset__c,
                    IAW_Asset_Owner__c,
                    Name,
                    Order__c,
                    HOMEtracker__Type__c,
                    HOMEtracker__Value__c,
                    Imputed_Interest_Percentage__c,
                    Imputed_Interest__c,
                    Calculated_Interest__c,
                    HOMEtracker__Date__c
                FROM HOMEtracker__Applicant_Asset__c 
                WHERE (HOMEtracker__Service_File__c=: sFileID)
                ORDER BY Order__c ASC];

    } 
    
    public void saveIS(){
        update listIS;
        showRefresh = 'true';
            }
    
    public void saveAsset(){
        update listAsset;
        showRefresh = 'true';    
    }

    public void saveSF(){
        update sFileList ;
        save();
       
    }
        public pageReference save(){
         update SerFile;
         PageReference pg = new PageReference('/'+SerFile.Id);
         return pg;
    }
    public void reFresh(){
    
    }
}