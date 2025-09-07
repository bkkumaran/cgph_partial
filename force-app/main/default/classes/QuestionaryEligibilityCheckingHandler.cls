public class QuestionaryEligibilityCheckingHandler 
{
    public static void createEligibilityReportForQuestionary(List<Application__c> lstApplications)
    {
        set<string> setPreapplicantIds = new set<string>();
        set<string> setPropertyIds = new set<string>();
        map<string,string> mapPreApplicantProperty = new map<string,string>();
        map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();
        
        Schema.DescribeSObjectResult cfrApplicationSchema = Schema.SObjectType.Application__c ; 
        Map<String,Schema.RecordTypeInfo> ApplicationRecordTypeInfo = cfrApplicationSchema.getRecordTypeInfosByName(); 
        string strApplicationRecTypeId = ApplicationRecordTypeInfo.get('Property Questionnaire').getRecordTypeId();
        
        for( Application__c application : lstApplications )
        {
            system.debug('application.RecordTypeId ==> '+application.RecordTypeId);
            system.debug('strApplicationRecTypeId ==> '+strApplicationRecTypeId);
            system.debug('application.Property__c ==> '+application.Property__c);
            if(application.RecordTypeId == strApplicationRecTypeId)
            {
                setPreapplicantIds.add(application.Pre_Applicant__c);
                setPropertyIds.add(application.Property__c);
                mapPreApplicantProperty.put(application.Pre_Applicant__c,application.Property__c);
            }
        }
        
        
        system.debug('setPropertyIds '+setPropertyIds);
        map<string,HOMEtracker__Property__c> mapProperties = new map<string,HOMEtracker__Property__c>([Select Id, Name,X3x_Rent_Requirement__c, 
                                                                                            CreatedDate, Status_Message__c,HOMEtracker__List_Price__c,Municipality_Name__r.Equalization_Ratio__c,HOMEtracker__Property_Type__c,
                                                                                            Maximum_Household_Size__c,  Min_Household_Size__c,Municipality_Name__r.General_Tax_Rate__c,
                                                                                            Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c,
                                                                                            Municipality_Name__r.Name, Municipality_Name__r.Region__c, Municipality_Name__r.Region_Counties__c, Max_Income_Level__c,Credit_Check_Required__c,
                                                                                            Rental_Assistance_Permitted__c, Listing_Stage__c,HOMEtracker__Status__c,HOMEtracker__Current_HOA_Condo_Fees__c,
                                                                                            Utilities__c, HOMEtracker__Property_Description__c, Deadline__c,Development_address__r.Minimum_Credit_Score_to_be_Eligible__c,
                                                                                            Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c,RecordTypeId, Development_address__r.Credit_Check_Required__c,
                                                                                            HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                                                                                            Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c, Development_address__r.X3x_Rent_Requirement__c,
                                                                                            Municipality_Name__r.Income_Limit__c,Disabled_eligible_regardless_of_age__c, Development_address__r.Dev_Income_Limit__c,
                                                                                            Municipality_Name__r.County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                                                                                            Municipality_Name__r.County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                                                                                            Municipality_Name__r.Down_Payment_Assistance_Cert_Text__c,
                                                                                            Municipality_Name__r.Rent_Assistance_Cert_Text__c
                                                                                            FROM 
                                                                                            HOMEtracker__Property__c 
                                                                                            Where Id 
                                                                                            IN : setPropertyIds
                                                                                            ]);
        
        
        map<string,PreApplicants__c> mapPreapplicants = new map<string,PreApplicants__c>([SELECT 
                                                                            Id, Name, Contact__r.Email, Phone__c, Street__c, Household_Disabled__c,
                                                                            City__c, Postal_Code__c, Household_Size__c, Household_Members_55__c ,
                                                                            Annual_Income__c, Live_Work_Regions__c,  Rental_Interest__c, 
                                                                            AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,
                                                                            Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,
                                                                            Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,
                                                                            Ext__c, State__c, Applicant_Name__c,Most_Recent_Update__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c,Veteran__c
                                                                            FROM  
                                                                            PreApplicants__c 
                                                                            Where id IN : setPreApplicantIds]);
        // call the eligibility criteria for the applications
//      map<Id,WrapperRentalProperties> mapRentalProperty = new map<Id,WrapperRentalProperties>();
        list<HOMEtracker__Property__c> lstRentalProperty;
        list<HOMEtracker__Property__c> lstPurchaseProperty;
        list<PreApplicants__c> lstPreApplicant;
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                          X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                          From Income_Limits__c]);
        PreApplicants__c preApplicantsInfo; 
        
        list<Task> lstTasks = new list<Task>();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
        string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
         
        for(Application__c  application : lstApplications)
        {
            // create parameter list to be sent to the library criteria method
            
            lstPreApplicant = new list<PreApplicants__c>();
            system.debug('mapProperties ** '+mapProperties);
            if(mapProperties != null && mapProperties.size() > 0 && mapProperties.get(application.Property__c).RecordTypeId == strRentalPropertyRecTypeId)
            {
                lstRentalProperty = new list<HOMEtracker__Property__c>();
                lstRentalProperty.add(mapProperties.get(application.Property__c));
                lstPreApplicant.add(mapPreapplicants.get(application.Pre_Applicant__c));
                preApplicantsInfo = new PreApplicants__c();
                //CGPHProfileController cntrl = new CGPHProfileController();//
                map<Id,CGPHProfileController.WrapperRentalProperties> mapWrapperRentalProperty ;//= new map<Id,WrapperRentalProperties>(); 
                // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEELIGIBILITYTRIGGER';
                mapWrapperRentalProperty = CGPHProfileController.calculateCriteriaForRental(lstRentalProperty,lstPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicantsInfo,application,'UseToPassPQCustomSetting');
                system.debug('return value mapWrapperRentalProperty : '+mapWrapperRentalProperty);
                application.Eligibility_Report__c = mapWrapperRentalProperty.get(application.Property__c).eligibilityReport;
                application.External_Report__c = mapWrapperRentalProperty.get(application.Property__c).eligibilityReportExternal;
                
                string strIntEligibilityReport = mapWrapperRentalProperty.get(application.Property__c).eligibilityReportExternal;
                system.debug(' strIntEligibilityReport '+strIntEligibilityReport);
                
                // if there is only exception is of divorce then mark status as Undetermined or regular process
                if( strIntEligibilityReport != null && strIntEligibilityReport != '' )
                {
                    if( strIntEligibilityReport.contains('-Applicant is in the process of separating or getting a divorce') == true)
                    {
                        strIntEligibilityReport = strIntEligibilityReport.remove('-Applicant is in the process of separating or getting a divorce');
                    }
                }
                
                if( strIntEligibilityReport != null && strIntEligibilityReport != '' && strIntEligibilityReport.contains('-') == false )
                {
                    application.Status__c = 'Undetermined, Pending Staff Action';
                }
                //else                
                if( mapWrapperRentalProperty.get(application.Property__c).b_IsEligible == true)
                        application.Status__c = 'Eligible, Pending Staff Action';
                else
                {
                    application.Status__c = 'Ineligible, Pending Staff Action';
                    Task t = new Task();
                    HOMEtracker__Property__c p = new HOMEtracker__Property__c();
                    system.debug('map of properties : '+mapProperties);
                    system.debug(' application.property  '+application.Property__c);
                    p = mapProperties.get(application.Property__c);
                    string subject =  'Submitted Interest Form, Not Advancing, Determined by Code - '+ (p!= null ? p.Name : '');
                    t = QuestionaryEligibilityCheckingHandler.createTask( subject,'Submitted Interest Form, Not Advancing - IF Ineligible, Determined by Code',application.Pre_Applicant__c);
                    lstTasks.add(t);                
                }
            }
            else if(mapProperties != null && mapProperties.size() > 0 && mapProperties.get(application.Property__c).RecordTypeId == strPurchasePropertyRecTypeId)
            {
                lstPurchaseProperty = new list<HOMEtracker__Property__c>();
                mapMunicipalityGTR = new map<Id,double>();
                mapMunicipalityGTR.put(mapProperties.get(application.Property__c).Municipality_Name__c,mapProperties.get(application.Property__c).Municipality_Name__r.General_Tax_Rate__c);
                lstPurchaseProperty.add(mapProperties.get(application.Property__c));
                lstPreApplicant.add(mapPreapplicants.get(application.Pre_Applicant__c));
                preApplicantsInfo = new PreApplicants__c();
                //CGPHProfileController cntrl = new CGPHProfileController();//
                map<Id,CGPHProfileController.WrapperPurchaseProperties> mapWrapperPurchaseProperty ;//= new map<Id,WrapperRentalProperties>(); 
                // in cgph custom setting add source from where function is called so as correct income limit lookup is retrieve
                cgphProfileCustomSettings.Maintenance_URL__c = 'SOURCEELIGIBILITYTRIGGER';
                mapWrapperPurchaseProperty = CGPHProfileController.calculateCriteriaForPurchase(lstPurchaseProperty,lstPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicantsInfo,mapMunicipalityGTR,application);
                system.debug('return value mapWrapperPurchaseProperty : '+mapWrapperPurchaseProperty);
                application.Eligibility_Report__c = mapWrapperPurchaseProperty.get(application.Property__c).eligibilityReport;
                application.External_Report__c = mapWrapperPurchaseProperty.get(application.Property__c).eligibilityReportExternal;
                
                String strIntEligibilityReport = mapWrapperPurchaseProperty.get(application.Property__c).eligibilityReportExternal;
                
                if(  mapWrapperPurchaseProperty.get(application.Property__c).b_IsEligible == true ) 
                application.Status__c = 'Eligible, Pending Staff Action';
                else
                {
                 
                 
                 /*
                  // check if divorce or downpayment are the only exceptions
                  Integer exceptionCheck = 0;               
                  // check if string contains the downpayment string
                  if( strIntEligibilityReport.contains('down payment') == true)
                    exceptionCheck = 90;

                  if( strIntEligibilityReport.contains('divorce') == true)
                   exceptionCheck += 90;

                  // Check if Divorce and Down payment are the only issues
                  if(strIntEligibilityReport.length() <= exceptionCheck) 
                    application.Status__c = 'Undetermined, Pending Staff Action';
                  else 
                    application.Status__c = 'Ineligible, Pending Staff Action';                 
                  */
                 application.Status__c = 'Ineligible, Pending Staff Action'; 
                 string strExternalEligibilityReport = ''; 
                 strExternalEligibilityReport = mapWrapperPurchaseProperty.get(application.Property__c).eligibilityReportExternal;
                    // if there is only exception is of divorce then mark status as Undetermined or regular process
                if( strExternalEligibilityReport != null && strExternalEligibilityReport != '' )
                {
                    if( strExternalEligibilityReport.contains('-Applicant is in the process of separating or getting a divorce') == true)
                    {
                        strExternalEligibilityReport = strExternalEligibilityReport.remove('-Applicant is in the process of separating or getting a divorce');
                    }
                }
                
                if( strExternalEligibilityReport != null && strExternalEligibilityReport != '' && strExternalEligibilityReport.contains('-') == false )
                {
                    application.Status__c = 'Undetermined, Pending Staff Action';
                }
                //else
                
                
                // if  only minimum down payment is ineligibility reason make status to undetermined pending staff action
                
                strExternalEligibilityReport = mapWrapperPurchaseProperty.get(application.Property__c).eligibilityReportExternal;
                system.debug(' strIntEligibilityReport '+strExternalEligibilityReport);
                
                
                if( strExternalEligibilityReport != null && strExternalEligibilityReport != '' )
                {
                    if( strExternalEligibilityReport.contains('-When you submitted an interest form for this home, you indicated that you will provide a down payment of $') == true)
                    {
                        strExternalEligibilityReport = strExternalEligibilityReport.remove('-When you submitted an interest form for this home, you indicated that you will provide a down payment of $');
                    }
                }
                
                if( strExternalEligibilityReport != null && strExternalEligibilityReport != '' && strExternalEligibilityReport.contains('-') == false )
                {
                    application.Status__c = 'Undetermined, Pending Staff Action';
                }
                
                    Task t = new Task();
                    HOMEtracker__Property__c p = new HOMEtracker__Property__c();
                    system.debug('map of properties : '+mapProperties);
                    system.debug(' application.property  '+application.Property__c);
                    p = mapProperties.get(application.Property__c);
                    system.debug('property is '+p);
                    string subject =  'Submitted Interest Form, Not Advancing, Determined by Code - '+ (p!= null ? p.Name : '');
                    t = QuestionaryEligibilityCheckingHandler.createTask( subject,'Submitted Interest Form, Not Advancing - IF Ineligible, Pending staff action',application.Pre_Applicant__c);
                    lstTasks.add(t);
                }
            }
        } 
        
        
        if(lstTasks != null && lstTasks.size()  > 0)
        {
            insert lstTasks;
        }  
    }
    
    
     // this method is used to log the activity
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
        
}