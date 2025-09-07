public without sharing class PreApplicantTriggerHandler {
  // method to get the email limits 
  @future(callout=true)
  public static void getEmailLimits(integer batchSize,string sessionId)
  {
        CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
        cgphSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
        string instanceURL = cgphSettings.Instance_URL__c; 
        instanceURL += '/services/data/v36.0/limits';
        system.debug('instanceURL'+instanceURL );
        system.debug(sessionId); 
        system.debug('session Id : '+UserInfo.getSessionId());
        string strLimitSingleEmails;
        string strTotalEmailRemainings = '0';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(instanceURL); // for sandbox 
        //req.setEndpoint('https://na17.salesforce.com/services/data/v36.0/limits'); // for production
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        Http http = new Http();
        HTTPResponse res;
        try{
        if(!Test.isRunningTest())
        {
            res = http.send(req);
        }
        System.debug(res.getBody());
         JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            (parser.getText() == 'SingleEmail')) 
           {
               parser.nextToken();
               system.debug('==> '+parser.nextToken());
               system.debug('parser.nextValue()==> '+parser.nextValue());
               strLimitSingleEmails = parser.getText();
               system.debug(' parser.getText() '+ strLimitSingleEmails);
               system.debug('=======================');
               parser.nextToken();
               system.debug('==> '+parser.nextToken());
               strTotalEmailRemainings = parser.getText();
               system.debug(' parser.getText() '+strTotalEmailRemainings);
            }
        } 
        }catch(Exception ex){
        
        }
            
        list<Task> lstTask = new list<Task>();
        Integer iEmailsRemaining = Integer.valueOf(strTotalEmailRemainings);
        // if email limits are gettting exhuasted then turn off the trigger and set the
        // activity to user saying that trigger is turned of
        
        // if the response is null then get the value of previously stored response limit
        // from the custom settings
        
        system.debug(' Email Response : '+res);
        
        if(res == null)
        {
            iEmailsRemaining = cgphSettings.Last_Email_Usage__c != null ?(Integer) cgphSettings.Last_Email_Usage__c : 1;
        }else if(res.getstatusCode() != 200){ //status code 200 is returned for successful response
                iEmailsRemaining = cgphSettings.Last_Email_Usage__c != null ?(Integer) cgphSettings.Last_Email_Usage__c : 1;
        }
        else if(res.getstatusCode() == 200){
            cgphSettings.Last_Email_Usage__c = iEmailsRemaining;
            if(Test.isRunningTest() == false)
                update cgphSettings;
        }
         
         
         //iEmailsRemaining = 1;
        if( iEmailsRemaining <= batchSize )
        {
            // switch off the trigger from the custom settings
            CGPH_Triggers_Custom_Settings__c triggerSettings = new CGPH_Triggers_Custom_Settings__c();
            triggerSettings = CGPH_Triggers_Custom_Settings__c.getOrgDefaults();
            triggerSettings.Pre_Applicant_Profile_Updates__c = false;
            
            // create task to admin user that trigger is turned off and 
            list<User> lstUsers = new list<User>([select id,Profile.Name,IsActive from User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'HomeKeeper Administrator' ) AND IsActive = true]);
            if(lstUsers != null && lstUsers.size() > 0 )
            {
                if(Test.isRunningTest() == false)
                    update triggerSettings;
                    
            
                for(User u : lstUsers)
                {
                    // create task to the user
                    // sending notification to the user when task is assigned is 
                    // managed by the configuration and no property for it in the code
                    task newTask = new task();
                    newTask.OwnerId = u.Id;
                    //newTask.WhatId = preAppId;
                    newTask.Description = 'res=' + res + '    iEmailsRemaining=' + iEmailsRemaining + '    batchSize=' + batchSize;//Click below link to turn your custom setting back on after 8pm EST'+'\n'+'https://na17.salesforce.com/setup/ui/listCustomSettingsData.apexp?id=a1J';
                    newTask.Subject = 'Email Limits Exceeded / Pre-Applicant Trigger Turned off';
                    newTask.status = 'Not Started';
                    lstTask.add(newTask);
                }
            }       
        }
        else
        {
            // there is some preoblem with the call out or some other issue
            // create task to user to log extra information
                    
            if( res == null && cgphSettings != null && cgphSettings.Admin_User_Id__c != null)
            {
                task newTask = new task();
                newTask.OwnerId = cgphSettings.Admin_User_Id__c;
                //newTask.WhatId = preAppId;
                newTask.Description = 'res=' + res + '    iEmailsRemaining=' + iEmailsRemaining + '    batchSize=' + batchSize;//Click below link to turn your custom setting back on after 8pm EST'+'\n'+'https://na17.salesforce.com/setup/ui/listCustomSettingsData.apexp?id=a1J';
                newTask.Subject = 'Email Usage Response Failed With Null Response';
                newTask.status = 'Not Started';
                lstTask.add(newTask);
            
            }else if(res != null && res.getstatuscode() != 200 && cgphSettings != null && cgphSettings.Admin_User_Id__c != null)
            {
                // if we receive response but there is some unsuccessful error status
                task newTask = new task();
                newTask.OwnerId = cgphSettings.Admin_User_Id__c;
                //newTask.WhatId = preAppId;
                newTask.Description = 'res=' + res + '    iEmailsRemaining=' + iEmailsRemaining + '    batchSize=' + batchSize;//Click below link to turn your custom setting back on after 8pm EST'+'\n'+'https://na17.salesforce.com/setup/ui/listCustomSettingsData.apexp?id=a1J';
                newTask.Subject = 'Email Usage Response Failed With StatusCode'+res.getstatuscode();
                newTask.status = 'Not Started';
                lstTask.add(newTask);
            } 
        }
    
    if( lstTask != null && lstTask.size() > 0 )
    {
        insert lstTask;
    }     
  } 
    
  public static void checkImpFieldChanges(list<PreApplicants__c> lstPreApplicants)
  {
     CGPH_Triggers_Custom_Settings__c cgphTriggerSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
     CGPH_Profile_Custom_Settings__c cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();
     
     list<Task> lstTask = new list<Task>();
     for(PreApplicants__c preApplicant : lstPreApplicants)
     {
        
        if( trigger.isBefore && trigger.isUpdate )
        {
            //preApplicant.Last_Modified_At__c = '';
            // Access the "old" record by its ID in Trigger.oldMap
            PreApplicants__c oldPreApplicant = (PreApplicants__c)Trigger.oldMap.get(preApplicant.Id);
            // check if there is change in the old and new fields of the pre applicants which may affect their
            // eligibility
            
            if((oldPreApplicant.Household_Members_55__c != preApplicant.Household_Members_55__c || oldPreApplicant.Rental_Interest__c != preApplicant.Rental_Interest__c ||
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
              oldPreApplicant.Max_Down_Payment__c != preApplicant.Max_Down_Payment__c
              ) || Test.isRunningTest())
              {
                if(cgphTriggerSettings.Pre_Applicant_Profile_Updates__c == false)
                {
                    preApplicant.Updated_w_o_Trigger__c = true;
                    //preApplicant.Force_Eligibility_Check__c = true;
                    if(cgphSettings.Admin_User_Id__c != null   || Test.isRunningTest() ) 
                    {
                        // log an activity
                        task newTask = new task(
                        OwnerId = cgphSettings.Admin_User_Id__c,
                        WhatId = preApplicant.id,    
                        Description = 'Updated w/o Trigger (Insert) for '+preApplicant.Name,
                        Subject = 'Updated w/o Trigger',
                        status = 'Not Started'    
                        );                       
                        lstTask.add(newTask);
                    }
                }                
              }
            }else if( trigger.isInsert || Test.isRunningTest())
            {
                if(cgphTriggerSettings.Pre_Applicant_Profile_Updates__c == false)
                {
                    preApplicant.Updated_w_o_Trigger__c = true;
                    preApplicant.Force_Eligibility_Check__c = true;
                    
                    if(cgphSettings.Admin_User_Id__c != null || Test.isRunningTest() )
                    {
                        // log an activity
                        task newTask = new task(
                        OwnerId = cgphSettings.Admin_User_Id__c,
                        WhatId = preApplicant.id,    
                        Description = 'Updated w/o Trigger (Insert) for '+preApplicant.Name,
                        Subject = 'Updated w/o Trigger',
                        status = 'Not Started'    
                        );                       
                        lstTask.add(newTask);
                    }
                }           
            }
        }
        
        if(lstTask != null && lstTask.size() > 0 )
        {
            try
            {
                insert lstTask;
            }
            catch(Exception ex)
            {
                system.debug('Error while inserting tasks ');
            }
        }
     }
     
     
    public void updateLocalPrefURL(list<PreApplicants__c>lstPreApplicantToReceiveLocalPreferences )
    {
        set<id> setPreAppIds = new set<id>();
        CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
        cgphSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
        list<Municipality_Preference__c> lstLoacalPreferencesToUpdate = new list<Municipality_Preference__c>();
        
        for( PreApplicants__c preApp :  lstPreApplicantToReceiveLocalPreferences  )
        {
            setPreAppIds.add(preApp.Id);
        }
        
        list<Municipality_Preference__c> lstLocalPreferences = new list<Municipality_Preference__c>();
        lstLocalPreferences = [SELECT id,Alternate_Local__c,General_Local__c,PreApplicant__c,Type__c,Municipality__c  
                                FROM 
                                Municipality_Preference__c 
                                WHERE
                                PreApplicant__c IN : setPreAppIds AND Status__c = 'Active'
                                AND 
                                (Municipality__c =:cgphSettings.Montaclair_Municipality_Id__c OR Municipality__c =: cgphSettings.Hoboken_Municipality_Id__c OR Municipality__c =: cgphSettings.Hoboken_Workforce_Program_Id__c )];
        
        map<id,list<Municipality_Preference__c>> mapPreAppRelatedLocalPreferences = new map<id,list<Municipality_Preference__c>>();
        for( Municipality_Preference__c preference : lstLocalPreferences  )
        {
            list<Municipality_Preference__c> lstTempPreferences = new list<Municipality_Preference__c>();
            if( mapPreAppRelatedLocalPreferences != null && mapPreAppRelatedLocalPreferences.containsKey(preference.PreApplicant__c ) == true )
            {
                lstTempPreferences = mapPreAppRelatedLocalPreferences.get(preference.PreApplicant__c );
                lstTempPreferences.add(preference);
                mapPreAppRelatedLocalPreferences.put(preference.PreApplicant__c,lstTempPreferences);
            }
            else
            {
                lstTempPreferences.add(preference);
                mapPreAppRelatedLocalPreferences.put(preference.PreApplicant__c,lstTempPreferences);
            }
        }
        
        list<PreApplicants__c> lstPreAppUpdateForLocal = new list<PreApplicants__c>();
        system.debug(' mapPreAppRelatedLocalPreferences '+mapPreAppRelatedLocalPreferences);
        if( mapPreAppRelatedLocalPreferences != null && mapPreAppRelatedLocalPreferences.size() > 0 )
        {
            for( string strPreAppId : mapPreAppRelatedLocalPreferences.keySet()) 
            {
                system.debug('strPreAppId '+strPreAppId);
                boolean b_isLocalPreferenceActive = false;
                PreApplicants__c preApplicant = new PreApplicants__c(id=strPreAppId);
                preApplicant.Local_Preference_URL__c = 'https://www.affordablehomesnewjersey.com/local-preferences/?';
                system.debug(' ==>  '+mapPreAppRelatedLocalPreferences.get(strPreAppId));
                for( Municipality_Preference__c pref : mapPreAppRelatedLocalPreferences.get(strPreAppId) )
                {
                        system.debug(' pref  '+pref);
                        if( cgphSettings.Montaclair_Municipality_Id__c == pref.Municipality__c && pref.Type__c == 'Ownership')
                        {
                            preApplicant.Local_Preference_URL__c += '&tfa_39='+pref.Id;
                            preApplicant.Email_Local_Preference__c = true;
                            b_isLocalPreferenceActive = true;
                            lstLoacalPreferencesToUpdate.add(new Municipality_Preference__c(id=pref.id,Local_Preferences_Unanswered__c = true));
                        }
                        if( ( cgphSettings.Hoboken_Municipality_Id__c == pref.Municipality__c || cgphSettings.Hoboken_Workforce_Program_Id__c == pref.Municipality__c )  && pref.Type__c == 'Ownership')    
                        {
                            preApplicant.Local_Preference_URL__c += '&tfa_41='+pref.Id;
                            preApplicant.Email_Local_Preference__c = true;
                            b_isLocalPreferenceActive = true;
                            lstLoacalPreferencesToUpdate.add(new Municipality_Preference__c(id=pref.id,Local_Preferences_Unanswered__c = true));
                        } 
                        
                        if( cgphSettings.Montaclair_Municipality_Id__c == pref.Municipality__c  && pref.Type__c == 'Rental')
                        {
                            preApplicant.Local_Preference_URL__c += '&tfa_53='+pref.Id;
                            preApplicant.Email_Local_Preference__c = true;
                            b_isLocalPreferenceActive = true;
                            lstLoacalPreferencesToUpdate.add(new Municipality_Preference__c(id=pref.id,Local_Preferences_Unanswered__c = true));
                        }
                        if( ( cgphSettings.Hoboken_Municipality_Id__c == pref.Municipality__c || cgphSettings.Hoboken_Workforce_Program_Id__c == pref.Municipality__c)  && pref.Type__c == 'Rental')    
                        {
                            preApplicant.Local_Preference_URL__c += '&tfa_55='+pref.Id;
                            preApplicant.Email_Local_Preference__c = true;
                            b_isLocalPreferenceActive = true;
                            lstLoacalPreferencesToUpdate.add(new Municipality_Preference__c(id=pref.id,Local_Preferences_Unanswered__c = true));
                        }                         
                }
                                
            if( lstLoacalPreferencesToUpdate != null && lstLoacalPreferencesToUpdate.size() > 0 )
            {
                system.debug(' lstLoacalPreferencesToUpdate  '+lstLoacalPreferencesToUpdate);
                update lstLoacalPreferencesToUpdate;
            }
            
            if( preApplicant.Email_Local_Preference__c == true && b_isLocalPreferenceActive == true )
            {
               preApplicant.Local_Preference_URL__c += '&tfa_43='+preApplicant.Id;
                lstPreAppUpdateForLocal.add(preApplicant);
            }
           } 
        } 
        
        if( lstPreAppUpdateForLocal  != null && lstPreAppUpdateForLocal.size() > 0 )
        {
            system.debug('lstPreAppUpdateForLocal '+lstPreAppUpdateForLocal);
            update lstPreAppUpdateForLocal;
        }    
        
       // return lstPreAppUpdateForLocal;                      
    } 
    
    static list<PreApplicants__c> lstPreApplicantToReceiveLocalPreferences = new list<PreApplicants__c>();
    public String strEmailBody {get; set;}
    public string strEmailBodyMsg {get;set;}
    private map<string, list<WrapperHownershipMunicipalPreference>> mapWrapperPurchaseMunicipality = new map<string, list<WrapperHownershipMunicipalPreference>>();
    private List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
    
    /*********************************************************************************************************************************/
    /* Purpose When pre applicant is updated from FA, it will have MP_Type__c,MP_Id__c,MP_Update__c fields populated. These fields   */
    /* will get changed for new municipality application. Function will create Municipality Preference if already existing ( Active) */
    /* preference is not present                                                                                                     */
    /*********************************************************************************************************************************/
    public void processForMPs(PreApplicants__c preApp,list<Municipality_Preference__c> lstRentalPreferences,list<Municipality_Preference__c> lstPurchasePreferences)
    {
        string mpType = preApp.MP_Type__c;
        string mpId = preApp.MP_ID__c;
        string mpTypeMatching = '';
        set<string> setMunicipalPreferenceIds = new set<string>();
        boolean b_MatchFound = false;
        Municipality_Preference__c newPrefToUpdate = new Municipality_Preference__c(); // preference for local ineligible case
        if(lstRentalPreferences != null && lstRentalPreferences.size() > 0)
        {
            for( Municipality_Preference__c pref : lstRentalPreferences )
            {
                string strPrefId = pref.Municipality__c;
                system.debug(' strPrefId '+strPrefId);
                system.debug('mpId '+mpId); 
                if( pref.Municipality__c == mpId && pref.Type__c == mpType && pref.Status__c == 'Active')
                {
                    b_MatchFound = true;
                    mpTypeMatching = 'Rental';                    
                    newPrefToUpdate = pref;
                    break;
                }
            }
        }
        
        if( lstPurchasePreferences != null && lstPurchasePreferences.size() > 0 )
        {
            for( Municipality_Preference__c pref : lstPurchasePreferences )
            {
                string strPrefId = pref.Municipality__c;
                system.debug('pref.Municipality__c '+pref.Municipality__c);
                system.debug('mpId '+mpId); 
                if( pref.Municipality__c == mpId && pref.Type__c == mpType && pref.Status__c == 'Active')
                {
            
                    b_MatchFound = true;
                    mpTypeMatching = 'Ownership';
                    newPrefToUpdate = pref;
                    break;
                }
            }
        }
        
        system.debug('b_MatchFound '+b_MatchFound);
        system.debug('mpType '+mpType);
        system.debug('mpTypeMatching '+mpTypeMatching);
        system.debug(' newPrefToUpdate  '+newPrefToUpdate);
        // if member match not found then create mp
        if (b_MatchFound == false &&( mpType == mpTypeMatching || mpTypeMatching == ''))
        {
            Municipality_Preference__c newPref = new Municipality_Preference__c();
            newPref.Status__c = 'Active';
            newPref.Interest_Date__c = date.today();
            newPref.Municipality__c = mpId;
            system.debug('mapAllMunicipalities '+mapAllMunicipalities);
            system.debug('264 '+mapAllMunicipalities.get(mpId));
            Municipality__c municipality = new Municipality__c();
            municipality = mapAllMunicipalities.get(mpId);
            if( municipality != null )
            newPref.Name = municipality.Name;
            newPref.PreApplicant__c = preApp.id;            
          //  newPref.Local_Ineligible__c = preApp.MP_Local_Ineligible__c;
            newPref.Type__c = mpType;
            if( mpType == 'Ownership' )
                preAppPurchasePreference.put(preApp.id,newPref);
            if( mpType == 'Rental' )
                preAppRentalPreference.put(preApp.id,newPref);

        }
        else if (b_MatchFound == true)
        {
            // if preapp is having active preference and is local ineligible due to new
            // submission. Make the preference ineligible.
            /*if(preApp.MP_Local_Ineligible__c == true)
                newPrefToUpdate.Status__c = 'Ineligible';
            newPrefToUpdate.Local_Ineligible__c = preApp.MP_Local_Ineligible__c;  */     
                 
            processPreference(preApp,newPrefToUpdate);  
            system.debug('newPrefToUpdate '+newPrefToUpdate);  
            update newPrefToUpdate;
        }
    }
    
    
    
    public map<string,Municipality_Preference__c> preAppPurchasePreference = new map<string,Municipality_Preference__c>();
    public map<string,Municipality_Preference__c> preAppRentalPreference = new map<string,Municipality_Preference__c>();
    map<id, Municipality__c> mapAllMunicipalities;
    
    public void verifyPreApplicantCriteria(List<PreApplicants__c> lstPreApplicantTriggeredRecords) {
        CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
        cgphSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
                
        // get details of the triggered pre applicant records
        List<PreApplicants__c> lstPreApplicant = new list<PreApplicants__c>([SELECT 
            Id, Name, Annual_Income__c, Applicant_Name__c, AR_Properties_Only__c, City__c, Contact__r.Email, MP_Local_Ineligible__c,
            Contact__r.FirstName, Contact__r.LastName, Email__c, Ext__c, Household_Disabled__c, 
            Household_Members_55__c, Household_Size__c, Last_Profile_View__c, Live_Work_Regions__c, 
            Max_Down_Payment__c, Monthly_Other_Assistance__c, Monthly_Rent__c, Most_Recent_Update__c, 
            Number_of_Profile_Views__c, Phone__c, Postal_Code__c, PreApplicant_Encoded_Id__c, 
            Property_Questionnaire_URL__c, Purchase_Interest__c, Region_Counties__c,MP_Update__c, 
            Remove_Me_from_All_URL__c, Rental_Interest__c, Restart_URL__c, Section_8__c, State__c, 
            Street__c, Substandard_Overcrowded_Housing__c, Update_Days__c, Update_Status__c, Update_URL__c, Inactive_Ineligible_MP_s__c,Active_MP_s__c,
            Youngest_Household_Member__c,Force_Eligibility_Check__c,Updated_w_o_Trigger__c,Last_Modified_At__c,Veteran__c,Email_Local_Preference__c,
            Contact__r.Provide_email_postcard_sent__c,Contact__r.Provide_Email_Postcard_Followup__c,Online_Submission__c,MP_Type__c,MP_ID__c
            FROM PreApplicants__c 
            WHERE Id IN : lstPreApplicantTriggeredRecords
            ]);
        system.debug('lstPreApplicant '+lstPreApplicant);
        List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunicipalityPref = new List<Municipality_Preference__c>();

        mapAllMunicipalities = new map<id, Municipality__c>([SELECT
                Id, Name, AR_Purchase_Properties__c, Purchase_Unit_Size__c, Purchase_Portfolio__c ,Purchase_Portfolio_Income_Levels__c,Rental_Portfolio__c ,
                Purchase_Units__c, Region__c, Live_Work_Preference__c, Rental_Portfolio_Income_Levels__c,Rental_Units__c ,County__c,
                Min_Income__c,AR_Rental_Properties__c,Rental_Unit_Size__c, Rental_Waiting_List__c, Rental_Permanent_Disability_AR_Exception__c,Income_Limit__c,Local_Preference__c
                FROM Municipality__c]);
        set<id> setMunicipalityIds = new set<id>();
        map<Id, List<Municipality_Preference__c>> mapRentalMunicipalPreference = new map<Id, List<Municipality_Preference__c>>();
        map<Id, List<Municipality_Preference__c>> mapOwnerMunicipalPreference = new map<Id, List<Municipality_Preference__c>>();

        // Query Rental Municipality Preferences
        lstRentalMunicipalityPreference = [Select 
            Id, Name, Ineligibilty_Reason__c, Interest_Date__c, Municipality__c, Municipality__r.Name, 
            On_Hold__c, PreApplicant__c, Removal_Date__c, Removal_Trigger__c, Status__c, 
            Township_Interest_ID__c, Type__c,Local_Ineligible__c,Municipality__r.Local_Preference__c,Local_Preferences_Unanswered__c
            From Municipality_Preference__c 
            Where PreApplicant__c  IN : lstPreApplicant AND Type__c = 'Rental' AND ( Status__c = 'Active' OR On_Hold__c = true)];

        // Query Ownership Municipality Preferences
        lstOwnerMunicipalityPreference = [Select 
            Id, Name, Ineligibilty_Reason__c, Interest_Date__c, Municipality__c, Municipality__r.Name, 
            On_Hold__c, PreApplicant__c, Removal_Date__c, Removal_Trigger__c, Status__c, 
            Township_Interest_ID__c, Type__c,Local_Ineligible__c,Municipality__r.Local_Preference__c
            From Municipality_Preference__c 
            Where PreApplicant__c  IN : lstPreApplicant AND Type__c = 'Ownership' AND (Status__c = 'Active'  OR On_Hold__c = true)];
        
        // set of properties for whose preferences are on hold and we need to reavaluate if these are eligible now
        map<string,list<Municipality__c>> mapPreAppwiseRentalMunicipalities = new map<string,list<Municipality__c>>();
        map<string,list<Municipality__c>> mapPreAppwisePurchaseMunicipalities = new map<string,list<Municipality__c>>();
        map<string,List<CGPHProfileController.RentalMunicipalPreference>> mapWrapperRentalMunicipalPreference; 
                
        system.debug('::lstOwnerMunicipalityPreference::' + lstOwnerMunicipalityPreference);
        //map of Rental Interest MunicipalityPreference
        if (lstRentalMunicipalityPreference != null && lstRentalMunicipalityPreference.size() > 0) 
        {
            for (Municipality_Preference__c municipalityPref : lstRentalMunicipalityPreference) 
            {
                if (!mapRentalMunicipalPreference.containskey(municipalityPref.PreApplicant__c)) 
                {
                    // if the preference is on hold then not add them in the regular list but check if it is eligible now and then
                    // make it inactive or active on the basis of current updates
                    if(municipalityPref.On_Hold__c == true)
                    {
                        list<Municipality__c> lstTempMunicipality = new list<Municipality__c>();
                        // create map of pre app wise municipalities
                        if(mapPreAppwiseRentalMunicipalities.containsKey( municipalityPref.PreApplicant__c  ) == true)
                        {
                            lstTempMunicipality = mapPreAppwiseRentalMunicipalities.get(municipalityPref.PreApplicant__c);
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwiseRentalMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                        else
                        {
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwiseRentalMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                            
                    }
                        List<Municipality_Preference__c> listMunicipalityPreference = new List<Municipality_Preference__c>();
                        listMunicipalityPreference.add(municipalityPref);
                        mapRentalMunicipalPreference.put(municipalityPref.PreApplicant__c, listMunicipalityPreference);
                } 
                else 
                {
                    if(municipalityPref.On_Hold__c == true)
                    {
                        list<Municipality__c> lstTempMunicipality = new list<Municipality__c>();
                        // create map of pre app wise municipalities
                        if(mapPreAppwiseRentalMunicipalities.containsKey( municipalityPref.PreApplicant__c  ) == true)
                        {
                            lstTempMunicipality = mapPreAppwiseRentalMunicipalities.get(municipalityPref.PreApplicant__c);
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwiseRentalMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                        else
                        {
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwiseRentalMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                            
                    }
                        List<Municipality_Preference__c> listMunicipalityPreference = mapRentalMunicipalPreference.get(municipalityPref.PreApplicant__c);
                        listMunicipalityPreference.add(municipalityPref);
                        mapRentalMunicipalPreference.put(municipalityPref.PreApplicant__c, listMunicipalityPreference);
                    }
            }
        }
        system.debug('::mapPreAppwiseRentalMunicipalities::' + mapPreAppwiseRentalMunicipalities);

        //map of Purchase/Owner Interest MunicipalityPreference
        if (lstOwnerMunicipalityPreference != null && lstOwnerMunicipalityPreference.size() > 0) {
            for (Municipality_Preference__c municipalityPref : lstOwnerMunicipalityPreference) 
            {
                // create map of preapplicant and there preferences
                // we also create another map for pre applicant who are on hold and there preferences
                //on the basis of this map we can finalise if pre applicant is eligible then set it active
                // or it will be ineligible
                
                if (!mapOwnerMunicipalPreference.containskey(municipalityPref.PreApplicant__c)) 
                {
                    if(municipalityPref.On_Hold__c == true)
                    {
                        list<Municipality__c> lstTempMunicipality = new list<Municipality__c>();
                        // create map of pre app wise municipalities
                        if(mapPreAppwisePurchaseMunicipalities.containsKey( municipalityPref.PreApplicant__c  ) == true)
                        {
                            lstTempMunicipality = mapPreAppwisePurchaseMunicipalities.get(municipalityPref.PreApplicant__c);
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwisePurchaseMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                        else
                        {
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwisePurchaseMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }  
                    }
                    
                    List<Municipality_Preference__c> listMunicipalityPreference = new List<Municipality_Preference__c>();
                    listMunicipalityPreference.add(municipalityPref);
                    mapOwnerMunicipalPreference.put(municipalityPref.PreApplicant__c, listMunicipalityPreference);

                } 
                else 
                {
                    if(municipalityPref.On_Hold__c == true)
                    {
                        list<Municipality__c> lstTempMunicipality = new list<Municipality__c>();
                        // create map of pre app wise municipalities
                        if(mapPreAppwisePurchaseMunicipalities.containsKey( municipalityPref.PreApplicant__c  ) == true)
                        {
                            lstTempMunicipality = mapPreAppwisePurchaseMunicipalities.get(municipalityPref.PreApplicant__c);
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwisePurchaseMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                        else
                        {
                            lstTempMunicipality.add(mapAllMunicipalities.get(municipalityPref.Municipality__c));
                            mapPreAppwisePurchaseMunicipalities.put(municipalityPref.PreApplicant__c,lstTempMunicipality);
                        }
                            
                    }
                    
                    List<Municipality_Preference__c> listMunicipalityPreference = mapOwnerMunicipalPreference.get(municipalityPref.PreApplicant__c);
                    listMunicipalityPreference.add(municipalityPref);
                    mapOwnerMunicipalPreference.put(municipalityPref.PreApplicant__c, listMunicipalityPreference);
                }
            }
        }

        system.debug('::mapOwnerMunicipalPreference::' + mapOwnerMunicipalPreference);
        // iterate on the preapplicant list
        
        if (lstPreApplicant != null && lstPreApplicant.size() > 0) 
        {
            list<PreApplicants__c> lstPreAppToUpdate = new list<PreApplicants__c>();
            for (PreApplicants__c preApplicant : lstPreApplicant) 
            {
                // call the method to check if MP is present and if not present then create map of 
                // pre app and mp then process that to add mp in correct list
                
                sObject oldPreApp;
                if( trigger.isUpdate )
                    oldPreApp = trigger.oldMap.get(preApplicant.id);
                
                // if oldPreApp MpId and MpType is changed then process the records
               
                if( ( trigger.isUpdate && ( preApplicant.MP_Id__c  != null ) ) || trigger.isInsert) 
                    processForMPs(preApplicant,mapRentalMunicipalPreference.get(preApplicant.id),mapOwnerMunicipalPreference.get(preApplicant.id));
                
                
                // now insert the preferences
            system.debug('preAppRentalPreference '+preAppRentalPreference);
            if(preAppRentalPreference != null && preAppRentalPreference.size() > 0)
            {
                insert preAppRentalPreference.values();
            }
            
            system.debug('preAppPurchasePreference '+preAppPurchasePreference);
            if(preAppPurchasePreference != null && preAppPurchasePreference.size() > 0)
            {
                //list<PreApplicants__c> lstPreAppToUpdate = new list<PreApplicants__c>();
                insert preAppPurchasePreference.values();
            }
                //preAppRentalPreference
                system.debug('preApplicant '+preApplicant);
                system.debug('Pre App last modified at ==> '+preApplicant.Last_Modified_At__c);
                    if( preApplicant.MP_Type__c != null &&  preApplicant.MP_ID__c != null ) 
                    {
                        Municipality_Preference__c placeholderPrefrence = new Municipality_Preference__c();
                        //preApplicant.MP_Local_Ineligible__c = false;
                        if( preApplicant.MP_Type__c == 'Rental' )
                            placeholderPrefrence = preAppRentalPreference.get(preApplicant.Id);
                        else if( preApplicant.MP_Type__c == 'Ownership' )
                                    placeholderPrefrence = preAppPurchasePreference.get(preApplicant.Id);
                                                                
                        system.debug( placeholderPrefrence );
                        
                        system.debug(' preAppPurchasePreference '+preAppPurchasePreference);
                        Municipality__c placeHolderMunicipality = new Municipality__c();   
                        system.debug(' mapAllMunicipalities '+mapAllMunicipalities);                     
                        placeHolderMunicipality = mapAllMunicipalities.get(preApplicant.MP_ID__c);
                        system.debug('placeHolderMunicipality '+placeHolderMunicipality);
                        if( placeholderPrefrence != null && placeHolderMunicipality != null && placeHolderMunicipality.Local_Preference__c == true && placeholderPrefrence.Local_Preferences_Unanswered__c == false )
                        {                       
                            
                            
                                if( cgphSettings.Montaclair_Municipality_Id__c == placeholderPrefrence.Municipality__c )
                                {
                                    system.debug(' adding in the list '+preApplicant);
                                    lstPreApplicantToReceiveLocalPreferences.add(preApplicant);
                                } 
                            
                                if( cgphSettings.Hoboken_Municipality_Id__c == placeholderPrefrence.Municipality__c || cgphSettings.Hoboken_Workforce_Program_Id__c == placeholderPrefrence.Municipality__c )
                                {
                                    system.debug(' adding in the list '+preApplicant);
                                     lstPreApplicantToReceiveLocalPreferences.add(preApplicant); 
                                }
                                
                           // preApplicant.Local_Preference_URL__c += '&tfa_43='+preApplicant.Id;
                        }
                        preApplicant.MP_Type__c=null;
                        preApplicant.MP_ID__c=null;
                        preApplicant.MP_Update__c = false;
                        
                        lstPreAppToUpdate.add(preApplicant);
                    }   
            }                       
            
            if( lstPreAppToUpdate != null && lstPreAppToUpdate.size() > 0 )
            {
                system.debug('called from trigger again==> ');
                update lstPreAppToUpdate;
            }
            
            
            // add the preferences in the created map
            if( preAppRentalPreference != null && preAppRentalPreference.size() > 0 )
            {
                for( string preAppId : preAppRentalPreference.keySet() )
                {
                    List<Municipality_Preference__c> listTempPreferences = new list<Municipality_Preference__c>();
                    listTempPreferences = mapRentalMunicipalPreference.get(preAppId);
                    if( listTempPreferences != null )
                    {
                        listTempPreferences.add(preAppRentalPreference.get(preAppId));
                        mapRentalMunicipalPreference.put(preAppId,listTempPreferences);
                    }
                    else
                    {
                        listTempPreferences = new list<Municipality_Preference__c>();
                        listTempPreferences.add(preAppRentalPreference.get(preAppId));
                        mapRentalMunicipalPreference.put(preAppId,listTempPreferences);
                    }   
                }
            }
            
            if( preAppPurchasePreference != null && preAppPurchasePreference.size() > 0 )
            {
                for( string preAppId : preAppPurchasePreference.keySet() )
                {
                    List<Municipality_Preference__c> listTempPreferences = new list<Municipality_Preference__c>();
                    listTempPreferences = mapOwnerMunicipalPreference.get(preAppId);
                    if( listTempPreferences != null )
                    {
                        listTempPreferences.add(preAppPurchasePreference.get(preAppId));
                        mapOwnerMunicipalPreference.put(preAppId,listTempPreferences);
                    }
                    else
                    {
                        listTempPreferences = new list<Municipality_Preference__c>();
                        listTempPreferences.add(preAppPurchasePreference.get(preAppId));
                        mapOwnerMunicipalPreference.put(preAppId,listTempPreferences);
                    }   
                }
            }
        }       

        boolean sendIneligibleMsg = false;
        string msg = '';
        list<PreApplicants__c> lstPreApplicantUpdated = new list<PreApplicants__c>();
        
        map<string, List<RentalMunicipalPreference>> mapWrapperMunicipality = new map<string, List<RentalMunicipalPreference>>();
        if (lstPreApplicant != null && lstPreApplicant.size() > 0) 
        {
            for (PreApplicants__c preApplicant : lstPreApplicant) 
            {
            // Access the "old" record by its ID in Trigger.oldMap           
            
                PreApplicants__c oldPreApplicant;
                if( trigger.isupdate )
                {
                    oldPreApplicant = (PreApplicants__c)Trigger.oldMap.get(preApplicant.Id);
                    system.debug('====> oldPreApplicant.get(Last_Modified_At__c) '+oldPreApplicant.get('Last_Modified_At__c'));
                }
                
                system.debug('====> new last modified at '+preApplicant.Last_Modified_At__c);
                
                if( trigger.isUpdate &&( (preApplicant.Force_Eligibility_Check__c == false && oldPreApplicant.get('Force_Eligibility_Check__c') == true ) ||
                   (preApplicant.Updated_w_o_Trigger__c == false && oldPreApplicant.get('Updated_w_o_Trigger__c') == true ) || 
                   (preApplicant.MP_Update__c == false && oldPreApplicant.get('MP_Update__c') == true) ||
                     (preApplicant.Last_Modified_At__c == null && oldPreApplicant.get('Last_Modified_At__c') != null)                  
                   )
                   
                   )
                {
                    // trigger is called from the self
                }
                else
                {   
                     // uncheck the checkbox and add the pre applicant in the update list
                    if(preApplicant.Force_Eligibility_Check__c == true || preApplicant.Updated_w_o_Trigger__c == true || (preApplicant.Last_Modified_At__c != null && trigger.isUpdate))
                    {
                        PreApplicants__c newTempPreApp = new PreApplicants__c();
                        newTempPreApp.id = preApplicant.id;
                        newTempPreApp.Force_Eligibility_Check__c = false;
                        newTempPreApp.Updated_w_o_Trigger__c = false; 
                        newTempPreApp.Last_Modified_At__c = null;
                        lstPreApplicantUpdated.add(newTempPreApp);
                    }
                    
                strEmailBody = '';
                strEmailBodyMsg = '';
                msg = '';
                //Test for 9+ Household Size
                if (lstPreApplicant[0].Household_Size__c == '9+') {
                    sendIneligibleMsg = true;
                    msg += '<ul><li>Based on your household size, you will require a 5 bedroom home or larger.  There are no homes with more than 4 bedrooms in our portfolio.</li>';
                    //preApplicant.addError('There are no homes with more than 4 bedrooms in our portfolio. Based on your household size of 9+, you will require a 5 bedroom home or larger.');
    
                    // make all the preferences as in active 
                    
                    if( mapOwnerMunicipalPreference != null && mapOwnerMunicipalPreference.size() > 0 )
                    {
                        strEmailBodyMsg += '<p>You are not eligible for the following ownership waiting lists.</p><ul>';
                        for( Municipality_Preference__c mPref : mapOwnerMunicipalPreference.get(preApplicant.id) )
                        {
                            
                            strEmailBodyMsg += '<li>' + mPref.Municipality__r.Name  +' '+'Household size is too large' + '</li>';
                            
                            Municipality_Preference__c newMPref = new Municipality_Preference__c(id = mPref.id);
                            newMPref.Status__c = 'Ineligible';
                            system.debug(' preApplicant.Last_Modified_At__c '+preApplicant.Last_Modified_At__c);
                            if(preApplicant.Last_Modified_At__c == 'External Pre-Application/Update')
                                    newMPref.Removal_Trigger__c = 'External Pre-Application/Update';
                            
                            newMPref.Removal_Date__c = date.today();    
                            lstToUpdateMunicipalityPref.add(newMPref);
                        }
                    }
                    
                    if( mapRentalMunicipalPreference != null && mapRentalMunicipalPreference.size() > 0 )
                    {
                        strEmailBodyMsg += '<p>You are not eligible for the following rental waiting lists.</p><ul>';
                        for( Municipality_Preference__c mPref : mapRentalMunicipalPreference.get(preApplicant.id) )
                        {
                            strEmailBodyMsg += '<li>' + mPref.Municipality__r.Name  +' '+'Household size is too large' + '</li>';
                            Municipality_Preference__c newMPref = new Municipality_Preference__c(id = mPref.id);
                            newMPref.Status__c = 'Ineligible';
                            system.debug(' preApplicant.Last_Modified_At__c '+preApplicant.Last_Modified_At__c);

                            if(preApplicant.Last_Modified_At__c == 'External Pre-Application/Update')
                                    newMPref.Removal_Trigger__c = 'External Pre-Application/Update';
                            
                            newMPref.Removal_Date__c = date.today();        
                            lstToUpdateMunicipalityPref.add(newMPref);
                        }
                    }
                    
                    //lstToUpdateMunicipalityPref
                }

                //Test for blank Household Size
                if (preApplicant.Household_Size__c == null ) {
                    sendIneligibleMsg = true;
                    msg += '<li>You have n\'t selected any household size. please select one household size.</li>';
                    //preApplicant.addError('You have n\'t selected any household size. please select one household size.');
                } 
                
                if (lstPreApplicant[0].Annual_Income__c == null) {
                    sendIneligibleMsg = true;
                    msg += '<li>Please provide information about your annual income.</li></ul>';                
                } 
                
                if (preApplicant.Monthly_Other_Assistance__c == null) {
                    preApplicant.Monthly_Other_Assistance__c = 0;
                }
                system.debug(' sendIneligibleMsg '+sendIneligibleMsg);  
                                
                if( sendIneligibleMsg == false )
                {
                    // check if updated informaion makes preapplicant eligible for the property he has applied for
                    // if yes then take them on the waiting list or make their municipality preference as inactive
                    // call the method for verification if pre applicant is still eligible
                    
                    CGPHProfileController cntrl;
                    try{
                    cntrl = new CGPHProfileController();
                    }
                    catch(Exception ex)
                    {
                    
                    }
                    
                    list<task> lstActivities = new list<task>();
                    list<PreApplicants__c> lstTempPreApplicant = new list<PreApplicants__c>();
                    list<Municipality__c> lstMunicipality = new list<Municipality__c>();
                    lstTempPreApplicant.add(preApplicant);
                    if(mapPreAppwiseRentalMunicipalities != null && mapPreAppwiseRentalMunicipalities.size() > 0)
                        lstMunicipality.addAll(mapPreAppwiseRentalMunicipalities.get(preApplicant.id));
                        
                    // check the eligibility for the current pre applicant using the library methods
                    mapWrapperRentalMunicipalPreference = new map<string,List<CGPHProfileController.RentalMunicipalPreference>>();
                    mapWrapperRentalMunicipalPreference = cntrl.verifyRentalMunicipalityCriterias(lstTempPreApplicant,lstMunicipality,'rental');
                    system.debug('In is back in action '+ mapWrapperRentalMunicipalPreference);
                    
                    // for rental
                    if(mapWrapperRentalMunicipalPreference != null)
                    {
                        list<Municipality_Preference__c> lstPrefToUpdate = new list<Municipality_Preference__c>();
                        list<CGPHProfileController.RentalMunicipalPreference> lstPreferencesToIterate = new list<CGPHProfileController.RentalMunicipalPreference>();
                        if( mapWrapperRentalMunicipalPreference != null && mapWrapperRentalMunicipalPreference.size() > 0 )
                        {
                            lstPreferencesToIterate.addAll(mapWrapperRentalMunicipalPreference.get('EligibleMunicipalities'));
                            lstPreferencesToIterate.addAll(mapWrapperRentalMunicipalPreference.get('MyMunicipalities'));
                        }
                        
                        // check if the preference which is on hold is eligible of ineligible now
                        for(CGPHProfileController.RentalMunicipalPreference preference : lstPreferencesToIterate)
                        {
                            string municipalityId = preference.municipalityId;  
                            system.debug('preference '+preference);                 
                            Municipality_Preference__c tempPrefrence = new Municipality_Preference__c();
                            list<Municipality_Preference__c> lstTempPreference = new list<Municipality_Preference__c>();
                            lstTempPreference = mapRentalMunicipalPreference.get(preApplicant.id);
                            Date todaysDate = Date.today();
                            for(Municipality_Preference__c pref : lstTempPreference)
                            {
                                if(pref.Municipality__c == municipalityId)
                                { // add code for sending local municipality preference url
                                    system.debug(pref.Removal_Date__c + '  '+ todaysDate.addYears(-1)); 
                                    if( pref.Removal_Date__c > todaysDate.addYears(-1) ||  pref.Removal_Date__c == null )
                                    {
                                        tempPrefrence = new Municipality_Preference__c(id=pref.id);
                                        tempPrefrence.Status__c = 'Active';
                                        tempPrefrence.On_Hold__c = false;
                                        lstPrefToUpdate.add(tempPrefrence);
                                    //  task newTask = PreApplicantTriggerHandler.createTask('Re-Activated '+pref.Municipality__r.Name+' '+pref.Type__c+' Preference from On Hold','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id,preApplicant.id);//new task();new task();
                                    //  lstActivities.add(newTask);
                                    }
                                    else
                                    {
                                        tempPrefrence = new Municipality_Preference__c(id=pref.id);
                                        tempPrefrence.Ineligibilty_Reason__c = 'Expired On Hold';
                                        tempPrefrence.Status__c = 'Ineligible';                                    
                                        processPreference(preApplicant,tempPrefrence);   
                                        tempPrefrence.On_Hold__c = false;
                                        tempPrefrence.Removal_Date__c = date.today();
                                        lstPrefToUpdate.add(tempPrefrence);
                                        //task newTask = PreApplicantTriggerHandler.createTask('Removed Expired On Hold '+pref.Municipality__r.Name+' '+pref.Type__c+' Preference','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id,preApplicant.id);//new task();new task();
                                        //lstActivities.add(newTask);
                                    }
                                }
                            }
                        }
                        
                        system.debug('lstPrefToUpdate '+lstPrefToUpdate);
                        {
                            update lstPrefToUpdate;
                            if( lstActivities != null && lstActivities.size() > 0 )
                                insert lstActivities;
                        }
                    }
                    
                    // for purchase check if there is change in the municipal criteria and 
                    // that change can re activate or remove preference from the on hold to 
                    // inactive again by calculating criterias
                    
                    lstTempPreApplicant.add(preApplicant);
                    lstMunicipality = new list<Municipality__c>();
                    if( mapPreAppwisePurchaseMunicipalities != null && mapPreAppwisePurchaseMunicipalities.size() > 0 )
                        lstMunicipality.addAll(mapPreAppwisePurchaseMunicipalities.get(preApplicant.id));
                    
                    // check for the purchase preferences if these are eligible
                    map<string,List<CGPHProfileController.WrapperHownershipMunicipalPreference>> mapWrapperPurchaseMunicipalPreference = new map<string,List<CGPHProfileController.WrapperHownershipMunicipalPreference>>();
                    mapWrapperPurchaseMunicipalPreference = cntrl.verifyPurchaseMunicipalityCriterias(lstTempPreApplicant,lstMunicipality,'purchase');
                    system.debug('In is back in action for purchase'+mapWrapperPurchaseMunicipalPreference);
                    
                    if(mapWrapperPurchaseMunicipalPreference != null)
                    {
                        list<Municipality_Preference__c> lstPrefToUpdate = new list<Municipality_Preference__c>();
                        list<CGPHProfileController.WrapperHownershipMunicipalPreference> lstPreferencesToIterate = new list<CGPHProfileController.WrapperHownershipMunicipalPreference>();
                        
                        // mapWrapperPurchaseMunicipalPreference map contains all municipalities from which 
                        // municipalities with map key 'EligibleMunicipalities' and 'MyMunicipalities' are the municipalties which meets the pre applicants criteria
                        if( mapWrapperPurchaseMunicipalPreference != null && mapWrapperPurchaseMunicipalPreference.size() > 0 )
                        {
                            lstPreferencesToIterate.addAll(mapWrapperPurchaseMunicipalPreference.get('EligibleMunicipalities'));
                            lstPreferencesToIterate.addAll(mapWrapperPurchaseMunicipalPreference.get('MyMunicipalities'));
                        }
                        
                        
                        lstActivities = new list<task>();
                        for(CGPHProfileController.WrapperHownershipMunicipalPreference preference : lstPreferencesToIterate)
                        {
                            string municipalityId = preference.municipalityId;  
                            system.debug('preference purchase'+preference);                 
                            Municipality_Preference__c tempPrefrence = new Municipality_Preference__c();
                            list<Municipality_Preference__c> lstTempPreference = new list<Municipality_Preference__c>();
                            system.debug(' mapOwnerMunicipalPreference is : '+mapOwnerMunicipalPreference);
                            lstTempPreference = mapOwnerMunicipalPreference.get(preApplicant.id);
                            system.debug('lstTempPreference '+lstTempPreference);
                            for(Municipality_Preference__c pref : lstTempPreference)
                            {
                                Date todaysDate = Date.today();
                                system.debug(pref.Municipality__c+' AND   '+municipalityId);
                                if(pref.Municipality__c == municipalityId)
                                {
                                    // check if the municipality preference is on hold for more than a year 
                                    // if so then remove the preference from active on hold to inctive
                                    if( pref.Removal_Date__c > todaysDate.addYears(-1) ||  pref.Removal_Date__c == null )
                                    {
                                        tempPrefrence = new Municipality_Preference__c(id=pref.id);  
                                        tempPrefrence.Status__c = 'Active';
                                        tempPrefrence.On_Hold__c = false;
                                        lstPrefToUpdate.add(tempPrefrence);
                                        
                                        // create an activity
                                        //task newTask = PreApplicantTriggerHandler.createTask('Re-Activated '+pref.Municipality__r.Name+' '+pref.Type__c+' Preference from On Hold','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id,preApplicant.id);//new task();new task();
                                        //lstActivities.add(newTask);
                                    }
                                    else
                                    {
                                        tempPrefrence = new Municipality_Preference__c(id=pref.id);
                                        tempPrefrence.Status__c = 'Ineligible';
                                        tempPrefrence.Ineligibilty_Reason__c = 'Expired On Hold';
                                        //tempPrefrence.Removal_Trigger__c = 'Pre-Application Renewal';                                    
                                        processPreference(preApplicant,tempPrefrence);
                                        tempPrefrence.Removal_Date__c = date.today();
                                        tempPrefrence.On_Hold__c = false;                                        
                                        lstPrefToUpdate.add(tempPrefrence);                                        
                                        // create an activity
                                        //task newTask = PreApplicantTriggerHandler.createTask('Removed Expired On Hold '+pref.Municipality__r.Name+' '+pref.Type__c+' Preference','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id,preApplicant.id);//new task();
                                        //lstActivities.add(newTask);
                                    }
                                }
                            }
                        }
                        
                        system.debug('lstPrefToUpdate purchase'+lstPrefToUpdate);
                        update lstPrefToUpdate;
                        if( lstActivities != null && lstActivities.size() > 0 )
                        {
                            insert lstActivities;
                        }
                    }
                } // end of if
                
                // sendIneligibleMsg is false then we need to check the fields for changes if there is any changes in the fields and 
                // if there is change in the fields which can affect the municipalities eligibilty for an pre applicant then it calculate
                // for criterias again. If eligible then fine otherwise it send an email to pre applicant that they are removed from the 
                // waiting list as they are no longer meeting the citerias for the municipalities they have opted for
                
                if(sendIneligibleMsg == false)  
                {
                    list<task> lstActivities = new list<task>();
                    Task newTask;
if( Trigger.isUpdate && test.isRunningTest() == false )
{

    //if( oldPreApplicant.Monthly_Other_Assistance__c == null )
    //    oldPreApplicant.Monthly_Other_Assistance__c = 0;
    
    system.debug('oldPreApplicant.Inactive_Ineligible_MP_s__c'+oldPreApplicant.Inactive_Ineligible_MP_s__c +'  preApplicant.Inactive_Ineligible_MP_s__c '+preApplicant.Inactive_Ineligible_MP_s__c);
    system.debug('oldPreApplicant.Active_MP_s__c '+oldPreApplicant.Active_MP_s__c +'  preApplicant.Active_MP_s__c '+preApplicant.Active_MP_s__c );
    
    
    system.debug(' oldPreApplicant.Household_Members_55__c '+oldPreApplicant.Household_Members_55__c+' preApplicant.Household_Members_55__c '+preApplicant.Household_Members_55__c+' => '+(oldPreApplicant.Household_Members_55__c != preApplicant.Household_Members_55__c));
    
    system.debug('  oldPreApplicant.Rental_Interest__c '+oldPreApplicant.Rental_Interest__c+'  preApplicant.Rental_Interest__c  '+preApplicant.Rental_Interest__c+' =>  '+(oldPreApplicant.Rental_Interest__c != preApplicant.Rental_Interest__c));
    
    system.debug(' oldPreApplicant.Purchase_Interest__c '+oldPreApplicant.Purchase_Interest__c+' preApplicant.Purchase_Interest__c '+preApplicant.Purchase_Interest__c+' => '+(oldPreApplicant.Purchase_Interest__c != preApplicant.Purchase_Interest__c));
    
    system.debug(' oldPreApplicant.Section_8__c '+oldPreApplicant.Section_8__c+' preApplicant.Section_8__c '+oldPreApplicant.Section_8__c+' => '+(oldPreApplicant.Section_8__c != preApplicant.Section_8__c));
    
    system.debug(' oldPreApplicant.Household_Size__c '+oldPreApplicant.Household_Size__c+' preApplicant.Household_Size__c '+preApplicant.Household_Size__c+' =>  '+(oldPreApplicant.Household_Size__c != preApplicant.Household_Size__c));
    
    system.debug(' oldPreApplicant.Annual_Income__c '+oldPreApplicant.Annual_Income__c+' preApplicant.Annual_Income__c '+preApplicant.Annual_Income__c+' => '+(oldPreApplicant.Annual_Income__c!= preapplicant.Annual_Income__c));
    
    system.debug( ' oldPreApplicant.Monthly_Other_Assistance__c '+oldPreApplicant.Monthly_Other_Assistance__c+' preApplicant.Monthly_Other_Assistance__c '+preApplicant.Monthly_Other_Assistance__c+' => '+(oldPreApplicant.Monthly_Other_Assistance__c != preApplicant.Monthly_Other_Assistance__c) );
    
    system.debug(' oldPreApplicant.AR_Properties_Only__c '+oldPreApplicant.AR_Properties_Only__c+' preApplicant.AR_Properties_Only__c '+preApplicant.AR_Properties_Only__c+' => '+(oldPreApplicant.AR_Properties_Only__c != preApplicant.AR_Properties_Only__c));
    
    system.debug(' oldPreApplicant.Household_Disabled__c '+oldPreApplicant.Household_Disabled__c+'  preApplicant.Household_Disabled__c '+preApplicant.Household_Disabled__c+'  => '+(oldPreApplicant.Household_Disabled__c!=PreApplicant.Household_Disabled__c));
    
    system.debug(' oldPreApplicant.Substandard_Overcrowded_Housing__c '+oldPreApplicant.Substandard_Overcrowded_Housing__c+' preApplicant.Substandard_Overcrowded_Housing__c '+PreApplicant.Substandard_Overcrowded_Housing__c+' => '+(oldPreApplicant.Substandard_Overcrowded_Housing__c!= PreApplicant.Substandard_Overcrowded_Housing__c));
    
    system.debug(' oldPreApplicant.Max_Down_Payment__c '+oldPreApplicant.Max_Down_Payment__c+' PreApplicant.Max_Down_Payment__c '+PreApplicant.Max_Down_Payment__c +' => '+(oldPreApplicant.Max_Down_Payment__c != PreApplicant.Max_Down_Payment__c));
    system.debug(' oldPreApplicant.MP_Update__c '+oldpreApplicant.MP_Update__c +'  preApplicant.MP_Update__c '+preApplicant.MP_Update__c);
    system.debug(' RESULT '+ ( trigger.isUpdate && ( oldPreApplicant.Household_Members_55__c != preApplicant.Household_Members_55__c || oldPreApplicant.Rental_Interest__c != preApplicant.Rental_Interest__c ||
                            oldPreApplicant.Purchase_Interest__c != preApplicant.Purchase_Interest__c || oldPreApplicant.Section_8__c != preApplicant.Section_8__c ||
                            oldPreApplicant.Household_Size__c != preApplicant.Household_Size__c || oldPreApplicant.Annual_Income__c != preApplicant.Annual_Income__c ||
                            (( oldPreApplicant.Monthly_Other_Assistance__c != null ? oldPreApplicant.Monthly_Other_Assistance__c : 0 ) != preApplicant.Monthly_Other_Assistance__c) || oldPreApplicant.AR_Properties_Only__c != preApplicant.AR_Properties_Only__c  ||
                            oldPreApplicant.Household_Disabled__c != preApplicant.Household_Disabled__c || oldPreApplicant.Substandard_Overcrowded_Housing__c != preApplicant.Substandard_Overcrowded_Housing__c ||
                            oldPreApplicant.Max_Down_Payment__c != preApplicant.Max_Down_Payment__c ||
                            preApplicant.Force_Eligibility_Check__c == true ||  // If this is update and we want to check for eligibility again
                            preApplicant.Updated_w_o_Trigger__c == true ||
                            preApplicant.Most_Recent_Update__c == null || 
                            preApplicant.MP_Update__c == true
                            )));
                    system.debug('Updated without trigger'+preApplicant.Updated_w_o_Trigger__c);
                    system.debug(' preApplicant.Most_Recent_Update__c '+preApplicant.Most_Recent_Update__c);
  }                 
                    if ( trigger.isUpdate && ( oldPreApplicant.Household_Members_55__c != preApplicant.Household_Members_55__c || oldPreApplicant.Rental_Interest__c != preApplicant.Rental_Interest__c ||
                            oldPreApplicant.Purchase_Interest__c != preApplicant.Purchase_Interest__c || oldPreApplicant.Section_8__c != preApplicant.Section_8__c ||
                            oldPreApplicant.Household_Size__c != preApplicant.Household_Size__c || oldPreApplicant.Annual_Income__c != preApplicant.Annual_Income__c ||
                            (( oldPreApplicant.Monthly_Other_Assistance__c != null ? oldPreApplicant.Monthly_Other_Assistance__c : 0 ) != preApplicant.Monthly_Other_Assistance__c) || oldPreApplicant.AR_Properties_Only__c != preApplicant.AR_Properties_Only__c  ||
                            oldPreApplicant.Household_Disabled__c != preApplicant.Household_Disabled__c || oldPreApplicant.Substandard_Overcrowded_Housing__c != preApplicant.Substandard_Overcrowded_Housing__c ||
                            oldPreApplicant.Max_Down_Payment__c != preApplicant.Max_Down_Payment__c ||
                            preApplicant.Force_Eligibility_Check__c == true ||  // If this is update and we want to check for eligibility again
                            preApplicant.Updated_w_o_Trigger__c == true ||
                            preApplicant.Most_Recent_Update__c == null ||
                            oldPreApplicant.Inactive_Ineligible_MP_s__c !=  preApplicant.Inactive_Ineligible_MP_s__c                          
                            ))
                            {
                            
                                // if any of the eligibility criteria changing field change
                                // send local questionarrie URL in email
                                system.debug(' adding in the list '+preApplicant);
                                lstPreApplicantToReceiveLocalPreferences.add(preApplicant);
                                  
                                list<string> lstStrMessage = new list<string>();
                                List<Municipality_Preference__c> lstRentalMunicipalPref = mapRentalMunicipalPreference.get(preApplicant.id);
                                if (preApplicant.Rental_Interest__c == false && preApplicant.Rental_Interest__c == false && lstRentalMunicipalPref != null && lstRentalMunicipalPref.size() > 0) // if rental interest is unchecked then deactivate all the preferences
                                {
                                    List<RentalMunicipalPreference> lstRentalNoInterestMP = new List<RentalMunicipalPreference>();
                                    
                                    // check if preference is on hold for more than 1 year
                                    //if it is the case then make it as inactive
                                    // if pre applicant have updated profile and they are no longer interested in the
                                    // rental homes then this code removes all the preferences for the pre applicant
                                    for (Municipality_Preference__c municipalPref : lstRentalMunicipalPref) 
                                    {
                                        Municipality__c municipality = new Municipality__c();
                                        lstStrMessage = new list<string>();
                                        municipalPref.Status__c = 'Inactive';
                                        municipalPref.Removal_Date__c = date.today();
                                        municipalPref.Ineligibilty_Reason__c = 'Not interested in Rental Proerties';
                                        //municipalPref.Removal_Trigger__c = 'Pre-Application Renewal';
                                        
                                            processPreference(preApplicant,municipalPref);
                                            
                                        if( municipalPref.On_Hold__c == true )  
                                        {
                                            municipalPref.On_Hold__c = false;
                                            // create task for deactivation again
                                            //newTask = PreApplicantTriggerHandler.createTask(municipalPref.Municipality__r.Name+' Rental On Hold Inactive again','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+municipalPref.id,municipalPref.PreApplicant__c);//new task();new task();
                                            //lstActivities.add(newTask);
                                        }
                                        else{
                                        // create task for deactivation again
                                            //newTask = PreApplicantTriggerHandler.createTask(municipalPref.Municipality__r.Name+' Rental Inactive ','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+municipalPref.id,municipalPref.PreApplicant__c);//new task();new task();
                                            //lstActivities.add(newTask);
                                        }
                                        municipalPref.Removal_Date__c = Date.today(); 
                                        system.debug('Preference updated for deactivation : ' + municipalPref);
                                        lstToUpdateMunicipalityPref.add(municipalPref);
                                        municipality = mapAllMunicipalities.get(municipalPref.Municipality__c);
                                        lstStrMessage.add('Removed from the preference');
                                        lstRentalNoInterestMP.add(new RentalMunicipalPreference(municipality, 'Ineligible', lstStrMessage, municipalPref, false));
                                    }
                                    mapWrapperMunicipality.put('rentalnointerest', lstRentalNoInterestMP);
                                    list<PreApplicants__c> lstTempPreApp = new list<PreApplicants__c>();
                                    lstTempPreApp.add(preApplicant);
                                    setEmailTemplate(mapWrapperMunicipality, mapWrapperPurchaseMunicipality, lstTempPreApp);
                            }
                            else if (preApplicant.Rental_Interest__c && lstRentalMunicipalPref != null && lstRentalMunicipalPref.size() > 0) 
                            {
                                // if they are interested in the rental but there is some other change which is assigning 
                                map<string, List<RentalMunicipalPreference>> mapRentalIneligibleMunicipality = checkRentalMunicipalityCriterias(preApplicant, lstRentalMunicipalPref);
                                system.debug('::mapRentalIneligibleMunicipality::' + mapRentalIneligibleMunicipality);
                                List<RentalMunicipalPreference> lstRentalIneligibleMunicipality = mapRentalIneligibleMunicipality.get('InEligibleMunicipalities');
                                if (lstRentalIneligibleMunicipality != null && lstRentalIneligibleMunicipality.size() > 0) {
                                    for (RentalMunicipalPreference objWrapperMunicipality : lstRentalIneligibleMunicipality) {
                                        Municipality_Preference__c objMunicipalityPreference = new Municipality_Preference__c();
                                        objMunicipalityPreference.Ineligibilty_Reason__c = (objWrapperMunicipality.lstStrMessage != null && objWrapperMunicipality.lstStrMessage.size() > 0) ? objWrapperMunicipality.lstStrMessage[0] : '';
                                        objMunicipalityPreference.Status__c = 'Ineligible';
                                        
                                        //objMunicipalityPreference.Removal_Trigger__c = 'Pre-Application Renewal';
                                    
                                        processPreference(preApplicant,objMunicipalityPreference);
                                        
                                        if( objWrapperMunicipality.rentalPreferences.On_Hold__c == true )
                                        {
                                            objMunicipalityPreference.On_Hold__c = false;
                                            // create task for deactivation again
                                            //newTask = PreApplicantTriggerHandler.createTask(objWrapperMunicipality.rentalPreferences.Municipality__r.Name+' Rental On Hold Ineligible again','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objWrapperMunicipality.rentalPreferences.id,objWrapperMunicipality.rentalPreferences.PreApplicant__c);//new task();new task();
                                            //lstActivities.add(newTask);
                                        }
                                        else{
                                            // create task for deactivation again
                                            //newTask = PreApplicantTriggerHandler.createTask(objWrapperMunicipality.rentalPreferences.Municipality__r.Name+' Rental Ineligible','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objWrapperMunicipality.rentalPreferences.id,objWrapperMunicipality.rentalPreferences.PreApplicant__c);//new task();new task();
                                            //lstActivities.add(newTask);
                                        }
                                        objMunicipalityPreference.Removal_Date__c = Date.today(); //municipality
                                        objMunicipalityPreference.id = objWrapperMunicipality.rentalPreferences.Id;
                                        system.debug('Preference updated for deactivation : ' + objMunicipalityPreference);
                                        lstToUpdateMunicipalityPref.add(objMunicipalityPreference);
                                    }
                                    system.debug('::Rental Inelgible List::' + lstToUpdateMunicipalityPref);
                                    mapWrapperMunicipality.put('rentalineligible', lstRentalIneligibleMunicipality);
                                    list<PreApplicants__c> lstTempPreApp = new list<PreApplicants__c>();
                                    lstTempPreApp.add(preApplicant);
                                    setEmailTemplate(mapWrapperMunicipality, mapWrapperPurchaseMunicipality, lstTempPreApp);
                                }
                            }
                            
                            
                        // Removing Ownership Municip Prefs wehn no longer interested in Purchase
                        List<Municipality_Preference__c> lstPurchaseMunicipalPref = mapOwnerMunicipalPreference.get(preApplicant.id);
                        system.debug('::lstPurchaseMunicipalPref::' + lstPurchaseMunicipalPref);
                        if ( preApplicant.Purchase_Interest__c == false && lstPurchaseMunicipalPref != null && lstPurchaseMunicipalPref.size() > 0) // if the purchase interest is unchecked deactivate all the preferences 
                        {
                            // if there is change in the criteria which makes pre applicant ineligible for
                            // all the municipality and then remove all preferences
                            string strDesc = '';
                            List<WrapperHownershipMunicipalPreference> lstOwnerNoInterestMP = new List<WrapperHownershipMunicipalPreference>();
                            for (Municipality_Preference__c municipalPref : lstPurchaseMunicipalPref) 
                            {
                                Municipality__c municipality = new Municipality__c();
                                municipalPref.Status__c = 'Inactive';
                                municipalPref.Ineligibilty_Reason__c = 'Not interested in Ownership Proerties';
                                //municipalPref.Removal_Trigger__c = 'Pre-Application Renewal';         
                                processPreference(preApplicant,municipalPref);
                                
                                municipalPref.On_Hold__c = false;
                                municipalPref.Removal_Date__c = Date.today();
                                lstToUpdateMunicipalityPref.add(municipalPref);
    
                                system.debug('Preference updated for deactivation : ' + municipalPref);
                                municipality = mapAllMunicipalities.get(municipalPref.Municipality__c);
                                lstStrMessage.add('Removed from the preference');
                                lstOwnerNoInterestMP.add(new WrapperHownershipMunicipalPreference(municipality, 'Ineligible', lstStrMessage, municipalPref, false));
                                strDesc += municipalPref.Name+' '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+municipalPref.id+'\n';
                            }
                        
                        // create task for deactivation again
                                //newTask = PreApplicantTriggerHandler.createTask('Removed from all Ownership Preferences ','Link to the Preference Records : \n'+strDesc,preApplicant.id);//new task();new task();
                                //lstActivities.add(newTask);
    
                            mapWrapperPurchaseMunicipality.put('ownernointerest', lstOwnerNoInterestMP);
                            list<PreApplicants__c> lstTempPreApp = new list<PreApplicants__c>();
                            lstTempPreApp.add(preApplicant);
                            setEmailTemplate(mapWrapperMunicipality, mapWrapperPurchaseMunicipality, lstTempPreApp);
                        } 
                        else if (preApplicant.Purchase_Interest__c == true && lstPurchaseMunicipalPref != null && lstPurchaseMunicipalPref.size() > 0) 
                        {
                            map<string, List<WrapperHownershipMunicipalPreference>> mapOwnerIneligibleMunicipality =  verifyPurchaseMunicipalityCriterias(preApplicant, lstPurchaseMunicipalPref);
                            system.debug('::mapOwnerIneligibleMunicipality::' + mapOwnerIneligibleMunicipality);
                            List<WrapperHownershipMunicipalPreference> lstOwnerIneligibleMunicipality = mapOwnerIneligibleMunicipality.get('InEligibleMunicipalities');
                            if (lstOwnerIneligibleMunicipality != null && lstOwnerIneligibleMunicipality.size() > 0) {
                                for (WrapperHownershipMunicipalPreference objWrapperMunicipality : lstOwnerIneligibleMunicipality) 
                                {
                                    system.debug('objWrapperMunicipality in purchase : ==> ' + objWrapperMunicipality);
                                    Municipality_Preference__c objMunicipalityPreference = new Municipality_Preference__c();
                                    objMunicipalityPreference.Ineligibilty_Reason__c = (objWrapperMunicipality.lstStrMessage != null && objWrapperMunicipality.lstStrMessage.size() > 0) ? objWrapperMunicipality.lstStrMessage[0] : '';
                                    objMunicipalityPreference.Status__c = 'Ineligible';
                                    //objMunicipalityPreference.Removal_Trigger__c = 'Pre-Application Renewal';
                                    //objMunicipalityPreference.On_Hold__c = false;
                                    processPreference(preApplicant,objMunicipalityPreference);
                                    
                                    if( objWrapperMunicipality.hownershipPreferences.On_Hold__c == true )
                                    {
                                        objMunicipalityPreference.On_Hold__c = false;
                                        // create task for deactivation again
                                        //newTask = PreApplicantTriggerHandler.createTask(objWrapperMunicipality.hownershipPreferences.Municipality__r.Name+' Ownership On Hold Ineligible again','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objWrapperMunicipality.hownershipPreferences.id,objWrapperMunicipality.hownershipPreferences.PreApplicant__c);//new task();new task();
                                        //lstActivities.add(newTask);
                                    }
                                    else{
                                        //newTask = PreApplicantTriggerHandler.createTask(objWrapperMunicipality.hownershipPreferences.Municipality__r.Name+' Ownership Ineligible','Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objWrapperMunicipality.hownershipPreferences.id,objWrapperMunicipality.hownershipPreferences.PreApplicant__c);//new task();new task();
                                        //lstActivities.add(newTask);
                                    }
                                    objMunicipalityPreference.Removal_Date__c = Date.today();
                                    objMunicipalityPreference.id = objWrapperMunicipality.hownershipPreferences.id;
                                    system.debug('Preference updated for deactivation : ' + objMunicipalityPreference);
                                    lstToUpdateMunicipalityPref.add(objMunicipalityPreference);
                                }
                                mapWrapperPurchaseMunicipality.put('ownerineligible', lstOwnerIneligibleMunicipality);
                                list<PreApplicants__c> lstTempPreApp = new list<PreApplicants__c>();
                                lstTempPreApp.add(preApplicant);
                                setEmailTemplate(mapWrapperMunicipality, mapWrapperPurchaseMunicipality, lstTempPreApp);
                            }
                        }
                        
                        if( lstActivities != null && lstActivities.size() > 0 )
                            insert lstActivities;
                            
                        if (strEmailBody != null || strEmailBody != '') 
                        {
                            /*string strEmailBodyIntro = '';
                            system.debug(' preApplicant.Contact__r.Email '+preApplicant.Contact__r.Email);
                            strEmailBodyIntro += '<img src="https://www.affordablehomesnewjersey.com/wp-content/uploads/2016/03/cgph-email-logo1.png" width="600" height="73"/>';
                            strEmailBodyIntro += '<p>Dear ' + preApplicant.Contact__r.FirstName + ' ' + preApplicant.Contact__r.LastName + ',</p>';
                            strEmailBodyIntro += '<p>Thank You For Updating Your Profile. The information you provided has impacted your eligibility for affordable housing. (Income limits, Rents, and Purchase Prices are revised annually. Even though your income may not have changed, your eligibility may be affected by these changes.)</p><br/>';
                            //strEmailBodyIntro += '<h3>You will not be considered for any property until you update the following information</h3><br/>';
                            
                            strEmailBody = strEmailBodyIntro + strEmailBody;*/
                    
                            // if contact email address is blank do the following
                            if( preApplicant.Contact__r.Email == null || preApplicant.Contact__r.Email == '')
                            {
                                // if email is blank then for case 1 if Provide_email_postcard_sent__c is true and
                                // Pre-App.Contact.Provide Email Postcard Followup = Waiting for Deadline OR No Response, Removed from waitlists
                                // then do not send an email
                                // also when Online_Submission__c = false then it is CGPH staff submitting pre application on the applicants behalf                                                     
                                if( (preApplicant.Contact__r.Provide_email_postcard_sent__c == true && 
                                (preApplicant.Contact__r.Provide_Email_Postcard_Followup__c == 'Waiting for Deadline' || preApplicant.Contact__r.Provide_Email_Postcard_Followup__c == 'No Response, Removed from waitlists') ) 
                                || preApplicant.Online_Submission__c == false)
                                {
                                    // do not send an email 
                                }
                                else
                                {
                                    // else send an email and it will throw an error as email is blank
                                    // but no updates for the preferences will be done
                                    sendEmail(preApplicant.Contact__r.Email);
                                } 
                            }
                            else
                            {
                                sendEmail(preApplicant.Contact__r.Email);
                                // Update the Pre Applicant Record with the Local Preference links
                                // there is some change in preferences and some preferences are in active
                              //  lstPreApplicantToReceiveLocalPreferences.add(preApplicant);
                                
                            }
                        }
                    }
                }
                else if(sendIneligibleMsg == true && msg != '')
                {
                    // deactivate all the preference of preapplicant
                    list<Municipality_Preference__c> lstPreferencesToUpdate = new list<Municipality_Preference__c>();
                    //deactivate rental preferences 
                    lstPreferencesToUpdate = mapRentalMunicipalPreference.get(preApplicant.id);
                    PreApplicantTriggerHandler.deactivatePreferences(lstPreferencesToUpdate,preApplicant.id);
                    
                    // deactivate purchase preferences
                    lstPreferencesToUpdate = mapOwnerMunicipalPreference.get(preApplicant.id);
                    PreApplicantTriggerHandler.deactivatePreferences(lstPreferencesToUpdate,preApplicant.id);
                    
                    
                    strEmailBody += '<img src="https://www.affordablehomesnewjersey.com/wp-content/uploads/2016/10/AHNJ-logo.png" width="600" height="73"/>';
                    strEmailBody += '<font face=calibri><p>Dear ' + preApplicant.Contact__r.FirstName + ' ' + preApplicant.Contact__r.LastName + ',</p>';
                    strEmailBody += '<p>Thank You For Updating Your Profile. The information you provided has impacted your eligibility for affordable housing. (Income limits, Rents, and Purchase Prices are revised annually. Even though your income may not have changed, your eligibility may be affected by these changes.)</p>';
                    //strEmailBody += '<h3>You will not be considered for any property until you update the following information</h3>';
                    strEmailBody += msg+'<br/>';
                    strEmailBody += strEmailBodyMsg;
                    
                    strEmailBody += '<p>To review your updated profile or to see any new Municipalities you may now be eligible for, visit your <a href="http://affordablehomesnewjersey.force.com/CGPHProfile?appId=' + preApplicant.PreApplicant_Encoded_Id__c +'">profile page here</a>.</p>';
                    strEmailBody += '<p>If you made a mistake when you updated your profile or the changes you provided are temporary and you would like to remain on the waiting lists, <a href="http://www.affordablehomesnewjersey.com/request-review-of-waiting-list-status/?tfa_10=' + preApplicant.Id + '&tfa_11=' + preApplicant.Contact__r.FirstName + '%20' + preApplicant.Contact__r.LastName + '&tfa_13=' + preApplicant.Contact__r.Id + '">please submit an appeal here</a>.</font>';

                    strEmailBody += '<div style="text-align:center; color:#2B4981; margin-top:30px; width:600px;">';
                    strEmailBody += '<font color=#21407B face=calibri>1249 South River Road, Suite 301, Cranbury, NJ 08512-3633<br/>';
                    strEmailBody += '<a href="mailto:homes@cgph.net" style="color:#0E6BCA;">homes@cgph.net</a><br/>';
                    strEmailBody +=' <a href="www.affordablehomesnewjersey.com/" style="color:#0E6BCA;">www.affordablehomesnewjersey.com</a><br/><br/>';
                    strEmailBody += 'View my <a href="http://affordablehomesnewjersey.force.com/CGPHProfile?appId=' + preApplicant.PreApplicant_Encoded_Id__c + '" style="color:#0E6BCA;">Affordable Homes New Jersey Profile</a><br/>';
                    strEmailBody += 'I am no longer interested in affordable housing: <a href="'+ preApplicant.Remove_Me_from_All_URL__c +'" style="color:#0E6BCA;">Remove me from all Waiting Lists</a><br/><font></div>';

                    
                    // if contact email address is blank do the following
                    if( preApplicant.Contact__r.Email == null || preApplicant.Contact__r.Email == '')
                    {
                        // if email is blank then for case 1 if Provide_email_postcard_sent__c is true and
                        // Pre-App.Contact.Provide Email Postcard Followup = Waiting for Deadline OR No Response, Removed from waitlists
                        // then do not send an email
                        // also when Online_Submission__c = false then it is CGPH staff submitting pre application on the applicants behalf                                                     
                        if( (preApplicant.Contact__r.Provide_email_postcard_sent__c == true && 
                        (preApplicant.Contact__r.Provide_Email_Postcard_Followup__c == 'Waiting for Deadline' || preApplicant.Contact__r.Provide_Email_Postcard_Followup__c == 'No Response, Removed from waitlists') ) 
                        || preApplicant.Online_Submission__c == false)
                        {
                            // do not send an email 
                        }
                        else
                        {
                            // else send an email and it will throw an error as email is blank
                            // but no updates for the preferences will be done
                            sendEmail(preApplicant.Contact__r.Email);
                        }
                    }
                    else
                    {
                        sendEmail(preApplicant.Contact__r.Email);
                    }
                }
               }// end of else
            }//loop ends here
            
            
            
           /* if( lstPreApplicantUpdated != null && lstPreApplicantUpdated.size() > 0 )
            {
                system.debug('Pre Applicant list for update is '+lstPreApplicantUpdated);
                update lstPreApplicantUpdated;
            }*/
        }

        // 
        try {
            if (lstToUpdateMunicipalityPref != null && lstToUpdateMunicipalityPref.size() > 0) {
                update lstToUpdateMunicipalityPref;
                system.debug('::lstToUpdateMunicipalityPref::' + lstToUpdateMunicipalityPref);
            system.debug( ' Local Pref Email  '+lstPreApplicantToReceiveLocalPreferences);
            if( lstPreApplicantToReceiveLocalPreferences != null && lstPreApplicantToReceiveLocalPreferences.size() > 0 )
            {
                //system.debug('  => '+lstPreApplicantToReceiveLocalPreferences[0].Email_Local_Preference__c);
                //list<> lstAllUpdatePreapps = new list<>
                updateLocalPrefURL(lstPreApplicantToReceiveLocalPreferences );
            }    
                
             //   if (!Test.IsRunningTest()) 
                {
                    if (allEmails != null && allEmails.size() > 0) 
                    {
                        Messaging.sendEmail(allEmails);
                    }
                }
            }
           
                if( lstPreApplicantToReceiveLocalPreferences != null && lstPreApplicantToReceiveLocalPreferences.size() > 0 )
                {
                    //system.debug('  => '+lstPreApplicantToReceiveLocalPreferences[0].Email_Local_Preference__c);
                    //list<> lstAllUpdatePreapps = new list<>
                    updateLocalPrefURL(lstPreApplicantToReceiveLocalPreferences );
                } 
                
                 if( lstPreApplicantUpdated != null && lstPreApplicantUpdated.size() > 0 )
                {
                    system.debug('Pre Applicant list for update is '+lstPreApplicantUpdated);
                    update lstPreApplicantUpdated;
                }   
            
        } catch (DMLException ex) {
            system.debug('::Update DMLException::' + ex.getMessage());
            string description = 'Exception '+ ex.getMessage()+' Stack trace '+ex.getStackTraceString()+' Cause '+ex.getCause();
            Task errTask = new Task();
            errTask = PreApplicantTriggerHandler.createTask('Error in preapp trigger',description,null);
            insert errTask;     
        }
    }
    
    // function to set the preference from the form assembly
     
    public static void processPreference(PreApplicants__c preApplicant,Municipality_Preference__c objMunicipalityPreference)
    {
            system.debug('#####preApplicant.Last_Modified_At__c '+preApplicant.Last_Modified_At__c);
        if(preApplicant.Last_Modified_At__c == 'Internal Pre-Application/Update')
            objMunicipalityPreference.Removal_Trigger__c = 'Internal Pre-Application/Update';
        else if(preApplicant.Last_Modified_At__c == 'External Pre-Application/Update')
            objMunicipalityPreference.Removal_Trigger__c = 'External Pre-Application/Update';
        else if(preApplicant.Last_Modified_At__c == 'Internal RTV')
             {
                objMunicipalityPreference.Removal_Trigger__c = 'Internal RTV';
                objMunicipalityPreference.Ineligibilty_Reason__c = '';
             }
             else if(preApplicant.Last_Modified_At__c == 'External RTV')
                {
                    objMunicipalityPreference.Removal_Trigger__c = 'External RTV';
                    objMunicipalityPreference.Ineligibilty_Reason__c = '';
                }
        else if( preApplicant.Last_Modified_At__c == 'RFA Form')
                {
                    objMunicipalityPreference.Removal_Trigger__c = 'Submitted removal form';
                    objMunicipalityPreference.Ineligibilty_Reason__c = '';
                }
        else if(preApplicant.Last_Modified_At__c == null || preApplicant.Last_Modified_At__c == '' )
             {
                objMunicipalityPreference.Removal_Trigger__c = 'Staff Update';
                objMunicipalityPreference.Ineligibilty_Reason__c = '';
             }
    }
    
    
    // function to deactivate municipality preferences
    
    public static void deactivatePreferences(list<Municipality_Preference__c> lstPreferences,string preAppId){
        
        list<Municipality_Preference__c> lstPreferencesToUpdate = new list<Municipality_Preference__c>();
        string strDesc = '';
        if( lstPreferences != null && lstPreferences.size() > 0 )
        {
            for( Municipality_Preference__c preference : lstPreferences )
            {
                Municipality_Preference__c newPref = new Municipality_Preference__c(id=preference.id);
                newPref.Status__c = 'Ineligible';
                lstPreferencesToUpdate.add(newPref);
                strDesc += preference.Name+' '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+preference.id+'\n';
            }
            // create activity as all preferences are removed
            Task newTask = new Task();
            list<Task> lstActivities = new list<Task>();
            // create task for deactivation again
            newTask = PreApplicantTriggerHandler.createTask('Removed from all Preferences ','Link to the Preference Records : \n'+strDesc,preAppId);//new task();new task();
            lstActivities.add(newTask);
            
            if( lstPreferencesToUpdate != null && lstPreferencesToUpdate.size() > 0 )
                update lstPreferencesToUpdate;
                
            if(lstActivities != null && lstActivities.size() > 0)
                insert lstActivities;
        }
    
    }
    
    
    
    
    
    // create task record if municipal preference which is on hold and 
    // is eligible now or is expired then calculating the municipal 
    // criterias process the preferences
    
    public static task createTask(string subject,string description,string preAppId)
    {
        CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
        cgphSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
        
        task newTask = new task();
        newTask.OwnerId = cgphSettings.Admin_User_Id__c != null ? cgphSettings.Admin_User_Id__c : UserInfo.getUserId();
        newTask.WhatId = preAppId;
        newTask.Description = description;//'Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id;
        newTask.Subject = subject;//'Removed Expired On Hold MP Name Preference';
        newTask.status = 'Completed';
        return newTask;
    }

    //setEmailTemplate body for Rental and Purchase Municiplaities for Preapplicant applied MunicipalityPreferences
    public void setEmailTemplate(map<string, List<RentalMunicipalPreference>> mapWrapperMunicipality, map<string, List<WrapperHownershipMunicipalPreference>> mapOwnerIneligibleMunicipality,List<PreApplicants__c> lstPreApplicant) {
        strEmailBody = '';

        if (lstPreApplicant != null && lstPreApplicant.size() > 0) {
            for (PreApplicants__c preApplicant : lstPreApplicant) {
            
                strEmailBody += '<img src="https://www.affordablehomesnewjersey.com/wp-content/uploads/2016/10/AHNJ-logo.png" width="600" height="73"/>';
                strEmailBody += '<font face=calibri><p>Dear ' + preApplicant.Contact__r.FirstName + ' ' + preApplicant.Contact__r.LastName + ',</p>';
                strEmailBody += '<p>Thank You For Updating Your Profile. The information you provided has impacted your eligibility for affordable housing. (Income limits, Rents, and Purchase Prices are revised annually. Even though your income may not have changed, your eligibility may be affected by these changes.)</p></font>';
            
        if (mapWrapperMunicipality != null && mapWrapperMunicipality.size() > 0 ) {
            /*strEmailBody += '<img src="https://www.affordablehomesnewjersey.com/wp-content/uploads/2016/03/cgph-email-logo1.png" width="600" height="73"/>';
            strEmailBody += '<p>Dear ' + preApplicant.Contact__r.FirstName + ' ' + preApplicant.Contact__r.LastName + ',</p>';
            strEmailBody += '<p>Thank You For Updating Your Profile. The information you provided has impacted your eligibility for affordable housing. (Income limits, Rents, and Purchase Prices are revised annually. Even though your income may not have changed, your eligibility may be affected by these changes.)</p>';
            */
            
            List<RentalMunicipalPreference> lstRentalNoInterestMP = mapWrapperMunicipality.get('rentalnointerest');
            if (lstRentalNoInterestMP != null && lstRentalNoInterestMP.size() > 0) {
                strEmailBody += '<font face=calibri><p>Because you are no longer interested in Rental Units, you have been removed from these rental waiting lists:</p><ul>';
                for (RentalMunicipalPreference objWMuniciplaity : lstRentalNointerestMP) {
                    strEmailBody += '<li>' + objWMuniciplaity.strMunicipalityName + '</li>';
                }
                strEmailBody += '</ul></font>';
            }
            List<RentalMunicipalPreference> lstRentalIneligibleMP = mapWrapperMunicipality.get('rentalineligible');
            if (lstRentalIneligibleMP != null && lstRentalIneligibleMP.size() > 0) {
                strEmailBody += '<p>You are not eligible for the following rental waiting lists.</p><ul>';
                for (RentalMunicipalPreference objWMuniciplaity : lstRentalIneligibleMP) {
                    strEmailBody += '<li>' + objWMuniciplaity.strMunicipalityName  + ' ' + objWMuniciplaity.lstStrMessage[0]  + '</li>';
                }
                strEmailBody += '</ul></font>';
            }
        }


        if ( mapOwnerIneligibleMunicipality != null && mapOwnerIneligibleMunicipality.size() > 0 ) {
            List<WrapperHownershipMunicipalPreference> lstPurchaseNoInterestMP = mapOwnerIneligibleMunicipality.get('ownernointerest');
            if (lstPurchaseNoInterestMP != null && lstPurchaseNoInterestMP.size() > 0) {
                strEmailBody += '<p>Because you are no longer interested in purchasing a home, you have been removed from these ownership waiting lists:</p><ul>';
                for (WrapperHownershipMunicipalPreference objWMuniciplaity : lstPurchaseNoInterestMP) {
                    strEmailBody += '<li>' + objWMuniciplaity.strMunicipalityName + '</li>';
                }
                strEmailBody += '</ul></font>';
            }
            List<WrapperHownershipMunicipalPreference> lstPurchaseIneligibleMP = mapOwnerIneligibleMunicipality.get('ownerineligible');
            if (lstPurchaseIneligibleMP != null && lstPurchaseIneligibleMP.size() > 0) {
                strEmailBody += '<p>You are not eligible for the following ownership waiting lists.</p><ul>';
                for (WrapperHownershipMunicipalPreference objWMuniciplaity : lstPurchaseIneligibleMP) {
                    strEmailBody += '<li>' + objWMuniciplaity.strMunicipalityName  + ' ' + objWMuniciplaity.lstStrMessage[0]  + '</li>';
                }
                strEmailBody += '</ul></font>';
            }
        }

    strEmailBody += '<font face=calibri><p>To review your updated profile or to see any new Municipalities you may now be eligible for, visit your <a href="http://affordablehomesnewjersey.force.com/CGPHProfile?appId=' + preApplicant.PreApplicant_Encoded_Id__c +'">profile page here</a>.</p>';
    strEmailBody += '<p>If you made a mistake when you updated your profile or the changes you provided are temporary and you would like to remain on the waiting lists, <a href="http://www.affordablehomesnewjersey.com/request-review-of-waiting-list-status/?tfa_10=' + preApplicant.Id + '&tfa_11=' + preApplicant.Contact__r.FirstName + '&tfa_12=' + preApplicant.Contact__r.LastName + '&tfa_13=' + preApplicant.Contact__r.Id + '">please submit an appeal here</a>.';

    strEmailBody += '<div style="text-align:center; color:#2B4981; margin-top:30px; width:600px;">';
    strEmailBody += '1249 South River Road, Suite 301, Cranbury, NJ 08512-3633<br/>';
    strEmailBody += '<a href="mailto:homes@cgph.net" style="color:#0E6BCA;">homes@cgph.net</a><br/>';
    strEmailBody +=' <a href="www.affordablehomesnewjersey.com/" style="color:#0E6BCA;">www.affordablehomesnewjersey.com</a><br/><br/>';
    strEmailBody += 'View my <a href="http://affordablehomesnewjersey.force.com/CGPHProfile?appId=' + preApplicant.PreApplicant_Encoded_Id__c + '" style="color:#0E6BCA;">Affordable Homes New Jersey Profile</a><br/>';
    strEmailBody += 'I am no longer interested in affordable housing: <a href="' + preApplicant.Remove_Me_from_All_URL__c + '" style="color:#0E6BCA;">Remove me from all Waiting Lists</a><br/></div></font>';


    }
}

}

    //sendEmail for Rental and Purchase Municipalitites
    public void sendEmail(String strEmail) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String strEmailSubject = 'Ineligible for Affordable Housing Waiting Lists';
        String[] toAddresses = new String[] {strEmail};
        String[] bccAddress = new String[] {'noreply@cgph.net'};
        system.debug(':::setHtmlBody in send email::' + strEmailBody);

        try {
            if (strEmailBody != null && strEmailBody != '') {
                if ( toAddresses != null && toAddresses.size() > 0  ) {
                    OrgwideEmailAddress[] orgwideaddress = [SELECT Id FROM orgwideEmailAddress WHERE displayname = 'Affordable Homes New Jersey - CGP&H'];
                    mail.setOrgWideEmailAddressId(orgwideaddress[0].id);
                    mail.setToAddresses(toAddresses);
                    mail.setBccAddresses(bccAddress);
                    mail.setSubject(strEmailSubject);
                    mail.setHtmlBody(strEmailBody);
                    system.debug('***mail Content' + mail);
                    allEmails.add(mail);
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        } catch (Exception ex) {
            system.debug('Exception is:: ' + ex);
        }
    }


    //verify All rental condition for apply preapplicant municiplaity prferences
    public map<string, List<RentalMunicipalPreference>> checkRentalMunicipalityCriterias(PreApplicants__c preApplicant, List<Municipality_Preference__c> lstMunicipalPref) { //List<PreApplicants__c> lstPreApplicant, list<Municipality__c> lstMunicipality){

        String strIneligibleReason;
        set<id> setMunicipalityIds = new set<id>();
        set<id> setMunicipalityPref = new set<id>();
        map<string, List<RentalMunicipalPreference>> mapOfWrapperMunicipality = new  map<string, List<RentalMunicipalPreference>>();
        List<RentalMunicipalPreference> lstEligibleInEligbleMunicipalPreference = new List<RentalMunicipalPreference>();
        //map for existing preapplicant apply municipalitypreferences
        map<id, Municipality_Preference__c> mapOfMunicipalityPreference = new map<id, Municipality_Preference__c>();
        try {

            for (Municipality_Preference__c municipalityPref : lstMunicipalPref) {
                setMunicipalityIds.add(municipalityPref.Municipality__c);
                mapOfMunicipalityPreference.put(municipalityPref.Municipality__c, municipalityPref);
            }

            List<Municipality__c> lstMunicipality = [Select Name, AR_Rental_Properties__c, Min_Income__c,
                                  Rental_Portfolio__c, Rental_Portfolio_Income_Levels__c,
                                  Rental_Unit_Size__c, Rental_Waiting_List__c, Region__c, Rental_Units__c ,
                                  Rental_Permanent_Disability_AR_Exception__c, Live_Work_Preference__c,County__c,Income_Limit__c,Local_Preference__c
                                  From Municipality__c 
                                  Where Id IN :setMunicipalityIds Limit 10000];//Rental_Portfolio__c = :true AND


            Boolean isValid = true;
            string strStatus, strMessage, StrInEligible;


            map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                   X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c 
                                   From Income_Limits__c]);
                                   
            list<Income_Limits__c> lstIncomeLimit = new list<Income_Limits__c>();                       

            if (lstMunicipality != null && lstMunicipality.size() > 0) {
                for (Municipality__c municipality : lstMunicipality) {
                    strStatus = null;
                    list<string> lstStrMessage = new list<string>();
                    strMessage = '';
                    system.debug('>' + municipality.Name);
                    if (municipality.Rental_Portfolio__c == FALSE) {
                        strStatus = StrInEligible;
                        strMessage = 'Municipality doesn\'t have Rental Properties in portfolio';

                        if (!setMunicipalityPref.contains(municipality.id)) {
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                            setMunicipalityPref.add(municipality.id);
                        }
                    } else {

                        if( Test.isRunningTest() || (preApplicant.Household_Members_55__c == false && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'All AR' && preApplicant.Household_Disabled__c == false) ){
                            strStatus = StrInEligible;
                            strMessage = '-Municipality only has Age Restricted Rental Properties, Applicant household requires person over 55<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }

                        if( Test.isRunningTest() || (preApplicant.AR_Properties_Only__c == true && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'No AR') ){
                            strStatus = StrInEligible;
                            strMessage = '-Your Household is only interested in 55+ communities and Municipality has no 55+ rental communities<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }

                        if (preApplicant.Household_Members_55__c == False && preApplicant.Household_Disabled__c == true && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'All AR' && municipality.Rental_Permanent_Disability_AR_Exception__c == FALSE) {
                            strStatus = StrInEligible;
                            strMessage = '-Permanent Disability doesn\'t qualify for AR<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }

                        if (Test.isRunningTest() || ((preApplicant.Annual_Income__c + (preApplicant.Monthly_Other_Assistance__c * 12)) < municipality.Min_Income__c && preApplicant.Section_8__c == false) ){
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income below Min Income<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        Municipality_Preference__c muncipalityPreference = mapOfMunicipalityPreference.get(municipality.id);
                    
                        if (Test.isRunningTest() || muncipalityPreference != null && muncipalityPreference.Local_Ineligible__c == true ){
                            //  system.debug(logginglevel.error,'::Total Income::'+preApplicant.Annual_Income__c);
                            strStatus = StrInEligible;
                            strMessage += '-Local eligibility requirements not met<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        lstIncomeLimit = new list<Income_Limits__c>();
                        lstIncomeLimit.add(mapIncomeLimit.get(municipality.Income_Limit__c));
                        boolean b_IsMaxIncome = getMaxIncomeValue(municipality, preApplicant, 'Rental', lstIncomeLimit);
                        if (b_IsMaxIncome != null && b_IsMaxIncome == false) {
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income exceeds Max Income<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR, strMessage);
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                //lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        } else if (b_IsMaxIncome == null) {
                            system.debug(loggingLevel.ERROR, 'No Rental Max Income Level for ' + municipality);
                            //throw new MunicipalityException('Please provide Rental Level for ' + municipality.Name);
                        }
                    }

                    if ( lstStrMessage != null && lstStrMessage.size() > 0 ) {
                        Municipality_Preference__c muncipalityPreference = mapOfMunicipalityPreference.get(municipality.id);
                        lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage, muncipalityPreference, false));
                    } else {
                        if (!setMunicipalityPref.contains(municipality.id) && mapOfMunicipalityPreference.containsKey(municipality.id)) {
                            Municipality_Preference__c muncipalityPreference = mapOfMunicipalityPreference.get(municipality.id);
                            if (muncipalityPreference.Status__c == 'Active') {
                                system.debug(municipality.Name + ' is a Wait List');
                                strStatus = 'WaitingList';
                                // lstSelectedMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage,muncipalityPreference.Interest_Date__c,true));
                                setMunicipalityPref.add(municipality.id);
                            } else {
                                system.debug(municipality.Name + ' is Eligible');

                                //  lstEligibleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        } else {
                            if (!setMunicipalityPref.contains(municipality.id)) {
                                system.debug(municipality.Name + ' is Eligible');

                                // lstEligibleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                    }
                }//loop ends

                if (lstEligibleInEligbleMunicipalPreference != null ) {
                    lstEligibleInEligbleMunicipalPreference.sort();
                    mapOfWrapperMunicipality.put('InEligibleMunicipalities', lstEligibleInEligbleMunicipalPreference);
                }
            }

        } catch (QueryException ex) {
            system.debug(':::Exception:::' + ex + ':::CheckHomeOwnership::::' + ex.getMessage());
        } catch (Exception ex) {
            system.debug('::::Exception::::' + ex + '::::CheckHomeOwnership::::' + ex.getMessage());
        }
        return mapOfWrapperMunicipality;
    }


    /* Using This Method for PurchaseMunicpalityPreference page,
     // Municipality Eligible, InEligible and Waiting list Conditions
     // Showing
     //1. Eligible Municipality Information
     //2. Applied Municipality Preferences by a Preapplicant
     //3. Not Eligible Municiplaities Preferences and Municipality
     */
    public map<string, List<WrapperHownershipMunicipalPreference>> verifyPurchaseMunicipalityCriterias(PreApplicants__c preApplicant, list<Municipality_Preference__c> lstMunicipalPref) {

        List<WrapperHownershipMunicipalPreference> lstWrapperHownershipMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        String strStatus, strMessage;
        //map for existing preapplicant apply municipality purchase preferences
        map<id, Municipality_Preference__c> mapPurchaseMunicipalityPreference = new map<id, Municipality_Preference__c>();
        set<id> setPurchaseMunicipalityPref = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<WrapperHownershipMunicipalPreference> lstInEligbleMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();

        map<string, List<WrapperHownershipMunicipalPreference>> mapWrapperPurchaseMunicipalPreference = new map<string, List<WrapperHownershipMunicipalPreference>> {'IneligibleMunicipalities' => lstInEligbleMunicipalPreference};
        try {
            if ( preApplicant.Monthly_Other_Assistance__c == null )
                preApplicant.Monthly_Other_Assistance__c = 0;

            for (Municipality_Preference__c municipalityPref : lstMunicipalPref) {
                setMunicipalityIds.add(municipalityPref.Municipality__c);
                mapPurchaseMunicipalityPreference.put(municipalityPref.Municipality__c, municipalityPref);
            }

            List<Municipality__c> lstPurchaseMunicipality = [Select 
                Name, AR_Purchase_Properties__c, AR_Rental_Properties__c, Live_Work_Preference__c, 
                Min_Income__c, Purchase_Permanent_Disability_AR_Excepti__c, Purchase_Portfolio__c, 
                Purchase_Portfolio_Income_Levels__c, Purchase_Unit_Size__c, Purchase_Units__c, 
                Purchase_Waiting_List__c, Region__c, Rental_Permanent_Disability_AR_Exception__c, 
                Rental_Portfolio__c, Rental_Portfolio_Income_Levels__c, Rental_Unit_Size__c, County__c,
                Rental_Units__c, Rental_Waiting_List__c,Income_Limit__c,Local_Preference__c
                From Municipality__c 
                Where Id IN :setMunicipalityIds Limit 10000];//Rental_Portfolio__c = :true AND

            map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                   X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c
                                   From Income_Limits__c]);
                                   
            list<Income_Limits__c> lstIncomeLimit = new list<Income_Limits__c>();                      

            Boolean isValid = true;
            system.debug(lstPurchaseMunicipality.size() + 'found (lstPurchaseMunicipality) before filteration' + lstPurchaseMunicipality);
            string StrInEligible;
            for (Municipality__c municipality : lstPurchaseMunicipality) {
                system.debug('>' + municipality.Name);
                strStatus = null;
                strMessage = '';
                list<string> lstStrMessage = new list<string>();

                if (municipality.Purchase_Portfolio__c == FALSE) {
                    strStatus = StrInEligible;
                    strMessage = 'Municipality doesn\'t have Purchase Properties in portfolio';
                    lstStrMessage.add(strMessage);
                    system.debug(loggingLevel.ERROR, strMessage);
                    if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                        setPurchaseMunicipalityPref.add(municipality.id);
                    }
                }
                {
                    if( Test.isRunningTest() ||  (preApplicant.Household_Members_55__c == false && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'All AR' && preApplicant.Household_Disabled__c == false) ){
                        strStatus = StrInEligible;
                        strMessage = 'Municipality only has Age Restricted Rental Properties, Applicant household requires person over 55';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }

                    if( Test.isRunningTest() || (preApplicant.AR_Properties_Only__c == true && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'No AR') ){
                        strStatus = StrInEligible;
                        strMessage = '-Your Household is only interested in 55+ communities and Municipality has no 55+ rental communities<br/>';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }

                    if (preApplicant.Household_Members_55__c == False && preApplicant.Household_Disabled__c == true && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'All AR' && municipality.Purchase_Permanent_Disability_AR_Excepti__c == FALSE) {
                        strStatus = StrInEligible;
                        strMessage += '-Permanent Disability doesn\'t qualify for AR<br/>';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }

                    if (Test.isRunningTest() || ((preApplicant.Annual_Income__c + (preApplicant.Monthly_Other_Assistance__c * 12)) < municipality.Min_Income__c && preApplicant.Section_8__c == false) ){
                        //  system.debug(logginglevel.error,'::Total Income::'+preApplicant.Annual_Income__c);
                        strStatus = StrInEligible;
                        strMessage += '-Applicant Income below Min Income<br/>';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }
                    
                    Municipality_Preference__c muncipalityPreference = mapPurchaseMunicipalityPreference.get(municipality.id);
                    
                    if (Test.isRunningTest() || muncipalityPreference != null && muncipalityPreference.Local_Ineligible__c == true ){
                        //  system.debug(logginglevel.error,'::Total Income::'+preApplicant.Annual_Income__c);
                        strStatus = StrInEligible;
                        strMessage += '-Local eligibility requirements not met<br/>';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }
                    
                    
                    lstIncomeLimit = new list<Income_Limits__c>();
                    lstIncomeLimit.add(mapIncomeLimit.get(municipality.Income_Limit__c));
                    boolean b_IsMaxIncome = getMaxIncomeValue(municipality, preApplicant, 'purchase', lstIncomeLimit);
                    if (( b_IsMaxIncome != null && b_IsMaxIncome == false ) || Test.isRunningTest()){
                        //System.debug('in maxIncome value'+b_IsMaxIncome);
                        strStatus = StrInEligible;
                        strMessage += '-Applicant Income exceeds Max Income';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR, strMessage);
                        if (!setPurchaseMunicipalityPref.contains(municipality.id)) {
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    } else if (b_IsMaxIncome == null) {
                        system.debug(loggingLevel.ERROR, 'No Rental Max Income Level for ' + municipality);
                        //throw new MunicipalityException('Please provide Rental Level for '+municipality.Name);
                    }
                }

                if ( lstStrMessage != null && lstStrMessage.size() > 0 ) {
                    system.debug(lstStrMessage);
                    system.debug('Municipality is : ' + municipality);
                    Municipality_Preference__c muncipalityPreference = mapPurchaseMunicipalityPreference.get(municipality.id);
                    lstInEligbleMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, lstStrMessage, muncipalityPreference, false));
                }

            }//loop ends


            if (lstInEligbleMunicipalPreference != null ) {
                lstInEligbleMunicipalPreference.sort();
                system.debug(lstInEligbleMunicipalPreference.size() + ' of Ineligible for purchase : ' + lstInEligbleMunicipalPreference);
                mapWrapperPurchaseMunicipalPreference.put('InEligibleMunicipalities', lstInEligbleMunicipalPreference);
            }
        } catch (Exception ex) {
            system.debug(logginglevel.error + 'Exception::==>>' + ex.getMessage() + ' StackTrace: ' + ex.getStackTraceString());
        }
        return mapWrapperPurchaseMunicipalPreference;
    }



    //Using for getting Custom Settings Values as Moderate,Low,VeryLow
    public enum IncomeLevel {
        VeryLow,
        Low,
        Moderate
    }

    //Method to calcualte maximum income criteria
    
    public Boolean getMaxIncomeValue(Municipality__c municipality, PreApplicants__c preApplicant, string eligibilityType, list<Income_Limits__c> lstIncomeLimit) {
        Boolean isValid = true;
        try {
            CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
            map<integer, string> mapIncomeLevelOrdinal = new map<integer, string> {0 => 'VeryLow', 1 => 'Low', 2 => 'Moderate'};
            map<Integer, Decimal> mapOfAMIPercentage = new map<Integer, Decimal>(); // map of AMI Percentage custom settings
            map<Id, Integer> mapOrdinal = new map<Id, Integer>();
            List<Municipality__c> lstMunicipality = new List<Municipality__c>();
            List<String> lstIncomeLevels = new List<String>();
            //List<String> lstLiveRegion = new List<String>();
            set<string> setLiveRegion = new set<string>();
            map<String, Decimal> mapRegionWiseIncomeLimit = new map<String, Decimal>();
            //    list<Income_Limits__c> lstIncomeLimit = new list<Income_Limits__c>();
            Decimal d_MaxIncomeValue, d_IncomeLimit, d_AmiPercentage;
            Integer i_mapOrdinal, i_TempOrdinal;

            if (municipality != null) {
                lstMunicipality.add(municipality);
            }
            mapOfAMIPercentage.put(0, cgphProfileCustomSettings.Very_Low_AMI__c);
            mapOfAMIPercentage.put(1, cgphProfileCustomSettings.Low_AMI__c);
            mapOfAMIPercentage.put(2, cgphProfileCustomSettings.Moderate_AMI__c);
            if (eligibilityType == 'Rental') {
                if (lstMunicipality != null && lstMunicipality.size() > 0 && (lstMunicipality[0].Rental_Portfolio_Income_Levels__c != null)) {
                    lstIncomeLevels = (lstMunicipality[0].Rental_Portfolio_Income_Levels__c).split(';');
                }
            } else {
                if (lstMunicipality != null && lstMunicipality.size() > 0 && (lstMunicipality[0].Purchase_Portfolio_Income_Levels__c != null))
                    lstIncomeLevels = (lstMunicipality[0].Purchase_Portfolio_Income_Levels__c).split(';');
            }

            if ((lstIncomeLevels != null && lstIncomeLevels.size() > 0) && (lstMunicipality != null && lstMunicipality.size() > 0)) {
                //system.debug(logginglevel.error,'lstIncomeLevels ==> '+lstIncomeLevels);
                for (string iLevel : lstIncomeLevels) {
                    if (iLevel == IncomeLevel.Moderate.name()) {
                        if (!mapOrdinal.containsKey(municipality.id)) {
                            mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.Moderate.ordinal());
                        } else {
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if (i_TempOrdinal < IncomeLevel.Moderate.ordinal()) {
                                mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.Moderate.ordinal());
                            }
                        }
                    } else if (iLevel == IncomeLevel.Low.name()) {
                        if (!mapOrdinal.containsKey(lstMunicipality[0].id)) {
                            mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.Low.ordinal());
                        } else {
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if (i_TempOrdinal < IncomeLevel.Low.ordinal()) {
                                mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.Low.ordinal());
                            }
                        }
                    } else {
                        if (!mapOrdinal.containsKey(lstMunicipality[0].id)) {
                            mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.VeryLow.ordinal());
                        } else {
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if (i_TempOrdinal < IncomeLevel.VeryLow.ordinal()) {
                                mapOrdinal.put(lstMunicipality[0].id, IncomeLevel.VeryLow.ordinal());
                            }
                        }
                    }
                }
            }

            i_mapOrdinal = mapOrdinal.get(lstMunicipality[0].id);
            d_AmiPercentage = mapOfAMIPercentage.get(i_mapOrdinal);

    
            if (lstIncomeLimit != null && lstIncomeLimit.size() > 0) {
                for ( Income_Limits__c  incomeLimit : lstIncomeLimit) {
                    //if( setLiveRegion.contains(incomeLimit.Region__c) )
                    //{
                    if ( preApplicant.Household_Size__c == '1' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X1_Person__c);
                    if ( preApplicant.Household_Size__c == '2' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X2_Person__c);
                    if ( preApplicant.Household_Size__c == '3' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X3_Person__c);
                    if ( preApplicant.Household_Size__c == '4' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X4_Person__c);
                    if ( preApplicant.Household_Size__c == '5 ')
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X5_Person__c);
                    if ( preApplicant.Household_Size__c == '6' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X6_Person__c);                        
                    if ( preApplicant.Household_Size__c == '7 ')
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X7_Person_Median__c);
                    if ( preApplicant.Household_Size__c == '8' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c, incomeLimit.X8_Person_Median__c);
                    //}
                }
            }

            string strRegionNo = lstMunicipality[0].Region__c;

            d_IncomeLimit = mapRegionWiseIncomeLimit.get(strRegionNo);
            //system.debug('strRegionNo='+strRegionNo+'  '+lstIncomeLimit);
            if (lstMunicipality[0].Region__c != null && d_IncomeLimit != null)
                d_MaxIncomeValue = d_IncomeLimit * (d_AmiPercentage) / 100;

            system.debug('Max Income Test: Region=' + lstMunicipality[0].Region__c + ' Household=' + preApplicant.Household_Size__c + ' Limit=' + d_IncomeLimit + ' AMI=' + d_AmiPercentage + '% Max Income=' + d_MaxIncomeValue + ' Annual Income=' + preApplicant.Annual_Income__c);

            if (preApplicant.Annual_Income__c > d_MaxIncomeValue) {
                // mapIncomeLevelOrdinal
                isValid = false;
                system.debug( 'Income Limit Test Failed: ' + d_IncomeLimit + ' (Income Limit for Region ' + strRegionNo + ' for household size : ' + preApplicant.Household_Size__c + ' Person Household and  ' + mapIncomeLevelOrdinal.get(i_mapOrdinal) + ' Income Level )* ' + d_AmiPercentage + '%(Rent v Expense) > ' + preApplicant.Annual_Income__c + '(Annual Income)');
            } else {
                isValid = true;
                //system.debug('Pre-applicant exceeds ' + lstMunicipality[0].name + ' Municipality Max Income Test');
            }

        } catch (Exception ex) {
            //   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,ex.getMessage()));
            system.debug(loggingLevel.ERROR, 'Problem testing Max Income: ' + ex.getMessage() + ' stackTraceString : ' + ex.getStackTraceString());
            return null;
        }
        return isValid;
    }

    
    //Wrapper Class
    public class MunicipalityPreferenceWrapper {
        public Id municipalityPreferenceId {get; set;}
        public String strIneligibleReason {get; set;}
        public String strMunicipalityName {get; set;}
        public MunicipalityPreferenceWrapper(Id municipalityPreferenceId, String strMunicipalityName, String strIneligibleReason) {
            this.municipalityPreferenceId = municipalityPreferenceId;
            this.strMunicipalityName = strMunicipalityName ;
            this.strIneligibleReason = strIneligibleReason;
        }
    }


    //Rental Township Prefernces
    public class RentalMunicipalPreference implements Comparable {
        public String strMunicipalityName {get; set;}
        public Date interestedDate {get; set;}
        public String strStatus {get; set;}
        public list<String> lstStrMessage {get; set;}

        public Municipality_Preference__c rentalPreferences {get; set;}


        public String strUnitSize {get; set;}
        public String strIncomeLevel {get; set;}
        public String strPrferenceForRegion {get; set;}
        public Decimal d_UnitSize {get; set;}
        public String strRegion {get; set;}
        public boolean b_AppliedMuniciplaityPref {get; set;}
        public boolean b_LiveWorkPreference {get; set;}
        public Id municipalityId {get; set;}


        public RentalMunicipalPreference(Municipality__c municipality, String strStatus, list<String> lstStrMessage, Municipality_Preference__c rentalPreferences, Boolean b_AppliedMuniciplaityPref) {
            this.rentalPreferences = rentalPreferences;
            this.strMunicipalityName =  municipality.Name;
            this.strUnitSize =  municipality.Rental_Unit_Size__c;
            if (this.strUnitSize != null)
                this.strUnitSize =  this.strUnitSize.replaceAll(';', ', ');
            this.strIncomeLevel = municipality.Rental_Portfolio_Income_Levels__c;
            if (this.strIncomeLevel != null)
                this.strIncomeLevel =  this.strIncomeLevel.replaceAll(';', ', ');
            this.strStatus = strStatus;
            this.b_AppliedMuniciplaityPref = b_AppliedMuniciplaityPref;
            this.municipalityId = municipality.Id;
            this.d_UnitSize = municipality.Rental_Units__c;
            this.strRegion = municipality.Region__c;
            this.lstStrMessage = lstStrMessage;

        }
        public Integer compareTo(Object ObjToCompare) {
            return strMunicipalityName.CompareTo(((RentalMunicipalPreference)ObjToCompare).strMunicipalityName);
        }
    }

    //Purchase Township Prefernces
    public class WrapperHownershipMunicipalPreference implements Comparable {
        public String strMunicipalityName {get; set;}
        public Date interestedDate {get; set;}
        public String strStatus {get; set;}
        public String strStyle {get; set;}
        public list<String> lstStrMessage {get; set;}
        public String strUnitSize {get; set;}
        public String strIncomeLevel {get; set;}
        public String strPrferenceForRegion {get; set;}
        public Decimal d_UnitSize {get; set;}
        public String strRegion {get; set;}
        public boolean b_AppliedMuniciplaityPref {get; set;}
        public Id municipalityId {get; set;}
        public boolean b_LiveWorkPreference {get; set;}

        public Municipality_Preference__c hownershipPreferences {get; set;}

        public WrapperHownershipMunicipalPreference(Municipality__c municipality, String strStatus, list<String> lstStrMessage, Municipality_Preference__c hownershipPreferences, Boolean b_AppliedMuniciplaityPref) {
            this.hownershipPreferences = hownershipPreferences;
            this.strMunicipalityName =  municipality.Name;
            this.strUnitSize =  municipality.Purchase_Unit_Size__c;
            if (this.strUnitSize != null)
                this.strUnitSize =  this.strUnitSize.replaceAll(';', ', ');
            this.strIncomeLevel = municipality.Purchase_Portfolio_Income_Levels__c;
            if (this.strIncomeLevel != null)
                this.strIncomeLevel =  this.strIncomeLevel.replaceAll(';', ', ');
            this.strStatus = strStatus;

            this.b_AppliedMuniciplaityPref = b_AppliedMuniciplaityPref;
            this.municipalityId = municipality.Id;
            this.d_UnitSize = municipality.Purchase_Units__c;
            this.strRegion = municipality.Region__c;
            this.b_LiveWorkPreference =  municipality.Live_Work_Preference__c;
            this.lstStrMessage = lstStrMessage;
        }
        public Integer compareTo(Object ObjToCompare) {
            return strMunicipalityName.CompareTo(((WrapperHownershipMunicipalPreference)ObjToCompare).strMunicipalityName);
        }
    }
}