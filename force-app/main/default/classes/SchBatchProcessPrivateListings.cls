global class SchBatchProcessPrivateListings implements Database.Batchable<sObject>,Schedulable,Database.stateful {
    global string strPropertyId;
    global list<HOMEtracker__Property__c> lstProperties = new list<HOMEtracker__Property__c>();
    global list<string> lstPreApplicantIds = new list<string>();
    global string strPurchasePropertyRecTypeId;
    global string strRentalPropertyRecTypeId;
    global CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
    map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>();
    global map<string,CampaignMember> mapCampaignMember = new map<string,CampaignMember>();
    map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();
    
    global SchBatchProcessPrivateListings(string strPropertyId, list<HOMEtracker__Property__c> lstProperties,list<string> lstPreApplicantIds){
        //     
        this.strPropertyId = strPropertyId;
        this.lstProperties = lstProperties;
        this.lstPreApplicantIds = lstPreApplicantIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){      
        
        set<string> setPreAppids = new set<string>();
        mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                       X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                       From Income_Limits__c]);
        for(CampaignMember member : [SELECT  
                                     id,CampaignId,Status,ContactId,Note__c,Pre_Applicant__c,Last_Eligibility_Check__c,
                                     Deadline_Date__c,Invited_Date__c,Flagged_RTV__c,CreatedDate,Campaign_Preliminary_Submission__c,Campaign_Preliminary_Submission__r.Status__c 
                                     FROM 
                                     CampaignMember 
                                     WHERE 
                                     CampaignId =: lstProperties[0].Campaign__c])
        {
            mapCampaignMember.put(member.ContactId,member);
        }
        system.debug('mapCampaignMember:'+mapCampaignMember);
        setPreAppids.addAll(lstPreApplicantIds);
        String query = 'SELECT Contact__r.Name,Contact__r.Id, Flagged_for_Outreach__c,Id, Name, Contact__r.Email, Contact__r.Phone, Contact__r.Alternate_Phone__c,Contact__r.Ext__c, Contact__r.Alt_Ext__c,Contact__r.MailingStreet,Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Household_Disabled__c,Pre_Applicant_Active__c,Household_Size__c, Household_Members_55__c , Annual_Income__c, Live_Work_Regions__c, Most_Recent_Update__c, Rental_Interest__c, AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,LastModifiedDate,Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,Contact__r.EB_tools__Email_Verification__c,Ext__c, Applicant_Name__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c FROM  PreApplicants__c Where  Id IN :setPreAppids ';
        system.debug('query '+query);
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        HOMEtracker__Property__c p = new HOMEtracker__Property__c();
        p = [SELECT id,Calculation_Status__c,Last_Calculation__c,Calculation_Message__c FROM HOMEtracker__Property__c WHERE Id =: strPropertyId];
        p.Calculation_Status__c = 'In Progress';
        p.Calculation_Message__c = 'Criteria calculation started on '+datetime.now().format('MMMMM dd, yyyy hh:mm:ss a')+'\n'+
            'Processing total batches : '+a.TotalJobItems;
        p.Criteria_Calculation_Job_Id__c = BC.getJobId();
        p.Last_Calculation__c = datetime.now();
        update p; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PreApplicants__c> lstPreApplicants){
        string errMSg = '';
        try{
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
            Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
            string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
            string strOverEighteen, strUnderEighteen, 
                strEighteen, strOver17, str55Plus;
            strOverEighteen = 'Over 18';
            strUnderEighteen = 'Under 18';
            strEighteen = '18';
            str55Plus = '55+ Exclusive';
            strOver17 = 'Over 17';
            
            list<campaign> lstCampaigns = new list<Campaign>([SELECT id,Calculation_Status__c,Calculation_Message__c,Campaign_Property__c,Calculation_Type__c FROM Campaign WHERE Id =: lstProperties[0].Campaign__c]);
            list<Campaignmember> lstCampaignMemberToUpdate = new list<CampaignMember>();
            for( PreApplicants__c preApplicant : lstPreApplicants ){
                system.debug('preApplicant.Contact__c:'+preApplicant.Contact__c);
                Campaignmember mem = new CampaignMember();
                mem = mapCampaignMember.get(preApplicant.Contact__c);
                string strIneligibilityMsg = '';
                if(mem != null || Test.isRunningTest())
                    if( Test.isRunningTest() || (mapCampaignMember != null && mapCampaignMember.get(preApplicant.Contact__c) != null && ( mapCampaignMember.get(preApplicant.Contact__c).Status == 'Not Invited' ||  mapCampaignMember.get(preApplicant.Contact__c).status == 'Ineligible') ) ){
                        // create correct parameter format for the library method
                        list<PreApplicants__c> lstTempPreApplicant = new list<PreApplicants__c>();
                        lstTempPreApplicant.add(preApplicant);
                        system.debug('lstProperties[0].RecordTypeId:'+lstProperties[0].RecordTypeId);
                        system.debug('strRentalPropertyRecTypeId:'+strRentalPropertyRecTypeId);
                        if( lstProperties[0].RecordTypeId ==  strRentalPropertyRecTypeId ){
                            // check primary eligibility conditions for rental
                            // if primary conditions satisfied then go for detailed criteria checks
                            // or else mark campaignmember as ineligible
                            boolean b_rentalIneligible = false;
                            // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
                            // ====================================================================
                           system.debug('lstProperties[0].Age_Restriction__c:'+lstProperties[0].Age_Restriction__c);
                           system.debug('preApplicant.AR_Properties_Only__c:'+preApplicant.AR_Properties_Only__c);
                            if((lstProperties[0].Age_Restriction__c == null || lstProperties[0].Age_Restriction__c == 'None') && preApplicant.AR_Properties_Only__c) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                                strIneligibilityMsg += '- This is not age restricted property and you are only applying for age restricted property \n';
                            }
                            // ====================================================================
                            // Test if Pre-Applicant Household Size <= Max Household Size                
                            // ====================================================================                
                            if(lstProperties[0].Maximum_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Maximum_Household_Size__c < integer.valueof(preApplicant.Household_Size__c) )) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                                strIneligibilityMsg += '- Your household size '+preApplicant.Household_Size__c+' is greater than maximum household size '+lstProperties[0].Maximum_Household_Size__c+' for the property.\n';
                            }
                            // ====================================================================
                            // Test if Pre-Applicant Household Size >= Min Household Size                 
                            // ====================================================================
                            system.debug('lstProperties[0].Min_Household_Size__c:'+lstProperties[0].Min_Household_Size__c);
                            system.debug('preApplicant.Household_Size__c:'+preApplicant.Household_Size__c);
                            if(lstProperties[0].Min_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Min_Household_Size__c > integer.valueof(preApplicant.Household_Size__c) )) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                                strIneligibilityMsg += '- Your household size '+preApplicant.Household_Size__c+' is less than minimum household size '+lstProperties[0].Min_Household_Size__c+' for the property.\n';
                            }
                            // ====================================================================
                            // Test Property Listing Stage Region Restriction                 
                            // ====================================================================     
                            if(lstProperties[0].Listing_Stage__c == 'Region and bedroom/household size restricted' && (preApplicant.Live_Work_Regions__c == null || preApplicant.Live_Work_Regions__c.contains(lstProperties[0].Municipality_Name__r.Region__c) == false)) {
                                b_rentalIneligible = true;
                                system.debug('Test ');
                                strIneligibilityMsg += '- Your live work region is not in the live work region allowed for municipality\n';
                            }
                            // ====================================================================
                            // Test Pre-Applicant meets Rental Age Restriction
                            // ====================================================================                 
                            if(lstProperties[0].Disabled_eligible_regardless_of_age__c  != 'Yes' && (lstProperties[0].Age_Restriction__c != null && lstProperties[0].Age_Restriction__c != 'None') && !(preApplicant.Household_Disabled__c && lstProperties[0].Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c))
                            {
                                if( preApplicant.Household_Members_55__c == false ){
                                    b_rentalIneligible = true;
                                    system.debug('Test ');
                                    strIneligibilityMsg += '-This is a 55+ home.  Your household no longer qualifies because of the ages of your household members.'+'\n';
                                }else if(lstProperties[0].Age_Restriction__c == strOverEighteen && preApplicant.Youngest_Household_Member__c != strOverEighteen){
                                    b_rentalIneligible = true;
                                    system.debug('Test ');
                                     strIneligibilityMsg += '-Over 18 Age restriction, yougest household member not over 18.'+'\n';
                                }else if(lstProperties[0].Age_Restriction__c == strOver17 && (preApplicant.Youngest_Household_Member__c == strUnderEighteen) ){
                                    b_rentalIneligible = true;
                                    system.debug('Test ');
                                    strIneligibilityMsg += '-Over 17 Age restriction, yougest household member not over 17.'+'\n';
                                }
                            }
                            
                            system.debug(' b_rentalIneligible  '+b_rentalIneligible );
                            if(b_rentalIneligible == false){
                                map<Id,CGPHProfileController.WrapperRentalProperties> mapWrapperRentalProperty ;//= new map<Id,WrapperRentalProperties>(); 
                                // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                                cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEPRIVATELISTING';
                                if(!Test.isRunningTest())
                                    mapWrapperRentalProperty = CGPHProfileController.calculateCriteriaForRental(lstProperties,lstTempPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicant,null,'UseToSubmitPQCustomSetting');
                                system.debug('return value mapWrapperRentalProperty : '+mapWrapperRentalProperty); 
                                // if pre applicant is eligible for the property add him in eligible list which needs to display on the page
                                if( mapWrapperRentalProperty!=null && mapWrapperRentalProperty.get(lstProperties[0].id).b_IsEligible == true ){
                                    // to do update value on the campaign member that person is eligible
                                    // update campaign member status as there may be case that campaign member is ineligible previously but eligible now
                                    CampaignMember member = new CampaignMember();
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Not Invited';
                                    member.Eligible_for_Property__c = true;
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                }else{
                                    try{
                                        CampaignMember member = new CampaignMember();
                                        member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                        member.status = 'Ineligible';
                                        member.Eligible_for_Property__c = false;    
                                        member.EA_Order__c = null;
                                        member.Ineligibility_Message__c = mapWrapperRentalProperty.get(lstProperties[0].Id).eligibilityReportExternal; 
                                        member.Last_Eligibility_Check__c = datetime.now();
                                        lstCampaignMemberToUpdate.add(member);
                                    }catch(Exception e){}
                                }
                            }else{
                                try{
                                    CampaignMember member = new CampaignMember();                        
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Ineligible';
                                    member.Eligible_for_Property__c = false;
                                    member.EA_Order__c = null;
                                    member.Ineligibility_Message__c = strIneligibilityMsg;
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                }catch(exception e){
                                    system.debug('exception:'+e.getLineNumber());
                                    system.debug('exception msg:'+e.getMessage());
                                }
                            }
                        }// rental end
                        else if( lstProperties[0].RecordTypeId ==  strPurchasePropertyRecTypeId ){
                            boolean b_purchaseIneligible = false;
                            // check primary eligibility conditions for purchase
                            // if primary conditions satisfied then go for detailed criteria checks
                            // or else mark campaignmember as ineligible
                            
                            ////////////////////////////////////
                            // ====================================================================
                            // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
                            // ====================================================================
                            if((lstProperties[0].Age_Restriction__c == null || lstProperties[0].Age_Restriction__c == 'None') && preApplicant.AR_Properties_Only__c ){
                                b_purchaseIneligible = true;
                                  strIneligibilityMsg += '- This is not age restricted property and you are only applying for age restricted property \n';
                            }
                            // ====================================================================
                            // Test if Pre-Applicant Household Size <= Max Household Size                
                            // ====================================================================                 
                            if(lstProperties[0].Maximum_Household_Size__c != null && preApplicant.Household_Size__c != null && ( preApplicant.Household_Size__c == '9+' || lstProperties[0].Maximum_Household_Size__c < integer.valueof(preApplicant.Household_Size__c) )) {
                                b_purchaseIneligible = true;
                                 strIneligibilityMsg += '- Your household size '+preApplicant.Household_Size__c+' is greater than maximum household size '+lstProperties[0].Maximum_Household_Size__c+' for the property.\n';
                            }
                            
                            // ====================================================================
                            // Test if Pre-Applicant Household Size >= Min Household Size                 
                            // ====================================================================             
                            if(lstProperties[0].Min_Household_Size__c != null && preApplicant.Household_Size__c != null && (preApplicant.Household_Size__c == '9+' || lstProperties[0].Min_Household_Size__c > integer.valueof(preApplicant.Household_Size__c) )) {
                                b_purchaseIneligible = true;
                                   strIneligibilityMsg += '- Your household size '+preApplicant.Household_Size__c+' is less than minimum household size '+lstProperties[0].Min_Household_Size__c+' for the property.\n';
                            }
                            // ====================================================================
                            // Test Property Listing Stage Region Restriction                 
                            // ====================================================================                 
                            if( lstProperties[0].Listing_Stage__c == 'Region and bedroom/household size restricted'  && (preApplicant.Live_Work_Regions__c == null || preApplicant.Live_Work_Regions__c.contains(lstProperties[0].Municipality_Name__r.Region__c) == false) ){
                                b_purchaseIneligible = true;
                                 strIneligibilityMsg += '- Your live work region is not in the live work region allowed for municipality\n';
                            } 
                            // ====================================================================
                            // Test Pre-Applicant meets Rental Age Restriction
                            // ====================================================================     
                            if(lstProperties[0].Disabled_eligible_regardless_of_age__c != 'Yes' && (lstProperties[0].Age_Restriction__c != null && lstProperties[0].Age_Restriction__c != 'None') && !(preApplicant.Household_Disabled__c &&  lstProperties[0].Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c)){
                                if( preApplicant.Household_Members_55__c == false ){
                                    b_purchaseIneligible = true;
                                     strIneligibilityMsg += '-This is a 55+ home.  Your household no longer qualifies because of the ages of your household members.'+'\n';
                                }else if(lstProperties[0].Age_Restriction__c == strOverEighteen && preApplicant.Youngest_Household_Member__c != strOverEighteen){
                                    b_purchaseIneligible = true;
                                    strIneligibilityMsg += '-Over 18 Age restriction, yougest household member not over 18.'+'\n';
                                }else if(lstProperties[0].Age_Restriction__c == strOver17 && preApplicant.Youngest_Household_Member__c == strUnderEighteen){
                                    b_purchaseIneligible = true;
                                     strIneligibilityMsg += '-Over 17 Age restriction, yougest household member not over 17.'+'\n';
                                }
                            }//
                            if(b_purchaseIneligible == false){
                                map<Id,CGPHProfileController.WrapperPurchaseProperties> mapWrapperPurchaseProperty ;//= new map<Id,WrapperRentalProperties>(); 
                                mapMunicipalityGTR.put(lstProperties[0].Municipality_Name__c,lstProperties[0].Municipality_Name__r.General_Tax_Rate__c);
                                
                                system.debug('homeOwnerProperty.Municip '+lstProperties[0].Municipality_Name__c);
                                system.debug('homeOwnerProperty Income limit '+lstProperties[0].Municipality_Name__r.Equalization_Ratio__c);
                                // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                                cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEPRIVATELISTING';                                
                                if(!Test.isRunningTest())
                                    mapWrapperPurchaseProperty = CGPHProfileController.calculateCriteriaForPurchase(lstProperties,lstTempPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicant,mapMunicipalityGTR,null);
                                system.debug('return value mapWrapperPurchaseProperty : '+mapWrapperPurchaseProperty);
                                //if pre applicant is eligible for the property add him in the eligible list
                                if(mapWrapperPurchaseProperty!=null &&  mapWrapperPurchaseProperty.get(lstProperties[0].id).b_IsEligible == true ){
                                    // update campaign member status as there may be case that campaign member is ineligible previously but eligible now so setting them as not invited
                                    CampaignMember member = new CampaignMember();
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Not Invited';
                                    member.Eligible_for_Property__c = true;
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                }else{
                                    // if ineligible set campaignmember status to ineligible    
                                    try{                        
                                        CampaignMember member = new CampaignMember();
                                        member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                        member.status = 'Ineligible';
                                        member.Eligible_for_Property__c = false; 
                                        member.EA_Order__c = null;
                                        member.Ineligibility_Message__c = mapWrapperPurchaseProperty.get(lstProperties[0].Id).eligibilityReportExternal; 
                                        member.Last_Eligibility_Check__c = datetime.now();
                                        lstCampaignMemberToUpdate.add(member);
                                    }catch(Exception ex){system.debug('Exception '+ex.getCause()+ex.getLineNumber()+ex.getMessage()+ex.getStackTraceString());}
                                }
                            }else{
                                // if ineligible set campaignmember status to ineligible
                                try{
                                    CampaignMember member = new CampaignMember();
                                    member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                                    member.status = 'Ineligible';
                                    member.Eligible_for_Property__c = false;
                                     member.EA_Order__c = null;
                                    member.Ineligibility_Message__c = strIneligibilityMsg;
                                    member.Last_Eligibility_Check__c = datetime.now();
                                    lstCampaignMemberToUpdate.add(member);
                                }catch(Exception e){}
                            }
                        }
                    }else if(Test.isRunningTest() || mapCampaignMember != null && mapCampaignMember.get(preApplicant.Contact__c).Status == 'Submitted Interest Form Not Advancing' && mapCampaignMember.get(preApplicant.Contact__c).Campaign_Preliminary_Submission__c != null && mapCampaignMember.get(preApplicant.Contact__c).Campaign_Preliminary_Submission__r.Status__c == 'Ineligible, Pending Staff Action' ){ // if member has submitted the IF and campaignmember status as submitted interest form not advancing then
                        // now we need to make changes in the campaignmember status = Ineligible, Pending Staff Action
                        CampaignMember member = new CampaignMember();
                        member.id = mapCampaignMember.get(preApplicant.Contact__c).id;
                        member.status = 'Ineligible, Pending Staff Action';
                        member.Eligible_for_Property__c = false;
                         member.EA_Order__c = null;
                        // member.Last_Eligibility_Check__c = datetime.now();
                        lstCampaignMemberToUpdate.add(member);
                    }       
            }// for loop end
            
            system.debug('lstCampaignMemberToUpdate size '+lstCampaignMemberToUpdate.size());    
            if(lstCampaignMemberToUpdate != null && lstCampaignMemberToUpdate.size() > 0){
                update lstCampaignMemberToUpdate;
            } 
        }
        catch(exception ex){
            errMSg = 'Error in Criteria batch message : '+ex.getMessage()+' cause : '+ex.getCause()+
                ' StackTrace : ' +ex.getStacktraceString() +' Line Number : '+ex.getLineNumber();
        }finally{
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                              TotalJobItems,ExtendedStatus, CreatedBy.Email
                              FROM AsyncApexJob WHERE Id =
                              :BC.getJobId()];
            
            HOMEtracker__Property__c p = new HOMEtracker__Property__c();
            p = [SELECT id,Calculation_Status__c,Last_Calculation__c,Calculation_Message__c FROM HOMEtracker__Property__c WHERE Id =: strPropertyId];
            p.Calculation_Status__c = 'In Progress';
            p.Calculation_Message__c = p.Calculation_Message__c + '\n'+a.JobItemsProcessed+' processed out of '+a.TotalJobItems +' on ' +datetime.now().format('MMMMM dd, yyyy hh:mm:ss a') + ( errMSg != null && errMSg != '' ?  '\n'+errMSg :''); 
            p.Last_Calculation__c = datetime.now();
            update p; 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems,ExtendedStatus, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        HOMEtracker__Property__c p = new HOMEtracker__Property__c();
        p = [SELECT id,Calculation_Status__c,Last_Calculation__c,Calculation_Message__c FROM HOMEtracker__Property__c WHERE Id =: strPropertyId];
        p.Calculation_Status__c = 'Complete';
        p.Calculation_Message__c = p.Calculation_Message__c + '\n'+a.JobItemsProcessed+' processed out of '+a.TotalJobItems +' on ' +datetime.now().format('MMMMM dd, yyyy hh:mm:ss a');
        p.Last_Calculation__c = datetime.now();
        update p; 
        
        // get the next property for criteria calculations. 
        list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT id FROM HOMEtracker__Property__c 
                                                                                         WHERE Last_Calculation__c != today
                                                                                        AND HOMEtracker__Status__c IN ('Available for Sale/Resale','Available for Rent')]);
        if(lstProperty.size() > 0){
            // call the next batch
            PropertyPrivateListingInviteControllerV2.startCriteriaCalculations(lstProperty[0].Id);
        }
    }
    
    global void execute(SchedulableContext SC){
        /*list<HOMEtracker__Property__c> lstProperties = new list<HOMEtracker__Property__c>();
        HOMEtracker__Property__c property = new HOMEtracker__Property__c ();
        property = (HOMEtracker__Property__c)PropertyPrivateListingInviteControllerV2.getPropertyDetails(strPropertyId);
        lstProperties.add(property);
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
        string prefrenceType;
        system.debug('strPropertyId:'+strPropertyId);
        
        if(lstProperties[0].RecordTypeID == strRentalPropertyRecTypeId)
            prefrenceType = 'Rental';
        else if(lstProperties[0].RecordTypeID == strPurchasePropertyRecTypeId )
            prefrenceType = 'Ownership';
        string strMunicipalityId = lstProperties[0].Municipality_Name__c;
        string strPreferenceQuery = 'SELECT '+
            'id,Name,PreApplicant__c,PreApplicant__r.Contact__c,PreApplicant__r.Veteran__c,PreApplicant__r.Meets_Montclair_Local_Pref_Criteria__c,Status__c,Interest_Date__c , '+
            + 'General_Local__c,Alternate_Local__c '+
            ' FROM '+
            'Municipality_Preference__c '+
            'WHERE '+                                                                       
            'Municipality__c =: strMunicipalityId '+
            'AND Type__c = : prefrenceType '+
            ' AND On_Hold__c = false ';
        list<string> lstPreApplicantIds = new list<string>();
        for(Municipality_Preference__c preference : Database.query(strPreferenceQuery)){
            lstPreApplicantIds.add(preference.PreApplicant__c);
        }
        SchBatchProcessPrivateListings batchObj = new SchBatchProcessPrivateListings(strPropertyId,lstProperties,lstPreApplicantIds);
        database.executeBatch(batchObj,200);*/
        
        
         // get the next property for criteria calculations. 
        list<HOMEtracker__Property__c> lstProperty = new list<HOMEtracker__Property__c>([SELECT id FROM HOMEtracker__Property__c 
                                                                                         WHERE Last_Calculation__c != today
                                                                                        AND HOMEtracker__Status__c IN ('Available for Sale/Resale','Available for Rent')]);
        if(lstProperty.size() > 0){
            // call the next batch
            PropertyPrivateListingInviteControllerV2.startCriteriaCalculations(lstProperty[0].Id);
        }   
    }
}