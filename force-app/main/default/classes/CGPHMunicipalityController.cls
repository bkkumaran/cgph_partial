public class CGPHMunicipalityController {

    public CGPHMunicipalityController(){

        String municipalityId = System.currentPageReference().getParameters().get('mid');
        strMunicipalityId = municipalityId;
        
        if (strMunicipalityId != null) {
            getMunicipalityInfo();
        }
    }
    
    public String strMunicipalityId{get;set;}
    public List<HOMEtracker__Property__c> lstDevelopmentInfo{get;set;}
    public List<HOMEtracker__Property__c> lstDevelopmentNAInfo{get;set;}
    public Municipality__c municipalityInfo{get;set;}
    public WrapperMunicipalityInfo objWrapperMunicipalityInfo{get;set;}

    public String getCurrency(Decimal d){
        if (d != null) {
            return '$' + d.format();
        }
        return '';
    }

    public pagereference getMunicipalityInfo(){
        municipalityInfo = [ Select
                           Id,
                           Name,
                           Municipal_Type__c,
                           Live_Work_Preference__c,
                           Adopted_Optional_Veterans_Pref__c,
                           County_Lookup__r.Name,
                           County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                           County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                           
                           Down_Payment_Assistance_Cert_Text__c,
                           Rent_Assistance_Cert_Text__c,
                           CGP_H_M_Availability_Text__c,
                           
                           Income_Limit__r.Year__c,
                           Income_Limit__r.Income_Limit_Description_Text__c,
                           Income_Limit__r.X1_Person__c,
                           Income_Limit__r.X2_Person__c,
                           Income_Limit__r.X3_Person__c,
                           Income_Limit__r.X4_Person__c,
                           Income_Limit__r.X5_Person__c,
                           Income_Limit__r.X6_Person__c,
                           Income_Limit__r.X7_Person_Median__c,
                           Income_Limit__r.X8_Person_Median__c,
                           Income_Limit__r.HH1_Very_Low__c,
                           Income_Limit__r.HH2_Very_Low__c,
                           Income_Limit__r.HH3_Very_Low__c,
                           Income_Limit__r.HH4_Very_Low__c,
                           Income_Limit__r.HH5_Very_Low__c,
                           Income_Limit__r.HH6_Very_Low__c,
                           Income_Limit__r.HH7_Very_Low__c,
                           Income_Limit__r.HH8_Very_Low__c,
                           Income_Limit__r.HH1_Low__c,
                           Income_Limit__r.HH2_Low__c,
                           Income_Limit__r.HH3_Low__c,
                           Income_Limit__r.HH4_Low__c,
                           Income_Limit__r.HH5_Low__c,
                           Income_Limit__r.HH6_Low__c,
                           Income_Limit__r.HH7_Low__c,
                           Income_Limit__r.HH8_Low__c,
                           Income_Limit__r.HH1_Moderate__c,
                           Income_Limit__r.HH2_Moderate__c,
                           Income_Limit__r.HH3_Moderate__c,
                           Income_Limit__r.HH4_Moderate__c,
                           Income_Limit__r.HH5_Moderate__c,
                           Income_Limit__r.HH6_Moderate__c,
                           Income_Limit__r.HH7_Moderate__c,
                           Income_Limit__r.HH8_Moderate__c
                            
                            
                            FROM Municipality__c
                            Where Id =: strMunicipalityId
                            ];
        
        List<HOMEtracker__Property__c> lstAllDevelopmentInfo = [ Select 
                           Id,
                           Name,
                           HOMEtracker__Status__c,
                           Admin_by_CGP_H_Availability_Text__c,
                           Not_Admin_by_CGP_H_Availability_Text__c,
                           Local_Pref_Website_Text__c,
                           Rental_or_Sale_Development__c,
                           Number_of_units__c,
                           HOMEtracker__Property_Type__c,
                           Unit_Mix__c,
                           Affordability_restriction_del__c,
                           Age_Restriction__c,
                           HOMEtracker__Number_of_Stories__c,
                           Elevator__c,
                           HOMEtracker__YearBuilt__c,
                           Credit_Check_Required__c,
                           Background_Check_Required__c,
                           Credit_Background_Check_Fee__c,
                           Co_Signers_Allowed__c,
                           Minimum_Credit_Score_to_be_Eligible__c,
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
                           HOMEtracker__Image_URL__c

                             FROM 
                            HOMEtracker__Property__c Where Municipality_Name__r.Id =: strMunicipalityId AND
                            Development_address__c = null AND
                            Devel_Visible_on_Website__c = TRUE AND
                            Municipality_Name__r.Muni_Visible_on_Website__c = TRUE
                            ];
        
        list<HOMEtracker__Property__c> lstListingInfo;
        try{
            lstListingInfo = [ SELECT Id,
                                                                Name,
                                                                HOMEtracker__List_Price__c,
                                                                HOMEtracker__Monthly_Rent__c,
                                                                HOMEtracker__Number_of_Bedrooms__c,
                                                                HOMEtracker__Number_of_Bathrooms__c,
                                                                Max_Income_Level__c,
                                                                HOMEtracker__Status__c,
                                                                Development_address__r.Name,
                                                                Development_address__r.Rental_or_Sale_Development__c
                            FROM 
                            HOMEtracker__Property__c
                            WHERE Municipality_Name__r.Id =: strMunicipalityId 
                            AND Property_Web_Listing__c = true
                            AND ( HOMEtracker__Status__c = 'Available For Rent'
                                 OR HOMEtracker__Status__c = 'Available for Sale/Resale')
                            ];
        } catch(Exception ex){
            lstListingInfo = null;
        }
        
        if (municipalityInfo.CGP_H_M_Availability_Text__c != null) {
            municipalityInfo.CGP_H_M_Availability_Text__c = municipalityInfo.CGP_H_M_Availability_Text__c.replace('\r\n','<br/>').replace('\n','<br/>');
        }
        
        if (municipalityInfo.Income_Limit__r.Income_Limit_Description_Text__c != null) {
            municipalityInfo.Income_Limit__r.Income_Limit_Description_Text__c = municipalityInfo.Income_Limit__r.Income_Limit_Description_Text__c.replace('\r\n','<br/>').replace('\n','<br/>');
        }

        lstDevelopmentInfo = new List<HOMEtracker__Property__c>();
        lstDevelopmentNAInfo = new List<HOMEtracker__Property__c>();
        
        for (HOMEtracker__Property__c DevelopmentInfo : lstAllDevelopmentInfo) {
            
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
            if (DevelopmentInfo.Age_Restriction__c != null && DevelopmentInfo.Age_Restriction__c != 'None') {
                DevelopmentInfo.Age_Restriction__c = 'Age-Restricted';
            } else {
                DevelopmentInfo.Age_Restriction__c = null;
            }

            if (DevelopmentInfo.HOMEtracker__Status__c == 'Not administered directly by CGP&H') {
                lstDevelopmentNAInfo.add(DevelopmentInfo);
            } else {
                lstDevelopmentInfo.add(DevelopmentInfo);
            }
        }
               
        objWrapperMunicipalityInfo = new WrapperMunicipalityInfo(municipalityInfo,lstDevelopmentInfo,lstDevelopmentNAInfo,lstListingInfo);
        
        municipalityInfo = null;
        strMunicipalityId = null;
        return null;
    }
    
    //Municipality Full Information
    public class WrapperMunicipalityInfo{
        public Municipality__c municipality{get;set;}
        public List<HOMEtracker__Property__c> lstDevelopmentInfo{get;set;}
        public List<HOMEtracker__Property__c> lstDevelopmentNAInfo{get;set;}
        public List<HOMEtracker__Property__c> lstListings{get;set;}
        public WrapperMunicipalityInfo( Municipality__c municipality, List<HOMEtracker__Property__c> lstDevelopmentInfo, List<HOMEtracker__Property__c> lstDevelopmentNAInfo, List<HOMEtracker__Property__c> lstListings)
        {
            this.municipality = municipality;
            this.lstDevelopmentInfo = lstDevelopmentInfo;
            this.lstDevelopmentNAInfo = lstDevelopmentNAInfo;
            this.lstListings = lstListings;
        }
    }
    
    public class MunicipalityException extends Exception{}
}