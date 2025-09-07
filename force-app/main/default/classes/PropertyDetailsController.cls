global class PropertyDetailsController
{
  public list<Municipality__c> lstMunicipality {get;set;}
  public string preappId {get;set;}
  public string propertyId {get;set;}
  list<HOMEtracker__Property__c> lstProperty;
  list<PreApplicants__c> lstpreApplicant;
  public string testAttr {get;set;}
  public WrapperPropertyDetails wrapObj {get; set;
     }
  
  public void getPropertyDetails()  
  {
    testAttr = 'Yes';
    system.debug('Method called');
    if(preappId != null && propertyId != null )
    {
     try{
      lstProperty = new list<HOMEtracker__Property__c>([Select Name,Status_Message__c,Campaign__c,Campaign__r.Text__c,
                                          Age_Restriction__c, Municipality_Name__r.Name,Municipality_Name__r.County__c, Municipality_County__c,
                                          Max_Income_Level__c,Deadline__c,X3x_Rent_Requirement__c,
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
                                          HOMEtracker__Property__c Where Id =: propertyId 
                                          LIMIT 1]);
                                          
            string municipalityId = lstProperty[0].Municipality_Name__c;
            
        list<CampaignMember> lstCampaignMember = new list<CampaignMember>();
      
      String campaignMemberID = '';
      String campaignMemberDeadline = '';
      Decimal campaignMemberLottery = null;
      Date campaignMemberInterest = null;
 
      lstCampaignMember = [SELECT Id,CampaignId,ContactId,Deadline_Date__c,Campaign_Member_Lottery_Number__c,Campaign_Member_Join_Date__c FROM CampaignMember WHERE ContactId = : preappId AND CampaignId = : lstProperty[0].Campaign__c];
      if(lstCampaignMember != null && lstCampaignMember.size() > 0)
      {

        if(preappId == lstCampaignMember[0].ContactId)
        {
        campaignMemberID = lstCampaignMember[0].Id;
        campaignMemberDeadline = ((lstCampaignMember[0].Deadline_Date__c.month() < 10)?'0':'') + string.valueOf(lstCampaignMember[0].Deadline_Date__c.month()) + '/' + (((lstCampaignMember[0].Deadline_Date__c.day()) < 10)?'0':'') + string.valueOf(lstCampaignMember[0].Deadline_Date__c.day() ) + '/' + string.valueOf(lstCampaignMember[0].Deadline_Date__c.year());
        campaignMemberLottery = lstCampaignMember[0].Campaign_Member_Lottery_Number__c;
        campaignMemberInterest = lstCampaignMember[0].Campaign_Member_Join_Date__c;

        } 
      }
                                
      lstpreApplicant = new list<PreApplicants__c>([SELECT 
                                  Id, Name, Contact__r.Email, Phone__c, Street__c, Household_Disabled__c,Pre_Applicant_Active__c,
                                        City__c, Postal_Code__c, Household_Size__c, Household_Members_55__c ,Contact__c,Profile_URL__c,
                                        Annual_Income__c, Live_Work_Regions__c, Rental_Interest__c, Most_Recent_Update__c,
                                        AR_Properties_Only__c, Purchase_Interest__c, Monthly_Other_Assistance__c, Section_8__c,
                                        Update_URL__c, Restart_URL__c, Youngest_Household_Member__c,Last_Profile_View__c,PreApplicant_Encoded_Id__c,
                                        Substandard_Overcrowded_Housing__c, Monthly_Rent__c, Update_Days__c,Number_of_Profile_Views__c,First_Name__c,Last_Name__c,
                                        Ext__c, State__c, Applicant_Name__c, Property_Questionnaire_URL__c, Max_Down_Payment__c,Region_Counties__c,Update_Status__c, Remove_Me_from_All_URL__c,Veteran__c
                                        FROM  
                                        PreApplicants__c 
                                        Where 
                                        Contact__c =: preappId ]);
                                        
        PreApplicants__c preAppObj = new PreApplicants__c();
        
        if(lstpreApplicant != null && lstpreApplicant.size() > 0)
        { 
        preappId = lstpreApplicant[0].Contact__c;
        preAppObj = lstpreApplicant[0];
        } 
        String invitedDate = '';
        if(campaignMemberInterest != null) 
            invitedDate = campaignMemberInterest.format();
        String lotteryNumber ='';   
        if(campaignMemberLottery != null)
          lotteryNumber = campaignMemberLottery.format();
     
        string strQuestionaireUrl = lstProperty[0].Property_Questionnaire_URL__c + preAppObj.Property_Questionnaire_URL__c + '&tfa_579=' + lstProperty[0].Campaign__c + '&tfa_581=' + campaignMemberID + '&tfa_586=' + campaignMemberLottery + '&tfa_588=' + invitedDate;
        string strSkipUnitUrl = 'https://www.tfaforms.com/413574?tfa_1='+preAppObj.PreApplicant_Encoded_Id__c+'&tfa_2='+campaignMemberID+'&tfa_3='+lstProperty[0].Name;
        string strRemoveMeFromAllUrl = preAppObj.Remove_Me_from_All_URL__c; 
            string strProfileUrl = preAppObj.Profile_URL__c; 
            
            string strDeadline = campaignMemberDeadline;


      if(lstProperty != null && lstpreApplicant != null)                                  
             wrapObj = new WrapperPropertyDetails(lstProperty[0],preAppObj,strQuestionaireUrl,strSkipUnitUrl,strRemoveMeFromAllUrl,strProfileURL,strDeadline);
          system.debug('Method is called');
      }
      catch(exception ex)
      {
        system.debug('Eception is : '+ex);
        testAttr = ex.getMessage() +' '+ex.getStacktraceString();
      }
    }
//        return null;
  }
  
  public class WrapperPropertyDetails
  {
    public HOMEtracker__Property__c property {get;set;}
    public PreApplicants__c preApplicant {get;set;}
    public string strQuestionaireUrl{get;set;}
    public string strSkipUnitUrl{get;set;}
    public string strRemoveMeFromAllUrl{get;set;}
    public string strProfileUrl{get;set;}
    public string strDeadline{get;set;}
    
    public WrapperPropertyDetails(HOMEtracker__Property__c property,PreApplicants__c preApplicant,string strQuestionaireUrl,string strSkipUnitUrl,string strRemoveMeFromAllUrl, string strProfileUrl, string strDeadline)
    {
      this.property = property;
      this.preApplicant = preApplicant;
      this.strQuestionaireUrl = strQuestionaireUrl;
      this.strSkipUnitUrl = strSkipUnitUrl;
      this.strRemoveMeFromAllUrl = strRemoveMeFromAllUrl;
      this.strProfileUrl = strProfileUrl;
      this.strDeadline = strDeadline;    
    }
  }
}