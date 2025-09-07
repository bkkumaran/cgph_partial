public class CGPHDevelopmentController {

    public CGPHDevelopmentController(){
        String developmentId = System.currentPageReference().getParameters().get('did');
        strDevelopmentId = developmentId;
        
        if (strDevelopmentId != null) {
            getDevelopmentInfo();
        }
    }

    public String strDevelopmentId{get;set;}
    public HOMEtracker__Property__c DevelopmentInfo{get;set;}
    public List<Property_Image__c> lstDevelopmentImage{get;set;}
    public WrapperDevelopmentInfo objWrapperDevelopmentInfo{get;set;}

    public String getCurrency(Decimal d){
        if (d != null) {
            return '$' + d.format();
        }
        return '';
    }

    public pagereference getDevelopmentInfo(){
        lstDevelopmentImage = new List<Property_Image__c>();
        DevelopmentInfo = new HOMEtracker__Property__c();
        DevelopmentInfo = [ Select Id,
                           Name,
                           HOMEtracker__Status__c,
                           Admin_by_CGP_H_Availability_Text__c,
                           Not_Admin_by_CGP_H_Availability_Text__c,
                           Rental_or_Sale_Development__c,
                           Number_of_units__c,
                           HOMEtracker__Property_Type__c,
                           Unit_Mix__c,
                           Affordability_restriction_del__c,
                           Age_Restriction__c,
                           COAH_Regions__c,
                           Municipality_Name__r.Live_Work_Preference__c,
                           Municipality_Name__r.Adopted_Optional_Veterans_Pref__c,
                           Local_Pref_Website_Text__c, 
                           HOMEtracker__Number_of_Stories__c,
                           Elevator__c,
                           HOMEtracker__YearBuilt__c,
                           Credit_Check_Required__c,
                           Background_Check_Required__c,
                           Credit_Background_Check_Fee__c,
                           Co_Signers_Allowed__c,
                           Minimum_Credit_Score_to_be_Eligible__c,
                           Utilities_Included__c,
                           Pets_allowed__c,
                           Pet_fee__c,
                           Smoking_Allowed__c,
                           Additional_Parking_Fee__c,
                           Amenities__c,
                           HOMEtracker__Interior__c,
                           Municipality_County__c,
                           Development_Location__c,
                           HOMEtracker__City__c,
                           HOMEtracker__State__c,
                           HOMEtracker__Postal_Code__c,
                           HOMEtracker__Property_Photo__c,
                           HOMEtracker__Image_URL__c,

                           Custom_Pre_app_Text__c,
                           Custom_Pre_app_Link__c,
                           Custom_Pre_app_Label__c,
                           
                           Dev_Income_Limit__r.Year__c,                           
                           Dev_Income_Limit__r.Income_Limit_Description_Text__c,
                           Dev_Income_Limit__r.X1_Person__c,
                           Dev_Income_Limit__r.X2_Person__c,
                           Dev_Income_Limit__r.X3_Person__c,
                           Dev_Income_Limit__r.X4_Person__c,
                           Dev_Income_Limit__r.X5_Person__c,
                           Dev_Income_Limit__r.X6_Person__c,
                           Dev_Income_Limit__r.X7_Person_Median__c,
                           Dev_Income_Limit__r.X8_Person_Median__c,
                           Dev_Income_Limit__r.HH1_Very_Low__c,
                           Dev_Income_Limit__r.HH2_Very_Low__c,
                           Dev_Income_Limit__r.HH3_Very_Low__c,
                           Dev_Income_Limit__r.HH4_Very_Low__c,
                           Dev_Income_Limit__r.HH5_Very_Low__c,
                           Dev_Income_Limit__r.HH6_Very_Low__c,
                           Dev_Income_Limit__r.HH7_Very_Low__c,
                           Dev_Income_Limit__r.HH8_Very_Low__c,
                           Dev_Income_Limit__r.HH1_Low__c,
                           Dev_Income_Limit__r.HH2_Low__c,
                           Dev_Income_Limit__r.HH3_Low__c,
                           Dev_Income_Limit__r.HH4_Low__c,
                           Dev_Income_Limit__r.HH5_Low__c,
                           Dev_Income_Limit__r.HH6_Low__c,
                           Dev_Income_Limit__r.HH7_Low__c,
                           Dev_Income_Limit__r.HH8_Low__c,
                           Dev_Income_Limit__r.HH1_Moderate__c,
                           Dev_Income_Limit__r.HH2_Moderate__c,
                           Dev_Income_Limit__r.HH3_Moderate__c,
                           Dev_Income_Limit__r.HH4_Moderate__c,
                           Dev_Income_Limit__r.HH5_Moderate__c,
                           Dev_Income_Limit__r.HH6_Moderate__c,
                           Dev_Income_Limit__r.HH7_Moderate__c,
                           Dev_Income_Limit__r.HH8_Moderate__c,

                           Municipality_Name__r.Id,
                           Municipality_Name__r.Name,
                           Municipality_Name__r.Local_Preference_Requirements__c,
                           Municipality_Name__r.County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                           Municipality_Name__r.County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                                                      
                           Municipality_Name__r.Down_Payment_Assistance_Cert_Text__c,
                           Municipality_Name__r.Rent_Assistance_Cert_Text__c,
                           
                           Municipality_Name__r.Income_Limit__r.Year__c,                           
                           Municipality_Name__r.Income_Limit__r.Income_Limit_Description_Text__c,
                           Municipality_Name__r.Income_Limit__r.X1_Person__c,
                           Municipality_Name__r.Income_Limit__r.X2_Person__c,
                           Municipality_Name__r.Income_Limit__r.X3_Person__c,
                           Municipality_Name__r.Income_Limit__r.X4_Person__c,
                           Municipality_Name__r.Income_Limit__r.X5_Person__c,
                           Municipality_Name__r.Income_Limit__r.X6_Person__c,
                           Municipality_Name__r.Income_Limit__r.X7_Person_Median__c,
                           Municipality_Name__r.Income_Limit__r.X8_Person_Median__c,
                           Municipality_Name__r.Income_Limit__r.HH1_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH2_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH3_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH4_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH5_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH6_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH7_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH8_Very_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH1_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH2_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH3_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH4_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH5_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH6_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH7_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH8_Low__c,
                           Municipality_Name__r.Income_Limit__r.HH1_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH2_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH3_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH4_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH5_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH6_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH7_Moderate__c,
                           Municipality_Name__r.Income_Limit__r.HH8_Moderate__c,
                           
                            (Select Name, Image_url__c From Property_Images__r order by Sorting_Sequence_Number__c )
                             FROM 
                            HOMEtracker__Property__c Where Id =: strDevelopmentId 
                            LIMIT 1
                            ];
        
        list<HOMEtracker__Property__c> lstListingInfo;
        try{
        lstListingInfo = [ SELECT Id,
                                                                Name,
                                                                HOMEtracker__List_Price__c,
                                                                HOMEtracker__Monthly_Rent__c,
                                                                HOMEtracker__Number_of_Bedrooms__c,
                                                                HOMEtracker__Number_of_Bathrooms__c,
                                                                Max_Income_Level__c
                            FROM 
                            HOMEtracker__Property__c
                            WHERE Development_address__c =: strDevelopmentId 
                            AND Property_Web_Listing__c = true
                            AND ( HOMEtracker__Status__c = 'Available For Rent'
                                 OR HOMEtracker__Status__c = 'Available for Sale/Resale')
                            ];
        } catch(Exception ex){
            lstListingInfo = null;
        }
        
        list<Property_Image__c>lstDevelopmentImage = new list<Property_Image__c>();                     
        lstDevelopmentImage = DevelopmentInfo.Property_Images__r;
        
        if (DevelopmentInfo.Admin_by_CGP_H_Availability_Text__c != null) {
            DevelopmentInfo.Admin_by_CGP_H_Availability_Text__c = JSON.serialize(DevelopmentInfo.Admin_by_CGP_H_Availability_Text__c.replace('\r\n','<br/>').replace('\n','<br/>'));
        } else {
            DevelopmentInfo.Admin_by_CGP_H_Availability_Text__c = '""';
        }
        
        if (DevelopmentInfo.Not_Admin_by_CGP_H_Availability_Text__c != null) {
            DevelopmentInfo.Not_Admin_by_CGP_H_Availability_Text__c = JSON.serialize(DevelopmentInfo.Not_Admin_by_CGP_H_Availability_Text__c.replace('\r\n','<br/>').replace('\n','<br/>'));
        } else {
            DevelopmentInfo.Not_Admin_by_CGP_H_Availability_Text__c = '""';
        }
                
        if (DevelopmentInfo.Local_Pref_Website_Text__c != null) {
            DevelopmentInfo.Local_Pref_Website_Text__c = DevelopmentInfo.Local_Pref_Website_Text__c.replace('\r\n','<br/>').replace('\n','<br/>');
        }
        
        if (DevelopmentInfo.Dev_Income_Limit__r.Income_Limit_Description_Text__c != null) {
            DevelopmentInfo.Dev_Income_Limit__r.Income_Limit_Description_Text__c = DevelopmentInfo.Dev_Income_Limit__r.Income_Limit_Description_Text__c.replace('\r\n','<br/>').replace('\n','<br/>');
        }
        
        
        switch on DevelopmentInfo.HOMEtracker__Property_Type__c {
            when 'Single-Family Home' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Single-Family Home(s)';
            }
            when 'Condominium' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Condominium(s)';
            }
            when 'Townhome' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Townhome(s)';
            }
            when 'Duplex' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Duplex(es)';
            }
            when 'Mobile or Manufactured Home' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Mobile or Manufactured Home(s)';
            }
            when 'Apartment' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Apartment(s)';
            }
            when 'Independent Living Facility Apartment' {
                DevelopmentInfo.HOMEtracker__Property_Type__c = 'Independent Living Facility Apartment(s)';
            }
        }

        if (DevelopmentInfo.COAH_Regions__c != null) {
            DevelopmentInfo.COAH_Regions__c = DevelopmentInfo.COAH_Regions__c
                .replaceAll('.+\\((.+),([^,]+)\\)', '$1, or$2');
        }
         
        if (DevelopmentInfo.Unit_Mix__c != null) {
            DevelopmentInfo.Unit_Mix__c = DevelopmentInfo.Unit_Mix__c
                .replace('studios', 'Studio')
                .replace('bedrooms', 'Bed')
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.Affordability_restriction_del__c != null) {
            DevelopmentInfo.Affordability_restriction_del__c = DevelopmentInfo.Affordability_restriction_del__c
                .replace('Very-low', 'Very Low')
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.Age_Restriction__c != null && (DevelopmentInfo.Id == 'a0J3m00001icNzM' || DevelopmentInfo.Id == 'a0J3m00001nOnwt')) {
            DevelopmentInfo.Age_Restriction__c = DevelopmentInfo.Age_Restriction__c
                .replace('55+ Exclusive', 'This is a 62+ exclusive community. All household members must be 62 years or older.')
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.Age_Restriction__c != null && (DevelopmentInfo.Id != 'a0J3m00001icNzM' || DevelopmentInfo.Id != 'a0J3m00001nOnwt')) {
            DevelopmentInfo.Age_Restriction__c = DevelopmentInfo.Age_Restriction__c
                .replace('55+ Exclusive', 'This is a 55+ exclusive community. All household members must be 55 years or older.')
                .replace('Over 18', 'This is a 55+ community. At least one household member must be 55 years or older. All other household members must be over 18 years old.')
                .replace('Over 17', 'This is a 55+ community. At least one household member must be 55 years or older. All other household members must be over 17 years old.')
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.HOMEtracker__Number_of_Stories__c != null) {
            DevelopmentInfo.HOMEtracker__Number_of_Stories__c = DevelopmentInfo.HOMEtracker__Number_of_Stories__c
                .replace('1 story', '1 Story')
                .replace('2 stories', '2 Stories')
                .replace('3 or more', '3 or More Stories')
                .replace(';Split level', '')
                .replace('Split level;', '')
                .replace('Split level', '')
                .replace(';Other', '')
                .replace('Other;', '')
                .replace('Other', '')
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.Credit_Check_Required__c != null) {
            DevelopmentInfo.Credit_Check_Required__c = DevelopmentInfo.Credit_Check_Required__c
                .replace('Yes', 'Credit Check Required')
                .replace('No', '')
                .replace('Unknown', '');
        }
        if (DevelopmentInfo.Background_Check_Required__c != null) {
            DevelopmentInfo.Background_Check_Required__c = DevelopmentInfo.Background_Check_Required__c
                .replace('Yes', 'Background Check Required')
                .replace('No', '')
                .replace('Unknown', '');
        }
        String CreditBackgroundCheckFee = this.getCurrency(DevelopmentInfo.Credit_Background_Check_Fee__c);
        if (DevelopmentInfo.Co_Signers_Allowed__c != null) {
            DevelopmentInfo.Co_Signers_Allowed__c = DevelopmentInfo.Co_Signers_Allowed__c
                .replace('Yes', 'Co-Signers Allowed')
                .replace('No', 'No Co-Signers Allowed')
                .replace('Unknown', '');
        }
        if (DevelopmentInfo.Utilities_Included__c != null) {
            DevelopmentInfo.Utilities_Included__c = DevelopmentInfo.Utilities_Included__c
                .replace('None', '')
                .replace(';', ' · ');
        } else {
            DevelopmentInfo.Utilities_Included__c = '';
        }
        if (DevelopmentInfo.Pets_allowed__c != null) {
            DevelopmentInfo.Pets_allowed__c = DevelopmentInfo.Pets_allowed__c
                .replace('Yes', '')
                .replace('No', 'No Pets Allowed');
        }
        if (DevelopmentInfo.Smoking_Allowed__c != null) {
            DevelopmentInfo.Smoking_Allowed__c = DevelopmentInfo.Smoking_Allowed__c
                .replace('Yes', '')
                .replace('No', 'No Smoking Allowed');
        }
        if (DevelopmentInfo.Amenities__c != null) {
            DevelopmentInfo.Amenities__c = DevelopmentInfo.Amenities__c
                .replace(';', ' · ');
        }
        if (DevelopmentInfo.HOMEtracker__Interior__c != null) {
            DevelopmentInfo.HOMEtracker__Interior__c = DevelopmentInfo.HOMEtracker__Interior__c
                .replace(';', ' · ');
        }

        objWrapperDevelopmentInfo = new WrapperDevelopmentInfo(DevelopmentInfo,CreditBackgroundCheckFee,lstListingInfo,lstDevelopmentImage);
        
        DevelopmentInfo = null;
        strDevelopmentId = null;
        return null;
    }
    
    //Development Full Information
    public class WrapperDevelopmentInfo{
        public HOMEtracker__Property__c development{get;set;}
        public String CreditBackgroundCheckFee{get;set;}
        public List<HOMEtracker__Property__c> lstListings{get;set;}
        public List<Property_Image__c> lstDevelopmentImg{get;set;}
        public WrapperDevelopmentInfo( HOMEtracker__Property__c development, String cbcf, List<HOMEtracker__Property__c> lstListings, List<Property_Image__c> lstDevelopmentImg)
        {
            this.development = development;
            this.CreditBackgroundCheckFee = cbcf;
            this.lstListings = lstListings;
            this.lstDevelopmentImg = lstDevelopmentImg;
        }
    }
    
    public class DevelopmentException extends Exception{}
}