trigger PreApplicantTrigger on PreApplicants__c (after insert,after update,before update) {
    system.debug('Trigger fired');

        List<PreApplicants__c> lstPreApplicant = trigger.new;
        CGPH_Triggers_Custom_Settings__c cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        if(cgphSettings != null && cgphSettings.Pre_Applicant_Profile_Updates__c )
        {
            system.debug('trigger.isInsert'+trigger.isInsert+' trigger.isUpdate '+trigger.isUpdate +'  trigger.isAfter '+trigger.isAfter+' trigger.isBefore'+trigger.isBefore);
           if((trigger.isInsert || trigger.isUpdate ) && trigger.isAfter)// && checkRecursive.runOnce() == true)
           {
                // check the criteria in the method and send email if there is any 
                // changes which affect pre applicants preferences
                // so when email limit is exhuasted this method is turned off
                // but trigger mark all the pre applicant so that criteria check is 
                // enforced on them             
                system.debug('::Update Trigger Called::');
               
               PreApplicants__c preApplicant = new PreApplicants__c();
               preApplicant = trigger.new[0];
               
               PreApplicants__c oldPreApplicant = new PreApplicants__c();
               
               if( trigger.isUpdate )
               {
                   oldPreApplicant = (PreApplicants__c)Trigger.oldMap.get(preApplicant.id);
                   
                   // if there is change in the criteria field whci can trigger email
                   // then only check for email limit 
                   
                   if (oldPreApplicant.Household_Members_55__c != preApplicant.Household_Members_55__c || oldPreApplicant.Rental_Interest__c != preApplicant.Rental_Interest__c ||
                  oldPreApplicant.Purchase_Interest__c != preApplicant.Purchase_Interest__c || oldPreApplicant.Section_8__c != preApplicant.Section_8__c ||
                  oldPreApplicant.Household_Size__c != preApplicant.Household_Size__c || oldPreApplicant.Annual_Income__c != preApplicant.Annual_Income__c ||
                  oldPreApplicant.Monthly_Other_Assistance__c != preApplicant.Monthly_Other_Assistance__c || oldPreApplicant.AR_Properties_Only__c != preApplicant.AR_Properties_Only__c  ||
                  oldPreApplicant.Household_Disabled__c != preApplicant.Household_Disabled__c || oldPreApplicant.Substandard_Overcrowded_Housing__c != preApplicant.Substandard_Overcrowded_Housing__c ||
                  oldPreApplicant.Household_Size__c  != preApplicant.Household_Size__c ||
                  oldPreApplicant.Live_Work_Regions__c != preApplicant.Live_Work_Regions__c ||
                  oldPreApplicant.Annual_Income__c != preApplicant.Annual_Income__c ||
                  oldPreApplicant.Monthly_Other_Assistance__c != preApplicant.Monthly_Other_Assistance__c ||
                  oldPreApplicant.AR_Properties_Only__c != preApplicant.AR_Properties_Only__c ||
                  oldPreApplicant.Section_8__c != preApplicant.Section_8__c ||
                  oldPreApplicant.Max_Down_Payment__c != preApplicant.Max_Down_Payment__c ||
                  preApplicant.Most_Recent_Update__c == null
                  )
                  {
                    PreApplicantTriggerHandler.getEmailLimits(lstPreApplicant.size(),UserInfo.getSessionId());
                  }
              }               
                PreApplicantTriggerHandler objPreapplicantHandler = new PreApplicantTriggerHandler ();
               
               // if it is insert or update trigger and mp id has value in it
               
               list<PreApplicants__c> lstPreappsTriggered = new list<PreApplicants__c>();
               
               for( PreApplicants__c preApp : lstPreApplicant )
               {
                   PreApplicants__c oldPreApp = new PreApplicants__c();
                   if( trigger.isUpdate )
                       oldPreApp = (PreApplicants__c)Trigger.oldMap.get(preApplicant.id);
                       
                   if(Trigger.isInsert || ( Trigger.isUpdate && (oldPreApp.Active_MP_s__c == preApp.Active_MP_s__c &&  oldPreApp.Inactive_Ineligible_MP_s__c == preApp.Inactive_Ineligible_MP_s__c) ))
                   {
                    if( preApp.MP_Update__c == true && preApp.MP_Id__c != null )
                    {
                        lstPreappsTriggered.add(preApp);
                    }
                    else if(  preApp.MP_Id__c == null )
                    {
                        lstPreappsTriggered.add(preApp);
                    }
                   } 
                    
               }
               
               if(lstPreappsTriggered != null && lstPreappsTriggered.size() > 0 )
               {
                   if( (checkRecursive.runOnce() == true) || Test.isRunningTest() ) 
                        objPreapplicantHandler.verifyPreApplicantCriteria(lstPreApplicant);
                }    
           }
        }
        else
        { 
            // now pre applicant trigger is off for criteria checks so we need to update check box
            // on the pre applicant that this pre applicant is not evaluted for the criteria
            if(trigger.isBefore &&  ( trigger.isUpdate || trigger.isInsert ))
            {
                PreApplicantTriggerHandler.checkImpFieldChanges(lstPreApplicant); 
            }            
        }   
        
        
        
        
        // encode id trigger
        
        if( (trigger.isAfter && trigger.isInsert) || ( trigger.isBefore && trigger.isUpdate) )
        {
        
            //List<PreApplicants__c> lstPreApplicant = trigger.new;
            cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
            if(cgphSettings != null && cgphSettings.Pre_Applicant_Id_Encode__c == true ){
                if(trigger.isInsert || (trigger.isUpdate && trigger.isBefore)){
                    PreAppEncodeIdTriggerHandler objPreappHandler = new PreAppEncodeIdTriggerHandler ();
                    objPreappHandler.updatePreAppEncodedId();
                }
             }
        }
        
        
}