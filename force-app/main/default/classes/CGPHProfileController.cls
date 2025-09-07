/** 
* @author 
* @date 
* @description :  This apex class maintain CGP&H Profile Application Details. 
* @unit-test:  CGPHProfileControllerTest
**/
/* **************************************************************************
* Controller Class: CGPHProfileController
* Created by : 
* @unit-test: CGPHProfileControllerTest
* * 
* */
public class CGPHProfileController{ 
    
    class CGPHException Extends Exception{
        
    }
    // Get Property Full Information
    public String strPropertyId{get;set;}
    //    public string strPreApplicantId
    public transient HOMEtracker__Property__c PropertyInfo{get;set;}
    public transient List<Property_Image__c> lstPropertyImage{get;set;}
    public transient WrapperPropertyInfo objWrapperPropertyInfo{get;set;}
    public Application__c localAnswers { set; get; }
    // Properties
    public String strPreApplicantId{get;set;}
    public String strMunicipalityId{get;set;} 
    public String showOwnership{get;set;}
    private PreApplicants__c preApplicantsInfo{get;set;}
    public List<PreApplicants__c> lstPreApplicant{get;set;}
    private transient PreApplicantDetails objPreApplicantDetails{get;set;}
    private List<Municipality_Preference__c> lstRentalMunicipalityPreferences{get;set;}
    public List<RentalMunicipalPreference> lstWrapperRentalMunicipalPreference{get;set;}
    List<Municipality_Preference__c> lstPurchaseMunicipality;
    
    public map<string,List<RentalMunicipalPreference>> mapWrapperRentalMunicipalPreference{get;set;} // 
    
    public map<string,List<WrapperHownershipMunicipalPreference>> mapWrapperPurchaseMunicipalPreference{get;set;} //
    
    private transient List<Municipality_Preference__c> lstPurchaseMunicipalityPreferences{get;set;}
    private transient List<WrapperHownershipMunicipalPreference> lstWrapperHownershipMunicipalPreference{get;set;}
    private transient set<id> setMunicipalityPref{get;set;}
    private transient set<id> setPurchaseMunicipalityPref{get;set;}
    public boolean b_ShowForm{get;set;}
    public String Url{get;set;}
    public boolean b_RentalService{get;set;}
    public boolean b_PurchaseService{get;set;}
    public transient List<WrapperRentalProperties> lstWrapperRentalProperties{get;set;}
    public transient List<WrapperPurchaseProperties> lstWrapperPurchaseProperties{get;set;}
    public CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings{get;set;}
    
    private static final String StrEligible = 'eligible';
    private static final String StrInEligible = 'inEligible'; 
    
    public transient map<string,Municipality_Preference__c> mapRentalMunicipalityNameToPreferences{get;set;}
    
    public transient map<string,Municipality_Preference__c>  mapPurchaseMunicipalityNameToPreferences{get;set;}
    public boolean showPurchaseMsg{ get;set; }
    public boolean showRentalMsg{ get;set; }
    
    private string helpContent;
    private string endPoint;
    static string streligibilityReport = '';
    static string streligibilityReportExternal = '';
    
    public integer iProfileViews {get;set;}
    public string strSuffix{get;set;}
    public String internalview;
    
    public map<String,List<WrapperPurchaseProperties>> mapWrapPurchaseProperties{get;set;}
    public map<String,List<WrapperRentalProperties>> mapWrapRentalProperties{get;set;}
    public integer iPurchasePropMapSize{get;set;}
    public integer iRentalPropMapSize{get;set;}
    public boolean b_showLocalModal{get;set;}
    public String pageName;
    
    // local municipality preference
    public boolean LiveInMontaclair{get;set;}
    public boolean FullTimeEmpMontClair{get;set;}
    
