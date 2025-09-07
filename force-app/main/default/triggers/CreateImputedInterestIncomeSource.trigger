trigger CreateImputedInterestIncomeSource on HOMEtracker__Applicant_Asset__c (before insert, before update) {
  /*      set<id> setAssetIds = new set<id>();
    for (HOMEtracker__Applicant_Asset__c a : trigger.new) {
        
        //NO RELATED INCOME SOURCE, CREATE A NEW IMPUTED INTEREST INCOME SOURCE
        if (a.Create_Imputed_Interest_Income_Source__c == true && a.Income_Source_ID__c == null) {
                                 
            // add the asset id to the set
            setAssetIds.add(a.id);
            
          /*  HOMEtracker__Income_Source__c isNew = new HOMEtracker__Income_Source__c (
                IAW_Income_Name__c = a.Imputed_Interest_Income_Name__c,
                HOMEtracker__Service_File__c = a.HOMEtracker__Service_File__c,
                Related_Asset_ID__c = a.Id,
                HOMEtracker__Income_Type__c = 'Interest from Asset',
                HOMEtracker__Pretax_Income_This_Year__c = a.Calculated_Interest__c,
                HOMEtracker__Date__c = a.HOMEtracker__Date__c,
                HOMEtracker__Employer_Business_Name__c = a.Name + ' ' + a.Account_Number_Text__c,
                PHA__Pay_Period__c = 'Annual',
                PHA__Employment_Status__c = 'This employment is finished',
                HOMEtracker__Employment_Start_Date__c = system.today(),
                HOMEtracker__Employment_End_Date__c = system.today(),
                HOMEtracker__Wage_Earner__c = a.HOMEtracker__Asset_Owner__c,
                IAW_Income_Earner__c = a.IAW_Asset_Owner__c,
                PHA__Household_Member__c = a.PHA__Household_Member__c,
                HOMEtracker__Verification_Type__c = 'Bank Statements',
                IAW_Verification_Type__c = 'Bank Statements',
                HOMEtracker__Income_Calculations__c = a.Imputed_Interest_Income_Calc_Notes__c
                   
            );       
            
            insert isNew;
            
            a.Income_Source_ID__c = isNew.Id;
            
            
        }                
        
        //RELATED INCOME SOURCE, UPDATE EXISTING IMPUTED INTEREST INCOME SOURCE - FUTURE PHASE
        else if (a.Create_Imputed_Interest_Income_Source__c == true && a.Income_Source_ID__c != null) {
            a.addError('There is already an imputed interest income source associated with this asset. Please update the amount and calculations manaully. The new values can be copied from the "Calculated Interest" and "Imputed Interest Income Calc Notes" fields on this asset.');
       }
    }
    */
    
    // if the set of asset ids is not null call the handler method
  //  if( setAssetIds != null && setAssetIds.size() > 0 ){
 //       if(!System.isBatch() && !System.isFuture() && !System.isScheduled() && !System.isQueueable()  )
  //      ImputedInterestIncomeSourceHandler.runImputedIncomeClaculation(setAssetIds);
  //  }    
        
}