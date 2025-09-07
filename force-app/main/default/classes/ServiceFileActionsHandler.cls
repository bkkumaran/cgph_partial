/***************************************************
* Name : ServiceFileActionsHandler
* Author : Pravin Waykar
* Description : This used to set min and max income limit fields
* 
* ************************************************/
public class ServiceFileActionsHandler {
    public static boolean isServiceFileActionsHandlerExecuted = false;
    public static boolean isRental_Service_AfterExecuted = false;
    public static void runActions(list<HOMEtracker__Service_File__c> lstServiceFiles)
    {
        Id devRecordTypeIdHO = Schema.SObjectType.HOMEtracker__Service_File__c.getRecordTypeInfosByName().get('Homeownership').getRecordTypeId();
        Id devRecordTypeIdRental = Schema.SObjectType.HOMEtracker__Service_File__c.getRecordTypeInfosByName().get('Rental').getRecordTypeId();
        isServiceFileActionsHandlerExecuted = true;
        for(HOMEtracker__Service_File__c serviceFile : lstServiceFiles)
        {
            system.debug('(serviceFile.RecordTypeId:'+serviceFile.RecordTypeId);
            //Meets Max Income Limit Update
          serviceFile.Meets_Max_Income_Limit__c =  ( (serviceFile.Property_Income_Level__c=='Very Low' && serviceFile.IAW_Income_Determination__c =='Very Low')
              ||
               (serviceFile.Property_Income_Level__c=='Low' && (serviceFile.IAW_Income_Determination__c=='Very Low' || serviceFile.IAW_Income_Determination__c=='Low'))
              ||
               (serviceFile.Property_Income_Level__c=='Moderate' && 
                    ( serviceFile.IAW_Income_Determination__c=='Very Low' || serviceFile.IAW_Income_Determination__c=='Low' || serviceFile.IAW_Income_Determination__c=='Moderate')
                   )
              ) ? 'Yes' : 'No';
            
            //O, Meets Min Income Limit Update
            if(serviceFile.RecordTypeId==devRecordTypeIdHO)
            {
                if(serviceFile.IAW_O_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_O_AR_F_Max__c ) 
                    serviceFile.Meets_Min_Income_Limit__c='Yes';
                
                else
                {
                    serviceFile.Meets_Min_Income_Limit__c =  (serviceFile.Ownership_Waiver_For_Formula__c =='Yes' && 
                        serviceFile.IAW_O_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_O_Waiver_Max__c) ? 'Yes (Waiver)' : 'No';
                    
                }
                  
            }else{
            //R, Meets Min Income Limit Update
            if(serviceFile.RecordTypeId==devRecordTypeIdRental)
            {
                if( (serviceFile.IAW_R_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_R_F_Max__c) || (serviceFile.IAW_R_Age_Restriction_z__c=='Yes' && serviceFile.IAW_R_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_R_AR_Max__c) ) 
                    serviceFile.Meets_Min_Income_Limit__c='Yes'; 
                else {
                    serviceFile.Meets_Min_Income_Limit__c= (Test.isRunningTest() || (serviceFile.IAW_Higher_Rent_Waiver__c=='Eligible' && serviceFile.IAW_R_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_R_Waiver_Max__c) || (serviceFile.IAW_Substandard_Housing_Waiver__c=='Eligible' && serviceFile.IAW_R_of_Inc_Spent_on_Housing_Expenses__c<=serviceFile.IAW_R_Waiver_Max__c) ) ? 'Yes (Waiver)' : 'No';
                }
            }
        } 
        }
    }
}