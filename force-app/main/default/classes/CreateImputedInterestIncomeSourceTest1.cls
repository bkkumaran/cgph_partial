@isTest
public class CreateImputedInterestIncomeSourceTest1 {
public static testmethod void CreateImputedInterestIncomeSourceTest_Method1()

    {
        Account newAcct = new Account();
        newAcct.Name = 'test account';
        Insert newAcct;
        
        Contact newCont = new Contact();
        newCont.LastName = 'Test';
        newCont.AccountId = newAcct.Id;
        Insert newCont;
        
        HOMEtracker__Service_File__c newSF= new HOMEtracker__Service_File__c();
        newSF.RecordTypeId = '012o0000000gaaB';
        newSf.Name='testSF';
        insert newSF;
                
        HOMEtracker__Household_Member__c newHHM = new HOMEtracker__Household_Member__c();
        newHHM.HOMEtracker__Service_File__c = newSF.Id;
        newHHM.HOMEtracker__Application_Role__c = 'Primary Applicant';
        newHHM.HOMEtracker__Contact__c = newCont.Id;
        Insert newHHM;
        
        HOMEtracker__Applicant_Asset__c newAsset = new HOMEtracker__Applicant_Asset__c();
        newAsset.Name = 'Test Asset';
        newAsset.HOMEtracker__Service_File__c = newSf.Id;
        newAsset.HOMEtracker__Value__c = 1000;
        newAsset.Imputed_Interest_Percentage__c = 2;
        newAsset.Create_Imputed_Interest_Income_Source__c = true;
        newAsset.Income_Source_ID__c = null;
        insert newAsset;
   
    }
}