/*
 * Purpose : Class used to store the methods for Private property listing pages functionality
 * 
 */
public class ListingUtility {
    // method to be called on page load to make sure all the 
    // applicants are added as the campaign member 
    @future  
    public static void addCampaignMembers(string strPropertyId,string strRecordLimit){
        try{
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
                                                                                            Id,Camp_Member_Add_Job_Status__c, Name, HOMEtracker__List_Price__c , Campaign__c,Lottery_Number_for_Priority__c,
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
        lstProperties[0].Camp_Member_Add_Job_Status__c = 'In Progress';
        update lstProperties[0];
        
        if(lstProperties[0].RecordTypeID == strRentalPropertyRecTypeId) prefrenceType = 'Rental';
        else if(lstProperties[0].RecordTypeID == strPurchasePropertyRecTypeId ) prefrenceType = 'Ownership';
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        system.debug('Remaining Qury Rows '+ (Limits.getLimitQueryRows() - Limits.getQueryRows()));
        /*transient map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                          X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                          From Income_Limits__c]);*/
        // select all the campaign member from the campaign 
        // commented query line
       transient list<Campaign> lstCampaign = new list<Campaign>([SELECT id,Name,(SELECT id,Note__c,Municipality_Preference__c,Pre_Applicant__c,Deadline_Date__c,ContactId,Status,Invited_Date__c,Last_Eligibility_Check__c FROM CampaignMembers) FROM Campaign WHERE id =: lstProperties[0].Campaign__c]);
       //transient list<Campaign> lstCampaign = new list<Campaign>(); 
        if(lstCampaign != null && lstCampaign.size() > 0){
            // create set of ids of campaign member
            for(CampaignMember member : lstCampaign[0].CampaignMembers){
                setContactIds.add(member.ContactId);
                mapCampaignMember.put(member.ContactId,member);
            }
        }
        
        Integer iPreApplicantLimit = 10000;
        if(lstProperties[0].EA_Layout__c == 'Include Invited'){
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 300;
        }else if(lstProperties[0].EA_Layout__c == 'Uninvited only'){
            iPreApplicantLimit = lstProperties[0].Private_Property_Preapplicant_Limit__c != null ? (Integer) lstProperties[0].Private_Property_Preapplicant_Limit__c : 500;
        }
                
        string strLotteryNumberToUse = 'Lottery_Number__c';
        if(lstProperties[0].Lottery_Number_for_Priority__c != '' && lstProperties[0].Lottery_Number_for_Priority__c != null)
            strLotteryNumberToUse =lstProperties[0].Lottery_Number_for_Priority__c;
       
        string strMunicipalityId = lstProperties[0].Municipality_Name__c;
        setContactIds.addAll(mapCampaignMember.keySet());
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
                                    'AND Type__c = : prefrenceType '+
                                    'AND PreApplicant__r.Contact__c NOT IN : setContactIds ';
             if( lstProperties[0].Local_Preference_for_Priority__c != null )                       
                 strPreferenceQuery  +=  'AND  '+lstProperties[0].Local_Preference_for_Priority__c+' = true ';
             strPreferenceQuery  +=  ' Order by '+ strLotteryNumberToUse +',Interest_Date__c';
     system.debug('strPreferenceQuery '+strPreferenceQuery);
        
        for( Municipality_Preference__c preference : Database.Query(strPreferenceQuery) ){
                setPreApplicant.add(preference.PreApplicant__c);
                mapPreAppToPreferenceId.put(preference.PreApplicant__c,preference.id);
        }
            
        map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();        
        // get all the pre applicant
        transient list<PreApplicants__c> lstPreapplicant = new list<PreApplicants__c>();
            string strOverEighteen, strUnderEighteen,strEighteen, strOver17, str55Plus;
            strOverEighteen = 'Over 18';strUnderEighteen = 'Under 18';strEighteen = '18';
            str55Plus = '55+ Exclusive';strOver17 = 'Over 17';
            
            system.debug(' setContactIds '+setContactIds);
            system.debug('  setPreApplicant '+setPreApplicant);
         list<CampaignMember> lstCampaignMembersTobeUpdated = new list<CampaignMember>();  
      
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
                            Id IN : setPreApplicant AND Contact__c NOT IN : setContactIds]){
            // create correct parameter format for the library method
                transient list<PreApplicants__c> lstTempPreApplicant = new list<PreApplicants__c>();
                lstTempPreApplicant.add(preApplicant);
            // if campaignmember have lookup fields not filled and there is issue    
            campaignmember campMember = new CampaignMember();
            campMember = mapCampaignmember.get(preApplicant.Contact__c);
            if(setContactIds.contains(preApplicant.Contact__c) == false){
                string preferenceId = mapPreAppToPreferenceId.get(preApplicant.id); 
                CampaignMember member = new CampaignMember();
                member.ContactId = preApplicant.Contact__c;
                member.CampaignId = lstProperties[0].Campaign__c;
                //member.Status = 'Not Invited';
                member.Pre_Applicant__c = preApplicant.id;
                member.Municipality_Preference__c = preferenceId;
                
                if(preApplicant.Contact__c != null && setContactIds.contains(preApplicant.Contact__c) == false){
                    setContactIds.add(preApplicant.Contact__c);
                    lstCampaignMembers.add(member);  
                    if( lstCampaignMembers.size() >= 9500 ){
                        system.debug('Campaign member list size '+lstCampaignMembers.size() +'  record count '+iRecordCount);
                        break;   
                    }   
                }               
            }
         }
        
        if(lstCampaignMembers != null && lstCampaignMembers.size() > 0){            
        system.debug('List of campaignmembers to be added : '+lstCampaignMembers.size());
            database.insert(lstCampaignMembers,false);
        }   
         lstProperties[0].Camp_Member_Add_Job_Status__c = 'Complete';
             update lstProperties[0];
        }catch(Exception ex){
            system.debug('Exception in the Add campaignmember method '+ex.getMessage()+' cause '+ex.getCause()+' stackstring '+ex.getStackTraceString()+' '+ex.getLineNumber());
        }     
    }

}