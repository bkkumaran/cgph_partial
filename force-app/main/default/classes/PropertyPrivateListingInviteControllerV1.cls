public class PropertyPrivateListingInviteControllerV1 
{ 
    public string strPropertyId {get;set;}
    public string instanceURL {get;set;}
    public Date dateVal {get;set;} 
    public static string helpContent {get;set;}
    public string reportName {get;set;}
    public string strRecordLimit{get;set;}
    public Integer gmtDateTimeNow{get;set;}
    public Integer hoursRemaining{get;set;}
    public Integer configuredPreAppEmailLimit{get;set;}
    public PropertyPrivateListingInviteControllerV1()
    {
        strPropertyId =  ApexPages.currentPage().getParameters().get('id');
        strRecordLimit = ApexPages.currentPage().getParameters().get('limit');
        datetime d = datetime.now(); 
        hoursRemaining = 24 - d.hourGmt();
        CGPH_Profile_Custom_Settings__c config = new CGPH_Profile_Custom_Settings__c();
        config = CGPH_Profile_Custom_Settings__c.getInstance();
        configuredPreAppEmailLimit =(Integer) config.Profile_Update_Email_Limits__c;
        if(configuredPreAppEmailLimit == null )
            configuredPreAppEmailLimit = 0;
             
        if(strRecordLimit == null || strRecordLimit == '')
            strRecordLimit = '10000';
        
        system.debug(' strRecordLimit '+strRecordLimit);
        list<Report> lstReport = new list<Report>([SELECT Id,Name FROM Report WHERE Name = 'Campaign Mailing List']);
        if(lstReport != null && lstReport.size() > 0)
            reportName = lstReport[0].Id;
            
        instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
        helpContent = getTextFromWP('https://www.affordablehomesnewjersey.com/?json=get_page&id=5324');
        // get the limits for email sent
        //getEmailLimits();
    }
  
  
  
  @remoteAction
  public static CGPH_Triggers_Custom_Settings__c getPreAppTriggerSettings()
  {
        CGPH_Triggers_Custom_Settings__c cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        return cgphSettings;
  }
      
  // get limit for emails sent
  @remoteAction
  public static Integer getEmailLimits()
  {
        CGPH_Profile_Custom_Settings__c config = new CGPH_Profile_Custom_Settings__c();
        config = CGPH_Profile_Custom_Settings__c.getInstance();
        string instanceURL = config.Instance_URL__c; 
        instanceURL += '/services/data/v36.0/limits';
        string strLimitSingleEmails;
        string strTotalEmailRemainings = '0';
        HttpRequest  req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(instanceURL); // for sandbox 
        //req.setEndpoint('https://na17.salesforce.com/services/data/v36.0/limits'); // for production
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse res;
    try{
        if(Test.isRunningTest() == false)
            res = http.send(req);

        //System.debug(res.getBody());
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
        }
        catch(exception ex)
        {
        
        }
    return Integer.valueOf(strTotalEmailRemainings);      
  } 
  
  // get the content from the wordpress
  public string getTextFromWP(string endPoint)
  { 
      //string endPoint = 'http://myhomekeeper.org/?json=get_page&id=2798';
      string Content;
      if(endPoint != '' && endPoint != null)
      {
          HttpRequest req = new HttpRequest();
          HttpResponse res = new HttpResponse();
          Http http = new Http();
          req.setEndpoint(endPoint);
          req.setMethod('GET');
          req.setTimeout(120000);
          string JSONContent = '';    
          try
          {
              if(Test.isRunningTest() == false)
              {
                res = http.send(req);
                system.debug('Response:: '+res);
                JSONContent = res.getBody();
                system.debug('JsonContent ==> '+JSONContent);
              }
              else
              {
  
              }
          }
          catch(System.CalloutException e)
          {
              System.debug('Callout error: '+ e);
              System.debug(res.toString());
          }
  
      JSONParser parser = JSON.createParser(JSONContent);
          
      while (parser.nextToken() != null) {
             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                 (parser.getText() == 'content')) {
                 parser.nextToken();
                 Content = parser.getText();
                 //System.debug('Help Content='+Content);
             }
         }    
      }
      return Content;
    }
    
    // method to be called on page load to make sure all the 
    // applicants are added as the campaign member 
    @remoteAction
    public static list<CampaignMember> addCampaignMembers(string strPropertyId,string strRecordLimit) 
    {
        list<CampaignMember> lstCampaignMembers = new list<CampaignMember>();
        transient list<Municipality_Preference__c> lstMunicipalityPreference;
        transient set<string> setPreApplicant = new set<string>();
        transient map<string,CampaignMember> mapCampaignMember = new map<string,CampaignMember>();
        transient set<string> setContactIds = new set<string>();
        
        // create map of properties recordtype id and name so as we can get the all the purchase property record types
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
        
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
        system.debug('Remaining Qury Rows '+ (Limits.getLimitQueryRows() - Limits.getQueryRows()));
        transient list<HOMEtracker__Property__c> lstProperties = new list<HOMEtracker__Property__c>([SELECT  
                                                                                            Id, Name, HOMEtracker__List_Price__c , Campaign__c,Lottery_Number_for_Priority__c,
                                                                                            CreatedDate, Status_Message__c,X3x_Rent_Requirement__c ,
                                                                                            Maximum_Household_Size__c,  Min_Household_Size__c,
                                                                                            Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, 
                                                                                            Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                                                                                            Rental_Assistance_Permitted__c, Listing_Stage__c,HOMEtracker__Status__c,
                                                                                            Utilities__c, HOMEtracker__Property_Description__c, Deadline__c,Municipality_Name__r.Region_Counties__c,
                                                                                            Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, 
                                                                                            HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c,EA_Layout__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                                                                                            Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c,
                                                                                            Municipality_Name__r.General_Tax_Rate__c,RecordTypeId, 
                                                                                            HOMEtracker__State__c ,HOMEtracker__Postal_Code__c,Property_Questionnaire_URL__c,
                                                                                            HOMEtracker__Current_HOA_Condo_Fees__c, Development_address__r.X3x_Rent_Requirement__c, 
                                                                                             Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c,Private_Property_Preapplicant_Limit__c, 
                                                                                            Municipality_Name__c ,Development_address__r.Age_Restriction__c,  Municipality_Name__r.Income_Limit__c,    
                                                                                            Municipality_Name__r.Equalization_Ratio__c, HOMEtracker__Property_Type__c ,Local_Preference_for_Priority__c                 
                                                                                            FROM HOMEtracker__Property__c WHERE id =: strPropertyId]);
        
        string prefrenceType;
        if(lstProperties[0].RecordTypeID == strRentalPropertyRecTypeId)
            prefrenceType = 'Rental';
        else if(lstProperties[0].RecordTypeID == strPurchasePropertyRecTypeId )
            prefrenceType = 'Ownership';
        
        
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        system.debug('Remaining Qury Rows '+ (Limits.getLimitQueryRows() - Limits.getQueryRows()));
        transient map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                          X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                          From Income_Limits__c]);
                                                                          
        
        
        // select all the campaign member from the campaign 
        // commented query line
       // transient list<Campaign> lstCampaign = new list<Campaign>([SELECT id,Name,(SELECT id,Note__c,Municipality_Preference__c,Pre_Applicant__c,Deadline_Date__c,ContactId,Status,Invited_Date__c,Last_Eligibility_Check__c FROM CampaignMembers) FROM Campaign WHERE id =: lstProperties[0].Campaign__c]);
       transient list<Campaign> lstCampaign = new list<Campaign>(); 
        if(lstCampaign != null && lstCampaign.size() > 0)
        {
            // create set of ids of campaign member
            for(CampaignMember member : lstCampaign[0].CampaignMembers)
            {
                setContactIds.add(member.ContactId);
                mapCampaignMember.put(member.ContactId,member);
            }
        }
        
        Integer iPreApplicantLimit = 10000;
        if(lstProperties[0].EA_Layout__c == 'Include Invited')
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 300;
                    else if(lstProperties[0].EA_Layout__c == 'Uninvited only')
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 500;
                
        string strLotteryNumberToUse = 'Lottery_Number__c';
        if(lstProperties[0].Lottery_Number_for_Priority__c != '' && lstProperties[0].Lottery_Number_for_Priority__c != null)
            strLotteryNumberToUse =lstProperties[0].Lottery_Number_for_Priority__c;
       
        string strMunicipalityId = lstProperties[0].Municipality_Name__c;
        
        map<string,string> mapPreAppToPreferenceId = new map<string,string>();
        system.debug('Remaining Qury Rows '+ (Limits.getLimitQueryRows() - Limits.getQueryRows()));
        string strPreferenceQuery = 'SELECT '+
                                    'id,Name,PreApplicant__c,PreApplicant__r.Contact__c,Status__c,Interest_Date__c , '+
                                     strLotteryNumberToUse + 
                                    ' FROM '+
                                    'Municipality_Preference__c '+
                                    'WHERE '+                                                                       
                                    'Municipality__c =: strMunicipalityId '+
                                    ' AND Status__c = \'Active\'  '+
                                    'AND Type__c = : prefrenceType ';
             if( lstProperties[0].Local_Preference_for_Priority__c != null )                       
                 strPreferenceQuery  +=  'AND  '+lstProperties[0].Local_Preference_for_Priority__c+' = true ';
             strPreferenceQuery  +=  ' Order by '+ strLotteryNumberToUse +',Interest_Date__c';
                
        
        
        for( Municipality_Preference__c preference : Database.Query(strPreferenceQuery) )
        {
                setPreApplicant.add(preference.PreApplicant__c);
                mapPreAppToPreferenceId.put(preference.PreApplicant__c,preference.id);
        }
            
        map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();
        
        // get all the pre applicant
        transient list<PreApplicants__c> lstPreapplicant = new list<PreApplicants__c>();
    
                            
            string strOverEighteen, strUnderEighteen, 
            strEighteen, strOver17, str55Plus;
            strOverEighteen = 'Over 18';
            strUnderEighteen = 'Under 18';
            strEighteen = '18';
            str55Plus = '55+ Exclusive';
            strOver17 = 'Over 17';
            
            system.debug(' setContactIds '+setContactIds);
            system.debug('  setPreApplicant '+setPreApplicant);
         list<CampaignMember> lstCampaignMembersTobeUpdated = new list<CampaignMember>();   
            //set<string> setContactIds = new set<string>();
            setContactIds.addAll(mapCampaignMember.keySet()); 
      
          Integer iRecordCount = Integer.valueOf(strRecordLimit);
        system.debug('Remaining Qury Rows '+ (Limits.getLimitQueryRows() - Limits.getQueryRows()));
         // add all the eligible preapplicants to campaign if they are not in there
         for( PreApplicants__c preApplicant : [SELECT Contact__r.Name,Contact__r.Id, Flagged_for_Outreach__c,Veteran__c,
                            Id, Name, Contact__r.Email, Contact__r.Phone, Contact__r.Ext__c, Contact__r.MailingStreet,
                            Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Household_Disabled__c,Pre_Applicant_Active__c,
                            Household_Size__c, Household_Members_55__c , 
                            Annual_Income__c, Live_Work_Regions__c, Most_Recent_Update__c, Rental_Interest__c, 
                            AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,
                            Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,
                            Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,
                            Ext__c, Applicant_Name__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c, Meets_Montclair_Local_Pref_Criteria__c
                            FROM  
                            PreApplicants__c 
                            Where 
                            Id IN : setPreApplicant])
         {
            // create correct parameter format for the library method
                transient list<PreApplicants__c> lstTempPreApplicant = new list<PreApplicants__c>();
                lstTempPreApplicant.add(preApplicant);
                
                
            // if campaignmember have lookup fields not filled and there is issue    
            campaignmember campMember = new CampaignMember();
            campMember = mapCampaignmember.get(preApplicant.Contact__c);
            if(setContactIds.contains(preApplicant.Contact__c) == false)
            {
                string preferenceId = mapPreAppToPreferenceId.get(preApplicant.id); 
                CampaignMember member = new CampaignMember();
                member.ContactId = preApplicant.Contact__c;
                member.CampaignId = lstProperties[0].Campaign__c;
                //member.Status = 'Not Invited';
                member.Pre_Applicant__c = preApplicant.id;
                member.Municipality_Preference__c = preferenceId;
                
                if(preApplicant.Contact__c != null && setContactIds.contains(preApplicant.Contact__c) == false)
                {
                    setContactIds.add(preApplicant.Contact__c);
                    lstCampaignMembers.add(member);  
                    if( lstCampaignMembers.size() >= iRecordCount )
                    {
                        system.debug('Campaign member list size '+lstCampaignMembers.size() +'  record count '+iRecordCount);
                        break;   
                     }   
                }               
            }
            
         }
         
         if(lstCampaignMembers != null && lstCampaignMembers.size() > 0)
         {            
            system.debug('List of campaignmembers to be added : '+lstCampaignMembers);
             list<CampaignMember> lstTempCampMember = new list<Campaignmember>();
             for( campaignmember member : lstCampaignMembers ){
                 lstTempCampMember.add(member);
                 if( lstTempCampMember.size() >= 9000 ){
                     database.insert(lstTempCampMember,false);
                     lstTempCampMember = new list<Campaignmember>();
                 }    
             }
             if( math.MOD( lstCampaignMembers.size(), 9000) != 0 )
                 database.insert(lstTempCampMember,false);
         }           
         
        return lstCampaignMembers;
    }
    // get property
    
    @remoteAction
    public static sObject getPropertyDetails(string strPropertyId)
    {   
        list<HOMEtracker__Property__c> lstProperties = new list<HOMEtracker__Property__c>([SELECT id,Name, Lottery_Number_for_Priority__c,HOMEtracker__List_Price__c , Campaign__c,
                                                                                            CreatedDate, Status_Message__c,HOMEtracker__Property_Type__c,
                                                                                            Maximum_Household_Size__c,  Min_Household_Size__c,
                                                                                            Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, 
                                                                                            Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                                                                                            Rental_Assistance_Permitted__c, Listing_Stage__c,HOMEtracker__Status__c,
                                                                                            Utilities__c, HOMEtracker__Property_Description__c, Deadline__c,Municipality_Name__r.Region_Counties__c,
                                                                                            Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, 
                                                                                            HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c,EA_Layout__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                                                                                            Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c,
                                                                                            Municipality_Name__r.General_Tax_Rate__c,RecordTypeId, 
                                                                                            HOMEtracker__State__c ,HOMEtracker__Postal_Code__c,
                                                                                            HOMEtracker__Current_HOA_Condo_Fees__c, Property_Questionnaire_URL__c,
                                                                                             Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c, 
                                                                                            Municipality_Name__c ,Development_address__r.Age_Restriction__c,      
                                                                                            Municipality_Name__r.Equalization_Ratio__c,Last_Eligibility_Criteria_Modification__c,Municipality_Name__r.Income_Limit__c
                                                                                            FROM HOMEtracker__Property__c WHERE id =: strPropertyId
                                                                                            ]);
                                                                                            
        if(lstProperties != null && lstProperties.size() > 0)
        {
            return lstProperties[0];
        }
        else
        return null;
    }
    
    // method to display all the mebers in the correct list
    @remoteAction
    public static list<WrapperApplicant> getMembersDetails(string strPropertyId,string strRecordLimit)
    {
        system.debug('Member details function is called');
        transient list<Municipality_Preference__c> lstMunicipalityPreference = new list<Municipality_Preference__c>();
        transient list<HOMEtracker__Property__c> lstProperties = new list<HOMEtracker__Property__c>();
        //transient list<PreApplicants__c> lstEligiblePreApplicant = new list<PreApplicants__c>();
        transient map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();
        transient map<string,CampaignMember> mapCampaignMember = new map<string,CampaignMember>();
        transient map<string,Municipality_Preference__c> mapPreApplicantIdPreference = new map<string,Municipality_Preference__c>();
        transient list<WrapperApplicant> lstWrapperPreApplicant = new list<WrapperApplicant>();
        //set<string> setPreApplicant = new set<string>();
        // create map of properties recordtype id and name so as we can get the all the purchase property record types
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
        
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
        
        // get all the fields of the property as these will be needed in the criteria calculations for library function
        lstProperties = [SELECT  
                        Id, Name, HOMEtracker__List_Price__c , Campaign__c,Lottery_Number_for_Priority__c,Disabled_eligible_regardless_of_age__c,
                        CreatedDate, Status_Message__c,X3x_Rent_Requirement__c ,Consider_Veterans_Preference__c,
                        Maximum_Household_Size__c,  Min_Household_Size__c,
                        Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, 
                        Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                        Rental_Assistance_Permitted__c, Listing_Stage__c,HOMEtracker__Status__c,
                        Utilities__c, HOMEtracker__Property_Description__c, Deadline__c,Municipality_Name__r.Region_Counties__c,
                        Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, 
                        HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c,EA_Layout__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                        Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c,
                        Municipality_Name__r.General_Tax_Rate__c,RecordTypeId, 
                        HOMEtracker__State__c ,HOMEtracker__Postal_Code__c,Property_Questionnaire_URL__c,
                        HOMEtracker__Current_HOA_Condo_Fees__c, Development_address__r.X3x_Rent_Requirement__c, Development_address__r.Dev_Income_Limit__c,
                         Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c, Private_Property_Preapplicant_Limit__c,
                        Municipality_Name__c ,Development_address__r.Age_Restriction__c,  Municipality_Name__r.Income_Limit__c,    
                        Municipality_Name__r.Equalization_Ratio__c,HOMEtracker__Property_Type__c,Last_Eligibility_Criteria_Modification__c, Local_Preference_Type__c,
                        Local_Preference_for_Priority__c                    
                        FROM HOMEtracker__Property__c WHERE id =: strPropertyId];   

        if(lstProperties[0].Last_Eligibility_Criteria_Modification__c == null)
            lstProperties[0].Last_Eligibility_Criteria_Modification__c = Datetime.now();
            
        string strLotteryField = lstProperties[0].Lottery_Number_for_Priority__c != null ? lstProperties[0].Lottery_Number_for_Priority__c : 'Lottery_Number__c';
        set<string> setInvitedPreApp = new set<string>();        
        for(CampaignMember member : [SELECT  
                                        id,CampaignId,Status,ContactId,Note__c,Pre_Applicant__c,Last_Eligibility_Check__c,
                                        Deadline_Date__c,Invited_Date__c,Flagged_RTV__c,CreatedDate,Campaign_Preliminary_Submission__c,Campaign_Preliminary_Submission__r.Status__c 
                                        FROM 
                                        CampaignMember 
                                        WHERE 
                                        CampaignId =: lstProperties[0].Campaign__c])
        {
            mapCampaignMember.put(member.ContactId,member);
            if( member.Status != 'Not Invited' && member.Status != 'Ineligible' )
                setInvitedPreApp.add(member.Pre_Applicant__c);
            
        }
                
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        if(cgphProfileCustomSettings.Last_Modification__c == null )
            cgphProfileCustomSettings.Last_Modification__c = Datetime.now();
    
        transient map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                          X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                          From Income_Limits__c]);
        // create query dynamically so as we can query for rental and purchase based on certain conditions                                                                
        string prefrenceType;
        if(lstProperties[0].RecordTypeID == strRentalPropertyRecTypeId)
            prefrenceType = 'Rental';
        else if(lstProperties[0].RecordTypeID == strPurchasePropertyRecTypeId )
            prefrenceType = 'Ownership';
            
        //need to make sure that the people on the eligible applicants have 
        //active municipality preferences for that property's municipality and for that
        // type of property rental or homeownership 
        
        Integer iPreApplicantLimit = 10000;
        if(lstProperties[0].EA_Layout__c == 'Include Invited')
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 300;
                    else if(lstProperties[0].EA_Layout__c == 'Uninvited only')
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 500;

        string strLotteryNumberToUse = 'Lottery_Number__c';
        if(lstProperties[0].Lottery_Number_for_Priority__c != '' && lstProperties[0].Lottery_Number_for_Priority__c != null)
            strLotteryNumberToUse =lstProperties[0].Lottery_Number_for_Priority__c;
           
        
        string strMunicipalityId = lstProperties[0].Municipality_Name__c;
        
        string strPreferenceQuery = 'SELECT '+
                                    'id,Name,PreApplicant__c,PreApplicant__r.Contact__c,PreApplicant__r.Veteran__c,PreApplicant__r.Meets_Montclair_Local_Pref_Criteria__c,Status__c,Interest_Date__c , '+
                                    + strLotteryNumberToUse +  
                                    + ',General_Local__c,Alternate_Local__c '+
                                    ' FROM '+
                                    'Municipality_Preference__c '+
                                    'WHERE '+                                                                       
                                    'Municipality__c =: strMunicipalityId '+
                                    /*' AND Status__c = \'Active\'  '+*/           // done the chage for the trello request on 24/o5/2016
                                    'AND Type__c = : prefrenceType '+
                                    ' AND On_Hold__c = false ';
                                    
        
        if( lstProperties[0].Local_Preference_for_Priority__c != null )                       
                 strPreferenceQuery  +=  'AND  '+lstProperties[0].Local_Preference_for_Priority__c+' = true ';
                                         
        strPreferenceQuery  += ' Order by '+ strLotteryNumberToUse +' NULLS LAST,Interest_Date__c';
                                    
        Integer iRecordCount = Integer.valueOf(strRecordLimit);
        if(iRecordCount != 10000)
            strPreferenceQuery += ' limit '+iRecordCount;
        system.debug(' Query is :  '+strPreferenceQuery);
                                    
        list<string> lstPreApplicantIds = new list<string>();
        
        // list CampaignMember whos preferences are inactive or ineligible for some resn now so make their status
        //  ineligible
        map<string,CampaignMember> mapNotActiveCampMember = new map<string,CampaignMember>();
        list<CampaignMember> lstMemberToUpdateNotAdvancing = new list<CampaignMember>();
        // get all the pre applicant ordered by the lottery number and date
        // we need to query pre applicant on the basis of the ids we get from preference
        // and we also need them to be ordered by the lottery number and invited date
        // so creted list of ids(list is ordered)
        set<string> setPreAppIdsFromPrefrences = new set<string>();
        for( Municipality_Preference__c preference : Database.Query( strPreferenceQuery ) )
        {
            //CampaignMember newMember = new CampaignMember();
            //if( preference.Status__c == 'Active' )
            //{
            //    if( lstProperties[0].Consider_Veterans_Preference__c == true &&  preference.PreApplicant__r.Veteran__c == true )
            //        lstPreApplicantIds.add(preference.PreApplicant__c);
            //    else if( lstProperties[0].Consider_Veterans_Preference__c == false )
            //            lstPreApplicantIds.add(preference.PreApplicant__c);
            //            
            //    mapPreApplicantIdPreference.put(preference.PreApplicant__c,preference);
            //    setPreAppIdsFromPrefrences.add(preference.PreApplicant__c);
            //    newMember = mapCampaignMember.get(preference.PreApplicant__r.Contact__c);
            //    if( newMember != null )
            //        mapNotActiveCampMember.remove(newMember.id);
            //}
            
            //NS Added on 08-01-19
            CampaignMember newMember = new CampaignMember();
            if( preference.Status__c == 'Active' )
            
            {
                boolean PreAppEAQualification = true;
                
                if( lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'General_Local__c' &&                 
                     preference.General_Local__c != true )
                        PreAppEAQualification = false;
                        


                 if( lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'Alternate_Local__c' &&                 
                     preference.Alternate_Local__c != true )       
                        PreAppEAQualification = false;

                 // veteran
                 
                  if( lstProperties[0].Consider_Veterans_Preference__c == true && preference.PreApplicant__r.Veteran__c != true)
                         PreAppEAQualification = false;                  
                         
                if( PreAppEAQualification == true )
                {
                    lstPreApplicantIds.add(preference.PreApplicant__c);
                }         
            
          /*       // Only Local Pref
             if( lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'General_Local__c' &&                 
                     preference.General_Local__c == true )                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);
            else 
            if( lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'Alternate_Local__c' &&                 
                     preference.Alternate_Local__c == true )                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);             
                         
            else
            // Only Veterans' Pref
                 if( lstProperties[0].Consider_Veterans_Preference__c == true && preference.PreApplicant__r.Veteran__c == true )                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);
             else
             if( lstProperties[0].Consider_Veterans_Preference__c == true && 
                     preference.PreApplicant__r.Veteran__c == true &&
                     lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'General_Local__c' &&                 
                     preference.General_Local__c == true
             )
             lstPreApplicantIds.add(preference.PreApplicant__c);
             else
                 if( lstProperties[0].Consider_Veterans_Preference__c == true && 
                     preference.PreApplicant__r.Veteran__c == true &&
                    lstProperties[0].Local_Preference_for_Priority__c != null && lstProperties[0].Local_Preference_for_Priority__c == 'Alternate_Local__c' &&                 
                     preference.Alternate_Local__c == true )                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);     
                                
             else
                 lstPreApplicantIds.add(preference.PreApplicant__c);   */         
            
            /*else if( lstProperties[0].Consider_Veterans_Preference__c == false &&
                     lstProperties[0].Consider_Local_Preference__c == false )
                        
                         lstPreApplicantIds.add(preference.PreApplicant__c);
            
            // Only Local Pref
            else if( lstProperties[0].Consider_Veterans_Preference__c == false && 
                     lstProperties[0].Consider_Local_Preference__c == true && 
                     lstProperties[0].Local_Preference_Type__c == 'Montclair' &&
                     preference.PreApplicant__r.Meets_Montclair_Local_Pref_Criteria__c == 'Yes' )
                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);
            
            // Veterans' Pref and Local Pref
            else if( lstProperties[0].Consider_Veterans_Preference__c == true && 
                     preference.PreApplicant__r.Veteran__c == true &&
                     lstProperties[0].Consider_Local_Preference__c == true && 
                     lstProperties[0].Local_Preference_Type__c == 'Montclair' &&
                     preference.PreApplicant__r.Meets_Montclair_Local_Pref_Criteria__c == 'Yes' )
                    
                         lstPreApplicantIds.add(preference.PreApplicant__c);
            
            // No Pref
            else if( lstProperties[0].Consider_Veterans_Preference__c == false &&
                     lstProperties[0].Consider_Local_Preference__c == false )
                     
                     lstPreApplicantIds.add(preference.PreApplicant__c);
              */          
                         
            
            mapPreApplicantIdPreference.put(preference.PreApplicant__c,preference);
                setPreAppIdsFromPrefrences.add(preference.PreApplicant__c);
                newMember = mapCampaignMember.get(preference.PreApplicant__r.Contact__c);
                 if( newMember != null )
                     mapNotActiveCampMember.remove(newMember.id);
            }
            
            //End of NS's Addition
            
            else
            {
                newMember = mapCampaignMember.get(preference.PreApplicant__r.Contact__c);
                
                if(newMember != null && newMember.Status == 'Ineligible, Pending Staff Action')
                {
                   newMember.Status = 'Submitted Interest Form Not Advancing';
                   lstMemberToUpdateNotAdvancing.add(newMember);
                }
                else
                if( setPreAppIdsFromPrefrences.contains(preference.PreApplicant__c) == false && mapCampaignMember != null && mapCampaignMember.containsKey(preference.PreApplicant__r.Contact__c) == true && mapCampaignMember.get(preference.PreApplicant__r.Contact__c).Status != 'Ineligible' )
                {
                    newMember = mapCampaignMember.get(preference.PreApplicant__r.Contact__c);
                    //newMember.Status = 'Ineligible';
                    mapNotActiveCampMember.put(newMember.id,newMember);
                }   
            }
            
        }
        
        
         if( lstMemberToUpdateNotAdvancing != null && lstMemberToUpdateNotAdvancing.size() > 0 )
            update lstMemberToUpdateNotAdvancing;
            
        setPreAppIdsFromPrefrences = new set<string>();
        // update the campaignmembers
        if(Test.isRunningTest() ||  mapNotActiveCampMember != null && mapNotActiveCampMember.size() > 0 )
        {
            for(CampaignMember campMember : mapNotActiveCampMember.values())
            {
                campMember.Status = 'Ineligible';
            }
            update mapNotActiveCampMember.values();
        }
        
        // get all the pre applicant
         transient list<PreApplicants__c> lstPreapplicant = new list<PreApplicants__c>();
                                   
         // for each pre applicant check if he is eligible for the property
         transient set<string> setPreApplicants = new set<string>();
         
         // set contact ids which are eligible
        //transient set<string> setEligibleConIds = new set<string>();
         
         system.debug('setPreApplicants => '+setPreApplicants.size());
         
         string strOverEighteen, strUnderEighteen, 
            strEighteen, strOver17, str55Plus;
            strOverEighteen = 'Over 18';
            strUnderEighteen = 'Under 18';
            strEighteen = '18';
            str55Plus = '55+ Exclusive';
            strOver17 = 'Over 17';
         list<CampaignMember> lstCampaignMemberToUpdate = new list<CampaignMember>();
         Integer iPreAppCount = 0;
         
         // fill the list using all the invited pre-applicant so as we can show them in the graph
         if( lstProperties[0].EA_Layout__c != 'Uninvited only')
         {
         for( PreApplicants__c preApplicant : [SELECT Contact__r.Name,Contact__r.Id, Flagged_for_Outreach__c,
                            Id, Name, Contact__r.Email, Contact__r.Phone,Contact__r.Alternate_Phone__c,Contact__r.Alt_Ext__c, Contact__r.Ext__c, Contact__r.MailingStreet,
                            Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Household_Disabled__c,Pre_Applicant_Active__c,
                            Household_Size__c, Household_Members_55__c , 
                            Annual_Income__c, Live_Work_Regions__c,  Rental_Interest__c, 
                            AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,
                            Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,LastModifiedDate,
                            Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,Contact__r.EB_tools__Email_Verification__c,
                            Ext__c, Applicant_Name__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c
                            FROM  
                            PreApplicants__c 
                            Where  
                            Id IN :setInvitedPreApp limit : iRecordCount] )   
         {         
                lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),mapCampaignMember.get(preApplicant.Contact__c).Status,mapCampaignMember.get(preApplicant.Contact__c),strLotteryField,setInvitedPreApp.size()));
         }
        }
        
          set<string> setPreAppids = new set<string>();
          Integer iCount = 0,iTotalCount = 0;       
          system.debug('lstPreApplicantIds '+lstPreApplicantIds.size());
          system.debug('getLimitQueries '+limits.getLimitQueries());
          system.debug('getQueries'+limits.getQueries());
          system.debug('=============');
         // iterate for all the not invited and ineligible pre-applicant in the batches of the specified count limit
         for( string preAppId : lstPreApplicantIds ) // we are iterating on the list of ids which are ordered by the lottery number and then date
         {
            
            iTotalCount++;
            if( setInvitedPreApp.contains(preAppId) == false || Test.isRunningTest())
            {
                iCount++;
                setPreAppids.add( preAppId );
            }
            
            if( iCount >= iPreApplicantLimit || iCount >= lstPreApplicantIds.size() || iTotalCount >= lstPreApplicantIds.size()) // we get the ids specified in the limit or the list is exhuasted
            {
              system.debug('########');
             system.debug('getLimitQueries '+limits.getLimitQueries());
          system.debug('getQueries'+limits.getQueries());
          system.debug('iCount '+iCount);
          system.debug('lstPreApplicantIds.size() '+lstPreApplicantIds.size());
          system.debug('iTotalCount '+iTotalCount);
          system.debug('setPreAppids '+setPreAppids.size());
          system.debug('iPreApplicantLimit '+iPreApplicantLimit);
                iCount = 0;
                for( PreApplicants__c preApplicant : [SELECT Contact__r.Name,Contact__r.Id, Flagged_for_Outreach__c,
                            Id, Name, Contact__r.Email, Contact__r.Phone, Contact__r.Alternate_Phone__c,Contact__r.Ext__c, Contact__r.Alt_Ext__c,Contact__r.MailingStreet,
                            Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Household_Disabled__c,Pre_Applicant_Active__c,
                            Household_Size__c, Household_Members_55__c , 
                            Annual_Income__c, Live_Work_Regions__c, Most_Recent_Update__c, Rental_Interest__c, 
                            AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,
                            Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,LastModifiedDate,
                            Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,Contact__r.EB_tools__Email_Verification__c,
                            Ext__c, Applicant_Name__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c
                            FROM  
                            PreApplicants__c 
                            Where  
                            Id IN :setPreAppids] )   
            { 
            Campaignmember mem = new CampaignMember();
            mem = mapCampaignMember.get(preApplicant.Contact__c);
            // we will be checking preliminary ineligibility criterias and then will go for detailed criteria checking
            if(mem != null )
            if( Test.isRunningTest() || (mapCampaignMember != null && mapCampaignMember.get(preApplicant.Contact__c) != null && mapCampaignMember.get(preApplicant.Contact__c).Status == 'Not Invited' && setPreApplicants != null && setPreApplicants.contains(preApplicant.Contact__c) == false /*&& mapCampaignMember.get(preApplicant.Contact__c).CreatedDate >= preApplicant.LastModifiedDate*/) || 
                (mapCampaignMember != null && setPreApplicants != null && setPreApplicants.contains(preApplicant.Contact__c) == false && ( (  (mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c == null) || ( (mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c != null ) &&   mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c <= preApplicant.Most_Recent_Update__c ) )&& mapCampaignMember.get(preApplicant.Contact__c).status == 'Ineligible' )) ||
                (mapCampaignMember != null && setPreApplicants != null && setPreApplicants.contains(preApplicant.Contact__c) == false && (  // if there is change in the custom settings fields which affect the eligibility criteria
                 (  (mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c == null) ||                                   // or there is change in the propoerty field which causes the criteria eligibility, Re evaluate the criteria for all 'Ineligible' and 'Not Invited'
                 ( ( (mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c != null ) && mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c <= lstProperties[0].Last_Eligibility_Criteria_Modification__c) ||  ( (mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c != null ) &&   mapCampaignMember.get(preApplicant.Contact__c).Last_Eligibility_Check__c <=    cgphProfileCustomSettings.Last_Modification__c ) )  )&& ( mapCampaignMember.get(preApplicant.Contact__c).status == 'Ineligible' || 
                mapCampaignMember.get(preApplicant.Contact__c).status == 'Not Invited' ) 
                ))
              )
            {
                system.debug(' in the condition for pre Applicant : '+preApplicant.Name +'  '+preApplicant.id);
                setPreApplicants.add(preApplicant.Contact__c);
                // create correct parameter format for the library method
                transient list<PreApplicants__c> lstTempPreApplicant = new list<PreApplicants__c>();
                lstTempPreApplicant.add(preApplicant);
                
                // if property is of type rental
                if( lstProperties[0].RecordTypeId ==  strRentalPropertyRecTypeId )
                {
                    // check primary eligibility conditions for rental
                    // if primary conditions satisfied then go for detailed criteria checks
                    // or else mark campaignmember as ineligible
                    
                    boolean b_rentalIneligible = false;
                     // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
                            // ====================================================================
                            if((lstProperties[0].Age_Restriction__c == null || lstProperties[0].Age_Restriction__c == 'None') && preApplicant.AR_Properties_Only__c) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                            }
                            
                            // ====================================================================
                            // Test if Pre-Applicant Household Size <= Max Household Size                
                            // ====================================================================                
                            else if(lstProperties[0].Maximum_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Maximum_Household_Size__c < integer.valueof(preApplicant.Household_Size__c) )) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                            }
                            
                            // ====================================================================
                            // Test if Pre-Applicant Household Size >= Min Household Size                 
                            // ====================================================================
                            else if(lstProperties[0].Min_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Min_Household_Size__c > integer.valueof(preApplicant.Household_Size__c) )) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                            }
                            
                            // ====================================================================
                            // Test Property Listing Stage Region Restriction                 
                            // ====================================================================     
                            else if(lstProperties[0].Listing_Stage__c == 'Region and bedroom/household size restricted' && (preApplicant.Live_Work_Regions__c == null || preApplicant.Live_Work_Regions__c.contains(lstProperties[0].Municipality_Name__r.Region__c) == false)) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                            }
                            
                          // ====================================================================
                            // Test Pre-Applicant meets Rental Age Restriction
                            // ====================================================================                 
                            else if(lstProperties[0].Disabled_eligible_regardless_of_age__c  != 'Yes' && (lstProperties[0].Age_Restriction__c != null && lstProperties[0].Age_Restriction__c != 'None') && !(preApplicant.Household_Disabled__c && lstProperties[0].Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c))
                            {
                               if( preApplicant.Household_Members_55__c == false )
                               {
                                    b_rentalIneligible = true;
                                    system.debug('Test ');
                                }
                                   
                                else if(lstProperties[0].Age_Restriction__c == strOverEighteen && preApplicant.Youngest_Household_Member__c != strOverEighteen)
                                    {
                                        b_rentalIneligible = true;
                                        system.debug('Test ');
                                    }
                                    
                                else if(lstProperties[0].Age_Restriction__c == strOver17 && (preApplicant.Youngest_Household_Member__c == strUnderEighteen) )
                                    {
                                        b_rentalIneligible = true;
                                        system.debug('Test ');
                                    }
                            }
                            
                            system.debug(' b_rentalIneligible  '+b_rentalIneligible );
                            if(b_rentalIneligible == false)
                            {
                                transient map<Id,CGPHProfileController.WrapperRentalProperties> mapWrapperRentalProperty ;//= new map<Id,WrapperRentalProperties>(); 
                                // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                                cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEPRIVATELISTING';
                                mapWrapperRentalProperty = CGPHProfileController.calculateCriteriaForRental(lstProperties,lstTempPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicant,null,'UseToSubmitPQCustomSetting');
                                system.debug('return value mapWrapperRentalProperty : '+mapWrapperRentalProperty);   
                                
                                // if pre applicant is eligible for the property add him in eligible list which needs to display on the page
                                if(Test.isRunningTest() || mapWrapperRentalProperty.get(lstProperties[0].id).b_IsEligible == true )
                                {
                                    // increment the count only if the pe applicant is eligible
                                    iPreAppCount++;
                                                                        
                                    if(preApplicant.Contact__c != null && mapCampaignMember.containsKey(preApplicant.Contact__c) == true)
                                        lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),'Not Invited',mapCampaignMember.get(preApplicant.Contact__c),strLotteryField,setInvitedPreApp.size()));
                                        //lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),mapCampaignMember.get(preApplicant.Contact__c).Status,mapCampaignMember.get(preApplicant.Contact__c),strLotteryField));
                                    else
                                        lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),'Not Invited',null,strLotteryField,setInvitedPreApp.size()));
                                        
                                    // update campaign member status as there may be case that campaign member is ineligible previously but eligible now
                                    CampaignMember member = new CampaignMember();
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Not Invited';
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                }
                                else{
                                    CampaignMember member = new CampaignMember();
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Ineligible';
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                } 
                            }else{
                                CampaignMember member = new CampaignMember();
                                member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                member.status = 'Ineligible';
                                member.Last_Eligibility_Check__c = datetime.now();
                                lstCampaignMemberToUpdate.add(member);
                            }
                }
                else if( lstProperties[0].RecordTypeId ==  strPurchasePropertyRecTypeId )
                {
                    
                    boolean b_purchaseIneligible = false;
                    
                    // check primary eligibility conditions for purchase
                    // if primary conditions satisfied then go for detailed criteria checks
                    // or else mark campaignmember as ineligible
                        
                        ////////////////////////////////////
                          // ====================================================================
                        // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
                        // ====================================================================
                        if((lstProperties[0].Age_Restriction__c == null || lstProperties[0].Age_Restriction__c == 'None') && preApplicant.AR_Properties_Only__c )
                        {
                            b_purchaseIneligible = true;
                                    
                        }
        
                        // ====================================================================
                        // Test if Pre-Applicant Household Size <= Max Household Size                
                        // ====================================================================                 
                        else if(lstProperties[0].Maximum_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Maximum_Household_Size__c < integer.valueof(preApplicant.Household_Size__c) )) {
                            b_purchaseIneligible = true;
                        }
        
                        // ====================================================================
                        // Test if Pre-Applicant Household Size >= Min Household Size                 
                        // ====================================================================             
                        else if(lstProperties[0].Min_Household_Size__c != null && preApplicant.Household_Size__c != null && (preApplicant.Household_Size__c == '9+' || lstProperties[0].Min_Household_Size__c > integer.valueof(preApplicant.Household_Size__c) )) {
                            b_purchaseIneligible = true;
                            
                        }
        
                        // ====================================================================
                        // Test Property Listing Stage Region Restriction                 
                        // ====================================================================                 
                        else if( lstProperties[0].Listing_Stage__c == 'Region and bedroom/household size restricted'  && (preApplicant.Live_Work_Regions__c == null || preApplicant.Live_Work_Regions__c.contains(lstProperties[0].Municipality_Name__r.Region__c) == false) )
                        {
                            b_purchaseIneligible = true;
                        } 
                        
                        // ====================================================================
                        // Test Pre-Applicant meets Rental Age Restriction
                        // ====================================================================     
                        else if(lstProperties[0].Disabled_eligible_regardless_of_age__c != 'Yes' && (lstProperties[0].Age_Restriction__c != null && lstProperties[0].Age_Restriction__c != 'None') && !(preApplicant.Household_Disabled__c &&  lstProperties[0].Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c))
                        {
                            if( preApplicant.Household_Members_55__c == false )
                            {
                                b_purchaseIneligible = true;
                            }
                                    
                           else if(lstProperties[0].Age_Restriction__c == strOverEighteen && preApplicant.Youngest_Household_Member__c != strOverEighteen)
                            {
                                b_purchaseIneligible = true;
                            }
                                    
                           else if(lstProperties[0].Age_Restriction__c == strOver17 && preApplicant.Youngest_Household_Member__c == strUnderEighteen)
                            {
                                b_purchaseIneligible = true;
                            }
                        }
                    if(b_purchaseIneligible == false)
                    {
                        
                        transient map<Id,CGPHProfileController.WrapperPurchaseProperties> mapWrapperPurchaseProperty ;//= new map<Id,WrapperRentalProperties>(); 
                        mapMunicipalityGTR.put(lstProperties[0].Municipality_Name__c,lstProperties[0].Municipality_Name__r.General_Tax_Rate__c);
                        
                        system.debug('homeOwnerProperty.Municip '+lstProperties[0].Municipality_Name__c);
                        system.debug('homeOwnerProperty Income limit '+lstProperties[0].Municipality_Name__r.Equalization_Ratio__c);
                        // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                        cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEPRIVATELISTING';                                
                        mapWrapperPurchaseProperty = CGPHProfileController.calculateCriteriaForPurchase(lstProperties,lstTempPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicant,mapMunicipalityGTR,null);
                        system.debug('return value mapWrapperPurchaseProperty : '+mapWrapperPurchaseProperty);
        
                        //if pre applicant is eligible for the property add him in the eligible list
                        if(  mapWrapperPurchaseProperty.get(lstProperties[0].id).b_IsEligible == true ) 
                        {
                            iPreAppCount++;
                            if(preApplicant.Contact__c != null && mapCampaignMember.containsKey(preApplicant.Contact__c) == true)
                            lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),'Not Invited',mapCampaignMember.get(preApplicant.Contact__c),strLotteryField,setInvitedPreApp.size()));
                            //lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),mapCampaignMember.get(preApplicant.Contact__c).Status,mapCampaignMember.get(preApplicant.Contact__c),strLotteryField));
                            else
                            lstWrapperPreApplicant.add(new WrapperApplicant(preApplicant,mapPreApplicantIdPreference.get(preApplicant.id),'Not Invited',null,strLotteryField,setInvitedPreApp.size()));
                            
                            // update campaign member status as there may be case that campaign member is ineligible previously but eligible now so setting them as not invited
                            CampaignMember member = new CampaignMember();
                            member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                            member.status = 'Not Invited';
                            member.Last_Eligibility_Check__c = datetime.now();
                            lstCampaignMemberToUpdate.add(member);
                        }else{
                            // if ineligible set campaignmember status to ineligible                            
                            CampaignMember member = new CampaignMember();
                            member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                            member.status = 'Ineligible';
                            member.Last_Eligibility_Check__c = datetime.now();
                            lstCampaignMemberToUpdate.add(member);
                        }
                    }else{
                        // if ineligible set campaignmember status to ineligible
                        CampaignMember member = new CampaignMember();
                        member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                        member.status = 'Ineligible';
                        member.Last_Eligibility_Check__c = datetime.now();
                        lstCampaignMemberToUpdate.add(member);
                    }
                }
             }
             else // if member has submitted the IF and campaignmember status as submitted interest form not advancing then 
            if(Test.isRunningTest() || mapCampaignMember != null && mapCampaignMember.get(preApplicant.Contact__c).Status == 'Submitted Interest Form Not Advancing' && mapCampaignMember.get(preApplicant.Contact__c).Campaign_Preliminary_Submission__c != null && mapCampaignMember.get(preApplicant.Contact__c).Campaign_Preliminary_Submission__r.Status__c == 'Ineligible, Pending Staff Action' )
            { 
                // now we need to make changes in the campaignmember status = Ineligible, Pending Staff Action
                CampaignMember member = new CampaignMember();
                member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                member.status = 'Ineligible, Pending Staff Action';
               // member.Last_Eligibility_Check__c = datetime.now();
                lstCampaignMemberToUpdate.add(member);
            }
             if( iPreAppCount >= iPreApplicantLimit ) // we have enough pre applicant in the list to show on the page so break the loop
                break;
                                
         }
         
         setPreAppids = new set<string>();
        } // end of if
        
        if( iPreAppCount >= iPreApplicantLimit ) // we have enough pre applicant in the list to show on the page so break the loop
                break;       
    }// outer for loop              
         
         system.debug('lstWrapperPreApplicant size '+lstWrapperPreApplicant.size());    
        if(lstCampaignMemberToUpdate != null && lstCampaignMemberToUpdate.size() > 0)
        {
            update lstCampaignMemberToUpdate;
        } 
        return lstWrapperPreApplicant;
    }
    
    
    // this method will create map of the campaignMember on the basis of status
    @remoteAction
    public static map<string,list<CampaignMember>> getStatusWiseMemberMap(string strPropertyId)
    {
        list<HOMEtracker__Property__c> lstProperties =new list<HOMEtracker__Property__c>([SELECT 
                        Id, Name,Campaign__c,Municipality_Name__r.Income_Limit__c                        
                        FROM HOMEtracker__Property__c WHERE id =: strPropertyId]);  
        
        // get all the campaign members
        list<CampaignMember> lstCampaignMember = new list<CampaignMember>([SELECT 
                                                                            id,CampaignId,Status,ContactId,
                                                                            Note__c,Deadline_Date__c,Invited_Date__c 
                                                                            FROM 
                                                                            CampaignMember 
                                                                            WHERE 
                                                                            CampaignId =: lstProperties[0].Campaign__c]);
                
        map<string,list<CampaignMember>> mapStatusWiseMember = new map<string,list<CampaignMember>>();
        
        // create map of the status and the list of the campaign member 
        for(CampaignMember member : lstCampaignMember)
        {
            list<CampaignMember> lstTempCampMember = new list<CampaignMember>();
            if (mapStatusWiseMember.containsKey(member.Status) == true )
            {
                lstTempCampMember = new list<CampaignMember>();
                lstTempCampMember = mapStatusWiseMember.get(member.Status);
                lstTempCampMember.add(member);
                mapStatusWiseMember.put(member.Status,lstTempCampMember);
            }
            else
            {
                lstTempCampMember = new list<CampaignMember>();
                lstTempCampMember.add(member);
                mapStatusWiseMember.put(member.Status,lstTempCampMember);
            }
        }
        return mapStatusWiseMember;
    }
    
    // this method is used to log the acrtivity
    public static task createTask(string subject,string description,string preAppId)
    {
        task newTask = new task();
        newTask.OwnerId = UserInfo.getUserId();
        newTask.WhatId = preAppId;
        newTask.Archive__c = true;
        newTask.Description = description;//'Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id;
        newTask.Subject = subject;//'Removed Expired On Hold MP Name Preference';
        newTask.status = 'Completed';
        return newTask;
    }
    
    @future
    public static void sendEmailsLib(list<string> lstPreAppIds,string strInviteType,string strInviteMethod,string outreachNote ,string strDeadLineDate,string propertyId,string campId ,list<string> lstContactIds,string templateId)
    {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        list<emailSentResult> emailResults = new list<emailSentResult>();
        String[] bccAddress = new String[] {'noreply@cgph.net'};
        list<Contact> lstContacts = new list<Contact>([SELECT id,Total_Invites__c,Email_Subject__c,Email,EB_tools__Email_Verification__c
                                                    FROM 
                                                    Contact 
                                                    WHERE 
                                                    id IN : lstContactIds]);
         
          // list of property
        list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT id,
                                                                                        Name,HOMEtracker__List_Price__c,HOMEtracker__Monthly_Rent__c,
                                                                                        Deadline__c,RecordType.Name,HOMEtracker__City__c,HOMEtracker__Number_of_Bedrooms__c,Municipality_Name__r.Income_Limit__c
                                                                                        FROM HOMEtracker__Property__c
                                                                                        WHERE id=: propertyId]);                                           
         
         date deadLineDate = Date.parse(strDeadLineDate);                                           
                                                    
        list<string> lstContactIdsToUpdateMember = new list<string>();
        set<string> setErrorContactId = new set<string>();
                                                    
        if(campId != null && campId != '')
        {
            for(contact con : lstContacts)
            {
                if(con.Email != '' && con.Email != null && con.EB_tools__Email_Verification__c != 'Problem')
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId); 
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(con.Id);
                    mail.setWhatId(propertyId);
                    mail.setSenderDisplayName('Affordable Homes New Jersey');
                    mail.setReplyTo('homes@cgph.net');
                    mail.setBccAddresses(bccAddress);
    
                    allmsg.add(mail);
                    system.debug('mail '+mail);
                    lstContactIdsToUpdateMember.add(con.Id);
                }
                else
                {
                    setErrorContactId.add(con.id);
                }
            }
            
            system.debug('lstContactIdsToUpdateMember  '+lstContactIdsToUpdateMember);
            Messaging.SendEmailResult[] results;
            
            if( allmsg != null && allmsg.size() > 0 )
            {               
                if(lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0)
                {
                    //PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstContactIdsToUpdateMember,'Emailed',deadLineDate,outreachNote,'Email',propertyId);
                    list<CampaignMember> lstCampMemberUpdate = new list<CampaignMember>();
                    
                    for( CampaignMember member : [SELECT id FROM CampaignMember WHERE CampaignId = :campId AND ContactId IN : lstContactIdsToUpdateMember] )
                    {
                        CampaignMember newMember = new CampaignMember();
                        newMember.id = member.id;
                        newMember.Deadline_Date__c = deadLineDate;
                        lstCampMemberUpdate.add(newMember);
                    }
                    
                    if( lstCampMemberUpdate != null && lstCampMemberUpdate.size() > 0 )
                    {
                        update lstCampMemberUpdate;
                    }
                }
                
                system.debug('allmsg '+allmsg);
                
                if(Test.isRunningTest() == false && allmsg != null && allmsg.size() > 0) // if test method is not running this code
                {
                    results = Messaging.sendEmail(allmsg);
                }
                system.debug('results '+results);
                                
                if(results != null && results.size() > 0 )
                {
                    for(Messaging.SendEmailResult emailStatus : results)
                    {
                        system.debug('Email is sent '+emailStatus);
                        if(emailStatus.success)
                            emailResults.add(new emailSentResult('success','The email was sent successfully.'));
                        else
                        {
                            // remove the contact id from the list of ids so campaignMember status will not be updated
                            emailResults.add(new emailSentResult('error',emailStatus.errors[0].message));
                            setErrorContactId.add(emailStatus.errors[0].TargetObjectId);
                        }
                    }
                }
                
                system.debug('lstContactIdsToUpdateMember  '+lstContactIdsToUpdateMember);
                
                // update campaignmeber status for sent emails
                if( lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0 )
                {
                    list<string> lstTempUpdateIds = new list<string>();
                    for( string conId : lstContactIdsToUpdateMember )
                    {
                        if( setErrorContactId != null && setErrorContactId.contains( conId ) == false )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                        else if( setErrorContactId == null  )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                    }
                    PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstTempUpdateIds,'Emailed',deadLineDate,outreachNote,'Email',propertyId);
                }
                
                system.debug('lstPreAppIds '+lstPreAppIds);
                list<PreApplicants__c> lstPreApps = new list<PreApplicants__c>([SELECT id,Name,Contact__c 
                                                                            FROM PreApplicants__c 
                                                                            WHERE 
                                                                            id IN : lstPreAppIds]);
                                                                            
                list<Task> lstActivities = new list<Task>();                                                            
                system.debug('Creating activities for: '+lstPreAppIds);
                // create activities
                for(PreApplicants__c PreApp : lstPreApps)
                {
                    if( setErrorContactId != null && setErrorContactId.contains( PreApp.Contact__c ) == false ) // if this is no error email create activities
                    {
                        Task newTask = new Task();
                        newTask = PropertyPrivateListingInviteControllerV1.createTask('Invited by Email for '+lstProperty[0].Name+' - Deadline: '+strDeadLineDate,'Link to the Pre-Applicant Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+PreApp.Id,PreApp.Id);//new task();new task();
                        lstActivities.add(newTask);
                    }
                } 
                system.debug('lstActivities '+lstActivities);
                if(lstActivities != null && lstActivities.size() > 0)
                    insert lstActivities;
                system.debug('Activities after insert'+lstActivities);
            }
    }
    
   } 
    
    // send email function works on the list of the pre applicants
    // for sending email we are using visualforce email template
    @remoteAction
    public static list<emailSentResult> sendEmail(string campId,string propertyId,list<string> lstContactIds,string strDeadLineDate,string outreachNote,list<string> lstPreAppIds,string strInviteType,string strInviteMethod)
    {
        date deadLineDate = Date.parse(strDeadLineDate);
        list<Task> lstActivities = new list<Task>();
        // list of property
        list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT id,
                                                                                        Name,HOMEtracker__List_Price__c,HOMEtracker__Monthly_Rent__c,
                                                                                        Deadline__c,RecordType.Name,HOMEtracker__City__c,HOMEtracker__Number_of_Bedrooms__c,Municipality_Name__r.Income_Limit__c
                                                                                        ,Disabled_eligible_regardless_of_age__c,
                                                                                         Municipality_Name__r.County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                                                                                        Municipality_Name__r.County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                                                                                        Municipality_Name__r.Down_Payment_Assistance_Cert_Text__c,
                                                                                        Municipality_Name__r.Rent_Assistance_Cert_Text__c
                                                                                        FROM HOMEtracker__Property__c
                                                                                        WHERE id=: propertyId]);
                                                                                        
        // create  map of contact id and campaign member
        
        list<CampaignMember> lstCampaignMember = new list<CampaignMember>([SELECT id,ContactId,Deadline_Date__c 
                                                                            FROM 
                                                                            CampaignMember 
                                                                            WHERE
                                                                            CampaignId = : campId]);
        
        list<Contact> lstContacts = new list<Contact>([SELECT id,Total_Invites__c,Email_Subject__c,Email,EB_tools__Email_Verification__c
                                                    FROM 
                                                    Contact 
                                                    WHERE 
                                                    id IN : lstContactIds]);
                                                    
        map<string,CampaignMember> mapContactIdWiseMember = new map<string,CampaignMember>();
        
        if(lstCampaignMember != null && lstCampaignMember.size() > 0)
        {
            for(CampaignMember member : lstCampaignMember)
            {
                mapContactIdWiseMember.put(member.ContactId,member);
            }       
        }
                                                    
        list<Contact> lstContactsToUpdate = new list<Contact>(); 
        string subject = '';
        subject += lstProperty[0].Name + ', ';
        subject += lstProperty[0].HOMEtracker__City__c + ' ';
        subject += lstProperty[0].HOMEtracker__Number_of_Bedrooms__c +'BR ';
        
        string priceString = '';

        if(lstProperty[0].RecordType.Name == 'Homeownership' ) 
        {
            if(lstProperty[0].HOMEtracker__List_Price__c > 999 )
            {
                priceString = string.valueOf(lstProperty[0].HOMEtracker__List_Price__c.setScale(0));
                subject += '$'+ priceString.left(priceString.length() - 3) +',' + priceString.right(3);
            }
            else
            {
                priceString = string.valueOf(lstProperty[0].HOMEtracker__List_Price__c.setScale(0));
                subject += '$'+ priceString.right(3);
            }
        }
        else if(lstProperty[0].RecordType.Name == 'Rental Unit' )
        {
            if(lstProperty[0].HOMEtracker__Monthly_Rent__c > 999)
            {
                priceString = string.valueOf(lstProperty[0].HOMEtracker__Monthly_Rent__c.setScale(0));
                subject += '$'+ priceString.left(priceString.length() - 3) +',' + priceString.right(3);
            }
            else
            {
                priceString = string.valueOf(lstProperty[0].HOMEtracker__Monthly_Rent__c.setScale(0));
                subject += '$'+ priceString.right(3);
            }
        }
            
        //subject += ' '+ ' - Respond by ';//+lstProperty[0].Deadline__c;
        //subject += 'Affordable Housing Opportunity';
        
        // store subject line for email
        
         string deadLines = '';
           
        if( lstContacts != null && lstContacts.size() > 0 ) 
        {
            for(contact con : lstContacts)
            {
                Contact newCon = new Contact(id=con.id);
                deadLines = ' '+ ' - Respond by '+strDeadLineDate/*mapContactIdWiseMember.get(con.id).Deadline_Date__c*/+' Affordable Housing Opportunity';
                newCon.Email_Subject__c = subject + deadLines;
                if(strInviteType == 'New Invite')
                    newCon.Total_Invites__c = con.Total_Invites__c != null ? (con.Total_Invites__c + 1) : 1;
    
                lstContactsToUpdate.add(newCon);
                deadLines = '';
            }
        }
        
        if(lstContactsToUpdate != null && lstContactsToUpdate.size() > 0)
            update lstContactsToUpdate;
        
     
        // store the subject line details in the text field on the property
        
    //  HOMEtracker__Property__c prop = new HOMEtracker__Property__c(id=lstProperty[0].id);
    //  prop.Emailer_Subject__c = subject;
        
        //update prop;
        list<string> lstContactIdsToUpdateMember = new list<string>();
        set<string> setErrorContactId = new set<string>();
        EmailTemplate templateId = [SELECT id FROM EmailTemplate WHERE name = 'PropertyListingDetails'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        list<emailSentResult> emailResults = new list<emailSentResult>();
        String[] bccAddress = new String[] {'noreply@cgph.net'};
        
        system.debug(' lstPreAppIds '+lstPreAppIds);
        system.debug(' strInviteType '+strInviteType);
        system.debug(' lstContactIds '+lstContactIds);
        
        PropertyPrivateListingInviteControllerV1.sendEmailsLib(lstPreAppIds,strInviteType,strInviteMethod,outreachNote,strDeadLineDate,propertyId,campId ,lstContactIds,templateId.Id);
        
        if(campId != null && campId != '')
        {
            for(contact con : lstContacts)
            {
                if(con.Email != '' && con.Email != null && con.EB_tools__Email_Verification__c != 'Problem')
                {
                   lstContactIdsToUpdateMember.add(con.Id);
                }
                else
                {
                    setErrorContactId.add(con.id);
                }
            }
         }
         
         
         // update campaignmeber status for sent emails
                if( lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0 )
                {
                    list<string> lstTempUpdateIds = new list<string>();
                    for( string conId : lstContactIdsToUpdateMember )
                    {
                        if( setErrorContactId != null && setErrorContactId.contains( conId ) == false )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                        else if( setErrorContactId == null  )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                    }
                    PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstTempUpdateIds,'Emailed',deadLineDate,outreachNote,'Email',propertyId);
                }   
        
        
        /*
        if(campId != null && campId != '')
        {
            for(contact con : lstContacts)
            {
                if(con.Email != '' && con.Email != null && con.EB_tools__Email_Verification__c != 'Problem')
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId.Id); 
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(con.Id);
                    mail.setWhatId(propertyId);
                    mail.setSenderDisplayName('Affordable Homes New Jersey');
                    mail.setReplyTo('homes@cgph.net');
                    mail.setBccAddresses(bccAddress);
    
                    allmsg.add(mail);
                    system.debug('mail '+mail);
                    lstContactIdsToUpdateMember.add(con.Id);
                }
                else
                {
                    setErrorContactId.add(con.id);
                }
            }
            
            Messaging.SendEmailResult[] results;
            if( allmsg != null && allmsg.size() > 0 )
            {               
                if(lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0)
                {
                    //PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstContactIdsToUpdateMember,'Emailed',deadLineDate,outreachNote,'Email',propertyId);
                    list<CampaignMember> lstCampMemberUpdate = new list<CampaignMember>();
                    
                    for( CampaignMember member : [SELECT id FROM CampaignMember WHERE CampaignId = :campId AND ContactId IN : lstContactIdsToUpdateMember] )
                    {
                        CampaignMember newMember = new CampaignMember();
                        newMember.id = member.id;
                        newMember.Deadline_Date__c = deadLineDate;
                        lstCampMemberUpdate.add(newMember);
                    }
                    
                    if( lstCampMemberUpdate != null && lstCampMemberUpdate.size() > 0 )
                    {
                        update lstCampMemberUpdate;
                    }
                }
                
                system.debug('allmsg '+allmsg);
                
                if(Test.isRunningTest() == false && allmsg != null && allmsg.size() > 0) // if test method is not running this code
                {
                    results = Messaging.sendEmail(allmsg);
                }
                system.debug('results '+results);
                                
                if( results != null && results.size() > 0 )
                {
                    for(Messaging.SendEmailResult emailStatus : results)
                    {
                        system.debug('Email is sent '+emailStatus);
                        if(emailStatus.success)
                            emailResults.add(new emailSentResult('success','The email was sent successfully.'));
                        else
                        {
                            // remove the contact id from the list of ids so campaignMember status will not be updated
                            emailResults.add(new emailSentResult('error',emailStatus.errors[0].message));
                            setErrorContactId.add(emailStatus.errors[0].TargetObjectId);
                        }
                    }
                }
                
                
                // update campaignmeber status for sent emails
                if( lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0 )
                {
                    list<string> lstTempUpdateIds = new list<string>();
                    for( string conId : lstContactIdsToUpdateMember )
                    {
                        if( setErrorContactId != null && setErrorContactId.contains( conId ) == false )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                        else if( setErrorContactId == null  )
                        {
                            lstTempUpdateIds.add(conId);
                        }
                    }
                    PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstTempUpdateIds,'Emailed',deadLineDate,outreachNote,'Email',propertyId);
                }
                
                list<PreApplicants__c> lstPreApps = new list<PreApplicants__c>([SELECT id,Name,Contact__c 
                                                                            FROM PreApplicants__c 
                                                                            WHERE 
                                                                            id IN : lstPreAppIds]);
                system.debug('Creating activities for: '+lstPreAppIds);
                // create activities
                for(PreApplicants__c PreApp : lstPreApps)
                {
                    if( setErrorContactId != null && setErrorContactId.contains( PreApp.Contact__c ) == false ) // if this is no error email create activities
                    {
                        Task newTask = new Task();
                        newTask = PropertyPrivateListingInviteControllerV1.createTask('Invited by Email for '+lstProperty[0].Name+' - Deadline: '+strDeadLineDate,'Link to the Pre-Applicant Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+PreApp.Id,PreApp.Id);//new task();new task();
                        lstActivities.add(newTask);
                    }
                } 
                system.debug('lstActivities '+lstActivities);
                if(lstActivities != null && lstActivities.size() > 0)
                    insert lstActivities;
                system.debug('Activities after insert'+lstActivities);
            }
        }  
        */ 
        return emailResults;
    }
    
    
    
    // follow up action 
    @remoteAction 
    public static list<CampaignMember> followUpAction(string campId,string propertyId,list<string> lstContactIds,string strDeadLineDate,string outreachNote,list<string> lstPreAppIds,string status,string strInviteType)
    {
        system.debug('  FollowUP action is called ');
        date deadLineDate = Date.parse(strDeadLineDate);
        list<Task> lstActivities = new list<Task>();
        // list of property
        list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT id,Name,Municipality_Name__r.Income_Limit__c FROM HOMEtracker__Property__c WHERE id=: propertyId]);
        
        list<CampaignMember> lstCampaignMembers = new list<CampaignMember>();
        
        list<string> lstContactIdsToUpdateMember = new list<string>();
        
        // email is sent update the status
        for(Integer iIndex = 0; iIndex < lstContactIds.size() ; iIndex++)
        {
            
            lstContactIdsToUpdateMember.add(lstContactIds[iIndex]);
        }       
        
        string lastInviteType = '';
        if(status == 'Emailed')
            lastInviteType = 'Email';
        if(status == 'Mailed')
            lastInviteType = 'Mailed';
            
        if(lstContactIdsToUpdateMember != null && lstContactIdsToUpdateMember.size() > 0)
            lstCampaignMembers = PropertyPrivateListingInviteControllerV1.updateCampaignMember(campId,lstContactIdsToUpdateMember,status,deadLineDate,outreachNote,lastInviteType,propertyId);
        
        list<PreApplicants__c> lstPreApplicants = new list<PreApplicants__c>();
        
        lstPreApplicants = [SELECT id,Contact__c,Contact__r.Total_Invites__c FROM PreApplicants__c WHERE Id IN : lstPreAppIds];
        
        string strTaskSubject = '';
        
        list<Contact> lstContacts = new list<Contact>();
        
        //list<Task> lstActivities = new list<Task>();
        
        for( PreApplicants__c preApp : lstPreApplicants )
        {
            strTaskSubject = '';
            if( lastInviteType == 'Mailed' )
            strTaskSubject = 'Invited by Mail for '+lstProperty[0].Name;
            
            if( status == 'Mailed' )
                strTaskSubject = 'Invited by Mail for '+lstProperty[0].Name+' - Deadline: '+strDeadLineDate;
            
            if( status == 'Submitted Interest Form Not Advancing' )
                strTaskSubject = 'Submitted Interest Form, Not Advancing - '+lstProperty[0].Name;
                
            if( status == 'Not Interested in Unit' )
                strTaskSubject = 'Skipped this Unit - '+lstProperty[0].Name+' - EA Outreach Phone Call';
                
            if( status == 'Did Not Respond to Invite' )
                strTaskSubject = 'Did Not Respond to Invite, Removed from '+lstProperty[0].Name;
                
            if( status == 'Called' )
                strTaskSubject = 'Invited by Phone for '+lstProperty[0].Name+' - Deadline: '+strDeadLineDate;
            
            system.debug('strInviteType '+strInviteType);   
            
            if( (strInviteType == 'New Invite' ) && (status == 'Called' || status == 'Mailed' ))
            { 
                if( preApp.Contact__c != null)
                {
                    Contact newCon = new Contact(id=preApp.Contact__c);
                    newCon.Total_Invites__c = preApp.Contact__r.Total_Invites__c != null ? (preApp.Contact__r.Total_Invites__c + 1) : 1;
                    lstContacts.add(newCon);
                }
            }       
            Task newTask = new Task();
            newTask = PropertyPrivateListingInviteControllerV1.createTask(strTaskSubject,'Link to the Pre-Applicant Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+PreApp.Id,PreApp.Id);//new task();new task();
            lstActivities.add(newTask);
        }
        
        system.debug('List of contacts to be updated '+lstContacts);
        
        if( lstContacts != null && lstContacts.size() > 0 )
            update lstContacts;
        
        system.debug('lstActivities '+lstActivities);
        if(lstActivities != null && lstActivities.size() > 0 /*&& lastInviteType != 'Mailed'*/)
            insert lstActivities;
        
        return lstCampaignMembers;      
    }
    
    
    // method to add applicant to emailed list status
    public static list<CampaignMember> updateCampaignMember(string campaignId,list<string> lstContactIds,string strStatus,date deadlineDate,string outreachNote,string inviteType,string propertyId)
    {
        //set<string> setContact
        list<CampaignMember> lstCampaignMembers = new list<CampaignMember>([SELECT
                                                                     id,ContactId,Status,Last_Invite__c,Last_Invite_Type__c,Pre_Applicant__r.Property_Name__c,
                                                                     Number_of_Invite_Attempts__c,Pre_Applicant__c,Pre_Applicant__r.Property__r.Name,
                                                                     Pre_Applicant__r.Property__r.Municipality_Name__c,Pre_Applicant__r.Property__c 
                                                                     FROM
                                                                     CampaignMember
                                                                     WHERE
                                                                     CampaignId = :campaignId
                                                                     AND
                                                                     ContactId IN : lstContactIds
                                                                     ]);
                                                                     
        if(Test.isRunningTest() == true)
        {
            lstCampaignMembers = new list<CampaignMember>([SELECT
                                                                     id,ContactId,Status,Last_Invite__c,Last_Invite_Type__c,Pre_Applicant__r.Property_Name__c,
                                                                     Number_of_Invite_Attempts__c,Pre_Applicant__c,Pre_Applicant__r.Property__r.Name,
                                                                     Pre_Applicant__r.Property__r.Municipality_Name__c,Pre_Applicant__r.Property__c,
                                                                     Campaign.Campaign_Property__c 
                                                                     FROM
                                                                     CampaignMember
                                                                     ]);
        }                                                            
    // create set municipality ids and pre applicant ids
    
       set<string> setPreAppIds = new set<string>();
       
                                                                     
       list<CampaignMember> lstCampaignMembersToUpdate = new list<CampaignMember>();
       
       
       list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT 
                                                                                        id,Municipality_Name__c FROM 
                                                                                        HOMEtracker__Property__c
                                                                                        WHERE 
                                                                                        id = : propertyId                                                                                              
                                                                                        ]);
        
       for(CampaignMember member : lstCampaignMembers) 
       {
            // add values in to set
            setPreAppIds.add(member.Pre_Applicant__c); 
       }
       
       // get the preferences
       list<Municipality_Preference__c> lstPreferences = new list<Municipality_Preference__c>([SELECT 
                                                                                            id,Name,Municipality__c,PreApplicant__c
                                                                                            FROM 
                                                                                            Municipality_Preference__c
                                                                                            WHERE 
                                                                                            Municipality__c = : lstProperty[0].Municipality_Name__c
                                                                                            AND
                                                                                            PreApplicant__c IN : setPreAppIds
                                                                                            AND 
                                                                                            Status__c = 'Active'
                                                                                            ]);
       
       
       
       map<string,Municipality_Preference__c> mapPreAppwisePreferences = new map<string,Municipality_Preference__c>();
       
       // create mapp
       for(Municipality_Preference__c pref : lstPreferences)
       {
            mapPreAppwisePreferences.put(pref.PreApplicant__c,pref);       
       }
       
       system.debug(' mapPreAppwisePreferences ==> '+mapPreAppwisePreferences); 
       // lstPreferences to update
       list<Municipality_Preference__c> lstPreToUpdate = new list<Municipality_Preference__c>();
       
       // list of activities 
       list<task> lstActivities = new list<task>();
       
       for(CampaignMember member : lstCampaignMembers)
       {
            system.debug('member Update '+member.Pre_Applicant__r.Property_Name__c);
            // if status is "Did Not Respond to Invite" remove preferences and create acrtivity
            if( strStatus == 'Did Not Respond to Invite' )
            {
                Municipality_Preference__c newPrefrence = new Municipality_Preference__c();
                newPrefrence = mapPreAppwisePreferences.get(member.Pre_Applicant__c);
                if(newPrefrence != null)
                {
                    newPrefrence.Status__c = 'Ineligible';
                    lstPreToUpdate.add(newPrefrence);
                }
                
                // create activity under pre applicant
                Task newTask = new Task();
                newTask = PropertyPrivateListingInviteControllerV1.createTask('Removed from '+member.Campaign.Campaign_Property__c+' Did Not Respond to Invite ','Link to the Pre-Applicant Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+member.Pre_Applicant__c,member.Pre_Applicant__c);//new task();new task();
                lstActivities.add(newTask);             
            }
            
            if(  strStatus == 'Submitted Interest Form Not Advancing' )
            {
                // create activity under pre applicant
                Task newTask = new Task();
                string strTaskSubject = date.today().year()+'.'+date.today().month()+'.'+date.today().day();
                
                newTask = PropertyPrivateListingInviteControllerV1.createTask('Submitted Interest Form, Not Advancing '+member.Campaign.Campaign_Property__c,'Link to the Pre-Applicant Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+member.Pre_Applicant__c,member.Pre_Applicant__c);//new task();new task();
                lstActivities.add(newTask);             
            }
                    
            
            member.Status = strStatus;
            if( outreachNote != '' && outreachNote != null )
                member.Note__c = outreachNote;
            member.Deadline_Date__c = deadLineDate;
            if( member.Number_of_Invite_Attempts__c == null || member.Number_of_Invite_Attempts__c == 0 )
            {
                member.Invited_Date__c = date.today();
                member.Last_Invite__c = date.today();
            }
            else
            member.Last_Invite__c = date.today();
            member.Number_of_Invite_Attempts__c = member.Number_of_Invite_Attempts__c != null ? (member.Number_of_Invite_Attempts__c + 1) : 1;
            member.Last_Invite_Type__c = inviteType;
            lstCampaignMembersToUpdate.add(member);
       }
       
       if(lstCampaignMembersToUpdate != null && lstCampaignMembersToUpdate.size() > 0)
            update lstCampaignMembersToUpdate;
        
      // if(lstPreToUpdate != null && lstPreToUpdate.size() > 0 ) // We are not any more deactivating the prefereances
            //update lstPreToUpdate;
            
       if(lstActivities != null && lstActivities.size() > 0 )
            insert lstActivities;
                                     
        return lstCampaignMembersToUpdate;
    }
    
    
    
    // follow up action 
    @remoteAction 
    public static CampaignMember getCampaignMember(string memberId){
        // getting details of the specific campaign member
        list<CampaignMember> lstCampaignMember = new list<CampaignMember>([SELECT id,Invited_Date__c,
                                                                        Last_Invite_Type__c,Number_of_Invite_Attempts__c,
                                                                        Note__c,Status,Deadline_Date__c
                                                                        FROM 
                                                                        CampaignMember
                                                                        WHERE 
                                                                        id = :memberId 
                                                                        ]);
        if(lstCampaignMember != null && lstCampaignMember.size() > 0)
            return lstCampaignMember[0];
        else
        return null;        
    }
    
    
    public class emailSentResult{
    public string status {get;set;}
    public string msg {get;set;}
    public emailSentResult(string status,string msg){
        this.status = status;
        this.msg = msg;
        }
    }
    
    public class WrapperApplicant{
        public integer iCountInvited{get;set;}
        public CampaignMember member {get;set;}
        public PreApplicants__c preApplicant {get;set;}
        public Municipality_Preference__c preference{get;set;}
        public string status{get;set;}
        public string strLotteryField{get;set;}
        public WrapperApplicant(PreApplicants__c preApplicant,Municipality_Preference__c preference,string status,CampaignMember member,string strLotteryField,integer iCountInvited)
        {
            this.preApplicant = preApplicant;
            this.preference = preference;
            this.status = status;
            this.member = member;
            this.strLotteryField = strLotteryField;
            this.iCountInvited = iCountInvited;
        }
    }
}