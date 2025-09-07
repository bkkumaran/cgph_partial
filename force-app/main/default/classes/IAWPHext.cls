public with sharing class IAWPHext {

    public List<HOMEtracker__Income_Source__c> listIS {get; set;}
    public List<Hometracker__Service_File__c> sFileList {get; set;}
    public List<HOMEtracker__Applicant_Asset__c> listAsset {get; set;}
    public List<HOMEtracker__Household_Member__c> listHM {get; set;}
    public Integer listHMsize {get; set;}
    public String sFileName {get; set;} 
    public String sFileID {get; set;}  
    public String rowStyle {get; set;}  
    public String showRefresh {get; set;}

    public Hometracker__Service_File__c SerFile {get; set;}
    
    public IAWPHext(ApexPages.StandardController controller) {
    rowStyle='lockRow';
    showRefresh='false';
    sFileList = [SELECT Name, Tax_Return_Gross_Income_1__c from HOMEtracker__Service_File__c WHERE ID=:ApexPages.currentPage().getParameters().get('Id')];
    sFileName = sFileList[0].name;
    sFileID = sFileList[0].id;
    SerFile = (Hometracker__Service_File__c )controller.getRecord();
             
    listIS=[SELECT  id, 
                    PHA__Household_Member_Name__c,
                    Lock_Income_Source__c,
                    PHA__Income_Source_Status__c,
                    PHA__Explanation__c,
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
            ORDER BY Order__c ASC];
    
    listAsset=[SELECT id, 
                    PHA__Household_Member_Name__c,
                    PHA__Account_Number__c,
                    Account_Number_Text__c,
                    Lock_Asset__c,
                    IAW_Asset_Owner__c,
                    HOMEtracker__Asset_Owner__c,
                    Joint_Asset_Owner__c,
                    Joint_Asset_Owner_Text__c,
                    Name,
                    Order__c,
                    HOMEtracker__Type__c,
                    HOMEtracker__Value__c,
                    Imputed_Interest_Percentage__c,
                    Imputed_Interest__c,
                    Calculated_Interest__c,
                    HOMEtracker__Date__c,
                    Equity__c,
                    Value_or_Equity__c
                FROM HOMEtracker__Applicant_Asset__c 
                WHERE (HOMEtracker__Service_File__c=: sFileID)
                ORDER BY Order__c ASC];
        listHM = [SELECT Id
             FROM HOMEtracker__Household_Member__c
             WHERE
             (HOMEtracker__Service_File__c=: sFileID) AND (HOMEtracker__Include_In_Service_File_HH_Size__c=true)
             ] ;
        listHMsize = listHM.size();
    } 

// new saving code
    public pageReference saveIS(){
        update listIS;
        PageReference pg = new PageReference('/apex/IncomeWorksheetPH?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
        
            }

    public pageReference saveAsset(){
        update listAsset;
        PageReference pg = new PageReference('/apex/IncomeWorksheetPH?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
        
            }    
        public pageReference saveSF(){
         update SerFile;
         PageReference pg = new PageReference('/apex/IncomeWorksheetPH?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
    }

        public pageReference save(){
         update SerFile;
         PageReference pg = new PageReference('/apex/IncomeWorksheetPH?id='+SerFile.Id);
         pg.setRedirect(true);
         return pg;
    }

//    public void saveIS(){
//        update listIS;
//       showRefresh = 'true';
//            }
    
//    public void saveAsset(){
//        update listAsset;
//        showRefresh = 'true';    
//    }

//    public void saveSF(){
//        update sFileList ;
//        save();
       
//    }
//        public pageReference save(){
//         update SerFile;
//         PageReference pg = new PageReference('/'+SerFile.Id);
//         return pg;
//    }
//    public void reFresh(){
//    
//    }
}