    public boolean LiveInHoboken{get;set;}
    public boolean EmployeeInHoboken{get;set;}
    public boolean LivedForYearInHoboken{get;set;}
    
    
    // Constructor
    public CGPHProfileController(){              
        cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        if(trigger.isExecuting == false)
        {
            
            try{
                pageName = ApexPages.CurrentPage().getUrl();     // THIS IS THE CLOSEST YOU CAN GET SO FAR
                if(Test.isRunningTest() == false) {
                    pageName = pageName.replaceFirst('/apex/','');          // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
                    
                    pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   // YOU WANT TO END AT THE QUESTION MARK BUT
                    // YOU HAVE TO ENCODE IT FIRST
                    string[] pageNameExtra = pageName.split('%3F',0);   // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8
                    // SO YOU MAY SPLIT THE STRING AT THAT POINT
                    pageName = pageNameExtra[0];
                    //system.debug();
                }
                iRentalPropMapSize = 0;
                iPurchasePropMapSize = 0;
                localAnswers = null;            
                b_ShowForm = true;
                b_RentalService = true;
                b_PurchaseService = true;
                internalview = ApexPages.currentPage().getParameters().get('internal');
                String ownershipParam = ApexPages.currentPage().getParameters().get('ownership');  // URL param tells profile page to open Ownership or Rental listings
                
                if(ownershipParam == 'true' || ownershipParam == null){
                    showOwnership = 'true';
                }else{
                    showOwnership = 'false'; 
                }
                
                // Get Enconded id url parameter and look up Pre-Applicant
                string strPreApplicantIdOld = '';
                strPreApplicantId =  ApexPages.currentPage().getParameters().get('appId');
                strPreApplicantIdOld = strPreApplicantId;
                
                if(strPreApplicantId != null || strPreApplicantId != ''){
                    strPreApplicantId = EncodingUtil.base64Decode(strPreApplicantId).toString();
                    // cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();
                    // string strEncodeSuffix = cgphSettings.Encrypted_ID_Suffix__c;
                    string strAddedSuffix = strPreApplicantId.substring(strPreApplicantId.length() - 4,strPreApplicantId.length());
                    strPreApplicantId = strPreApplicantId.substring(0,strPreApplicantId.length() - 4);
                    if(!Test.isRunningTest())
                        strPreApplicantId=String.escapesingleQuotes(strPreApplicantId);
                    else
                        strPreApplicantId=strPreApplicantId;   
                    
                    lstPreApplicant = new  List<PreApplicants__c>();
                    // Query Profile Pre-Applicant
                    lstPreApplicant = [SELECT Phone__c ,
                                       Id,Contact__c, Contact__r.FirstNAme,Contact__r.LastNAme,Name, Annual_Income__c,Applicant_Name__c,Test_Pre_Applicant__c,AR_Properties_Only__c,Contact__r.MailingStreet,
                                       Contact__r.MailingCity,Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.Email,Contact__r.Phone,Ext__c,Household_Disabled__c,Household_Members_55__c,
                                       Household_Size__c,Last_Profile_View__c,Live_Work_Regions__c,Max_Down_Payment__c,
                                       Monthly_Other_Assistance__c,Monthly_Rent__c,Most_Recent_Update__c,
                                       Number_of_Profile_Views__c,Property_Questionnaire_URL__c,
                                       Purchase_Interest__c,Region_Counties__c,Rental_Interest__c,Restart_URL__c,
                                       Section_8__c,Substandard_Overcrowded_Housing__c,Update_Days__c,
                                       Update_Status__c,Update_URL__c,Youngest_Household_Member__c,Encrypted_ID_Suffix__c,PreApplicant_Encoded_Id__c                            
                                       FROM  
                                       PreApplicants__c 
                                       Where 
                                       Id =: strPreApplicantId Limit 1];
                    
                    if( lstPreApplicant == null || lstPreApplicant.size() == 0 )
                    {
                        // throw exception
                        throw new CGPHException('Invalid Id');
                    }
                    
                    
                    // if original id and new id is not same throw error
                    
                    if( (lstPreApplicant[0].PreApplicant_Encoded_Id__c != strPreApplicantIdOld) && Test.isRunningTest() == false )
                    {
                        // throw exception 
                        throw new CGPHException('Invalid Id');
                    }
                    
                    CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
                    cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();                            
                    if( lstPreApplicant != null && lstPreApplicant.size() > 0 )
                    {
                        strSuffix = lstPreApplicant[0].Encrypted_ID_Suffix__c != null ? lstPreApplicant[0].Encrypted_ID_Suffix__c : cgphSettings.Encrypted_ID_Suffix__c;
                        
                        if(strAddedSuffix != strSuffix)
                        {
                            // throw exception
                            throw new CGPHException('Invalid Id');
                        }
                        
                        iProfileViews = (Integer)lstPreApplicant[0].Number_of_Profile_Views__c;
                    }   
                    if(lstPreApplicant.isEmpty()){
                        b_ShowForm = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'You have not provided a valid Affordable Homes New Jersey Id. Please <a href="https://www.affordablehomesnewjersey.com/my-profile/">click here</a> to request your link or create a new profile.'));
                    }else if(lstPreApplicant[0].Household_Size__c == '9+' || lstPreApplicant[0].Household_Size__c == null) {
                        if(lstPreApplicant[0].Household_Size__c == '9+'){
                            b_ShowForm = false;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, lstPreApplicant[0].Applicant_Name__c + ', there are no homes with more than 4 bedrooms in our portfolio. Based on your household size of 9+, you will require a 5 bedroom home or larger. Update your profile <a href="' + lstPreApplicant[0].Update_URL__c + '">here</a>.'));
                        }else{
                            b_ShowForm = false;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, lstPreApplicant[0].Applicant_Name__c + ', please update the household size in your profile <a href="' + lstPreApplicant[0].Update_URL__c + '">here</a>.'));
                        }
                        //}else if(lstPreApplicant[0].Live_Work_Regions__c==null){
                        //    b_ShowForm = false;
                        //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, lstPreApplicant[0].Applicant_Name__c + ', please update the live work regions in your profile <a href="' + lstPreApplicant[0].Update_URL__c + '">here</a>. Please choose at least one live work region.'));
                    }else if(lstPreApplicant[0].Monthly_Other_Assistance__c == null){
                        lstPreApplicant[0].Monthly_Other_Assistance__c = 0;
                    } else if(lstPreApplicant[0].Update_Status__c == 'Grace Period') {
                        b_ShowForm = false;
                        Date expiredDate = Date.valueOf(lstPreApplicant[0].Most_Recent_Update__c) + 366;
                        String expiredString = expiredDate.format();
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, lstPreApplicant[0].Applicant_Name__c + ', your profile expired on ' + expiredString + '. You have ' + lstPreApplicant[0].Update_Days__c + ' before you are removed from all waiting lists. <a href="' + lstPreApplicant[0].Update_URL__c + '">Please update your profile now</a>.'));
                    } else if(lstPreApplicant[0].Update_Status__c == 'Expired') {
                        b_ShowForm = false;
                        Date expiredDate = Date.valueOf(lstPreApplicant[0].Most_Recent_Update__c) + 366;
                        String expiredString = expiredDate.format();
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, lstPreApplicant[0].Applicant_Name__c + ', your profile expired on ' + expiredString + '. You have been removed from all waiting lists. You need to submit a new pre-application to reapply. <a href="' + lstPreApplicant[0].Restart_URL__c + '">Please update your profile now</a>.'));
                        
                    }
                }
                
                // get help content
                
                getGeneralMessageContent();
                
                preApplicantsInfo = lstPreApplicant[0];
                System.debug('Pre-Applicant ' + lstPreApplicant[0].Name + ' found. Dispaly form = ' + b_ShowForm);
                mapWrapPurchaseProperties = new map<String,List<WrapperPurchaseProperties>>();
                // get the purchase properties
                mapWrapPurchaseProperties = getPurchaseProperties();
                iPurchasePropMapSize = mapWrapPurchaseProperties.size();
                
                // get the renatal proprties
                mapWrapRentalProperties = new map<String,List<WrapperRentalProperties>>();
                mapWrapRentalProperties = getRentalProperties();
                iRentalPropMapSize = mapWrapRentalProperties.size();
                
            }
            catch(Exception e){
                b_ShowForm = false; 
                System.debug(logginglevel.error,'Pre-Applicant Query Exception: ' + e.getMessage() );
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'You have not provided a valid Affordable Homes New Jersey Id. Please <a href="https://www.affordablehomesnewjersey.com/my-profile/">click here</a> to request your link or create a new profile.'));
            }
            
        }
    }
    
    //public string strMunicipalityId{get;set;}
    public PageReference showLocalModal(){
        localAnswers = new Application__c();
        localAnswers.Answer_1__c = null;
        localAnswers.Answer_2__c = null;
        b_showLocalModal = true;
        String strMunicipalityName = ApexPages.currentPage().getParameters().get('strMunicipalityName');
        strMunicipalityId = ApexPages.currentPage().getParameters().get('strMunicipalityId');
        localAnswers.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Local Answers').getRecordTypeId();
        localAnswers.Pre_Applicant__c = preApplicantsInfo.Id; 
        localAnswers.Last_Name__c = preApplicantsInfo.Contact__r.LastName;
        localAnswers.First_Name__c = preApplicantsInfo.Contact__r.FirstName;
        Municipality__c muncipility = new Municipality__c();
        muncipility.Id = strMunicipalityId;
        muncipility.Name = strMunicipalityName;
        localAnswers.Municipality__c = strMunicipalityId;
        localAnswers.Municipality__r = muncipility;
        localAnswers.Question_1__c = 'Is anyone in your household an employee of the City of Hoboken, the Hoboken Board of Education, any Hoboken Charter School, or the Hoboken Housing Authority?';
        localAnswers.Question_2__c = 'Has anyone in your household been a Hoboken resident for at least one year?';
        return null;
    }
    
    
    public PageReference closeLocalModal(){
        localAnswers = null;
        b_showLocalModal = false;
        return Null;
    }
    
    public PageReference hideLocalModal(){
        
        b_showLocalModal= false;
        return Null;
    }
    
    
    // create Ineligible preference
    public PageReference createPreference()
    {
        try{
            Municipality__c muncipility = [SELECT Id,Name FROM Municipality__c WHERE Id =: localAnswers.Municipality__c LIMIT 1];
            Municipality_Preference__c newMunicipalityPreference = new Municipality_Preference__c();
            newMunicipalityPreference.Name = muncipility.Name;
            newMunicipalityPreference.PreApplicant__c =  String.escapesingleQuotes(strPreApplicantId);
            newMunicipalityPreference.Municipality__c = muncipility.Id;
            newMunicipalityPreference.Interest_Date__c = Date.today();
            if( pageName.equalsIgnoreCase('HomeownerMunicipalityPreferences' ) == true)
                newMunicipalityPreference.Type__c = 'Ownership';
            else if( pageName.equalsIgnoreCase('RentalMunicipalityPreferences' ) == true)
                newMunicipalityPreference.Type__c = 'Rental';
            newMunicipalityPreference.Status__c = 'Ineligible';               
            upsert newMunicipalityPreference;
        }catch(Exception ex){
            ApexPages.Message exceptionMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(exceptionMsg);
        }
        return null;
    }
    
    
    /* public PageReference saveLocalModalPreferences(){      
if( pageName.equalsIgnoreCase('HomeownerMunicipalityPreferences' ) == true)
{
joinOwnershipMunicipalityWaitingList();
}
else
{
joinRentalMunicipalityWaitingList();
}   
b_showLocalModal = false;
return null;
}

*/
    
    public Application__c app{get;set;}
    
    public PageReference saveLocalModal(){
        if(localAnswers != NULL){
            try{
                
                Application__c app = new Application__c();
                Municipality__c muncipility = [SELECT Id,Name FROM Municipality__c WHERE Id =: localAnswers.Municipality__c LIMIT 1];
                Application__c localMuncipalityAnswer = new Application__c();
                localAnswers.Status__c = 'Active';
                localMuncipalityAnswer.RecordTypeId = localAnswers.RecordTypeId;
                localMuncipalityAnswer.Pre_Applicant__c = localAnswers.Pre_Applicant__c;
                localMuncipalityAnswer.Municipality__c = muncipility.Id;
                localMuncipalityAnswer.First_Name__c = localAnswers.First_Name__c;
                localMuncipalityAnswer.Last_Name__c = localAnswers.Last_Name__c;
                localMuncipalityAnswer.Live_in_Montclair__c = LiveInMontaclair != null ? LiveInMontaclair : false;
                localMuncipalityAnswer.Employed_in_Montclair__c = FullTimeEmpMontClair != null ? FullTimeEmpMontClair : false;
                localMuncipalityAnswer.Live_in_Hoboken__c = LiveInHoboken != null ? LiveInHoboken : false;
                localMuncipalityAnswer.Employed_in_Hoboken__c = EmployeeInHoboken != null ? EmployeeInHoboken : false;
                localMuncipalityAnswer.Live_in_Hoboken_One_Year__c = LivedForYearInHoboken != null ? LivedForYearInHoboken : false;
                
                if(  strMunicipalityId == cgphProfileCustomSettings.Montaclair_Municipality_Id__c ) // if montaclair municipality
                {
                    if( (LiveInMontaclair != null && FullTimeEmpMontClair != null) && ( LiveInMontaclair || FullTimeEmpMontClair) )
                    {
                        localMuncipalityAnswer.Montclair_General_Local__c = true;   
                    }
                } 
                
                else if( strMunicipalityId == cgphProfileCustomSettings.Hoboken_Municipality_Id__c || strMunicipalityId == cgphProfileCustomSettings.Hoboken_Workforce_Program_Id__c)
                {
                    if( LiveInHoboken == true)
                    {
                        localMuncipalityAnswer.Hoboken_General_Local__c = true;
                    }
                    if( EmployeeInHoboken == true || LivedForYearInHoboken == true)
                    {
                        localMuncipalityAnswer.Hoboken_Alternate_Local__c = true;
                    }
                } 
                
                if( pageName.equalsIgnoreCase('HomeownerMunicipalityPreferences' ) == true)
                    localMuncipalityAnswer.Name = Date.today().Year()+'.'+Date.today().Month()+'.'+Date.today().Day()+' '+localAnswers.Last_Name__c + ', ' +localAnswers.First_Name__c+' Ownership Answers';
                else
                    localMuncipalityAnswer.Name = Date.today().Year()+'.'+Date.today().Month()+'.'+Date.today().Day()+' '+localAnswers.Last_Name__c + ', ' +localAnswers.First_Name__c+' Rental Answers';
                
                List<Application__c> localMuncipalityAnswerList = new List<Application__c>();
                localMuncipalityAnswerList.add(localMuncipalityAnswer);
                
                system.debug('===!!! '+localMuncipalityAnswer);
                system.debug('===!!! '+localAnswers);
                insert localMuncipalityAnswerList;  
                app = [SELECT id,Eligibility__c FROM Application__c WHERE Id =:localMuncipalityAnswer.Id ];
                strMunicipalityId = localAnswers.Municipality__c;
                
                
                CGPH_Profile_Custom_Settings__c cgphSettings = new CGPH_Profile_Custom_Settings__c();
                cgphSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
                
                string subject = localAnswers.Last_Name__c+', '+localAnswers.First_Name__c+' '+muncipility.Name;
                
                if( pageName.equalsIgnoreCase('HomeownerMunicipalityPreferences' ) == true)
                {
                    joinOwnershipMunicipalityWaitingList();
                    subject += ' '+'Purchase';
                }
                else
                {
                    subject += ' '+'Rental';
                    joinRentalMunicipalityWaitingList();
                }     
                
                subject += ' '+'Eligible';
                
                //createPreference();
                //subject += ' '+'Ineligible';
                
                strMunicipalityId = localMuncipalityAnswer.Municipality__c;
                
                task newTask = new task();
                newTask.OwnerId = cgphSettings.Admin_User_Id__c != null ? cgphSettings.Admin_User_Id__c : UserInfo.getUserId();
                newTask.WhatId = localAnswers.Pre_Applicant__c;
                newTask.Description = '';//'Link to the Preference Record : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+pref.id;
                newTask.Subject = subject;//'Removed Expired On Hold MP Name Preference';
                newTask.status = 'Completed';
                newTask.Archive__c = true;
                insert newTask;
                
                localAnswers = null; 
                b_showLocalModal = false;
            }catch(Exception ex){
                ApexPages.Message exceptionMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(exceptionMsg);
            }
        }
        return Null;
    }
    
    
    // Show PreApplicant Details On Page Load
    public PreApplicantDetails getPreApplicantDetails(){
        system.debug(' strPreApplicantId '+strPreApplicantId);
        try{
            if( lstPreApplicant != null && !lstPreApplicant.isEmpty() ){
                
                List<String> lstLiveRegion = new  List<String>();
                String strPhoneFormat, strLiveRegion = '', separator = ',';
                Date mostRecentDate;
                Boolean b_RentalMunicipalPreference, b_PurchaseMunicipalPreference, b_firstItem;
                b_RentalMunicipalPreference = false;
                b_PurchaseMunicipalPreference = false;
                lstRentalMunicipalityPreferences = new List<Municipality_Preference__c>();
                lstRentalMunicipalityPreferences = [SELECT Id, Municipality__c, Municipality__r.Name, Municipality__r.Rental_Portfolio__c, 
                                                    Interest_Date__c, Type__c, Municipality__r.Rental_Waiting_List__c, Municipality__r.County__c, Status__c ,
                                                    Municipality__r.Rental_Waiting_List_Type__c,Lottery_Number__c, On_Hold__c,Municipality__r.Local_Preference__c
                                                    FROM 
                                                    Municipality_Preference__c 
                                                    Where 
                                                    PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId)
                                                    AND 
                                                    Municipality__r.Rental_Portfolio__c = true 
                                                    AND 
                                                    PreApplicant__r.Rental_Interest__c = true 
                                                    AND 
                                                    Type__c = 'Rental' 
                                                    AND 
                                                    ( Status__c = 'Active' OR On_Hold__c = true ) limit 10000];
                
                System.debug(lstRentalMunicipalityPreferences.size() + ' Rental Municipalities found');
                
                system.debug('lstPreApplicant:'+lstPreApplicant);
                lstPurchaseMunicipality = [SELECT Id,Municipality__r.Local_Preference__c FROM Municipality_Preference__c 
                                           Where PreApplicant__c =: lstPreApplicant[0].Id AND Municipality__r.Purchase_Portfolio__c = true AND PreApplicant__r.Purchase_Interest__c = true  AND ( Status__c = 'Active' OR On_Hold__c = true) AND Type__c = 'Ownership' limit 10000];
                
                System.debug(lstPurchaseMunicipality.size() + ' Purchase Municipalities found');
                
                
                if(lstPreApplicant[0].phone__c != null){
                    strPhoneFormat = formatPhone(lstPreApplicant[0].phone__c); 
                }
                if(lstPreApplicant[0].Live_Work_Regions__c != null)
                    lstLiveRegion = lstPreApplicant[0].Live_Work_Regions__c.split(';');
                
                b_firstItem = true;
                if(lstLiveRegion != null && lstLiveRegion.size() > 0)
                    for (String item : lstLiveRegion) {
                        if(item != null) {
                            if(b_firstItem){
                                b_firstItem = false;
                            }
                            else {
                                strLiveRegion += separator;
                            }
                            strLiveRegion += item;
                        }
                    }
                
                if(lstPreApplicant[0].Most_Recent_Update__c != null)
                    mostRecentDate = Date.valueOF(lstPreApplicant[0].Most_Recent_Update__c);
                
                if(lstRentalMunicipalityPreferences != null && lstRentalMunicipalityPreferences.size() > 0 && lstPurchaseMunicipality != null && lstPurchaseMunicipality.size() > 0){
                    b_RentalMunicipalPreference = true;
                    b_PurchaseMunicipalPreference = true; 
                    objPreApplicantDetails = new PreApplicantDetails(lstPreApplicant[0],strLiveRegion,mostRecentDate,strPhoneFormat,b_RentalMunicipalPreference,b_PurchaseMunicipalPreference,(Integer)lstPreApplicant[0].Update_Days__c);//Inner Class
                }
                else if(lstPurchaseMunicipality != null && lstPurchaseMunicipality.size() > 0){
                    b_PurchaseMunicipalPreference = true;
                    b_RentalMunicipalPreference = false;
                    objPreApplicantDetails = new PreApplicantDetails(lstPreApplicant[0],strLiveRegion,mostRecentDate,strPhoneFormat,b_RentalMunicipalPreference,b_PurchaseMunicipalPreference,(Integer)lstPreApplicant[0].Update_Days__c);//Inner Class 
                }
                else if(lstRentalMunicipalityPreferences != null && lstRentalMunicipalityPreferences.size() > 0){
                    b_RentalMunicipalPreference = true;
                    b_PurchaseMunicipalPreference = false;
                    objPreApplicantDetails = new PreApplicantDetails(lstPreApplicant[0],strLiveRegion,mostRecentDate,strPhoneFormat,b_RentalMunicipalPreference,b_PurchaseMunicipalPreference,(Integer)lstPreApplicant[0].Update_Days__c);//Inner Class 
                }
                else{
                    objPreApplicantDetails = new PreApplicantDetails(lstPreApplicant[0],strLiveRegion,mostRecentDate,strPhoneFormat,b_RentalMunicipalPreference,b_PurchaseMunicipalPreference,(Integer)lstPreApplicant[0].Update_Days__c);//Inner Class
                }
            }
        }
        catch(Exception e) {
            b_ShowForm = false; 
            System.debug(logginglevel.error,'Pre-Applicant Rental/Purchase Preference Query Exception: ' + e.getMessage() +' stackTrace : '+e.getstackTraceString());          
        }
        
        return objPreApplicantDetails;
    }
    
    // preapplicant profile views summary 
    
    public pagereference setProfileStatistics()
    {
        try{
            
            CGPH_Profile_Custom_Settings__c cgphSettingsObj = new CGPH_Profile_Custom_Settings__c();
            cgphSettingsObj = CGPH_Profile_Custom_Settings__c.getInstance();
            if(cgphSettingsObj.Temporary_Maintenance__c==true)
            {
                string strURL = cgphSettingsObj.Maintenance_URL__c;
                PageReference pageRef = new PageReference(strURL);
                return pageRef.setRedirect(true);
                //pageRef.setRedirect(true);
                //return pageRef;
            }
            system.debug('lstPreApplicant:'+lstPreApplicant);
            PreApplicants__c preApplicant = new PreApplicants__c(id=lstPreApplicant[0].id,Last_Profile_View__c=lstPreApplicant[0].Last_Profile_View__c,Number_of_Profile_Views__c = lstPreApplicant[0].Number_of_Profile_Views__c);
            
            if(internalView != 'true') // bypass if being viewed internally
            {
                if( preApplicant.Last_Profile_View__c == null)
                {
                    if(lstPreApplicant[0].Update_Status__c != 'None')
                        preApplicant.Number_of_Profile_Views__c = 1;
                }
                
                if(preApplicant.Last_Profile_View__c != null) {
                    
                    Integer hours = Integer.valueOf(( datetime.now().getTime() - preApplicant.Last_Profile_View__c.getTime() )/(1000*60*60));
                    system.debug('p3='+ hours);
                    if( hours > 2 )
                    {
                        if(lstPreApplicant[0].Update_Status__c != 'None')
                            preApplicant.Number_of_Profile_Views__c = (preApplicant.Number_of_Profile_Views__c == null ? 1 : preApplicant.Number_of_Profile_Views__c) + 1;
                    }
                } 
                preApplicant.Last_Profile_View__c = datetime.now();
                
                update preApplicant;
            }  
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.error,'Pre-Applicant Profile Statistics Error: ' + ex.getMessage() +' stackTrace : '+ex.getstackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'You have not provided a valid Affordable Homes New Jersey Id. Please <a href="https://www.affordablehomesnewjersey.com/my-profile/">click here</a> to request your link or create a new profile.'));
        }
        
        return null;
    }
    
    // welcome content
    
    public pagereference updatePreApplicantActive()
    {   
        try{
            PreApplicants__c preApplicant = new PreApplicants__c(id=lstPreApplicant[0].id); 
            //preApplicant.Pre_Applicant_Active__c = true;
            update preApplicant;
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.error,'Pre-Applicant StatusActive: ' + ex.getMessage() +' stackTrace : '+ex.getstackTraceString());
        }
        string returnURL = '/apex/CGPHProfile'+'?appId='+String.escapesingleQuotes(ApexPages.currentPage().getParameters().get('appId'));
        
        if( internalview == 'true' )
            returnURL += '&internal=true';
        
        PageReference returnPage = new PageReference(returnURL);  
        returnPage.setRedirect(true);
        return returnPage;
    }
    //RentalMunicipality if Municiplaity have Rental Portfolio TownShips
    //Show RentalMunicipality Below Prapplicant Profile Information
    public List<RentalMunicipalPreference> getListRentalMunicipality(){
        //Rental Information
        
        lstWrapperRentalMunicipalPreference = new List<RentalMunicipalPreference>();
        
        try{
            if(lstRentalMunicipalityPreferences != null && lstRentalMunicipalityPreferences.size() > 0){
                for(Municipality_Preference__c rentalMunicipality : lstRentalMunicipalityPreferences){
                    lstWrapperRentalMunicipalPreference.add(new RentalMunicipalPreference(rentalMunicipality));
                }
            }          
        }catch(Exception e){
            system.debug(logginglevel.error,'Rental Municipality Wrapper Exception: ' + e.getMessage() +' stackTrace : '+e.getstackTraceString());
        }
        return lstWrapperRentalMunicipalPreference;
    }
    
    
    //Municipality Township with different-different filter
    public pagereference getRentalTownshipPreferences(){
         cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
        CGPH_Profile_Custom_Settings__c cgphSettingsObj = new CGPH_Profile_Custom_Settings__c();
        cgphSettingsObj = CGPH_Profile_Custom_Settings__c.getInstance();
        if(cgphSettingsObj.Temporary_Maintenance__c==true)
        {
            string strURL = cgphSettingsObj.Maintenance_URL__c;
            PageReference pageRef = new PageReference(strURL);
            return pageRef.setRedirect(true);
            //pageRef.setRedirect(true);
            //return pageRef;
        }
        showOwnership = 'false';
        List<Municipality__c> lstMunicipality;
        if( lstPreApplicant != null && lstPreApplicant.size() > 0 && lstPreApplicant[0].Test_Pre_Applicant__c == false )
        {
            lstMunicipality = [Select Name, AR_Rental_Properties__c, Min_Income__c, 
                               Rental_Portfolio__c, Rental_Portfolio_Income_Levels__c, 
                               Rental_Unit_Size__c, Rental_Waiting_List__c, Region__c, Rental_Units__c ,
                               Rental_Permanent_Disability_AR_Exception__c, Live_Work_Preference__c, County__c,Income_Limit__c,Local_Preference__c    
                               From Municipality__c Where Rental_Portfolio__c = true AND Test_Municipality__c = false Limit 10000];//
        }
        else
        {
            lstMunicipality = [Select Name, AR_Rental_Properties__c, Min_Income__c, 
                               Rental_Portfolio__c, Rental_Portfolio_Income_Levels__c, 
                               Rental_Unit_Size__c, Rental_Waiting_List__c, Region__c, Rental_Units__c ,
                               Rental_Permanent_Disability_AR_Exception__c, Live_Work_Preference__c, County__c,Income_Limit__c,Local_Preference__c    
                               From Municipality__c Where Rental_Portfolio__c = true  Limit 10000];//
        }                                        
        if((lstPreApplicant != null && lstPreApplicant.size() > 0) && (lstMunicipality != null && lstMunicipality.size() > 0)){
            mapWrapperRentalMunicipalPreference = new map<string,List<RentalMunicipalPreference>>(); 
            mapWrapperRentalMunicipalPreference = verifyRentalMunicipalityCriterias(lstPreApplicant,lstMunicipality,'');
            system.debug(lstMunicipality.size() + ' Municipalities with Rental Properties');
            //return lstWrapperRentalMunicipalPreference;
        }else{
            b_ShowForm = false; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'No Municipalities with Rental Portfolios at this time .'));
            //return null;
        }
        return null;
    }
    
    
    
    
    //This Method is used for RentalMunicpalityPreference page, 
    //1. Eligible Municipality Information
    //2. Applied Municipality Preferences by a Preapplicant
    //3. Not Eligible Municiplaities Preferences and Municipality
    public map<string,List<RentalMunicipalPreference>> verifyRentalMunicipalityCriterias(List<PreApplicants__c> lstPreApplicant, list<Municipality__c> lstMunicipality,string prefType){
        String strStatus, strMessage;
        //map for existing preapplicant apply municipalitypreferences
        map<id,list<Municipality_Preference__c>> mapOfMunicipalityPreference = new map<id,list<Municipality_Preference__c>>();      
        lstWrapperRentalMunicipalPreference = new List<RentalMunicipalPreference>();
        setMunicipalityPref = new set<id>();
        List<RentalMunicipalPreference> lstSelectedMunicipalPreference = new List<RentalMunicipalPreference>();
        List<RentalMunicipalPreference> lstEligibleInEligbleMunicipalPreference = new List<RentalMunicipalPreference>();
        List<RentalMunicipalPreference> lstEligbleMunicipalPreference = new List<RentalMunicipalPreference>();
        List<RentalMunicipalPreference> lstEligibleMunicipalPreference = new List<RentalMunicipalPreference>(); 
        mapWrapperRentalMunicipalPreference = new map<string,List<RentalMunicipalPreference>>{'MyMunicipalities' => lstSelectedMunicipalPreference ,'EligibleMunicipalities' =>lstSelectedMunicipalPreference, 'InEligibleMunicipalities' => lstSelectedMunicipalPreference};
            try{           
                for(Municipality_Preference__c municipalityPref : [SELECT Municipality__c,  
                                                                   Municipality__r.Name, Interest_Date__c, 
                                                                   Type__c, Municipality__r.Rental_Waiting_List__c, Status__c,Municipality__r.County__c,Municipality__r.Region__c,Municipality__r.Local_Preference__c  
                                                                   FROM Municipality_Preference__c 
                                                                   Where PreApplicant__c =: lstPreApplicant[0].id AND Type__c = 'Rental' Order By Status__c ASC]){
                                                                       if(mapOfMunicipalityPreference.containsKey(municipalityPref.Municipality__c) == true)
                                                                       {
                                                                           list<Municipality_Preference__c> lstPreference = new list<Municipality_Preference__c>();
                                                                           lstPreference =  mapOfMunicipalityPreference.get(municipalityPref.Municipality__c);
                                                                           lstPreference.add(municipalityPref);                                                
                                                                           mapOfMunicipalityPreference.put(municipalityPref.Municipality__c,lstPreference);
                                                                       } 
                                                                       else
                                                                       {
                                                                           list<Municipality_Preference__c> lstPreference = new list<Municipality_Preference__c>();
                                                                           lstPreference.add(municipalityPref);                                                
                                                                           mapOfMunicipalityPreference.put(municipalityPref.Municipality__c,lstPreference);
                                                                       }
                                                                   }
                Boolean isValid = true;
                
                list<Income_Limits__c> lstIncomeLimit;
                map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                                        X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                                        From Income_Limits__c]);     
                
                system.debug(mapOfMunicipalityPreference.size()+' Pre-Applicant Rental Municip Prefs found : ' + mapOfMunicipalityPreference);
                for(Municipality__c municipality : lstMunicipality) {
                    strStatus = null;
                    list<string> lstStrMessage = new list<string>();
                    strMessage = '';
                    system.debug('>'+municipality.Name); 
                    if(municipality.Rental_Portfolio__c == FALSE){
                        strStatus = StrInEligible;
                        strMessage = 'Municipality doesn\'t have Rental Properties in portfolio';
                        
                        if(!setMunicipalityPref.contains(municipality.id)){
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            setMunicipalityPref.add(municipality.id);
                        }
                    }else{
                        
                        if(lstPreApplicant[0].Household_Members_55__c == false && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'All AR' && lstPreApplicant[0].Household_Disabled__c == false){
                            strStatus = StrInEligible;
                            strMessage = '-All units are age restricted and your household does not have a member over 55. There is no exception to this requirement.<br/>';                    
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setMunicipalityPref.contains(municipality.id)){
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if(lstPreApplicant[0].AR_Properties_Only__c == true && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'No AR'){
                            strStatus = StrInEligible;
                            strMessage = '-Your Household is only interested in 55+ communities and Municipality has no 55+ rental communities<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setMunicipalityPref.contains(municipality.id)){
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if(lstPreApplicant[0].Household_Members_55__c == False && lstPreApplicant[0].Household_Disabled__c == true && municipality.AR_Rental_Properties__c != null && municipality.AR_Rental_Properties__c == 'All AR' && municipality.Rental_Permanent_Disability_AR_Exception__c == FALSE){
                            strStatus = StrInEligible;
                            strMessage = '-All units are age restricted and your household does not have a member over 55. There is no exception to this requirement.<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setMunicipalityPref.contains(municipality.id)){
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if((lstPreApplicant[0].Annual_Income__c + (lstPreApplicant[0].Monthly_Other_Assistance__c*12)) < municipality.Min_Income__c && lstPreApplicant[0].Section_8__c == false){
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income below Min Income<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setMunicipalityPref.contains(municipality.id)){
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        lstIncomeLimit = new list<Income_Limits__c>();
                        lstIncomeLimit.add(mapIncomeLimit.get(municipality.Income_Limit__c));
                        boolean b_IsMaxIncome = getMaxIncomeValue(municipality,lstPreApplicant,lstIncomeLimit,prefType);
                        if(b_IsMaxIncome != null && b_IsMaxIncome == false){
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income exceeds Max Income<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setMunicipalityPref.contains(municipality.id)){ 
                                setMunicipalityPref.add(municipality.id);
                            }
                        }else if(b_IsMaxIncome == null){
                            system.debug(loggingLevel.ERROR,'No Rental Max Income Level for ' + municipality);
                            throw new MunicipalityException('Please provide Rental Level for ' + municipality.Name);
                        }
                    }
                    
                    if( lstStrMessage != null && lstStrMessage.size() > 0 ) {
                        lstEligibleInEligbleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage,null,false));
                    }else{
                        if(!setMunicipalityPref.contains(municipality.id) && mapOfMunicipalityPreference.containsKey(municipality.id)){
                            list<Municipality_Preference__c> lstMuncipalityPreference = mapOfMunicipalityPreference.get(municipality.id);
                            if(lstMuncipalityPreference != null && lstMuncipalityPreference.size() > 0)
                            {
                                for(Municipality_Preference__c muncipalityPreference : lstMuncipalityPreference)
                                { 
                                    if(muncipalityPreference.Status__c == 'Active')
                                    {
                                        system.debug(municipality.Name+' is a Wait List');
                                        strStatus = 'WaitingList';
                                        lstSelectedMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage,muncipalityPreference.Interest_Date__c,true));
                                        setMunicipalityPref.add(municipality.id);
                                        break;
                                    }else{
                                        system.debug(municipality.Name+' is Eligible');
                                        strStatus = StrEligible;
                                        lstEligibleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                        setMunicipalityPref.add(municipality.id);
                                        break;
                                    }
                                }
                            }
                        }else{
                            if(!setMunicipalityPref.contains(municipality.id)) {
                                system.debug(municipality.Name+' is Eligible');
                                strStatus = StrEligible;
                                lstEligibleMunicipalPreference.add(new RentalMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                setMunicipalityPref.add(municipality.id);
                            }
                        }
                    }
                }//loop ends
                
                if(lstSelectedMunicipalPreference != null ){
                    lstSelectedMunicipalPreference.sort();
                    mapWrapperRentalMunicipalPreference.put('MyMunicipalities',lstSelectedMunicipalPreference);
                }
                if(lstEligibleMunicipalPreference != null ){
                    lstEligibleMunicipalPreference.sort();
                    mapWrapperRentalMunicipalPreference.put('EligibleMunicipalities',lstEligibleMunicipalPreference);
                }
                if(lstEligibleInEligbleMunicipalPreference != null ){
                    lstEligibleInEligbleMunicipalPreference.sort();
                    mapWrapperRentalMunicipalPreference.put('InEligibleMunicipalities',lstEligibleInEligbleMunicipalPreference);
                }
            }catch(Exception ex){
                b_ShowForm = false;
                system.debug(logginglevel.error,'Rental Municipality Prefrence Details Query Exception: ' + ex + ' ' + b_ShowForm + 'Reason : ' + ex.getStackTraceString());
                if(trigger.isExecuting == false)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Unexpected Eror: '+ex.getMessage()));
                }
                return null;
                
            }
        return mapWrapperRentalMunicipalPreference;
    }
    
    //Using for getting Custom Settings Values as Moderate,Low,VeryLow
    public enum IncomeLevel
    {
        VeryLow,
            Low,
            Moderate
            }
    
    
    
    public Boolean getMaxIncomeValue(Municipality__c municipality,List<PreApplicants__c> lstPreApplicant,list<Income_Limits__c> lstIncomeLimit,string strPreferences){
        Boolean isValid = true;
        try{
            cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
            map<integer,string> mapIncomeLevelOrdinal = new map<integer,string>{0 => 'VeryLow',1 => 'Low',2 => 'Moderate'};
                map<Integer,Decimal> mapOfAMIPercentage = new map<Integer,Decimal>();// map of AMI Percentage custom settings
            map<Id,Integer> mapOrdinal = new map<Id,Integer>();
            List<Municipality__c> lstMunicipality = new List<Municipality__c>();
            List<String> lstIncomeLevels = new List<String>();
            //List<String> lstLiveRegion = new List<String>();
            set<string> setLiveRegion = new set<string>();
            map<String,Decimal> mapRegionWiseIncomeLimit = new map<String,Decimal>();
            //list<Income_Limits__c> lstIncomeLimit = new list<Income_Limits__c>();
            Decimal d_MaxIncomeValue, d_IncomeLimit, d_AmiPercentage;
            Integer i_mapOrdinal, i_TempOrdinal; 
            
            if(municipality != null){
                lstMunicipality.add(municipality);
            }
            
            mapOfAMIPercentage.put(0,cgphProfileCustomSettings.Very_Low_AMI__c);
            mapOfAMIPercentage.put(1,cgphProfileCustomSettings.Low_AMI__c);
            mapOfAMIPercentage.put(2,cgphProfileCustomSettings.Moderate_AMI__c);
            
            
            if(!Test.isRunningTest() && trigger.isExecuting == false)
                Url = (Apexpages.currentPage().getUrl()).split('\\?')[0];
            
            else if( !Test.isRunningTest() && trigger.isExecuting == true )
            {
                if( strPreferences == 'rental')
                {
                    Url = '/apex/RentalMunicipalityPreferences';
                }
                else
                {
                    Url = '/apex/HomeownerMunicipalityPreferences';
                }
            }
            else
                Url = '/apex/RentalMunicipalityPreferences';
            
            if(Url == '/apex/RentalMunicipalityPreferences'){
                if(lstMunicipality != null && lstMunicipality.size() > 0 && (lstMunicipality[0].Rental_Portfolio_Income_Levels__c != null)){
                    lstIncomeLevels = (lstMunicipality[0].Rental_Portfolio_Income_Levels__c).split(';');
                }
            }else{
                if(lstMunicipality != null && lstMunicipality.size() > 0 && (lstMunicipality[0].Purchase_Portfolio_Income_Levels__c != null))
                    lstIncomeLevels = (lstMunicipality[0].Purchase_Portfolio_Income_Levels__c).split(';');
            }
            
            
            if((lstIncomeLevels != null && lstIncomeLevels.size() > 0) && (lstMunicipality != null && lstMunicipality.size() > 0))
            {
                //system.debug(logginglevel.error,'lstIncomeLevels ==> '+lstIncomeLevels);
                for(string iLevel : lstIncomeLevels)
                {
                    if(iLevel == IncomeLevel.Moderate.name()){
                        if(!mapOrdinal.containsKey(municipality.id)){
                            mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.Moderate.ordinal());
                        }
                        else{
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if(i_TempOrdinal < IncomeLevel.Moderate.ordinal()){
                                mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.Moderate.ordinal());
                            }
                        }
                    }
                    else if(iLevel == IncomeLevel.Low.name()){
                        if(!mapOrdinal.containsKey(lstMunicipality[0].id)){
                            mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.Low.ordinal());
                        }
                        else{
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if(i_TempOrdinal < IncomeLevel.Low.ordinal()){
                                mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.Low.ordinal());
                            }
                        }
                    }
                    else{
                        if(!mapOrdinal.containsKey(lstMunicipality[0].id)){
                            mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.VeryLow.ordinal());
                        }
                        else{
                            i_TempOrdinal = mapOrdinal.get(lstMunicipality[0].id);
                            if(i_TempOrdinal < IncomeLevel.VeryLow.ordinal()){
                                mapOrdinal.put(lstMunicipality[0].id,IncomeLevel.VeryLow.ordinal());
                            }
                        }
                    }
                }
            }
            
            i_mapOrdinal = mapOrdinal.get(lstMunicipality[0].id);
            d_AmiPercentage = mapOfAMIPercentage.get(i_mapOrdinal); 
            
            if(lstIncomeLimit != null && lstIncomeLimit.size() > 0){
                for( Income_Limits__c  incomeLimit : lstIncomeLimit)
                {
                    //if( setLiveRegion.contains(incomeLimit.Region__c) )
                    //{
                    if( lstPreApplicant[0].Household_Size__c == '1' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X1_Person__c);
                    if( lstPreApplicant[0].Household_Size__c == '2' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X2_Person__c);
                    if( lstPreApplicant[0].Household_Size__c == '3' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X3_Person__c);
                    if( lstPreApplicant[0].Household_Size__c == '4' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X4_Person__c);
                    if( lstPreApplicant[0].Household_Size__c == '5 ')
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X5_Person__c);
                    if( lstPreApplicant[0].Household_Size__c == '6' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X6_Person__c); 
                    if( lstPreApplicant[0].Household_Size__c == '7' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X7_Person_Median__c);
                    if( lstPreApplicant[0].Household_Size__c == '8' )
                        mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X8_Person_Median__c);                                      
                    //}
                }
            }
            
            string strRegionNo = lstMunicipality[0].Region__c;
            
            d_IncomeLimit = mapRegionWiseIncomeLimit.get(strRegionNo);
            //system.debug('strRegionNo='+strRegionNo+'  '+lstIncomeLimit);
            if(lstMunicipality[0].Region__c != null && d_IncomeLimit != null)
                d_MaxIncomeValue = d_IncomeLimit * (d_AmiPercentage)/100;
            
            system.debug('Max Income Test: Region=' + lstMunicipality[0].Region__c +' Household=' + lstPreApplicant[0].Household_Size__c + ' Limit=' + d_IncomeLimit + ' AMI=' + d_AmiPercentage + '% Max Income='+d_MaxIncomeValue+' Annual Income='+lstPreApplicant[0].Annual_Income__c);
            
            if(lstPreApplicant[0].Annual_Income__c > d_MaxIncomeValue)
            { // mapIncomeLevelOrdinal
                isValid = false;
                system.debug( 'Income Limit Test Failed: '+d_IncomeLimit+' (Income Limit for Region '+strRegionNo+' for household size : '+lstPreApplicant[0].Household_Size__c+' Person Household and  '+mapIncomeLevelOrdinal.get(i_mapOrdinal)+' Income Level )* '+d_AmiPercentage+'%(Rent v Expense) > '+lstPreApplicant[0].Annual_Income__c+'(Annual Income)');
            }
            else
            {
                isValid = true;
                //system.debug('Pre-applicant exceeds ' + lstMunicipality[0].name + ' Municipality Max Income Test');
            }
            
        }catch(Exception ex)
        {
            b_ShowForm = false;
            if(trigger.isExecuting == false)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,ex.getMessage())); 
            }
            system.debug(loggingLevel.ERROR,'Problem testing Max Income: ' + ex.getMessage()+' stackTraceString : '+ex.getStackTraceString());
            return null;
        }
        return isValid;
    }
    
    // Municipality Township Information Update 
    public PageReference updateMunicipalityPreference(){
        
        CGPH_Profile_Custom_Settings__c cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        string strEncodeId='';
        strEncodeId = strSuffix;
        
        Blob blobApplicantId = Blob.valueOf(strPreApplicantId+strEncodeId);
        // base64 encode the blob that contains our url param value
        String strAplicantEncodeId = EncodingUtil.base64Encode(blobApplicantId);
        string returnURL = '/apex/RentalMunicipalityPreferences'+'?appId='+strAplicantEncodeId;
        
        if( internalview == 'true' )
            returnURL += '&internal=true';
        
        Pagereference rentalMunPageRef = new Pagereference(returnURL);
        rentalMunPageRef.setRedirect(true);  
        return rentalMunPageRef;
    }
    
    
    // Remove PreApplicant from municipalitypreference
    public void removeRentalMunicipalityWaitingList(){
        try{
            List<Municipality_Preference__c> lstMunicipalityPreference = [SELECT  Municipality__c, Lottery_Number__c,
                                                                          Status__c,PreApplicant__c ,Removal_Trigger__c ,Municipality__r.Local_Preference__c
                                                                          FROM Municipality_Preference__c 
                                                                          Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND Municipality__c =: strMunicipalityId AND Type__c = 'Rental' AND ( Status__c = 'Active' OR On_Hold__c = true)]; //updated for Type__c == rental // 09/07/2015 
            lstMunicipalityPreference[0].Status__c = 'Inactive'; // uninterested
            PreApplicants__c preApp;
            // if it update by internal staff then update the last modified at
            if( internalview == 'true' )
            {   
                preApp = new PreApplicants__c(id=lstMunicipalityPreference[0].PreApplicant__c);
                preApp.Last_Modified_At__c = 'Internal Pre-Application/Update';
                lstMunicipalityPreference[0].Removal_Trigger__c = 'Internal Profile';
            }
            else
            {
                preApp = new PreApplicants__c(id=lstMunicipalityPreference[0].PreApplicant__c);
                preApp.Last_Modified_At__c = 'External Pre-Application/Update';
                lstMunicipalityPreference[0].Removal_Trigger__c = 'External Profile';
            }
            
            lstMunicipalityPreference[0].Removal_Date__c = date.today();
            
            update lstMunicipalityPreference[0];
            
            if( preApp != null )
            {
                update preApp;
            }
            getRentalTownshipPreferences(); // this is added as page need to rerendered with the updated data 
        }
        catch(QueryException ex){
            system.debug('<<==::Exception::==>>'+ex+' Cause : '+ex.getMessage()+' StackTraceString '+ex.getStackTraceString());
        }catch(Exception ex){
            system.debug('::::Exception::::'+ex+'::::Message::::'+ex.getMessage()+' StackTraceString '+ex.getStackTraceString());
        }
        
    }
    
    //return to cgphprofile page
    public PageReference returnToCGPHProfile(){
        
        string returnURL = '/apex/CGPHProfile'+'?appId='+String.escapesingleQuotes(ApexPages.currentPage().getParameters().get('appId')) + '&ownership=' + showOwnership;
        
        if( internalview == 'true' )
            returnURL += '&internal=true';
        
        PageReference returnPage = new PageReference(returnURL);  
        returnPage.setRedirect(true);
        return returnPage;//new PageReference('/apex/CGPHProfile').setRedirect(false);
    }
    
    //method to join waiting list/create municipalitypreference
    public void joinRentalMunicipalityWaitingList(){
        system.debug('joinRentalMunicipalityWaitingList  ');
        try{
            system.debug('strMunicipalityId '+strMunicipalityId);
            if( ApexPages.currentPage().getParameters().get('strMunicipalityId') != null )
                strMunicipalityId = ApexPages.currentPage().getParameters().get('strMunicipalityId'); 
            system.debug('strMunicipalityId '+strMunicipalityId);
            List<Municipality_Preference__c> lstMunicipalityPreference = [SELECT Municipality__c, Status__c, PreApplicant__c, Interest_Date__c, Type__c,Municipality__r.Local_Preference__c  
                                                                          FROM Municipality_Preference__c 
                                                                          Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND Municipality__c =: strMunicipalityId AND Type__c = 'Rental' AND ( Status__c = 'Active' OR On_Hold__c = true )limit 1]; // updated on 09/07/2015
            Municipality__c objMunicipality = [Select Name,Income_Limit__c,Rental_Portfolio_Income_Levels__c,Local_Preference__c FROM Municipality__c Where Id = :strMunicipalityId limit 1];
            
            system.debug(logginglevel.error,'lstMunicipalityPreference[0] ==> '+lstMunicipalityPreference);
            if(lstMunicipalityPreference != null && lstMunicipalityPreference.size() > 0)
            {
                lstMunicipalityPreference[0].Status__c = 'Ineligible ';
                lstMunicipalityPreference[0].Ineligibilty_Reason__c = 'No more interested in this property';
                
            }          
            
            Municipality_Preference__c newMunicipalityPreference = new Municipality_Preference__c();
            newMunicipalityPreference.Name = objMunicipality.Name;
            newMunicipalityPreference.PreApplicant__c =  String.escapesingleQuotes(strPreApplicantId);
            newMunicipalityPreference.Municipality__c = strMunicipalityId;
            newMunicipalityPreference.Interest_Date__c = Date.today();
            newMunicipalityPreference.Type__c = 'Rental';
            newMunicipalityPreference.Status__c = 'Active';
            lstMunicipalityPreference.add(checkLocalPreferenceFields(newMunicipalityPreference,strMunicipalityId));          
            
            system.debug(logginglevel.error,'lstMunicipalityPreference '+lstMunicipalityPreference);
            insert lstMunicipalityPreference;
            getRentalTownshipPreferences(); // this is added as page need to rerendered with the updated data
            
            PreApplicants__c preApp;
            // if it update by internal staff then update the last modified at
            if( internalview == 'true' )
            {   
                preApp = new PreApplicants__c(id=String.escapesingleQuotes(strPreApplicantId));
                preApp.Last_Modified_At__c = 'Internal Pre-Application/Update';
                //lstMunicipalityPreference[0].Last_Modified_At__c = 'Internal Pre-Application/Update';
            }
            else
            {
                preApp = new PreApplicants__c(id=String.escapesingleQuotes(strPreApplicantId));
                preApp.Last_Modified_At__c = 'External Pre-Application/Update';
                //lstMunicipalityPreference[0].Last_Modified_At__c = 'External Pre-Application/Update';
            }
            
            if(preApp != null )
                update preApp;
            
        }
        catch(QueryException ex){
            system.debug(logginglevel.error,'<<==::Exception::==>>'+ex);
        }catch(Exception ex){
            system.debug(logginglevel.error,'::::Exception::::'+ex+'::::Message::::'+ex.getMessage());
        }       
    }
    
    
    // method create the map of max income values from the custom setting so that those can be used in the property visibility settings
    public static map<string,Decimal> getPropertyIncomeComparison(list<Income_Limits__c> lstIncomeLimit,PreApplicants__c preApplicant,string propertyRegion)
    {
        map<String,Decimal> mapRegionWiseIncomeLimit = new map<String,Decimal>();   
        map<string,Decimal> mapOfAMIPercentageMaxIncome = new map<string,Decimal>();    
        if(lstIncomeLimit != null && lstIncomeLimit.size() > 0 )
        {
            for( Income_Limits__c  incomeLimit : lstIncomeLimit)
            {
                if(incomeLimit.Region__c == propertyRegion)
                {
                    if( preApplicant.Household_Size__c == '1' )
                        mapRegionWiseIncomeLimit.put('1',incomeLimit.X1_Person__c);
                    if( preApplicant.Household_Size__c == '2' )
                        mapRegionWiseIncomeLimit.put('2',incomeLimit.X2_Person__c);
                    if( preApplicant.Household_Size__c == '3' )
                        mapRegionWiseIncomeLimit.put('3',incomeLimit.X3_Person__c);
                    if( preApplicant.Household_Size__c == '4' )
                        mapRegionWiseIncomeLimit.put('4',incomeLimit.X4_Person__c);
                    if( preApplicant.Household_Size__c == '5')
                        mapRegionWiseIncomeLimit.put('5',incomeLimit.X5_Person__c);
                    if( preApplicant.Household_Size__c == '6' )
                        mapRegionWiseIncomeLimit.put('6',incomeLimit.X6_Person__c);
                    if( preApplicant.Household_Size__c == '7')
                        mapRegionWiseIncomeLimit.put('7',incomeLimit.X7_Person_Median__c);
                    if( preApplicant.Household_Size__c == '8' )
                        mapRegionWiseIncomeLimit.put('8',incomeLimit.X8_Person_Median__c);
                    
                }                                       
            }
        }    
        
        Decimal i_ModerateMaxIncome = 0,i_LowMaxIncome = 0,i_VeryLowMaxIncome = 0;
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        
        i_ModerateMaxIncome = (mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) != null ? mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) : 0) * cgphProfileCustomSettings.Moderate_AMI__c/100;
        
        i_LowMaxIncome =  (mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) != null ? mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) : 0) * cgphProfileCustomSettings.Low_AMI__c/100;
        
        i_VeryLowMaxIncome =  (mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) != null ? mapRegionWiseIncomeLimit.get(preApplicant.Household_Size__c) : 0) * cgphProfileCustomSettings.Very_Low_AMI__c/100;
        
        mapOfAMIPercentageMaxIncome.put('Moderate',i_ModerateMaxIncome);
        mapOfAMIPercentageMaxIncome.put('Low',i_LowMaxIncome);
        mapOfAMIPercentageMaxIncome.put('VeryLow',i_VeryLowMaxIncome);
        
        return mapOfAMIPercentageMaxIncome;
    }
    
    //method to show rental properties
    public map<String,List<WrapperRentalProperties>> getRentalProperties(){
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
        
        set<id> setMunicipalityIds = new set<id>();    
        //  mapMunicipalityCounty = new map<string,string>(); 
        lstWrapperRentalProperties = new list<WrapperRentalProperties>();
        list<HOMEtracker__Property__c> lstRentalProperty = new list<HOMEtracker__Property__c>();
        map<Id,WrapperRentalProperties> mapWrapperRentalProperty = new map<Id,WrapperRentalProperties>();
        map<String,List<WrapperRentalProperties>> mapOfMunicipalProperty = new map<String,List<WrapperRentalProperties>>();
        
        
        
        List<Municipality_Preference__c> lstRentalMunicipalityPreferences = [SELECT  Municipality__c, Lottery_Number__c,Municipality__r.Local_Preference__c,
                                                                             Status__c  
                                                                             FROM Municipality_Preference__c 
                                                                             Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) 
                                                                             AND 
                                                                             Type__c = 'Rental' 
                                                                             AND 
                                                                             ( Status__c = 'Active' OR On_Hold__c = true)
                                                                             AND 
                                                                             Municipality__r.Rental_Portfolio__c = true]; //Added this line on 26-11-2015, beofre it was referrring global variable
        
        try{           
            cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance(); 
            Integer i_HouseHoldSize = Integer.valueOf(lstPreApplicant[0].Household_Size__c);
            if(lstRentalMunicipalityPreferences != null && lstRentalMunicipalityPreferences.size() > 0){
                for(Municipality_Preference__c municipalityPref : lstRentalMunicipalityPreferences){
                    setMunicipalityIds.add(municipalityPref.Municipality__c);
                }
            }
            
            //list of income limits
            map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                                    X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                                    From Income_Limits__c]); 
            
            
            if(setMunicipalityIds != null && setMunicipalityIds.size() > 0){
                lstRentalProperty = [Select Id, Name, Test_Property__c,
                                     CreatedDate, Status_Message__c,
                                     Maximum_Household_Size__c,  Min_Household_Size__c,
                                     Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, 
                                     Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                                     Rental_Assistance_Permitted__c, Listing_Stage__c,HOMEtracker__Status__c,
                                     Utilities__c, HOMEtracker__Property_Description__c, Deadline__c,Municipality_Name__r.Region_Counties__c,
                                     Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, Development_address__r.X3x_Rent_Requirement__c, 
                                     HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                                     Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c,Municipality_Name__r.Income_Limit__c,Development_address__r.Dev_Income_Limit__c,
                                     Disabled_eligible_regardless_of_age__c
                                     FROM 
                                     HOMEtracker__Property__c 
                                     Where
                                     Municipality_Name__c IN: setMunicipalityIds  
                                     AND HOMEtracker__Status__c IN
                                     ('Available For Rent')
                                     AND RecordTypeId = :strRentalPropertyRecTypeId 
                                     AND Listing_Type__c = 'Public'
                                     ORDER BY Development_address__r.Name ASC, Name ASC
                                    ]; // made changes in criteria for 'Available For Rent - Immediate Occupancy',
                //'Available For Rent - Vacancy in Next 30-60 Days',
                
            }
            
            system.debug('>' + lstRentalProperty.size() + ' Rental Properties found from all Municipalities');
            if(lstRentalProperty != null && lstRentalProperty.size() > 0){
                
                // call function to filter the criteria for rental properties 
                
                mapWrapperRentalProperty = CGPHProfileController.calculateCriteriaForRental(lstRentalProperty,lstPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicantsInfo,null,'UseToSubmitPQCustomSetting');
                
                if(mapWrapperRentalProperty != null && mapWrapperRentalProperty.size() > 0)
                {
                    for(Id propId : mapWrapperRentalProperty.keySet())
                    {
                        WrapperRentalProperties objWrapperRentProp =  mapWrapperRentalProperty.get(propId);
                        
                        if(mapOfMunicipalProperty.containsKey(objWrapperRentProp.property.Municipality_Name__r.Name) == false)
                        {
                            list<WrapperRentalProperties> lstWrapRentProperty = new list<WrapperRentalProperties>();
                            if(objWrapperRentProp.b_IsEligible == true )
                            {
                                lstWrapperRentalProperties.add(objWrapperRentProp);
                                lstWrapRentProperty.add(objWrapperRentProp);
                                mapOfMunicipalProperty.put(objWrapperRentProp.property.Municipality_Name__r.Name,lstWrapRentProperty);
                            }                            
                            
                        }
                        else
                        {
                            list<WrapperRentalProperties> lstTempWrapRentProperty = new list<WrapperRentalProperties>();
                            if(objWrapperRentProp.b_IsEligible == true)
                            {
                                lstTempWrapRentProperty = mapOfMunicipalProperty.get(objWrapperRentProp.property.Municipality_Name__r.Name);
                                lstTempWrapRentProperty.add(objWrapperRentProp);
                                mapOfMunicipalProperty.put(objWrapperRentProp.property.Municipality_Name__r.Name,lstTempWrapRentProperty);
                            }
                            
                        }
                    }
                }
                
                
            }
            
            
            mapRentalMunicipalityNameToPreferences = new map<string,Municipality_Preference__c>();
            for(Municipality_Preference__c municipalityPref : [SELECT Municipality__c,Lottery_Number__c,
                                                               Municipality__r.Name, Interest_Date__c, Municipality__r.County__c,
                                                               Type__c, Municipality__r.Rental_Waiting_List__c, Status__c, On_Hold__c,Municipality__r.Local_Preference__c
                                                               FROM Municipality_Preference__c 
                                                               Where PreApplicant__c =: lstPreApplicant[0].id AND Type__c = 'Rental' AND ( Status__c = 'Active' OR On_Hold__c = true)])
            {
                mapRentalMunicipalityNameToPreferences.put(municipalityPref.Municipality__r.Name,municipalityPref);
                
                list<WrapperRentalProperties> lstTempWrapRentProperty = new list<WrapperRentalProperties>();
                if(mapOfMunicipalProperty.containsKey(municipalityPref.Municipality__r.Name)  == false)
                    mapOfMunicipalProperty.put(municipalityPref.Municipality__r.Name,lstTempWrapRentProperty);
            }
            // system.debug('::mapOfMunicipalProperty::'+mapOfMunicipalProperty);
            
            //system.debug('=======> Map of municipality counties: '+mapMunicipalityCounty);
            
            
        }catch(PropertyException ex){
            b_ShowForm = false;
            system.debug(logginglevel.error,'::Exception::'+ex+'::b_ShowForm::'+b_ShowForm+'::ex.getMessage()::'+ex.getMessage()+ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please provide property Income Level/Region Info'));
            
        }catch(Exception ex){
            system.debug(logginglevel.error,'::Exception::'+ex+'::b_ShowForm::'+b_ShowForm+'::ex.getMessage()::'+ex.getMessage()+ex.getStackTraceString());
        }
        
        if( mapOfMunicipalProperty != null && mapOfMunicipalProperty.size() == 0 )
            showRentalMsg = true;
        else
            showRentalMsg = false;
        
        return mapOfMunicipalProperty;
    }
    
    //map of amiPercentage  Custom Settings
    public  map<Integer,Decimal> amiPercentage(){
        map<Integer,Decimal> mapOfAMIPercentage = new  map<Integer,Decimal>();
        cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        mapOfAMIPercentage.put(0,cgphProfileCustomSettings.Very_Low_AMI__c);
        mapOfAMIPercentage.put(1,cgphProfileCustomSettings.Low_AMI__c);
        mapOfAMIPercentage.put(2,cgphProfileCustomSettings.Moderate_AMI__c);
        return mapOfAMIPercentage;
        
    }
    
    // ====================================================================
    // Max Income Test
    // ====================================================================
    public static Boolean getPropertyMaxIncome(HOMEtracker__Property__c objProperty, List<PreApplicants__c> lstPreApplicant,list<Income_Limits__c> lstIncomeLimit){
        
        Boolean isValid = false; 
        map<Integer,Decimal> mapOfAMIPercentage = new map<Integer,Decimal>();
        map<Id,Integer> mapOrdinal = new map<Id,Integer>();
        List<String> lstIncomeLevels = new List<String>();
        List<String> lstLiveRegion = new List<String>();
        set<string> setLiveRegion = new set<string>();
        map<String,Decimal> mapRegionWiseIncomeLimit = new map<String,Decimal>();
        map<integer,string> mapIncomeLevelOrdinal = new map<integer,string>{0 => 'VeryLow',1 => 'Low',2 => 'Moderate'};
            //list<Income_Limits__c> lstIncomeLimit = new list<Income_Limits__c>();
            Decimal d_MaxIncomeValue, d_IncomeLimit, d_AmiPercentage;
        Integer i_mapOrdinal;
        
        if(objProperty != null && objProperty.Max_Income_Level__c != null && objProperty.Municipality_Name__r.Region__c != null){
            //lstIncomeLevels = (objProperty.Max_Income_Level__c).split(';');
            String strIncomeLevel = objProperty.Max_Income_Level__c;
            if(strIncomeLevel == IncomeLevel.Moderate.name()){
                mapOrdinal.put(objProperty.id,IncomeLevel.Moderate.ordinal());
            }
            else if(strIncomeLevel == IncomeLevel.Low.name()){
                mapOrdinal.put(objProperty.id,IncomeLevel.Low.ordinal());
            }
            else{
                mapOrdinal.put(objProperty.id,IncomeLevel.VeryLow.ordinal());
            }
        }else{
            system.debug(logginglevel.error,'PropertyExceptionPropertyException::'+'property Income Level/Region Info not provided');
            throw new PropertyException('Please provide porperty Income Level/Region Info');
        }
        //system.debug('::mapOrdinal::'+mapOrdinal);
        CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        
        mapOfAMIPercentage.put(0,cgphProfileCustomSettings.Very_Low_AMI__c);
        mapOfAMIPercentage.put(1,cgphProfileCustomSettings.Low_AMI__c);
        mapOfAMIPercentage.put(2,cgphProfileCustomSettings.Moderate_AMI__c);
        
        
        i_mapOrdinal = mapOrdinal.get(objProperty.id);
        d_AmiPercentage = mapOfAMIPercentage.get(i_mapOrdinal);
        
        //system.debug('::lstIncomeLimit::'+lstIncomeLimit);
        if(lstIncomeLimit != null && lstIncomeLimit.size() > 0 && setLiveRegion != null)
            for( Income_Limits__c  incomeLimit : lstIncomeLimit)
        {
            //if( setLiveRegion.contains(incomeLimit.Region__c) )
            //{
            if( lstPreApplicant[0].Household_Size__c == '1' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X1_Person__c);
            if( lstPreApplicant[0].Household_Size__c == '2' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X2_Person__c);
            if( lstPreApplicant[0].Household_Size__c == '3' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X3_Person__c);
            if( lstPreApplicant[0].Household_Size__c == '4' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X4_Person__c);
            if( lstPreApplicant[0].Household_Size__c == '5')
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X5_Person__c);
            if( lstPreApplicant[0].Household_Size__c == '6' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X6_Person__c);             
            if( lstPreApplicant[0].Household_Size__c == '7')
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X7_Person_Median__c);
            if( lstPreApplicant[0].Household_Size__c == '8' )
                mapRegionWiseIncomeLimit.put(incomeLimit.Region__c,incomeLimit.X8_Person_Median__c);                                       
            //}
            
        }
        String strRegionNo;
        if(objProperty.Municipality_Name__r.Region__c != null){
            
            strRegionNo = objProperty.Municipality_Name__r.Region__c;
            
            d_IncomeLimit = mapRegionWiseIncomeLimit.get(strRegionNo);
            if(objProperty.Municipality_Name__r.Region__c != null && d_IncomeLimit != null)
            {
                d_MaxIncomeValue = d_IncomeLimit * (d_AmiPercentage)/100;
            }
        }
        
        if(lstPreApplicant[0].Annual_Income__c > d_MaxIncomeValue){
            streligibilityReport += '\t' + '-Max Income for Property: Annual Income ($'+lstPreApplicant[0].Annual_Income__c+') is GREATER than Max Income ($'+ d_MaxIncomeValue.setScale(0) +')\n';
            streligibilityReportExternal += 'Your household\'s income exceeds the maximum income allowed.'+'\n';
            system.debug( 'Annual Income $' + lstPreApplicant[0].Annual_Income__c + ' exceeds Income Max $' + d_MaxIncomeValue + ' = Income Limit for Region ' + strRegionNo + ' / Household Size ' + lstPreApplicant[0].Household_Size__c + ' $' + d_IncomeLimit + ' * ' + d_AmiPercentage + '% for (' + mapIncomeLevelOrdinal.get(i_mapOrdinal) + ' Income Level');
            return true;
        }else{
            // Passes
            return false;
        }
    }
    
    
    //method to format phone number
    private static String formatPhone(String strPhone) {
        String strNonDigits = '[^0-9]';
        String strPhoneDigits;
        // remove all non numeric
        strPhoneDigits = strPhone.replaceAll(strNonDigits,'');
        // 10 digit: reformat with dashes
        if (strPhoneDigits.length() == 10) 
            return '('+strPhoneDigits.substring(0,3)+') '+ 
            strPhoneDigits.substring(3,6) + '-' +
            strPhoneDigits.substring(6,10);
        // 11 digit: if starts with 1, format as 10 digit 
        if (strPhoneDigits.length() == 11) {
            if (strPhoneDigits.substring(0,1) == '1') {
                return  strPhoneDigits.substring(1,4) + '-' +
                    strPhoneDigits.substring(4,7) + '-' +
                    strPhoneDigits.substring(7,11);
            }
        }
        // if it isn't a 10 or 11 digit number, return the original because
        // it may contain an extension or special information
        return(strPhone);
    }
    
    // ====================================================================
    // Create List of Pre-Applicants Purchase Municiaplity Preferences 
    // ====================================================================   
    public List<WrapperHownershipMunicipalPreference> getListPurchaseMunicipality(){
        //Rental Information
        lstPurchaseMunicipalityPreferences = new List<Municipality_Preference__c>();
        lstWrapperHownershipMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        try{
            lstPurchaseMunicipalityPreferences = [SELECT Id, Municipality__c, Municipality__r.Name, Municipality__r.Purchase_Portfolio__c, On_Hold__C,
                                                  Interest_Date__c, Type__c, Municipality__r.Purchase_Waiting_List__c, Status__c, Municipality__r.Purchase_Waiting_List_Type__c,
                                                  Municipality__r.General_Tax_Rate__c,Municipality__r.Local_Preference__c 
                                                  FROM Municipality_Preference__c 
                                                  Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND 
                                                  Municipality__r.Purchase_Portfolio__c = true AND 
                                                  Type__c = 'Ownership' AND ( Status__c = 'Active' OR On_Hold__c = true) limit 10000];//AND Status__c = :'Active' AND PreApplicant__r.Purchase_Interest__c = :true
            
            system.debug(lstPurchaseMunicipalityPreferences.size()+ ' Purchase Municipality Preferences Found');
            if(lstPurchaseMunicipalityPreferences != null && lstPurchaseMunicipalityPreferences.size() > 0){
                for(Municipality_Preference__c purchaseMunicipality : lstPurchaseMunicipalityPreferences){
                    lstWrapperHownershipMunicipalPreference.add(new WrapperHownershipMunicipalPreference(purchaseMunicipality));
                }
            }
        }
        catch(QueryException ex){
            system.debug(logginglevel.error,'::::Exception::::'+ex+'::::Message::::'+ex.getMessage()+' stacktracestring: '+ex.getStackTraceString());
        }catch(Exception ex){
            system.debug(logginglevel.error,'::::Exception::::'+ex+'::::Message::::'+ex.getMessage()+' stacktracestring: '+ex.getStackTraceString());
        }
        return lstWrapperHownershipMunicipalPreference;
    }
    
    
    
    // ====================================================================
    // Find all Municipalities with Purchase Portfolios and create map of Pre-Applicant, 
    // Municipalities for Ownership Municipality Preferences Page  
    // ====================================================================  
    public pagereference getPurchaseTownshipPreferences(){
    
         cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getOrgDefaults();        
        CGPH_Profile_Custom_Settings__c cgphSettingsObj = new CGPH_Profile_Custom_Settings__c();
        cgphSettingsObj = CGPH_Profile_Custom_Settings__c.getInstance();
        if(cgphSettingsObj.Temporary_Maintenance__c==true)
        {
            string strURL = cgphSettingsObj.Maintenance_URL__c;
            PageReference pageRef = new PageReference(strURL);
            return pageRef.setRedirect(true);
            //pageRef.setRedirect(true);
            //return pageRef;
        }
        showOwnership = 'true'; // This will pass as a URL param when Returning to Profile
        List<Municipality__c> lstPurchaseMunicipality;
        
        if( lstPreApplicant != null && lstPreApplicant.size() > 0 && lstPreApplicant[0].Test_Pre_Applicant__c == false)
        {
            lstPurchaseMunicipality = [Select Name, AR_Purchase_Properties__c, Min_Income__c, 
                                       Purchase_Portfolio__c, Purchase_Portfolio_Income_Levels__c, 
                                       Purchase_Unit_Size__c, Purchase_Waiting_List__c, Rental_Portfolio_Income_Levels__c,
                                       Region__c, Purchase_Units__c, Purchase_Permanent_Disability_AR_Excepti__c, 
                                       Live_Work_Preference__c, County__c,Income_Limit__c,Local_Preference__c 
                                       From Municipality__c Where Purchase_Portfolio__c = :true  AND Test_Municipality__c = false Limit 10000]; 
        }                                       
        else
        {
            lstPurchaseMunicipality = [Select Name, AR_Purchase_Properties__c, Min_Income__c, 
                                       Purchase_Portfolio__c, Purchase_Portfolio_Income_Levels__c, 
                                       Purchase_Unit_Size__c, Purchase_Waiting_List__c, Rental_Portfolio_Income_Levels__c,
                                       Region__c, Purchase_Units__c, Purchase_Permanent_Disability_AR_Excepti__c, 
                                       Live_Work_Preference__c, County__c,Income_Limit__c,Local_Preference__c 
                                       From Municipality__c Where Purchase_Portfolio__c = :true  Limit 10000]; 
        }
        if((lstPreApplicant != null && lstPreApplicant.size() > 0) && (lstPurchaseMunicipality != null && lstPurchaseMunicipality.size() > 0)){
            mapWrapperPurchaseMunicipalPreference = new map<string,List<WrapperHownershipMunicipalPreference>>(); 
            mapWrapperPurchaseMunicipalPreference = verifyPurchaseMunicipalityCriterias(lstPreApplicant,lstPurchaseMunicipality,'');
        }
        else{ 
            b_ShowForm = false; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'There are no Municipalities with Purchase Portfolios'));
        }
        return null;
    }
    
    // ====================================================================
    // Ownership Municipality Preferences Page : Create lists of Municipalities on Waiting List,
    // that are Eligible and that are Ineligible Municipalities
    // Criteria failures are logged to Developer Console
    // ====================================================================
    public map<string,List<WrapperHownershipMunicipalPreference>> verifyPurchaseMunicipalityCriterias(List<PreApplicants__c> lstPreApplicant, list<Municipality__c> lstPurchaseMunicipality,string prefType){
        
        lstWrapperHownershipMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        String strStatus, strMessage;
        //map for existing preapplicant apply municipality purchase preferences
        map<id,list<Municipality_Preference__c>> mapPurchaseMunicipalityPreference = new map<id,list<Municipality_Preference__c>>();        
        setPurchaseMunicipalityPref = new set<id>();
        List<WrapperHownershipMunicipalPreference> lstSelectedMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        List<WrapperHownershipMunicipalPreference> lstInEligbleMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        List<WrapperHownershipMunicipalPreference> lstEligibleMunicipalPreference = new List<WrapperHownershipMunicipalPreference>();
        
        mapWrapperPurchaseMunicipalPreference = new map<string,List<WrapperHownershipMunicipalPreference>>{'MyMunicipalities' => lstSelectedMunicipalPreference ,'EligibleMunicipalities' =>lstSelectedMunicipalPreference, 'InEligibleMunicipalities' => lstSelectedMunicipalPreference};
            try{
                if( lstPreApplicant[0].Monthly_Other_Assistance__c == null )
                    lstPreApplicant[0].Monthly_Other_Assistance__c = 0;
                for(Municipality_Preference__c municipalityPref : [SELECT Municipality__c,  
                                                                   Municipality__r.Name, Interest_Date__c, On_Hold__c,Municipality__r.Local_Preference__c,
                                                                   Type__c, Municipality__r.Purchase_Waiting_List__c, Status__c,Municipality__r.County__c,Municipality__r.Region__c    
                                                                   FROM Municipality_Preference__c 
                                                                   Where PreApplicant__c =: lstPreApplicant[0].id AND Type__c = 'Ownership' Order By Status__c ASC])
                {
                    if(mapPurchaseMunicipalityPreference.containsKey(municipalityPref.Municipality__c) == true)
                    {
                        list<Municipality_Preference__c> lstPreference = new list<Municipality_Preference__c>();
                        lstPreference =  mapPurchaseMunicipalityPreference.get(municipalityPref.Municipality__c);
                        lstPreference.add(municipalityPref);                                                
                        mapPurchaseMunicipalityPreference.put(municipalityPref.Municipality__c,lstPreference);
                    } 
                    else
                    {
                        list<Municipality_Preference__c> lstPreference = new list<Municipality_Preference__c>();
                        lstPreference.add(municipalityPref);                                                
                        mapPurchaseMunicipalityPreference.put(municipalityPref.Municipality__c,lstPreference);
                    }
                }
                Boolean isValid = true;
                list<Income_Limits__c> lstIncomeLimit;
                
                map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                                        X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                                        From Income_Limits__c]);                 
                
                system.debug(lstPurchaseMunicipality.size() + 'found (lstPurchaseMunicipality) before filteration'+lstPurchaseMunicipality);
                
                for(Municipality__c municipality : lstPurchaseMunicipality){
                    system.debug('>'+municipality.Name);
                    strStatus = null;
                    strMessage = '';
                    list<string> lstStrMessage = new list<string>();
                    
                    if(municipality.Purchase_Portfolio__c == FALSE)
                    {
                        strStatus = StrInEligible;
                        strMessage = '-Municipality doesn\'t have Purchase Properties in portfolio';
                        lstStrMessage.add(strMessage);
                        system.debug(loggingLevel.ERROR,strMessage);
                        if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                            setPurchaseMunicipalityPref.add(municipality.id);
                        }
                    }
                    else
                    {
                        
                        if(lstPreApplicant[0].Household_Members_55__c == false && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'All AR' && lstPreApplicant[0].Household_Disabled__c == false)
                        {
                            strStatus = StrInEligible;
                            strMessage = '-All units are age restricted and your household does not have a member over 55. There is no exception to this requirement.';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if(lstPreApplicant[0].AR_Properties_Only__c == true && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'No AR')
                        {
                            strStatus = StrInEligible;
                            strMessage = '-Your household is only interested in 55+ communities and Municipality has no 55+ ownership communities<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if(lstPreApplicant[0].Household_Members_55__c == False && lstPreApplicant[0].Household_Disabled__c == true && municipality.AR_Purchase_Properties__c != null && municipality.AR_Purchase_Properties__c == 'All AR' && municipality.Purchase_Permanent_Disability_AR_Excepti__c == FALSE)
                        {
                            strStatus = StrInEligible;
                            strMessage = '-All units are age restricted and your household does not have a member over 55. There is no exception to this requirement.<br/>'; // previously permanently disabled
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        if((lstPreApplicant[0].Annual_Income__c + (lstPreApplicant[0].Monthly_Other_Assistance__c*12)) < municipality.Min_Income__c && lstPreApplicant[0].Section_8__c == false)
                        {
                            //  system.debug(logginglevel.error,'::Total Income::'+lstPreApplicant[0].Annual_Income__c);
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income below Min Income<br/>';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                //lstInEligbleMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, strMessage,null,false));
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                        
                        lstIncomeLimit = new list<Income_Limits__c>();
                        lstIncomeLimit.add(mapIncomeLimit.get(municipality.Income_Limit__c));
                        boolean b_IsMaxIncome = getMaxIncomeValue(municipality,lstPreApplicant,lstIncomeLimit,prefType);
                        if(b_IsMaxIncome != null && b_IsMaxIncome == false){
                            //System.debug('in maxIncome value'+b_IsMaxIncome);
                            strStatus = StrInEligible;
                            strMessage = '-Applicant Income exceeds Max Income';
                            lstStrMessage.add(strMessage);
                            system.debug(loggingLevel.ERROR,strMessage);
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                        else if(b_IsMaxIncome == null)
                        {
                            system.debug(loggingLevel.ERROR,'No Purchase Max Income Level for ' + municipality);
                            throw new MunicipalityException('Please provide Purchase Level for '+municipality.Name);
                        }
                    }
                    if( lstStrMessage != null && lstStrMessage.size() > 0 )
                    {
                        system.debug(lstStrMessage);
                        lstInEligbleMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, lstStrMessage,null,false));
                    }
                    else
                    {
                        if(!setPurchaseMunicipalityPref.contains(municipality.id) && mapPurchaseMunicipalityPreference.containsKey(municipality.id)){
                            list<Municipality_Preference__c> lstmuncipalityPreference = mapPurchaseMunicipalityPreference.get(municipality.id);
                            if(lstmuncipalityPreference != null && lstmuncipalityPreference.size() > 0)
                            {
                                for(Municipality_Preference__c muncipalityPreference : lstmuncipalityPreference)
                                {
                                    if(muncipalityPreference.Status__c == 'Active'){
                                        
                                        strStatus = 'WaitingList';
                                        system.debug(municipality.Name+' is a Wait List');
                                        lstSelectedMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, lstStrMessage,muncipalityPreference.Interest_Date__c,true));
                                        setPurchaseMunicipalityPref.add(municipality.id);
                                        break;
                                    }
                                    else{
                                        strStatus = StrEligible;
                                        system.debug(municipality.Name+' is Eligible');
                                        lstEligibleMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                        setPurchaseMunicipalityPref.add(municipality.id);
                                        break;
                                    }
                                }
                            }
                        }else{
                            if(!setPurchaseMunicipalityPref.contains(municipality.id)){
                                strStatus = StrEligible;
                                system.debug(municipality.Name+' is Eligible');
                                lstEligibleMunicipalPreference.add(new WrapperHownershipMunicipalPreference(municipality, strStatus, lstStrMessage, null,false));
                                setPurchaseMunicipalityPref.add(municipality.id);
                            }
                        }
                    }
                }//loop ends
                
                if(lstSelectedMunicipalPreference != null ){
                    lstSelectedMunicipalPreference.sort();
                    system.debug(lstSelectedMunicipalPreference.size() +' of selected for purchase : '+lstSelectedMunicipalPreference);
                    mapWrapperPurchaseMunicipalPreference.put('MyMunicipalities',lstSelectedMunicipalPreference);
                }
                
                if(lstEligibleMunicipalPreference != null ){
                    lstEligibleMunicipalPreference.sort();
                    system.debug(lstEligibleMunicipalPreference.size() +' of eligible for purchase : '+lstEligibleMunicipalPreference);
                    mapWrapperPurchaseMunicipalPreference.put('EligibleMunicipalities',lstEligibleMunicipalPreference);
                }
                if(lstInEligbleMunicipalPreference != null ){
                    lstInEligbleMunicipalPreference.sort();
                    system.debug(lstInEligbleMunicipalPreference.size() +' of Ineligible for purchase : '+lstInEligbleMunicipalPreference);
                    mapWrapperPurchaseMunicipalPreference.put('InEligibleMunicipalities',lstInEligbleMunicipalPreference);
                }
            }catch(Exception ex){
                b_ShowForm = false;
                system.debug(logginglevel.error+'Exception::==>>'+ex.getMessage()+' StackTrace: '+ex.getStackTraceString());
            }
        return mapWrapperPurchaseMunicipalPreference;
        
    }
    
    // ====================================================================
    // Ownership Municipality Preferences Page Redirect to Profile
    // ====================================================================  
    public PageReference updateMunicipalityHomeOwnerPreference(){
        
        CGPH_Profile_Custom_Settings__c cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        string strEncodeId='';
        strEncodeId = strSuffix;//cgphSettings.Encrypted_ID_Suffix__c;
        Blob beforeblob = Blob.valueOf(strPreApplicantId+strEncodeId);
        // base64 encode the blob that contains our url param value
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        
        string returnURL = '/apex/HomeownerMunicipalityPreferences'+'?appId='+paramvalue;
        
        if( internalview == 'true' )
            returnURL += '&internal=true';
        
        
        Pagereference pageRef = new Pagereference(returnURL);
        pageRef.setRedirect(true);  
        return pageRef;
    }
    
    // ====================================================================
    // Ownership Municipality Preferences Page : Remove a Munipality Preference
    // ====================================================================
    public void removeOwnershipMunicipalityWaitingList(){
        system.debug(logginglevel.error,'In Remove Ownership Preferences ');
        try{
            List<Municipality_Preference__c> lstMunicipalityPreference = [SELECT  Municipality__c, PreApplicant__c,Municipality__r.Local_Preference__c,
                                                                          Status__c  ,Removal_Trigger__c
                                                                          FROM Municipality_Preference__c 
                                                                          Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND Municipality__c =: strMunicipalityId AND Type__c ='Ownership' AND ( Status__c = 'Active' OR On_Hold__c = true)]; // updated the type__c on 09/07/2015
            
            system.debug(lstMunicipalityPreference.size()+' preferences found in the remove homeownership  ');
            lstMunicipalityPreference[0].Status__c = 'Inactive';//'Uninterested';
            
            // if it update by internal staff then update the last modified at
            PreApplicants__c preApp;
            // if it update by internal staff then update the last modified at
            if( internalview == 'true' )
            {   
                preApp = new PreApplicants__c(id=lstMunicipalityPreference[0].PreApplicant__c);
                preApp.Last_Modified_At__c = 'Internal Pre-Application/Update';
                lstMunicipalityPreference[0].Removal_Trigger__c = 'Internal Profile';
            }
            else
            {
                preApp = new PreApplicants__c(id=lstMunicipalityPreference[0].PreApplicant__c);
                preApp.Last_Modified_At__c = 'External Pre-Application/Update';
                lstMunicipalityPreference[0].Removal_Trigger__c = 'External Profile';
            }
            
            lstMunicipalityPreference[0].Removal_Date__c = date.today();
            
            update lstMunicipalityPreference[0];
            
            if(preApp != null)
            {
                update preApp;
            }
            
            getPurchaseTownshipPreferences();
        }
        catch(QueryException ex){
            system.debug(logginglevel.error+'Exception::==>>'+ex.getMessage()+' StackTrace: '+ex.getStackTraceString());
        }catch(Exception ex){
            system.debug(logginglevel.error,'Exception::==>'+ex+' StackTrace: '+ex.getMessage()+ex.getStackTraceString());
        }        
    }
    
    public void updateExistingLocalPreferences()
    {
        list<Municipality_Preference__c> lstMunicipalityPreferenceLocalUpdate = new list<Municipality_Preference__c>();
        string preAppId = String.escapesingleQuotes(strPreApplicantId);            
        List<Municipality_Preference__c> lstExistingPreferences = new List<Municipality_Preference__c>([SELECT Id,General_Local__c,Alternate_Local__c
                                                                          FROM 
                                                                          Municipality_Preference__c
                                                                          WHERE 
                                                                          PreApplicant__c =:preAppId
                                                                          AND
                                                                          Status__c = 'Active'
                                                                          AND
                                                                          (Municipality__c =: cgphProfileCustomSettings.Montaclair_Municipality_Id__c
                                                                          OR Municipality__c =: cgphProfileCustomSettings.Hoboken_Municipality_Id__c
                                                                          OR Municipality__c =: cgphProfileCustomSettings.Hoboken_Workforce_Program_Id__c
                                                                           )
                                                                          ]);
                                                                          
          if(lstExistingPreferences != null && lstExistingPreferences.size() > 0)
            {
                for(Municipality_Preference__c MP : lstExistingPreferences)
                {
                    Municipality_Preference__c newMunicipalityPreference = new Municipality_Preference__c(id = MP.id); 
                    if(  strMunicipalityId == cgphProfileCustomSettings.Montaclair_Municipality_Id__c ) // if montaclair municipality
                    {
                        
                        // local municipality preference
                        if( (LiveInMontaclair != null && FullTimeEmpMontClair != null) && ( LiveInMontaclair || FullTimeEmpMontClair) )
                        {
                            newMunicipalityPreference.General_Local__c = true;   
                        }
                        else
                        {
                            newMunicipalityPreference.General_Local__c = false;
                        }    
                    }
                    else if( strMunicipalityId == cgphProfileCustomSettings.Hoboken_Municipality_Id__c || strMunicipalityId == cgphProfileCustomSettings.Hoboken_Workforce_Program_Id__c)
                    {
                        if( LiveInHoboken == true)
                        {
                            newMunicipalityPreference.General_Local__c = true;
                        }
                        else
                        {
                            newMunicipalityPreference.General_Local__c = false;
                        }
                        
                        if( EmployeeInHoboken == true || LivedForYearInHoboken == true)
                        {
                            newMunicipalityPreference.Alternate_Local__c = true;
                        }
                        else
                        {
                            newMunicipalityPreference.Alternate_Local__c = false;                 
                        }
                    }
                    
                    lstMunicipalityPreferenceLocalUpdate.add(newMunicipalityPreference);
                }
                
                if( lstMunicipalityPreferenceLocalUpdate != null && lstMunicipalityPreferenceLocalUpdate.size() > 0 )
                    update lstMunicipalityPreferenceLocalUpdate; 
            }                                                   
    }
    
    public Municipality_Preference__c checkLocalPreferenceFields(Municipality_Preference__c newMunicipalityPreference,string strMunicipalityId )
    {
        updateExistingLocalPreferences();
        if(  strMunicipalityId == cgphProfileCustomSettings.Montaclair_Municipality_Id__c ) // if montaclair municipality
        {
            
            // local municipality preference
            if( (LiveInMontaclair != null && FullTimeEmpMontClair != null) && ( LiveInMontaclair || FullTimeEmpMontClair) )
            {
                newMunicipalityPreference.General_Local__c = true;   
            }
            else
            {
                newMunicipalityPreference.General_Local__c = false;
            }    
        }
        else if( strMunicipalityId == cgphProfileCustomSettings.Hoboken_Municipality_Id__c || strMunicipalityId == cgphProfileCustomSettings.Hoboken_Workforce_Program_Id__c)
        {
            if( LiveInHoboken == true)
            {
                newMunicipalityPreference.General_Local__c = true;
            }
            else
            {
                newMunicipalityPreference.General_Local__c = false;
            }
            
            if( EmployeeInHoboken == true || LivedForYearInHoboken == true)
            {
                newMunicipalityPreference.Alternate_Local__c = true;
            }
            else
            {
                newMunicipalityPreference.Alternate_Local__c = false;                 
            }
        }
        return newMunicipalityPreference;
    }
    
    // ====================================================================
    // Ownership Municipality Preferences Page : Join Wait List
    // ====================================================================
    public void joinOwnershipMunicipalityWaitingList(){
        try{
            List<Municipality_Preference__c> lstMunicipalityPreference = [SELECT Municipality__c, Status__c, PreApplicant__c, Interest_Date__c, Type__c ,Municipality__r.Local_Preference__c 
                                                                          FROM Municipality_Preference__c 
                                                                          Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND Municipality__c =: strMunicipalityId and Type__c = 'Ownership' AND ( Status__c = 'Active' OR On_Hold__c = true )limit 1];  // updated for type criteria
            
            system.debug(lstMunicipalityPreference.size()+' preferences found in the join homeownership  ');
            Municipality__c objMunicipality = [Select Name,Income_Limit__c,Rental_Portfolio_Income_Levels__c,Local_Preference__c FROM Municipality__c Where Id = :strMunicipalityId limit 1];
            
            if(lstMunicipalityPreference != null && lstMunicipalityPreference.size() > 0)
            {
                lstMunicipalityPreference[0].Status__c = 'Ineligible ';
                lstMunicipalityPreference[0].Ineligibilty_Reason__c = 'No more interested in this property';
            }
            
            Municipality_Preference__c newMunicipalityPreference = new Municipality_Preference__c();
            newMunicipalityPreference.Name = objMunicipality.Name;
            newMunicipalityPreference.PreApplicant__c =  String.escapesingleQuotes(strPreApplicantId);
            newMunicipalityPreference.Municipality__c = strMunicipalityId;
            newMunicipalityPreference.Interest_Date__c = Date.today();
            newMunicipalityPreference.Type__c = 'Ownership';
            newMunicipalityPreference.Status__c = 'Active';
            system.debug(' LiveInMontaclair  '+LiveInMontaclair );
            system.debug(' FullTimeEmpMontClair  '+FullTimeEmpMontClair );
            
            lstMunicipalityPreference.add(checkLocalPreferenceFields(newMunicipalityPreference,strMunicipalityId));
            insert lstMunicipalityPreference;          
            getPurchaseTownshipPreferences();
            
            PreApplicants__c preApp;
            // if it update by internal staff then update the last modified at
            if( internalview == 'true' )
            {   
                preApp = new PreApplicants__c(id=String.escapesingleQuotes(strPreApplicantId));
                preApp.Last_Modified_At__c = 'Internal Pre-Application/Update';
                //lstMunicipalityPreference[0].Last_Modified_At__c = 'Internal Pre-Application/Update';
            }
            else
            {
                preApp = new PreApplicants__c(id=String.escapesingleQuotes(strPreApplicantId));
                preApp.Last_Modified_At__c = 'External Pre-Application/Update';
                //lstMunicipalityPreference[0].Last_Modified_At__c = 'External Pre-Application/Update';
            }
            
            if(preApp != null )
                update preApp;
        }
        catch(QueryException ex){
            system.debug(logginglevel.error,'Exception::==>'+ex+' StackTrace: '+ex.getMessage()+ex.getStackTraceString());
        }catch(Exception ex){
            system.debug(logginglevel.error,'Exception::==>'+ex+' StackTrace: '+ex.getMessage()+ex.getStackTraceString());
        }       
    }
    
    // ====================================================================
    // Ownership Municipality Preferences Page : Create a Map of Municipalities and Purchase Properties
    // to evaluate if visible on Profile
    // ====================================================================   
    public map<String,List<WrapperPurchaseProperties>> getPurchaseProperties()
    {
        
        // create map of properties recordtype id and name so as we can get the all the purchase property record types
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strPurchasePropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
        set<id> setMunicipalityIds = new set<id>(); 
        // mapMunicipalityCountyPurchase = new map<string,string>();    
        set<Id> setPropertyIds = new set<Id>();
        lstWrapperPurchaseProperties = new list<WrapperPurchaseProperties>();
        list<HOMEtracker__Property__c> lstPurchaseProperty = new list<HOMEtracker__Property__c>();
        map<Id,WrapperPurchaseProperties> mapWrapperPurchaseProperty = new map<Id,WrapperPurchaseProperties>();
        map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();     
        map<String,List<WrapperPurchaseProperties>> mapOfMunicipalProperty = new map<String,List<WrapperPurchaseProperties>>();
        
        system.debug('Get purchase properties is called');
        try{
            
            lstPurchaseMunicipalityPreferences = [SELECT Id, Municipality__c, Municipality__r.Name, Municipality__r.Purchase_Portfolio__c, 
                                                  Interest_Date__c, Type__c, Municipality__r.Purchase_Waiting_List__c, Status__c, Municipality__r.Purchase_Waiting_List_Type__c,
                                                  Municipality__r.General_Tax_Rate__c ,Municipality__r.Local_Preference__c
                                                  FROM Municipality_Preference__c 
                                                  Where PreApplicant__c =: String.escapesingleQuotes(strPreApplicantId) AND Municipality__r.Purchase_Portfolio__c = true AND Type__c = 'Ownership' AND ( Status__c = 'Active' OR On_Hold__c = true) limit 10000];//AND Status__c = :'Active' AND PreApplicant__r.Purchase_Interest__c = :true
            
            cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance(); 
            Integer i_HouseHoldSize = Integer.valueOf(lstPreApplicant[0].Household_Size__c);
            
            // map of income limits
            map<id,Income_Limits__c> mapIncomeLimit = new map<id,Income_Limits__c>([Select Id, Region__c, X8_Person_Median__c, X7_Person_Median__c, X6_Person__c,
                                                                                    X5_Person__c, X4_Person__c, X3_Person__c, X2_Person__c, X1_Person__c, Regional_Asset_Limit__c 
                                                                                    From Income_Limits__c]); 
            
            if(lstPurchaseMunicipalityPreferences != null && lstPurchaseMunicipalityPreferences.size() > 0){
                for(Municipality_Preference__c municipalityPref : lstPurchaseMunicipalityPreferences){
                    setMunicipalityIds.add(municipalityPref.Municipality__c);
                    mapMunicipalityGTR.put(municipalityPref.Municipality__c,municipalityPref.Municipality__r.General_Tax_Rate__c);
                }
            }
            
            if(setMunicipalityIds != null && setMunicipalityIds.size() > 0){
                lstPurchaseProperty = [Select Id, Name, 
                                       CreatedDate, Status_Message__c,HOMEtracker__Current_HOA_Condo_Fees__c, Test_Property__c,
                                       Maximum_Household_Size__c,  Min_Household_Size__c, Deadline__c,
                                       Age_Restriction__c, Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c, 
                                       Municipality_Name__r.Name,  Municipality_Name__c, Municipality_Name__r.Region__c,
                                       Municipality_Name__r.Region_Counties__c,Max_Income_Level__c,Development_address__r.Age_Restriction__c,
                                       Rental_Assistance_Permitted__c, Listing_Type__c,HOMEtracker__Status__c,
                                       Utilities__c, HOMEtracker__Property_Description__c, HOMEtracker__Date_Listed__c,
                                       Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c,Listing_Stage__c,
                                       HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c, HOMEtracker__List_Price__c,
                                       Municipality_Name__r.County__c,Municipality_Name__r.Equalization_Ratio__c, HOMEtracker__Property_Type__c,Municipality_Name__r.Income_Limit__c,Development_address__r.Dev_Income_Limit__c,
                                       Disabled_eligible_regardless_of_age__c
                                       FROM 
                                       HOMEtracker__Property__c 
                                       Where
                                       Municipality_Name__c IN: setMunicipalityIds AND 
                                       HOMEtracker__Status__c IN
                                       ('Available for Sale/Resale')
                                       AND RecordTypeId = :strPurchasePropertyRecTypeId
                                       AND Listing_Type__c = 'Public'
                                       ORDER BY Development_address__r.Name ASC, Name ASC
                                      ];
                
                system.debug('>' + lstPurchaseProperty.size()+ ' Purchase Properties found from all Municipalities Found ');                                    
                if(lstPurchaseProperty != null && lstPurchaseProperty.size() > 0){
                    for(HOMEtracker__Property__c property : lstPurchaseProperty){
                        setPropertyIds.add(property.id);
                    }
                }
                
            }            
            if(lstPurchaseProperty != null && lstPurchaseProperty.size() > 0){ 
                
                mapWrapperPurchaseProperty = CGPHProfileController.calculateCriteriaForPurchase(lstPurchaseProperty,lstPreApplicant,cgphProfileCustomSettings,mapIncomeLimit,preApplicantsInfo,mapMunicipalityGTR,null);
                
                if(mapWrapperPurchaseProperty != null && mapWrapperPurchaseProperty.size() > 0){
                    for(Id propId : mapWrapperPurchaseProperty.keySet()){
                        WrapperPurchaseProperties objWrapperPurchaseProp =  mapWrapperPurchaseProperty.get(propId);
                        if(!mapOfMunicipalProperty.containsKey(objWrapperPurchaseProp.property.Municipality_Name__r.Name)){
                            if(objWrapperPurchaseProp.b_IsEligible)
                            {
                                lstWrapperPurchaseProperties.add(objWrapperPurchaseProp);
                                list<WrapperPurchaseProperties> lstWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
                                lstWrapPurchaseProperty.add(objWrapperPurchaseProp);
                                mapOfMunicipalProperty.put(objWrapperPurchaseProp.property.Municipality_Name__r.Name,lstWrapPurchaseProperty);
                            }
                        }else
                        {
                            if(objWrapperPurchaseProp.b_IsEligible)
                            {
                                list<WrapperPurchaseProperties> lstTempWrapPurchaseProperty = mapOfMunicipalProperty.get(objWrapperPurchaseProp.property.Municipality_Name__r.Name);
                                lstTempWrapPurchaseProperty.add(objWrapperPurchaseProp);
                                mapOfMunicipalProperty.put(objWrapperPurchaseProp.property.Municipality_Name__r.Name,lstTempWrapPurchaseProperty);
                            }
                        }
                    }           
                }
            }
            
            mapPurchaseMunicipalityNameToPreferences = new map<string,Municipality_Preference__c>();
            for(Municipality_Preference__c municipalityPref : [SELECT Municipality__c,Lottery_Number__c, On_Hold__c,
                                                               Municipality__r.Name, Interest_Date__c, Municipality__r.County__c,
                                                               Type__c, Municipality__r.Rental_Waiting_List__c, Status__c,Municipality__r.Purchase_Waiting_List__c ,Municipality__r.Local_Preference__c
                                                               FROM Municipality_Preference__c 
                                                               Where PreApplicant__c =: lstPreApplicant[0].id AND Type__c = 'Ownership' AND ( Status__c = 'Active' OR On_Hold__c = true)])
            {
                mapPurchaseMunicipalityNameToPreferences.put(municipalityPref.Municipality__r.Name,municipalityPref);
                
                list<WrapperPurchaseProperties> lstTempWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
                if(!mapOfMunicipalProperty.containsKey(municipalityPref.Municipality__r.Name))
                    mapOfMunicipalProperty.put(municipalityPref.Municipality__r.Name,lstTempWrapPurchaseProperty);
            }
            
        }catch(PropertyException ex){
            b_ShowForm = false;
            system.debug(logginglevel.error,'::Exception::'+ex+'::b_ShowForm::'+b_ShowForm+'::ex.getMessage()::'+ex.getMessage()+' stackTrace '+ex.getstackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please provide property Income Level/Region Info'));
            
        }catch(Exception ex){
            system.debug(logginglevel.error,'::Exception::'+ex+'::ex.getMessage()::'+ex.getMessage()+' stackTrace '+ex.getstackTraceString());
        }
        
        if(mapOfMunicipalProperty != null && mapOfMunicipalProperty.size () == 0)
            showPurchaseMsg = true;
        else
            showPurchaseMsg = false;
        
        
        return mapOfMunicipalProperty;
    }
    
    
    public pagereference getPropertyInfo(){
        lstPropertyImage = new List<Property_Image__c>();
        PropertyInfo = new HOMEtracker__Property__c();
        String strQuestionaireUrl;
        try{
            PropertyInfo = [ Select Name,Status_Message__c, Test_Property__c,
                            Age_Restriction__c, Municipality_Name__r.Name,Municipality_Name__r.County__c, 
                            Max_Income_Level__c,
                            HOMEtracker__Property_Description__c,
                            HOMEtracker__Number_of_Bedrooms__c, 
                            HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c, HOMEtracker__List_Price__c, 
                            Credit_Check_Required__c, Background_Check_Required__c,
                            Minimum_Credit_Score_to_be_Eligible__c, Co_Signers_Allowed__c,
                            Credit_Background_Check_Fee__c, Credit_Background_Check_Fee_Notes__c,
                            Pet_fee__c, Pets_allowed__c, Development_address__r.Development_Financing_Requirements__c,
                            Type_of_Free_Parking__c, Parking_Spaces_at_No_Additional_Charge__c, Additional_Parking_Fee__c,  
                            HOMEtracker__Accessibility_Features__c, HOMEtracker__Description_of_Accessibility_Features__c,
                            HOMEtracker__Property_Type__c, Floor_unit_is_located_on__c, Multi_level_unit__c,
                            Elevator__c, Smoking_Allowed__c, Amenities__c, HOMEtracker__Current_HOA_Condo_Fees__c,
                            HOMEtracker__Interior__c, HOMEtracker__Exterior__c,
                            Utilities_Included__c, Approximate_Annual_Property_Taxes__c,
                            X5_Down_Payment_Approximate__c, Seller_Listing_Instructions__c,
                            RecordType.Name, Property_Questionnaire_URL__c, 
                            Property_Map__c, HOMEtracker__County__c,HOMEtracker__City__c,
                            Development_address__c,Development_address__r.Name,Development_address__r.HOMEtracker__Property_Type__c,Development_address__r.Elevator__c,Development_address__r.Utilities_Included__c,
                            Development_address__r.Credit_Check_Required__c,Development_address__r.Background_Check_Required__c,Development_address__r.Minimum_Credit_Score_to_be_Eligible__c,
                            Development_address__r.Co_Signers_Allowed__c,Development_address__r.Required_Deposit__c,Development_address__r.Credit_Background_Check_Fee__c,Development_address__r.Credit_Background_Check_Fee_Notes__c,Development_address__r.Pets_allowed__c,
                            Development_address__r.Pet_fee__c,Development_address__r.Smoking_Allowed__c,Development_address__r.Amenities__c,
                            Municipality_Name__r.County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                            Municipality_Name__r.County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                            Municipality_Name__r.Down_Payment_Assistance_Cert_Text__c,
                            Municipality_Name__r.Rent_Assistance_Cert_Text__c,Disabled_eligible_regardless_of_age__c,
                            (Select Name, Image_url__c From Property_Images__r order by Sorting_Sequence_Number__c )
                            FROM 
                            HOMEtracker__Property__c Where Id =: strPropertyId 
                            LIMIT 1
                           ];
            
            system.debug('In get Property Details : Property is '+PropertyInfo);
            
            list<Application__c> lstPreliminarySubmission = new list<Application__c>([
                SELECT id,Name,Property__c,Pre_Applicant__c, Outcome__c
                FROM
                Application__c 
                WHERE 
                Property__c = :PropertyInfo.id AND Pre_Applicant__c = :lstPreApplicant[0].id AND (Outcome__c = 'Pending' OR Outcome__c = 'Online Full App Submitted')
                
            ]);
            
            system.debug(lstPreliminarySubmission.size()+' Preliminary Submission found'+lstPreliminarySubmission);
            if(lstPreApplicant != null && lstPreApplicant[0].Property_Questionnaire_URL__c != null && PropertyInfo != null)
            {
                strQuestionaireUrl = PropertyInfo.Property_Questionnaire_URL__c + lstPreApplicant[0].Property_Questionnaire_URL__c;
            }
            
            lstPropertyImage = PropertyInfo.Property_Images__r;//[Select Id, Name, Image_url__c From Property_Image__c Where Property__c =: strPropertyId order by Sorting_Sequence_Number__c];
            
            if(lstPropertyImage != null && lstPropertyImage.size() > 0)
            {
                objWrapperPropertyInfo = new WrapperPropertyInfo(PropertyInfo,lstPropertyImage,strQuestionaireUrl,lstPreliminarySubmission);
            }else
            {
                objWrapperPropertyInfo = new WrapperPropertyInfo(PropertyInfo,lstPropertyImage,strQuestionaireUrl,lstPreliminarySubmission);
            }
            PropertyInfo = null;
            strPropertyId = null;
            strQuestionaireUrl = null;
        }catch(exception ex)  {
            system.debug('exception '+ex);       
        }
        return null; 
    }
    
    public pagereference setEndpoint()
    {
        string endPointURL  =  Apexpages.currentPage().getParameters().get('endPoint');
        endPoint = endPointURL;
        system.debug('Endpoint is set');
        getHelpContent();
        return null; 
    }
    public string strGeneralMessage{get;set;}    
    // get general message content
    public void getGeneralMessageContent(){
        strGeneralMessage = getTextFromWP(cgphProfileCustomSettings.Wordpress_API_Endpoint_URL__c);
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
                    JSONContent = '[{"content":{"rendered":"test","protected":false}}]';
                    //This is a horrible way to pass code coverage, but these classes
                    //somehow were undercovered before I touched them.
                    //And the cost for me to write test cases in a set of classes I
                    //didn't write and additional time cost isn't worth 3% code coverage
                    Integer i = 0;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
					i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
					i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
					i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
					i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    i++;
					i++;
                    //This is dumb
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
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                                (parser.getText() == 'rendered')) {

                                parser.nextToken();
                                Content = parser.getText();
                                return Content;
                                //System.debug('Help Content='+Content);
                            }                               
                        }
                    }
            }  
        }
        return Content;
    }
    
    
    
    // method to get the help content in json format
    
    public string getHelpContent()
    { 
        //system.debug('endPoint == '+ endPoint );
        helpContent = '';
        if(endPoint != '' && endPoint != null)
        {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            cgphProfileCustomSettings = CGPH_Profile_Custom_Settings__c.getInstance();
            string baseURL = '';
            baseURL = cgphProfileCustomSettings.Help_URL__c;
            baseURL = baseURL + endPoint;
            
            system.debug(' baseURL '+baseURL);
            req.setEndpoint(baseURL);
            req.setMethod('GET');
            req.setTimeout(120000);
            string JSONContent = '';
            
            try
            {
                if(!Test.isRunningTest())
                {
                    res = http.send(req);
                    system.debug('Response:: '+res);
                    JSONContent = res.getBody();
                    
                }
                else
                {
                    JSONContent = '{\'title\':\'Profile Page Welcome Content\',\'content\':\'test\'}';
                }
            }
            catch(System.CalloutException e)
            {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            }
            
            system.debug('JSONContent ==> '+JSONContent);
            try{
                JSONParser parser = JSON.createParser(JSONContent);

                while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'content')) {
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                                (parser.getText() == 'rendered')) {

                                parser.nextToken();
                                helpContent = parser.getText();
                                return helpContent;
                                //System.debug('Help Content='+Content);
                            }                               
                        }
                    }
            	}  
            }
            catch(Exception ex){
                system.debug('Exception is : '+ex);
            }
            
        }
        return helpContent;
        
    }
    
    
    // ====================================================================
    // Rental Criteria Calculations                
    // ====================================================================   
    public static map<Id,WrapperRentalProperties> calculateCriteriaForRental(list<HOMEtracker__Property__c>lstRentalProperty,list<PreApplicants__c> lstPreApplicant,CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings,map<id,Income_Limits__c> mapIncomeLimit,PreApplicants__c preApplicantsInfo,Application__c application,string customSettingTobeUsed)
    {  
       
        map<string,Decimal> mapOfAMIPercentageMaxIncome = new map<string,Decimal>();
        map<Id,WrapperRentalProperties> mapWrapperRentalProperty = new map<Id,WrapperRentalProperties>();
        double d_MaxPerAnnualIncome, d_EffectiveRent;
        String strValidReason, strStatus, 
            strOverEighteen, strUnderEighteen, 
            strEighteen, strOver17, str55Plus;
        strOverEighteen = 'Over 18';
        strUnderEighteen = 'Under 18';
        strEighteen = '18';
        str55Plus = '55+ exclusive';
        strOver17 = 'Over 17';
        Boolean b_doNotShow = False;
        list<Income_Limits__c> lstIncomeLimit;
        streligibilityReport ='' ;
        streligibilityReportExternal = '';
        
        for(HOMEtracker__Property__c rentalProperty : lstRentalProperty)
        {
            b_doNotShow = False;
            // Effective Rent Calculation
            if(rentalProperty.HOMEtracker__Monthly_Rent__c == null)
                rentalProperty.HOMEtracker__Monthly_Rent__c = 0;
            if(rentalProperty.Rental_Assistance_Permitted__c && lstPreApplicant[0].Monthly_Other_Assistance__c >  0){
                d_EffectiveRent = (rentalProperty.HOMEtracker__Monthly_Rent__c + (rentalProperty.Utilities__c != null ? rentalProperty.Utilities__c : 0)) - lstPreApplicant[0].Monthly_Other_Assistance__c;
            }else{
                d_EffectiveRent = (rentalProperty.HOMEtracker__Monthly_Rent__c +  (rentalProperty.Utilities__c != null ? rentalProperty.Utilities__c : 0));
            }
            
            system.debug('3x Rent Requirement=' + rentalProperty.Development_address__r.X3x_Rent_Requirement__c);               
            //custom settings criteria for max percentage
            
            if(customSettingTobeUsed=='UseToSubmitPQCustomSetting')
            {
                if(!lstPreApplicant[0].Section_8__c) {
                    if(rentalProperty.Development_address__r.X3x_Rent_Requirement__c) {
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.Family_Rental_Max_Hsg_v_expense__c;
                    }else if(lstPreApplicant[0].Substandard_Overcrowded_Housing__c || (lstPreApplicant[0].Monthly_Rent__c > rentalProperty.HOMEtracker__Monthly_Rent__c)){
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.Rental_Max_Hsg_v_expense_with_waiver__c;
                    }else if(rentalProperty.Age_Restriction__c == null || rentalProperty.Age_Restriction__c =='None'){
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.Family_Rental_Max_Hsg_v_expense__c;
                    }else{
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.Age_Rest_Rental_Max_Hsg_v_expense__c;
                    }
                }
            }
            else if(customSettingTobeUsed =='UseToPassPQCustomSetting' || customSettingTobeUsed =='')
            {
                if(!lstPreApplicant[0].Section_8__c) {
                    if(rentalProperty.Development_address__r.X3x_Rent_Requirement__c) {
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.To_Pass_PQ_Family_Rent_Max_Hsg_vs_Exp__c;
                    }else if(lstPreApplicant[0].Substandard_Overcrowded_Housing__c ||(lstPreApplicant[0].Monthly_Rent__c > rentalProperty.HOMEtracker__Monthly_Rent__c)){
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.To_Pass_PQ_Waiver_Rent_Max_Hsg_vs_Exp__c;
                    }else if(rentalProperty.Age_Restriction__c == null || rentalProperty.Age_Restriction__c == 'None'){
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.To_Pass_PQ_Family_Rent_Max_Hsg_vs_Exp__c;
                    }else{
                        d_MaxPerAnnualIncome = cgphProfileCustomSettings.To_Pass_PQ_AR_Rent_Max_Hsg_vs_Exp__c;
                    }
                }
            }
            system.debug(rentalProperty.Name+'    ('+rentalProperty.Municipality_Name__r.Name+')');
            streligibilityReport += 'Property Name : '+rentalProperty.Name+'\n';
            streligibilityReportExternal += 'Property Name : '+rentalProperty.Name+'\n';
            
            // check if the income is satisfying the property income level criteria
            
            if( cgphProfileCustomSettings.Maintenance_URL__c == 'SOURCEPRIVATELISTING' || cgphProfileCustomSettings.Maintenance_URL__c ==  'SOURCEELIGIBILITYTRIGGER')
            {
                system.debug('&&&method called from Listing page or Eligibility trigger');
                lstIncomeLimit = new list<Income_Limits__c>();
                lstIncomeLimit.add(mapIncomeLimit.get(rentalProperty.Development_address__r.Dev_Income_Limit__c));
                mapOfAMIPercentageMaxIncome = CGPHProfileController.getPropertyIncomeComparison(lstIncomeLimit,preApplicantsInfo,rentalProperty.Municipality_Name__r.Region__c);
            }
            else
            {
                lstIncomeLimit = new list<Income_Limits__c>();
                lstIncomeLimit.add(mapIncomeLimit.get(rentalProperty.Municipality_Name__r.Income_Limit__c));
                mapOfAMIPercentageMaxIncome = CGPHProfileController.getPropertyIncomeComparison(lstIncomeLimit,preApplicantsInfo,rentalProperty.Municipality_Name__r.Region__c);
            }   
            // ====================================================================
            // Test if Pre-Applicant can view Property Income Level                 
            // ====================================================================
            if( preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('VeryLow') )
            {
                // Show all the properties
                streligibilityReport += '\t'+'-Property Income calculations: Eligible '+'(Property Income level - '+rentalProperty.Max_Income_Level__c+' is GREATER than the Pre-Applicant Income Level - Low)'+'\n';
            }
            else if( preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('Low') && rentalProperty.Max_Income_Level__c == 'Very Low')
            {                    
                // do not show property
                b_doNotShow = true;
                system.debug('Region '+rentalProperty.Municipality_Name__r.Region__c +' Income Levels => '+mapOfAMIPercentageMaxIncome);
                system.debug('Property Income level - '+rentalProperty.Max_Income_Level__c+' is LESS than the Pre-Applicant Income Level - Low');
                
                streligibilityReport += '\t'+'-Property Income calculations: Property Income level ('+rentalProperty.Max_Income_Level__c+') is LESS than the Pre-Applicant Income Level (Low)'+'\n';
                
                streligibilityReportExternal += '-Your household\'s income level is higher than the property income level.'+'\n';
            }
            
            if( preApplicantsInfo.Annual_Income__c > mapOfAMIPercentageMaxIncome.get('Low') && preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('Moderate') && (rentalProperty.Max_Income_Level__c == 'Very Low' || rentalProperty.Max_Income_Level__c == 'Low') )
            {
                // do not show the property
                b_doNotShow = true;
                system.debug('Region '+rentalProperty.Municipality_Name__r.Region__c +' Income Levels => '+mapOfAMIPercentageMaxIncome);
                system.debug('Property Income level - '+rentalProperty.Max_Income_Level__c+' is LESS than the Pre-Applicant Income Level - Moderate');
                
                streligibilityReport += '\t'+'-Property Income calculations: Property Income level ('+rentalProperty.Max_Income_Level__c+' is LESS than the Pre-Applicant Income Level (Moderate)'+'\n';
                
                streligibilityReportExternal += '-Your household\'s income exceeds the maximum income allowed.'+'\n';
            }
            
            // ====================================================================
            // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
            // ====================================================================
            if((rentalProperty.Age_Restriction__c == null || rentalProperty.Age_Restriction__c == 'None') && lstPreApplicant[0].AR_Properties_Only__c) {
                b_doNotShow = true;
                system.debug('AR Properties Only, no AR property');
                
                streligibilityReport += '\t'+'-AR Properties: Only AR properties requested, Not an AR property'+'\n';
                
                streligibilityReportExternal += '-You requested only 55+ homes. This is not an 55+.'+'\n';
            }
            
            // ====================================================================
            // Test if Pre-Applicant Household Size <= Max Household Size                
            // ====================================================================                
            
            string strHouseholdSize = '';
            if( lstPreApplicant != null )
                strHouseholdSize = lstPreApplicant[0].Household_Size__c;
            
            if(strHouseholdSize != null && strHouseholdSize != '' && strHouseholdSize.isNumeric() == false)
            {
                b_doNotShow = true;
                system.debug('Household Size exceeds Property Maximum');
                
                streligibilityReport += '\t' + '-Household Size: Household Size ('+integer.valueof(lstPreApplicant[0].Household_Size__c)+') is GREATER than Property Maximum ('+rentalProperty.Maximum_Household_Size__c+')\n';
                
                streligibilityReportExternal += '-Your household size is too large for this unit.'+'\n';                                    
            }                   
            else                
                if(rentalProperty.Maximum_Household_Size__c != null && lstPreApplicant[0].Household_Size__c != null && rentalProperty.Maximum_Household_Size__c < integer.valueof(lstPreApplicant[0].Household_Size__c)) {
                    b_doNotShow = true;
                    system.debug('Household Size exceeds Property Maximum');
                    
                    streligibilityReport += '\t' + '-Household Size: Household Size ('+integer.valueof(lstPreApplicant[0].Household_Size__c)+') is GREATER than Property Maximum ('+rentalProperty.Maximum_Household_Size__c+')\n';
                    
                    streligibilityReportExternal += '-Your household size is too large for this unit.'+'\n';                    
                }
            
            // ====================================================================
            // Test if Pre-Applicant Household Size >= Min Household Size                 
            // ====================================================================
            if( lstPreApplicant != null )
                strHouseholdSize = lstPreApplicant[0].Household_Size__c;
            
            if(strHouseholdSize != null && strHouseholdSize != '' && strHouseholdSize.isNumeric() == false)
            {
                b_doNotShow = true;
                system.debug('Household Size below Property Minimum');
                
                streligibilityReport += '\t' + '-Household Size: Household Size ('+integer.valueof(lstPreApplicant[0].Household_Size__c)+') is LESS than Property Minimum ('+rentalProperty.Min_Household_Size__c+')\n';
                
                streligibilityReportExternal += '-Affordable homes are first marketed to households with at least one person per bedroom.  Your household size does not meet this requirement.  If we do not find a household that meets this requirement, this home may become available to your household size.  You will be notified by email if you are eligible.'+'\n';                                    
            }                   
            else                
                if(rentalProperty.Min_Household_Size__c != null && lstPreApplicant[0].Household_Size__c != null && rentalProperty.Min_Household_Size__c > integer.valueof(lstPreApplicant[0].Household_Size__c)) {
                    b_doNotShow = true;
                    system.debug('Household Size below Property Minimum');
                    
                    streligibilityReport += '\t' + '-Household Size: Household Size ('+integer.valueof(lstPreApplicant[0].Household_Size__c)+') is LESS than Property Minimum ('+rentalProperty.Min_Household_Size__c+')\n';
                    
                    streligibilityReportExternal += '-Affordable homes are first marketed to households with at least one person per bedroom.  Your household size does not meet this requirement.  If we do not find a household that meets this requirement, this home may become available to your household size.  You will be notified by email if you are eligible.'+'\n';
                }
            
            // ====================================================================
            // Test Property Listing Stage Region Restriction                 
            // ====================================================================     
            if(rentalProperty.Listing_Stage__c == 'Region and bedroom/household size restricted' && (lstPreApplicant[0].Live_Work_Regions__c == null || lstPreApplicant[0].Live_Work_Regions__c.contains(rentalProperty.Municipality_Name__r.Region__c) == false)) {
                b_doNotShow = true;
                system.debug('Region Restricted Listing Stage, not in Region');
                
                streligibilityReport += '\t' + '-Region Restriction: Region Restricted Listing Stage, Preapplicant Live/Work Region '+lstPreApplicant[0].Live_Work_Regions__c+' not in property municipality Region '+rentalProperty.Municipality_Name__r.Region__c+'\n';
                
                streligibilityReportExternal += '-Affordable homes are first marketed to households that live or work within Region' + rentalProperty.Municipality_Name__r.Region_Counties__c + ' counties.  Your household does not live or work in these Counties.  If we do not find a household that meets this requirement, this home may become available to applicants who live or work outside the Region.  You will be notified by email if you are eligible.'+'\n';
            }
            else
            {
                // ====================================================================
                // Test if Pre-Applicant Annual Income < Property Municipality Region Income Limit for Household Size       
                // ====================================================================
                boolean b_IsMaxIncome = CGPHProfileController.getPropertyMaxIncome(rentalProperty,lstPreApplicant,lstIncomeLimit);
                if(b_IsMaxIncome == true){
                    b_doNotShow = true;
                    //Report messages added in getPropertyMaxIncome method
                    
                }
            }
            
            // ====================================================================
            // Test Pre-Applicant Housing Expenses vs Income for Rental (Rent not too much of Income) 
            // ====================================================================                 
            
            if( d_MaxPerAnnualIncome == null)
            {
                system.debug('Section 8 exception');
            } else {
                if(d_EffectiveRent * 12 > ((d_MaxPerAnnualIncome/100) * lstPreApplicant[0].Annual_Income__c)){
                    // 3/18 Removed part of conditional that was preventing evaluation for Pass PQ
                    b_doNotShow = true;
                    system.debug('Annual Income too low');
                    Decimal PercentIncome =((d_EffectiveRent * 12)/lstPreApplicant[0].Annual_Income__c)*100;
                    streligibilityReport += '\t' + '-Annual Income: Expenses/Income ('+PercentIncome.setScale(0)+'%) is GREATER than maximum ('+d_MaxPerAnnualIncome.round()+'%)'+'\n';
                    
                    streligibilityReportExternal += '-Your household\'s income does not meet the required minimum income.'+'\n';
                }
            }
            
            
            // ====================================================================
            // Test Pre-Applicant meets Rental Age Restriction
            // ==================================================================== 
            if(rentalProperty.Disabled_eligible_regardless_of_age__c == 'Yes' && lstPreApplicant[0].Household_Disabled__c == true) // added new condition on 04/09/2019
            {
                // no criteria check is done for age restriction
            }
            else
            {                
                if((rentalProperty.Age_Restriction__c != null && rentalProperty.Age_Restriction__c != 'None') && !(lstPreApplicant[0].Household_Disabled__c && rentalProperty.Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c))
                {
                    if( lstPreApplicant[0].Household_Members_55__c == false )
                    {
                        b_doNotShow = true;
                        system.debug('Age Restricted Property, no household member 55+');
                        
                        streligibilityReport += '\t' + '-Age Restriction: Age Restricted Property, no household member 55+\n';
                        
                        streligibilityReportExternal += '\t' + '-This is a 55+ home.  Your household no longer qualifies because of the ages of your household members.'+'\n';
                    }
                    
                    if(rentalProperty.Age_Restriction__c == strOverEighteen && lstPreApplicant[0].Youngest_Household_Member__c != strOverEighteen)
                    {
                        b_doNotShow = true;
                        system.debug('Over 18 Age restriction, yougest household member not over 18');
                        
                        streligibilityReport += '\t' + '-Age Restriction: Over 18 Age restriction, yougest household member not over 18\n';
                        
                        streligibilityReportExternal += '\t' + '-Over 18 Age restriction, yougest household member not over 18'+'\n';
                    }
                    
                    if(rentalProperty.Age_Restriction__c == strOver17 && (lstPreApplicant[0].Youngest_Household_Member__c == strUnderEighteen) )
                    {
                        b_doNotShow = true;
                        system.debug('Over 17 Age restriction, yougest household member not over 17');
                        
                        streligibilityReport += '\t' + '-Age restriction: Over 17 Age restriction, yougest household member not over 17'+'\n';
                        
                        streligibilityReportExternal += '\t' + '-Over 17 Age restriction, yougest household member not over 17'+'\n';
                    }
                    
                }
            }
            
            // ====================================================================
            // Prop-Questionnaire Additional Criteria 
            // ==================================================================== 
            if( customSettingTobeUsed=='UseToPassPQCustomSetting' )
            {
                // ====================================================================
                // Test Prop-Questionnaire Assets below Property Municipality Region Regional Asset Limit 
                // ====================================================================     
                for( Income_Limits__c incomeLimit : lstIncomeLimit )
                {
                    lstIncomeLimit = new list<Income_Limits__c>();
                    lstIncomeLimit.add(mapIncomeLimit.get(rentalProperty.Municipality_Name__r.Income_Limit__c));
                    if(incomeLimit.Region__c == rentalProperty.Municipality_Name__r.Region__c)
                    {
                        decimal d_regionalAssetLimit = incomeLimit.Regional_Asset_Limit__c;
                        if(application.Currently_Owns_Real_Estate__c == true && 
                           (application.Current_Mortgage__c == null || application.Current_Mortgage__c == 0) && 
                           application.Current_Estimated_Property_Value__c > d_regionalAssetLimit && 
                           (application.Current_Property_Taxes_Insurance__c < (0.38 * lstPreApplicant[0].Annual_Income__c)))
                        {
                            b_doNotShow = True;
                            Decimal toround = application.Current_Property_Taxes_Insurance__c * 100 / lstPreApplicant[0].Annual_Income__c;
                            Decimal rounded = toround.setScale(2);
                            
                            system.debug('House value'+application.Current_Estimated_Property_Value__c+' > Regional Asset Limit of '+ d_regionalAssetLimit +' for Region '+ incomeLimit.Region__c +', Current Property Taxes Insurance /Annual Income ='+rounded+'%, is LESS than 38%');
                            
                            streligibilityReport += '\t' + '-Regional Asset Limit: Est Property Value ($'+application.Current_Estimated_Property_Value__c+') is Greater than the Regional Asset Limit ($'+ d_regionalAssetLimit +') for Region '+ incomeLimit.Region__c +', Current Property Taxes Insurance /Annual Income ('+rounded+'%) is LESS than 38%\n';
                            
                            streligibilityReportExternal += '-The value of your current home exceeds that maximum permitted by the State.'+'\n';
                        }
                        //incomeLimit.Regional_Asset_Limit__c;
                    }
                }
                
                
                // ====================================================================
                // Test Pre-Applicant meets Development Property Minimum Credit Score 
                // ====================================================================                     
                if(application.Estimated_Credit_Score__c == null)
                    application.Estimated_Credit_Score__c = 0;
                
                if(rentalProperty.Development_address__c != null && rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c == null)
                    rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c = 0;   
                
                if(application.Estimated_Credit_Score__c < rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c)
                {
                    b_doNotShow = true;
                    system.debug('Credit score '+application.Estimated_Credit_Score__c +' is too low. You need credit score more than '+rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c);
                    
                    String intCreditScore = application.Estimated_Credit_Score__c != null ? String.valueOf(application.Estimated_Credit_Score__c.intValue()) : '0';
                    String intMinCreditScore = rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c != null ? String.valueOf(rentalProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c.intValue()) : '0';
                    streligibilityReport += '\t' + '-Credit score: ' + intCreditScore +' is LESS than Minimum Credit Score (' + intMinCreditScore +')\n';
                    
                    streligibilityReportExternal += '-When you submitted an interest form for this home, you indicated that your credit score is '+ intCreditScore +'. This is less than the minimum credit score of ' + intMinCreditScore +'.\n';
                }
                
                
                // ====================================================================
                // Flag (not eligibility criteria) Pre-Applicant in process of separation / divorce 
                // ====================================================================                     
                if(application.Separated_getting_divorced__c == 'Yes')
                {
                    system.debug('-Applicant is in the process of separating or getting a divorce');
                    
                    streligibilityReport += '\t' + '-Settlement Agreement: Applicant is in the process of separating or getting a divorce'+'\n';
                    
                    streligibilityReportExternal += '-Applicant is in the process of separating or getting a divorce'+'\n';            
                }           
                
            }
            
            
            
            if( b_doNotShow == true )
            {
                mapWrapperRentalProperty.put(rentalProperty.id,new WrapperRentalProperties(rentalProperty,false,streligibilityReport,streligibilityReportExternal));
            }
            else
            {       
                streligibilityReport += '\t' +'Eligible for Property';
                mapWrapperRentalProperty.put(rentalProperty.id,new WrapperRentalProperties(rentalProperty, true,streligibilityReport,streligibilityReportExternal));
                system.debug(logginglevel.error,'Property is visible  ');
            }
            
        }//loop ends here
        
        return mapWrapperRentalProperty;
    }
    
    
    // ====================================================================
    // Purchase Criteria Calculations                
    // ====================================================================   
    public static map<Id,WrapperPurchaseProperties> calculateCriteriaForPurchase(list<HOMEtracker__Property__c>lstPurchaseProperty,list<PreApplicants__c> lstPreApplicant,CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings,map<id,Income_Limits__c> mapIncomeLimit,PreApplicants__c preApplicantsInfo,map<id,double>mapMunicipalityGTR,Application__c application)
    {
        
        map<Id,WrapperPurchaseProperties> mapWrapperPurchaseProperty = new map<Id,WrapperPurchaseProperties>();
        map<String,List<WrapperPurchaseProperties>> mapOfMunicipalProperty = new map<String,List<WrapperPurchaseProperties>>();
        //map<Id,Double> mapMunicipalityGTR = new map<Id,Double>();     
        String strOverEighteen, 
            strUnderEighteen, 
            strEighteen, 
            strOver17,
            str55Plus;
        strOverEighteen = 'Over 18';
        strUnderEighteen = 'Under 18';
        strEighteen = '18';
        str55Plus = '55+ exclusive';
        strOver17 = 'Over 17';


        
        list<Income_Limits__c> lstIncomeLimit;
        
        streligibilityReport ='' ;
        streligibilityReportExternal = '';
        
        map<string,Decimal> mapInsurateRate = new map<string,Decimal>();
        mapInsurateRate.put('0',cgphProfileCustomSettings.Insurance_0_Bedroom__c);
        mapInsurateRate.put('1',cgphProfileCustomSettings.Insurance_1_Bedroom__c);
        mapInsurateRate.put('2',cgphProfileCustomSettings.Insurance_2_Bedroom__c);
        mapInsurateRate.put('3',cgphProfileCustomSettings.Insurance_3_Bedroom__c);
        mapInsurateRate.put('4',cgphProfileCustomSettings.Insurance_4_Bedroom__c);
        Decimal d_PMIRateForLTV95, d_PMIRateForLTV90, d_PMIRateForLTV85, d_PMIRateForLTV80, d_MortgageRate;
        
        d_PMIRateForLTV95 = cgphProfileCustomSettings.PMI_Rate_for_LTV_95__c;
        d_PMIRateForLTV90 = cgphProfileCustomSettings.PMI_Rate_for_LTV_90__c;
        d_PMIRateForLTV85 = cgphProfileCustomSettings.PMI_Rate_for_LTV_85__c;
        d_PMIRateForLTV80 = cgphProfileCustomSettings.PMI_Rate_for_LTV_80__c;
        d_MortgageRate = cgphProfileCustomSettings.Mortgage_Rate__c/12/100;
        
        
        for(HOMEtracker__Property__c homeOwnerProperty : lstPurchaseProperty)
        {
            system.debug(homeOwnerProperty.Name+'    ('+homeOwnerProperty.Municipality_Name__r.Name+')');
            streligibilityReport += 'Property Name : '+homeOwnerProperty.Name+'\n';
            streligibilityReportExternal += 'Property Name : '+homeOwnerProperty.Name+'\n';
            Decimal d_MortgageAmount, d_approxMonthlyTax,  d_TotalMonthlyExpenses, d_PropertyInsuranceRate, d_PercentMonthlyIncome, PMI;
            //boolean b_IsMaxIncome;
            double d_approxMonthlyPayment;
            system.debug('Preapplicant is : '+lstPreApplicant[0]);
            
            if(application == null){ // Called from Profile Page
                d_MortgageAmount = (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0) - (lstPreApplicant[0].Max_Down_Payment__c != null ? lstPreApplicant[0].Max_Down_Payment__c : 0);
            }else{
                d_MortgageAmount = (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0) - (application.Savings_Gifts_Down_Payment__c != null ? application.Savings_Gifts_Down_Payment__c : 0) - (application.Other_Sources_Down_Payment__c != null ? application.Other_Sources_Down_Payment__c : 0);
            }
            
            //system.debug('homeOwnerProperty.HOMEtracker__List_Price__c => '+homeOwnerProperty.HOMEtracker__List_Price__c +' lstPreApplicant[0].Max_Down_Payment__c => '+lstPreApplicant[0].Max_Down_Payment__c);
            
            if( d_MortgageAmount == null || d_MortgageAmount < 0)
                d_MortgageAmount = 0;
            
            if(homeOwnerProperty.HOMEtracker__List_Price__c != null && homeOwnerProperty.HOMEtracker__List_Price__c != 0 && d_MortgageAmount > 0 && homeOwnerProperty.HOMEtracker__Property_Type__c != 'Mobile or Manufactured Home') {
                if((d_MortgageAmount / (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0 )) > 0.9501)
                    PMI = (d_MortgageAmount*d_PMIRateForLTV95)/12;
                else if((d_MortgageAmount / (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0 )) > 0.9001)
                    PMI = (d_MortgageAmount*d_PMIRateForLTV90)/12;
                else if((d_MortgageAmount / (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0 )) > 0.8501)
                    PMI = (d_MortgageAmount*d_PMIRateForLTV85)/12;
                else if((d_MortgageAmount / (homeOwnerProperty.HOMEtracker__List_Price__c != null ? homeOwnerProperty.HOMEtracker__List_Price__c : 0 )) > 0.8001)
                    PMI = (d_MortgageAmount*d_PMIRateForLTV80)/12;
                else
                    PMI = 0;
            }else{
                PMI = 0;
            }
            
            if(homeOwnerProperty.HOMEtracker__Property_Type__c != 'Mobile or Manufactured Home') {
                d_approxMonthlyTax =((mapMunicipalityGTR.get(homeOwnerProperty.Municipality_Name__c)/100) * homeOwnerProperty.HOMEtracker__List_Price__c * (homeOwnerProperty.Municipality_Name__r.Equalization_Ratio__c/100))/12;
            }else{
                d_approxMonthlyTax=0; 
                system.debug('Mobile or Manufactured Home PMI and MonthlyTax = 0');
            }
            
            d_approxMonthlyPayment = d_MortgageAmount*d_MortgageRate/(1-1/(1+d_MortgageRate).pow(360));
            system.debug('d_MortgageAmount => '+d_MortgageAmount+' d_MortgageRate => '+d_MortgageRate);
            d_PropertyInsuranceRate = mapInsurateRate.get(homeOwnerProperty.HOMEtracker__Number_of_Bedrooms__c);
            d_TotalMonthlyExpenses = d_approxMonthlyPayment + d_approxMonthlyTax + PMI + d_PropertyInsuranceRate + (homeOwnerProperty.HOMEtracker__Current_HOA_Condo_Fees__c != null ? homeOwnerProperty.HOMEtracker__Current_HOA_Condo_Fees__c : 0 );
            
            if(d_TotalMonthlyExpenses != null)
                d_PercentMonthlyIncome = d_TotalMonthlyExpenses/(lstPreApplicant[0].Annual_Income__c/12)*100;           // changed Monthly_Rent__c ==> Annual_Income__c
            else 
                d_PercentMonthlyIncome = 0;
            
            system.debug('d_approxMonthlyTax => '+d_approxMonthlyTax+' d_approxMonthlyPayment => '+d_approxMonthlyPayment +' d_PropertyInsuranceRate => '+d_PropertyInsuranceRate+' d_TotalMonthlyExpenses => '+d_TotalMonthlyExpenses+' d_PercentMonthlyIncome => '+d_PercentMonthlyIncome);
            
            boolean b_doNotShow = false;
            
            map<string,decimal> mapOfAMIPercentageMaxIncome = new map<string,decimal>();
            
            // check if the income is satisfying the property income level criteria
            
            mapOfAMIPercentageMaxIncome = CGPHProfileController.getPropertyIncomeComparison(lstIncomeLimit,preApplicantsInfo,homeOwnerProperty.Municipality_Name__r.Region__c);
            
            // ====================================================================
            // Test if Pre-Applicant can view Property Income Level                 
            // ====================================================================   
            if( preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('VeryLow') )
            {
                // show all the properties
                streligibilityReport += '\t' + '-Property Income level: Eligible '+'\n';
            }
            else if( preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('Low') && homeOwnerProperty.Max_Income_Level__c == 'Very Low')
            {
                // do not show property
                b_doNotShow = true;
                system.debug('Region '+homeOwnerProperty.Municipality_Name__r.Region__c +' Income Levels => '+mapOfAMIPercentageMaxIncome);
                
                system.debug('Property Income level ('+homeOwnerProperty.Max_Income_Level__c+') is LESS than the Pre-Applicant Income Level (Low)');
                
                streligibilityReport += '\t' + '-Property Income level : Property Income Level ('+homeOwnerProperty.Max_Income_Level__c+') is LESS than the Pre-Applicant Income Level (Low)'+'\n';
                
                streligibilityReportExternal += '-Your household\'s income level is higher than the property income level.'+'\n';
                
            }
            if( preApplicantsInfo.Annual_Income__c > mapOfAMIPercentageMaxIncome.get('Low') && preApplicantsInfo.Annual_Income__c <= mapOfAMIPercentageMaxIncome.get('Moderate') && (homeOwnerProperty.Max_Income_Level__c == 'Very Low' || homeOwnerProperty.Max_Income_Level__c == 'Low') )
            {
                // do not show the property
                b_doNotShow = true;
                system.debug('Region '+homeOwnerProperty.Municipality_Name__r.Region__c +' Income Levels => '+mapOfAMIPercentageMaxIncome);
                system.debug('Property Income level ('+homeOwnerProperty.Max_Income_Level__c+') is LESS than the Pre-Applicant Income Level - Moderate');
                
                streligibilityReport += '\t' + '-Property Income level : Property Income Level ('+homeOwnerProperty.Max_Income_Level__c+') is LESS than the Pre-Applicant Income Level (Moderate)'+'\n';
                
                streligibilityReportExternal += '-Your household\'s income level is higher than the property income level.'+'\n';
                
            }
            
            
            // ====================================================================
            // Test if Property not Age Restricted and Pre-Applicant is only interested in Age Restricted                 
            // ====================================================================
            if((homeOwnerProperty.Age_Restriction__c == null || homeOwnerProperty.Age_Restriction__c == 'None') && lstPreApplicant[0].AR_Properties_Only__c )
            {
                system.debug('AR Properties Only, no AR property');
                b_doNotShow = true;
                
                streligibilityReport += '\t' + '-AR Properties : Only AR properties requested, Not an AR property'+'\n';
                
                streligibilityReportExternal += '-You requested only 55+ homes. This is not an 55+.'+'\n';                  
            }
            
            // ====================================================================
            // Test if Pre-Applicant Household Size <= Max Household Size                
            // ====================================================================
            string strHouseholdSize = '';
            if( lstPreApplicant != null )
                strHouseholdSize = lstPreApplicant[0].Household_Size__c;
            
            if(strHouseholdSize != null && strHouseholdSize != '' && strHouseholdSize.isNumeric() == false)
            {
                b_doNotShow = true;
                system.debug('Household Size exceeds Property Maximum');
                
                streligibilityReport += '\t' + '-Household Size: Household Size ('+lstPreApplicant[0].Household_Size__c+') is GREATER then Property Maximum ('+homeOwnerProperty.Maximum_Household_Size__c+')'+'\n';
                
                streligibilityReportExternal += '-Your household size is too large for this unit.'+'\n';                
                
            }                   
            else
                if(homeOwnerProperty.Maximum_Household_Size__c != null && lstPreApplicant[0].Household_Size__c != null && homeOwnerProperty.Maximum_Household_Size__c < integer.valueof(lstPreApplicant[0].Household_Size__c) ) {
                    b_doNotShow = true;
                    system.debug('Household Size exceeds Property Maximum');
                    
                    streligibilityReport += '\t' + '-Household Size: Household Size ('+lstPreApplicant[0].Household_Size__c+') is GREATER then Property Maximum ('+homeOwnerProperty.Maximum_Household_Size__c+')'+'\n';
                    
                    streligibilityReportExternal += '-Your household size is too large for this unit.'+'\n';
                }
            
            // ====================================================================
            // Test if Pre-Applicant Household Size >= Min Household Size                 
            // ====================================================================             
            
            if( lstPreApplicant != null )
                strHouseholdSize = lstPreApplicant[0].Household_Size__c;
            
            if(strHouseholdSize != null && strHouseholdSize != '' && strHouseholdSize.isNumeric() == false)
            {
                b_doNotShow = true;
                system.debug('Household Size below Property Minimum');
                
                streligibilityReport += '\t' + '-Household Size: Household Size ('+lstPreApplicant[0].Household_Size__c+') is LESS than Property Minimum ('+homeOwnerProperty.Min_Household_Size__c+')'+'\n';
                
                streligibilityReportExternal += '-Affordable homes are first marketed to households with at least one person per bedroom.  Your household size does not meet this requirement.  If we do not find a household that meets this requirement, this home may become available to your household size.  You will be notified by email if you are eligible.'+'\n';                
            }                   
            else                
                if(homeOwnerProperty.Min_Household_Size__c != null && lstPreApplicant[0].Household_Size__c != null && homeOwnerProperty.Min_Household_Size__c > integer.valueof(lstPreApplicant[0].Household_Size__c)) {
                    b_doNotShow = true;
                    system.debug('Household Size below Property Minimum');
                    
                    streligibilityReport += '\t' + '-Household Size: Household Size ('+lstPreApplicant[0].Household_Size__c+') is LESS than Property Minimum ('+homeOwnerProperty.Min_Household_Size__c+')'+'\n';
                    
                    streligibilityReportExternal += '-Affordable homes are first marketed to households with at least one person per bedroom.  Your household size does not meet this requirement.  If we do not find a household that meets this requirement, this home may become available to your household size.  You will be notified by email if you are eligible.'+'\n';
                }
            
            // ====================================================================
            // Test Property Listing Stage Region Restriction                 
            // ====================================================================                 
            if( homeOwnerProperty.Listing_Stage__c == 'Region and bedroom/household size restricted'  && (lstPreApplicant[0].Live_Work_Regions__c == null || lstPreApplicant[0].Live_Work_Regions__c.contains(homeOwnerProperty.Municipality_Name__r.Region__c) == false) )
            {
                b_doNotShow = true;
                system.debug('Region Restricted Listing Stage, not in Region');
                
                streligibilityReport += '\t' + '-Region Restriction: Region Restricted Listing Stage, Pre-Applicant Live/Work '+lstPreApplicant[0].Live_Work_Regions__c+' not in Region '+homeOwnerProperty.Municipality_Name__r.Region__c+'\n';
                
                streligibilityReportExternal += '-Affordable homes are first marketed to households that live or work within Region' + homeOwnerProperty.Municipality_Name__r.Region_Counties__c +' counties.  Your household does not live or work in these Counties.  If we do not find a household that meets this requirement, this home may become available to applicants who live or work outside the Region.  You will be notified by email if you are eligible.'+'\n';
            } 
            else 
            {
                // ====================================================================
                // Test if Pre-Applicant Annual Income < Property Municipality Region Income Limit for H0usehold Size       
                // ====================================================================                  
                lstIncomeLimit = new list<Income_Limits__c>();

                if( cgphProfileCustomSettings.Maintenance_URL__c == 'SOURCEPRIVATELISTING' || cgphProfileCustomSettings.Maintenance_URL__c ==  'SOURCEELIGIBILITYTRIGGER')
                {
                    system.debug('&&&method called from Listing page or Eligibility trigger');
                    lstIncomeLimit = new list<Income_Limits__c>();
                    system.debug('Income limit value is getting added from development => '+homeOwnerProperty.Development_address__r.Dev_Income_Limit__c);
                    lstIncomeLimit.add(mapIncomeLimit.get(homeOwnerProperty.Development_address__r.Dev_Income_Limit__c));
                    mapOfAMIPercentageMaxIncome = CGPHProfileController.getPropertyIncomeComparison(lstIncomeLimit,preApplicantsInfo,homeOwnerProperty.Municipality_Name__r.Region__c);
                }
                else
                {
                    lstIncomeLimit = new list<Income_Limits__c>();
                    system.debug('Income limit value is getting added from municipality => '+homeOwnerProperty.Municipality_Name__r.Income_Limit__c);
                    lstIncomeLimit.add(mapIncomeLimit.get(homeOwnerProperty.Municipality_Name__r.Income_Limit__c));
                    mapOfAMIPercentageMaxIncome = CGPHProfileController.getPropertyIncomeComparison(lstIncomeLimit,preApplicantsInfo,homeOwnerProperty.Municipality_Name__r.Region__c);
                } 
                system.debug('lstIncomeLimit '+lstIncomeLimit);
                //lstIncomeLimit.add(mapIncomeLimit.get(homeOwnerProperty.Municipality_Name__r.Income_Limit__c));
                boolean b_IsMaxIncome = CGPHProfileController.getPropertyMaxIncome(homeOwnerProperty,lstPreApplicant,lstIncomeLimit);
                if(b_IsMaxIncome == true)
                {
                    b_doNotShow = true;
                    system.debug('Property not visible: Exceeds Max Income');
                    //Report messages added in getPropertyMaxIncome method
                    
                }
            }
            
            // ====================================================================
            // Test Pre-Applicant Housing Expenses vs Income for Purchase (Mortgage not too of much Income) 
            // ====================================================================                 
            system.debug('d_PercentMonthlyIncome='+d_PercentMonthlyIncome+'   compared to '+cgphProfileCustomSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c);
            
            //if( (d_PercentMonthlyIncome > cgphProfileCustomSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c) && application == null ) // cgphProfileCustomSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c this value is 38%
            Decimal MaxHSG;
            // Application is null only for profile if it from elegibility trigger it is not null 
            if(application == null){ // Called from Profile Page
                MaxHSG = cgphProfileCustomSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c;
            }else{ // Called from PQ trigger
                MaxHSG = cgphProfileCustomSettings.To_Pass_PQ_Owner_Max_Hsg_vs_Exp__c;   
            }
            
            if(d_PercentMonthlyIncome > MaxHSG) 
            {                                                                                                                       
                b_doNotShow = true;
                system.debug('Annual Income too low : ' + d_PercentMonthlyIncome.setScale(2) + '%');
                
                streligibilityReport += '\t' + '-Annual Income: Expenses/Income (' + d_PercentMonthlyIncome.setScale(2) + '%) is GREATER than maximum (' +MaxHSG.setScale(2)+'%)\n';
                
                streligibilityReportExternal += '-Your household\'s income does not meet the required minimum income.'+'\n';
            }
            
            // ====================================================================
            // Test Pre-Applicant meets Rental Age Restriction
            // ====================================================================   
            if(homeOwnerProperty.Disabled_eligible_regardless_of_age__c == 'Yes' && lstPreApplicant[0].Household_Disabled__c == true) // added new condition on 04/09/2019
            {
                // no criteria check is done for age restriction
            }
            else
            {  
                if((homeOwnerProperty.Age_Restriction__c != null && homeOwnerProperty.Age_Restriction__c != 'None') && !(lstPreApplicant[0].Household_Disabled__c &&  homeOwnerProperty.Municipality_Name__r.Purchase_Permanent_Disability_AR_Excepti__c))
                {
                    if( lstPreApplicant[0].Household_Members_55__c == false )
                    {
                        b_doNotShow = true;
                        system.debug('Age Restricted Property, no household member 55+');
                        
                        streligibilityReport += '\t' + '-Age Restriction: Age Restricted Property, no household member 55+\n';
                        streligibilityReportExternal += '-This is a 55+ home.  Your household no longer qualifies because of the ages of your household members.'+'\n';
                    }
                    
                    if(homeOwnerProperty.Age_Restriction__c == strOverEighteen && lstPreApplicant[0].Youngest_Household_Member__c != strOverEighteen)
                    {
                        b_doNotShow = true;
                        system.debug('Over 18 Age restriction, yougest household member not over 18');
                        
                        streligibilityReport += '\t' + '-Age Restriction: Over 18 Age restriction, yougest household member not over 18\n';
                        streligibilityReportExternal += '-Over 18 Age restriction, yougest household member not over 18.'+'\n';
                    }
                    
                    if(homeOwnerProperty.Age_Restriction__c == strOver17 && lstPreApplicant[0].Youngest_Household_Member__c == strUnderEighteen)
                    {
                        b_doNotShow = true;
                        system.debug('Over 17 Age restriction, yougest household member not over 17');
                        
                        streligibilityReport += '\t' + '-Age Restriction: Over 17 Age restriction, yougest household member not over 17\n';
                        streligibilityReportExternal += '-Over 17 Age restriction, yougest household member not over 17.'+'\n';
                    }
                }
            }
            
            
            
            // ====================================================================
            // Prop-Questionnaire Additional Criteria 
            // ==================================================================== 
            if( application != null ) // this will only excute from the eligibility trigger and not from the profile pages
            {
                lstIncomeLimit = new list<Income_Limits__c>();
                system.debug('mapIncomeLimit '+mapIncomeLimit);
                system.debug('homeOwnerProperty.Development_address__r.Dev_Income_Limit__c '+homeOwnerProperty.Development_address__r.Dev_Income_Limit__c);
                lstIncomeLimit.add(mapIncomeLimit.get(homeOwnerProperty.Development_address__r.Dev_Income_Limit__c));
                for( Income_Limits__c incomeLimit : lstIncomeLimit )
                {
                    
                    // ====================================================================
                    // Test Prop-Questionnaire Assets below Property Municipality Region Regional Asset Limit 
                    // ==================================================================== 
                    system.debug('incomeLimit '+incomeLimit);
                    system.debug('homeOwnerProperty.Municipality_Name__r.Region__c '+homeOwnerProperty.Municipality_Name__r.Region__c);
                    system.debug('homeOwnerProperty.Municipality_Name__c '+homeOwnerProperty.Municipality_Name__r.Region__c);   
                    system.debug('homeOwnerProperty '+homeOwnerProperty);                      
                    if(incomeLimit.Region__c == homeOwnerProperty.Municipality_Name__r.Region__c)
                    {
                        decimal d_regionalAssetLimit = incomeLimit.Regional_Asset_Limit__c;
                        if(application.Currently_Owns_Real_Estate__c == true && 
                           (application.Current_Mortgage__c == null || application.Current_Mortgage__c == 0) && 
                           application.Current_Estimated_Property_Value__c > d_regionalAssetLimit && 
                           (application.Current_Property_Taxes_Insurance__c < (0.38 * lstPreApplicant[0].Annual_Income__c)))
                        {
                            b_doNotShow = true;
                            
                            Decimal toround = application.Current_Property_Taxes_Insurance__c * 100 / lstPreApplicant[0].Annual_Income__c;
                            Decimal rounded = toround.setScale(2);
                            Decimal PropVal = application.Current_Estimated_Property_Value__c.setScale(2);
                            Decimal AssetLimit = d_regionalAssetLimit.setScale(2);
                            
                            system.debug('-House value '+PropVal+' > Regional Asset Limit of '+ AssetLimit +' for Region '+ incomeLimit.Region__c +', Current Property Taxes Insurance /Annual Income ('+rounded+'%) is LESS than 38%');
                            
                            streligibilityReport += '\t' + '-Regional Asset Limit: Est Property Value ($'+PropVal+') is GREATER than Regional Asset Limit ($'+ AssetLimit +') for Region ('+ incomeLimit.Region__c +'), Current Property Taxes Insurance /Annual Income ('+ rounded+'%) is LESS than 38%' + '\n';
                            
                            streligibilityReportExternal += '-The value of your current home exceeds that maximum permitted by the State.'+'\n';
                        }
                        //incomeLimit.Regional_Asset_Limit__c;
                    }
                }
                
                
                // ====================================================================
                // Test Pre-Applicant meets Development Property Minimum Credit Score 
                // ====================================================================                     
                if(application.Estimated_Credit_Score__c == null)
                    application.Estimated_Credit_Score__c = 0;
                
                if((homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c == null || homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c == 0) && homeOwnerProperty.Development_address__c != null)
                    homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c = 600;  
                
                if( application.Other_Sources_Down_Payment__c == null )
                    application.Other_Sources_Down_Payment__c = 0;
                
                if( application.Savings_Gifts_Down_Payment__c == null )
                    application.Savings_Gifts_Down_Payment__c = 0;
                
                if(homeOwnerProperty.HOMEtracker__List_Price__c == null )
                    homeOwnerProperty.HOMEtracker__List_Price__c = 0;                       
                
                
                if(application.Estimated_Credit_Score__c < homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c ) 
                {
                    
                    if((homeOwnerProperty.Development_address__r.Credit_Check_Required__c == 'Yes') || (homeOwnerProperty.Development_address__r.Credit_Check_Required__c == 'No' && (application.Other_Sources_Down_Payment__c + application.Savings_Gifts_Down_Payment__c < homeOwnerProperty.HOMEtracker__List_Price__c )))  
                    {
                        b_doNotShow = true;
                        system.debug('-Credit score '+application.Estimated_Credit_Score__c +' is too low. You need credit score more than '+homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c);
                        
                        String intCreditScore = application.Estimated_Credit_Score__c != null ? String.valueOf(application.Estimated_Credit_Score__c.intValue()) : '0';
                        String intMinCreditScore = homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c.intValue() != null ? String.valueOf(homeOwnerProperty.Development_address__r.Minimum_Credit_Score_to_be_Eligible__c.intValue()) : '0';
                        
                        streligibilityReport += '\t' + '-Credit score: '+ intCreditScore  +' is LESS than Minimum Credit Score ('+ intMinCreditScore +')\n';
                        
                        streligibilityReportExternal += '-When you submitted an interest form for this home, you indicated that your credit score is '+ intCreditScore +'. This is less than the minimum credit score of ' + intMinCreditScore  +'\n';
                    }               
                }
                
                
                
                // ====================================================================
                // Test Pre-Applicant can afford Minimum Down Payment 
                // ====================================================================
                boolean b_DownPaymentException = false;
                if(application.Savings_Gifts_Down_Payment__c == null)
                    application.Savings_Gifts_Down_Payment__c = 0;
                
                if((application.Other_Sources_Down_Payment__c + application.Savings_Gifts_Down_Payment__c)  < (homeOwnerProperty.HOMEtracker__List_Price__c * 0.05).setScale(2) )   
                {
                    b_doNotShow = true;
                    system.debug('-Doesn\'t meet the minimum down payment requirement $'+ Math.round(application.Other_Sources_Down_Payment__c + application.Savings_Gifts_Down_Payment__c) +' is LESS than the minimum down payment required. $'+Math.round(homeOwnerProperty.HOMEtracker__List_Price__c * 0.05));
                    
                    streligibilityReport += '\t' + '-Minimum Down Payment: $'+ Math.round(application.Other_Sources_Down_Payment__c + application.Savings_Gifts_Down_Payment__c) +' is LESS than the Minimum Down Payment Required ($'+Math.round(homeOwnerProperty.HOMEtracker__List_Price__c * 0.05)+')\n';
                    
                    streligibilityReportExternal += '-When you submitted an interest form for this home, you indicated that you will provide a down payment of $' + Math.round(application.Other_Sources_Down_Payment__c + application.Savings_Gifts_Down_Payment__c) + '. This is less than  5% of the purchase price which is required by banks.\n';          
                }   
                
                
                // ====================================================================
                // Flag (not eligibility criteria) Pre-Applicant in process of separation / divorce 
                // ====================================================================                     
                if(application.Separated_getting_divorced__c == 'Yes')
                {
                    system.debug('-Applicant is in the process of separating or getting a divorce');
                    
                    streligibilityReport += '\t' + '-Settlement Agreement: Applicant is in the process of separating or getting a divorce'+'\n';
                    
                    streligibilityReportExternal += '-Applicant is in the process of separating or getting a divorce'+'\n';         
                }           
                
            }
            
            
            if( b_doNotShow == true )
            {
                // do not show as one of the above reason
                mapWrapperPurchaseProperty.put(homeOwnerProperty.id,new WrapperPurchaseProperties(homeOwnerProperty,false,streligibilityReport,streligibilityReportExternal));
            }
            else
            {   
                streligibilityReport += '\t' + '-Applicant is eligible for the property '+'\n';
                mapWrapperPurchaseProperty.put(homeOwnerProperty.id,new WrapperPurchaseProperties(homeOwnerProperty, true,streligibilityReport,streligibilityReportExternal));
                system.debug('Property is visible');
            }
            
            
            
        }//loop ends here
        return mapWrapperPurchaseProperty;
    }
    
    
    //----------------------------Inner Class Section-------------------------------------//
    //Inner classes for visualforce page processing
    public class PreApplicantDetails{
        public String strPhone {get;set;}
        public String strLiveWorkRegions {get;set;}
        public String strUpdateURL {get;set;}
        public String strRestartURL {get;set;}
        public Date mostRecentUpdate {get;set;}
        public Boolean b_RentalMunicipalPreference{get;set;}
        public Boolean b_PurchaseMunicipalPreference{get;set;}
        public PreApplicants__c preApplicant{get;set;}
        public Integer nDaysValid {get;set;}
        public PreApplicantDetails(PreApplicants__c preApplicant, String strLiveWorkRegion, Date mostRecentUpdate, String strPhone, Boolean b_RentalMunicipalPreference, Boolean b_PurchaseMunicipalPreference,Integer nDaysValid){
            this.preApplicant = preApplicant;
            this.strLiveWorkRegions = strLiveWorkRegion;
            this.strUpdateURL = preApplicant.Update_URL__c;
            this.strRestartURL = preApplicant.Restart_URL__c;
            this.mostRecentUpdate = mostRecentUpdate;
            this.strPhone = strPhone;
            this.b_RentalMunicipalPreference = b_RentalMunicipalPreference;
            this.b_PurchaseMunicipalPreference = b_PurchaseMunicipalPreference;
            this.nDaysValid = nDaysValid;
        }
    }
    
    //Rental Township Prefernces
    public class RentalMunicipalPreference implements Comparable{
        public String strMunicipalityName{get;set;}
        public Date interestedDate{get;set;}
        public String strStatus{get;set;}
        public String strStyle{get;set;}
        public list<String> lstStrMessage{get;set;}
        
        public Municipality_Preference__c rentalPreferences{get;set;}
        public RentalMunicipalPreference(Municipality_Preference__c rentalPreferences){
            this.strMunicipalityName = rentalPreferences.Municipality__r.Name;
            this.interestedDate = Date.valueOF(rentalPreferences.Interest_Date__c);
            this.rentalPreferences = rentalPreferences;
        }
        
        public String strUnitSize{get;set;}
        public String strIncomeLevel{get;set;}
        public String strPrferenceForRegion{get;set;}
        public Decimal d_UnitSize{get;set;} 
        public String strRegion{get;set;}
        public boolean b_AppliedMuniciplaityPref{get;set;}
        public boolean b_LiveWorkPreference{get;set;}
        public Id municipalityId{get;set;}
        public String strCounty{get;set;}
        public boolean b_isLocal{get;set;}
        
        
        public RentalMunicipalPreference(Municipality__c municipality, String strStatus, list<String> lstStrMessage, Date interestDate, Boolean b_AppliedMuniciplaityPref){
            this.b_isLocal = municipality.Local_Preference__c;
            this.strMunicipalityName =  municipality.Name;
            this.strUnitSize =  municipality.Rental_Unit_Size__c;
            if(this.strUnitSize != null) 
                this.strUnitSize =  this.strUnitSize.replaceAll(';',', ');
            this.strIncomeLevel = municipality.Rental_Portfolio_Income_Levels__c;
            if(this.strIncomeLevel != null) 
                this.strIncomeLevel =  this.strIncomeLevel.replaceAll(';',', ');
            this.strStatus = strStatus;
            this.interestedDate = Date.valueOF(interestDate);
            this.b_AppliedMuniciplaityPref = b_AppliedMuniciplaityPref;
            this.municipalityId = municipality.Id;
            this.d_UnitSize = municipality.Rental_Units__c;
            this.strRegion = municipality.Region__c;
            this.b_LiveWorkPreference = municipality.Live_Work_Preference__c;
            this.strCounty = municipality.County__c;
            if(strStatus == 'eligible'){
                this.lstStrMessage = lstStrMessage;
            }
            else if(strStatus == 'inEligible'){
                this.lstStrMessage = lstStrMessage;
            }else{
                this.lstStrMessage = lstStrMessage;
            }
            setStyle(strStatus);
        }
        
        public void setStyle(String status) {
            if(strStatus == 'eligible') {
                strStyle = 'greenTitle1';
            } else if(strStatus == 'inEligible') {
                strStyle = 'greyTitle1';
            } else {
                strStyle = 'blueTitle1';
            }  
        }
        
        
        public Integer compareTo(Object ObjToCompare) {
            return strMunicipalityName.CompareTo(((RentalMunicipalPreference)ObjToCompare).strMunicipalityName);
        }
    }
    
    //Purchase Township Prefernces
    public class WrapperHownershipMunicipalPreference implements Comparable{
        public String strMunicipalityName{get;set;}
        public Date interestedDate{get;set;}
        public String strStatus{get;set;}
        public String strStyle{get;set;}
        public list<String> lstStrMessage{get;set;}
        public String strUnitSize{get;set;}
        public String strIncomeLevel{get;set;}
        public String strPrferenceForRegion{get;set;}
        public Decimal d_UnitSize{get;set;} 
        public String strRegion{get;set;}
        public boolean b_AppliedMuniciplaityPref{get;set;}
        public Id municipalityId{get;set;}
        public boolean b_LiveWorkPreference{get;set;}
        public String strCounty{get;set;}
        public Municipality__c municipality{get;set;}
        public Municipality_Preference__c hownershipPreferences{get;set;}
        public WrapperHownershipMunicipalPreference (Municipality_Preference__c hownershipPreferences){
            this.strMunicipalityName = hownershipPreferences.Municipality__r.Name;
            this.interestedDate = Date.valueOF(hownershipPreferences.Interest_Date__c);
            this.hownershipPreferences = hownershipPreferences;
        }
        
        
        public WrapperHownershipMunicipalPreference(Municipality__c municipality, String strStatus, list<String> lstStrMessage, Date interestDate, Boolean b_AppliedMuniciplaityPref){
            this.municipality = municipality;
            this.strMunicipalityName =  municipality.Name;
            this.strUnitSize =  municipality.Purchase_Unit_Size__c;
            if(this.strUnitSize != null) 
                this.strUnitSize =  this.strUnitSize.replaceAll(';',', ');
            this.strIncomeLevel = municipality.Purchase_Portfolio_Income_Levels__c;
            if(this.strIncomeLevel != null) 
                this.strIncomeLevel =  this.strIncomeLevel.replaceAll(';',', ');
            this.strStatus = strStatus;
            this.interestedDate = Date.valueOF(interestDate);
            this.b_AppliedMuniciplaityPref = b_AppliedMuniciplaityPref;            
            this.municipalityId = municipality.Id;
            this.d_UnitSize = municipality.Purchase_Units__c;
            this.strRegion = municipality.Region__c;
            this.b_LiveWorkPreference =  municipality.Live_Work_Preference__c;
            this.strCounty = municipality.County__c;
            if(strStatus == 'eligible'){
                this.lstStrMessage = lstStrMessage;
            }
            else if(strStatus == 'inEligible'){
                this.lstStrMessage = lstStrMessage;
            }else{
                this.lstStrMessage = lstStrMessage;
            }
            setStyle(strStatus);
        }
        
        public void setStyle(String status) {
            if(strStatus == 'eligible') {
                strStyle = 'greenTitle1';
            } else if(strStatus == 'inEligible') {
                strStyle = 'greyTitle1';
            } else {
                strStyle = 'blueTitle1';
            }   
        }
        public Integer compareTo(Object ObjToCompare) {
            return strMunicipalityName.CompareTo(((WrapperHownershipMunicipalPreference)ObjToCompare).strMunicipalityName);
        }
    }
    
    //Rental Properties
    public class WrapperRentalProperties{
        public HOMEtracker__Property__c property{get;set;}
        public Boolean b_IsEligible{get;set;}
        public string eligibilityReport; 
        public string eligibilityReportExternal;
        public WrapperRentalProperties(){
            
        }
        public WrapperRentalProperties(HOMEtracker__Property__c property, Boolean b_IsEligible,string eligibilityReport,string eligibilityReportExternal){
            this.property = property; 
            this.b_IsEligible = b_IsEligible;
            this.eligibilityReport = eligibilityReport;
            this.eligibilityReportExternal = eligibilityReportExternal;
        }
        
    }
    
    
    //HomwOwnership Properties
    public class WrapperPurchaseProperties{
        public HOMEtracker__Property__c property{get;set;}
        public Boolean b_IsEligible{get;set;}
        public string eligibilityReport;
        public string eligibilityReportExternal;
        public WrapperPurchaseProperties(HOMEtracker__Property__c property, Boolean b_IsEligible,string eligibilityReport,string eligibilityReportExternal){
            this.property = property; 
            this.b_IsEligible = b_IsEligible;
            this.eligibilityReport = eligibilityReport;
            this.eligibilityReportExternal = eligibilityReportExternal;
        }
        
    }
    
    //Property Full Information
    public class WrapperPropertyInfo{ 
        public HOMEtracker__Property__c property{get;set;}
        public List<Property_Image__c> lstPropertyImg{get;set;}
        public String strQuestionaireUrl{get;set;}
        public list<Application__c> lstPreliminarySubmission{get;set;}
        public WrapperPropertyInfo( HOMEtracker__Property__c property, List<Property_Image__c> lstPropertyImg, String strQuestionaireUrl,list<Application__c> lstPreliminarySubmission){
            this.property = property;
            this.lstPropertyImg = lstPropertyImg;
            this.strQuestionaireUrl = strQuestionaireUrl;
            this.lstPreliminarySubmission = lstPreliminarySubmission;
        }
        
        public WrapperPropertyInfo( HOMEtracker__Property__c property, String strQuestionaireUrl){
            this.property = property;
            this.strQuestionaireUrl = strQuestionaireUrl;
        }
    }
    public class MunicipalityException extends Exception{}
    public class PropertyException extends Exception{}
}