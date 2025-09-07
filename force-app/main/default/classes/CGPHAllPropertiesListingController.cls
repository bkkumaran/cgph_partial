public without sharing class CGPHAllPropertiesListingController 
{
        
    //public map<string,string> mapMunicipalityCounty { get;set; }
    public map<string,Municipality__c> mapAllMunicipalitiesRental {get;set;}
    public map<string,Municipality__c> mapAllMunicipalitiesPurchase {get;set;}
    public List<WrapperRentalProperties> lstWrapperRentalProperties{get;set;}
    public List<WrapperPurchaseProperties> lstWrapperPurchaseProperties{get;set;}
    private CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings{get;set;}
    public String lType {get;set;}
    public String lid {get;set;}
    
    public string helpContent {get;set;}
    //method to show rental properties
    public CGPHAllPropertiesListingController(){
        getHelpContent();
        lType = System.currentPageReference().getParameters().get('ltype');
        if ( String.isBlank(lType) ) {
            lType = 'ownership';
        }
        lid = System.currentPageReference().getParameters().get('lid');
    }
    public map<String,List<WrapperRentalProperties>> getRentalProperties()
    {
        boolean b_ShowForm = true;
        set<string> setRentalStatus = new set<string>{'Available For Rent'};
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ;
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Rental Unit').getRecordTypeId();
    //  mapMunicipalityCounty = new map<string,string>();
        lstWrapperRentalProperties = new list<WrapperRentalProperties>();
        list<HOMEtracker__Property__c> lstRentalProperty = new list<HOMEtracker__Property__c>();
        mapAllMunicipalitiesRental = new map<string,Municipality__c>();
        
        map<Id,WrapperRentalProperties> mapWrapperRentalProperty = new map<Id,WrapperRentalProperties>();
        map<String,List<WrapperRentalProperties>> mapOfMunicipalProperty = new map<String,List<WrapperRentalProperties>>();
        try{
             list<WrapperRentalProperties> lstWrapRentProperty = new list<WrapperRentalProperties>();
            for(Municipality__c municipality : [SELECT id,Name,County__c,Rental_Waiting_List__c,(
                Select Id, Name,
                CreatedDate, Status_Message__c,Municipality_Name__r.Rental_Waiting_List__c,
                Maximum_Household_Size__c,  Min_Household_Size__c,HOMEtracker__Status__c,RecordTypeId, 
                Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c,
                Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                Rental_Assistance_Permitted__c, Listing_Stage__c,Property_Web_Listing__c,
                Utilities__c, HOMEtracker__Property_Description__c,HOMEtracker__List_Price__c ,
                Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, Development_address__r.Age_Restriction__c,
                HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c,HOMEtracker__Date_Listed__c,Development_address__c,
                Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c
                FROM
                Properties__r
            ) FROM Municipality__c])
                    {
                        if(municipality.Properties__r != null && municipality.Properties__r.size() > 0)
                        {
                            for(HOMEtracker__Property__c property : municipality.Properties__r)
                            {
                                system.debug('setRentalStatus.contains(property.HOMEtracker__Status__c) '+setRentalStatus.contains(property.HOMEtracker__Status__c));
                                system.debug('property = > '+property);
                                system.debug('property.RecordTypeId '+property.RecordTypeId+' strRentalPropertyRecTypeId => '+strRentalPropertyRecTypeId+' property.Property_Web_Listing__c '+property.Property_Web_Listing__c);
                                if(property.Property_Web_Listing__c == true && property.RecordTypeId == strRentalPropertyRecTypeId && setRentalStatus.contains(property.HOMEtracker__Status__c) )//&& property.Listing_Type__c == 'Public')
                                {
                                    system.debug('Municipality Name ==> '+property.Municipality_Name__r.Name);
                                    system.debug('Property name => '+property.name);
                                    if(mapOfMunicipalProperty.containsKey(property.Municipality_Name__r.Name) == true){
                                        lstWrapRentProperty = new list<WrapperRentalProperties>();
                                        lstWrapRentProperty = mapOfMunicipalProperty.get(property.Municipality_Name__r.Name);
                                        lstWrapRentProperty.add(new WrapperRentalProperties(property, true));
                                        mapOfMunicipalProperty.put(property.Municipality_Name__r.Name,lstWrapRentProperty);
                                        mapAllMunicipalitiesRental.put(property.Municipality_Name__r.Name,property.Municipality_Name__r);
                                    }else{
                                        lstWrapRentProperty = new list<WrapperRentalProperties>();
                                        lstWrapRentProperty.add(new WrapperRentalProperties(property, true));
                                        mapOfMunicipalProperty.put(property.Municipality_Name__r.Name,lstWrapRentProperty);
                                        mapAllMunicipalitiesRental.put(property.Municipality_Name__r.Name,property.Municipality_Name__r);
                                    }
                                }
                                
                            }
                    }
                    else{
                        // add municipalities which don't have related properties
                        lstWrapRentProperty = new list<WrapperRentalProperties>();
                    }
                    }
                    
                    system.debug(logginglevel.error,'::mapOfMunicipalProperty::'+mapOfMunicipalProperty);
                    
                    //system.debug(logginglevel.error,'=======> Map of municipality counties: '+mapMunicipalityCounty);
                
            
        }
        catch(PropertyException ex){
            b_ShowForm = false;
            system.debug('b_ShowForm::b_ShowForm::'+b_ShowForm);
            system.debug(logginglevel.error,'::Exception::'+ex+'::b_ShowForm::'+b_ShowForm+'::ex.getMessage()::'+ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please provide property Income Level/Region Info'));
            
        }catch(Exception ex){
            system.debug(logginglevel.error,'::Exception::'+ex);
            system.debug('::Exception::'+ex.getMessage());
        }
        return mapOfMunicipalProperty;
    }
    
    
    
    // get purchase properties
    public map<String,List<WrapperPurchaseProperties>> getPurchaseProperties()
    {
        system.debug('=============================Purchase list debug =======================');
        boolean b_ShowForm = true;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        set<string> setPurchaseStatus = new set<string>{'Available for Sale/Resale'};
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        string strRentalPropertyRecTypeId = PropertiesRecordTypeInfo.get('Homeownership').getRecordTypeId();
    //  mapMunicipalityCounty = new map<string,string>();
        lstWrapperRentalProperties = new list<WrapperRentalProperties>();
        list<HOMEtracker__Property__c> lstRentalProperty = new list<HOMEtracker__Property__c>();
        mapAllMunicipalitiesPurchase = new map<string,Municipality__c>();
        map<Id,WrapperPurchaseProperties> mapWrapperPurchaseProperty = new map<Id,WrapperPurchaseProperties>();
        map<String,List<WrapperPurchaseProperties>> mapOfMunicipalProperty = new map<String,List<WrapperPurchaseProperties>>();
        try{
            list<WrapperPurchaseProperties> lstWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
            for(Municipality__c municipality : [SELECT id,Name,County__c,Rental_Waiting_List__c,(
                Select Id, Name,HOMEtracker__Status__c, 
                CreatedDate, Status_Message__c,Municipality_Name__r.Rental_Waiting_List__c,
                Maximum_Household_Size__c,  Min_Household_Size__c,RecordTypeId,
                Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c,
                Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                Rental_Assistance_Permitted__c, Listing_Stage__c,Property_Web_Listing__c,
                Utilities__c, HOMEtracker__Property_Description__c,HOMEtracker__List_Price__c ,
                Development_address__r.Name, HOMEtracker__Number_of_Bedrooms__c, Development_address__r.Age_Restriction__c,
                HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c,Listing_Type__c ,HOMEtracker__Date_Listed__c,Development_address__c,
                Property_Map__c,HOMEtracker__City__c, HOMEtracker__County__c ,Municipality_Name__r.County__c
                FROM
                Properties__r
            ) FROM Municipality__c])
                    {
                        if(municipality.Properties__r != null && municipality.Properties__r.size() > 0){
                            for(HOMEtracker__Property__c property : municipality.Properties__r){
                                if(property.Property_Web_Listing__c == true && property.RecordTypeId == strRentalPropertyRecTypeId && setPurchaseStatus.contains(property.HOMEtracker__Status__c)){
                                    if(mapOfMunicipalProperty.containsKey(property.Municipality_Name__r.Name) == true){
                                        lstWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
                                        lstWrapPurchaseProperty = mapOfMunicipalProperty.get(property.Municipality_Name__r.Name);
                                        lstWrapPurchaseProperty.add(new WrapperPurchaseProperties(property, true));
                                        mapOfMunicipalProperty.put(property.Municipality_Name__r.Name,lstWrapPurchaseProperty);
                                        mapAllMunicipalitiesPurchase.put(property.Municipality_Name__r.Name,property.Municipality_Name__r);
                                    }else{
                                        lstWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
                                        lstWrapPurchaseProperty.add(new WrapperPurchaseProperties(property, true));
                                        mapOfMunicipalProperty.put(property.Municipality_Name__r.Name,lstWrapPurchaseProperty);
                                        mapAllMunicipalitiesPurchase.put(property.Municipality_Name__r.Name,property.Municipality_Name__r);
                                    }
                                }
                                
                            }
                    }else {
                        // add municipalities which don't properties
                        lstWrapPurchaseProperty = new list<WrapperPurchaseProperties>();
                    }
                    }
                    
                    system.debug(logginglevel.error,'::mapOfMunicipalProperty::'+mapOfMunicipalProperty);
                    
                    //system.debug(logginglevel.error,'=======> Map of municipality counties: '+mapMunicipalityCounty);
                
            
        }
        catch(PropertyException ex){
            b_ShowForm = false;
            system.debug('b_ShowForm::b_ShowForm::'+b_ShowForm);
            system.debug(logginglevel.error,'::Exception::'+ex+'::b_ShowForm::'+b_ShowForm+'::ex.getMessage()::'+ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please provide property Income Level/Region Info'));
            
        }catch(Exception ex){
            system.debug(logginglevel.error,'::Exception::'+ex);
            system.debug('::Exception::'+ex.getMessage());
        }
        
        system.debug(' == mapAllMunicipalitiesPurchase '+mapAllMunicipalitiesPurchase);
        system.debug(' == mapOfMunicipalProperty '+mapOfMunicipalProperty);
        return mapOfMunicipalProperty;
    }
    
    
    
    //get Property Full Information
    public String strPropertyId{get;set;}
    public HOMEtracker__Property__c PropertyInfo{get;set;}
    public List<Property_Image__c> lstPropertyImage{get;set;}
    public WrapperPropertyInfo objWrapperPropertyInfo{get;set;}
    public pagereference getPropertyInfo(){
        lstPropertyImage = new List<Property_Image__c>();
        PropertyInfo = new HOMEtracker__Property__c();
        String strQuestionaireUrl;
        PropertyInfo = [ Select Id, Name, Municipality_Name__r.Rental_Waiting_List__c,X5_Down_Payment_Approximate__c ,
                            CreatedDate, Status_Message__c, HOMEtracker__List_Price__c ,Required_Deposit__c ,
                            Maximum_Household_Size__c,  Min_Household_Size__c,Multi_level_unit__c ,Development_address__r.Development_Financing_Requirements__c , 
                            Age_Restriction__c, Municipality_Name__r.Rental_Permanent_Disability_AR_Exception__c, 
                            Municipality_Name__r.Name, Municipality_Name__r.Region__c, Max_Income_Level__c,
                            Rental_Assistance_Permitted__c, Approximate_Annual_Property_Taxes__c ,
                            Utilities__c, HOMEtracker__Property_Description__c,
                            HOMEtracker__Number_of_Bedrooms__c, HOMEtracker__Current_HOA_Condo_Fees__c ,
                            HOMEtracker__Number_of_Bathrooms__c, HOMEtracker__Monthly_Rent__c, 
                            Credit_Check_Required__c, Background_Check_Required__c,
                            Minimum_Credit_Score_to_be_Eligible__c, Co_Signers_Allowed__c,
                            Credit_Background_Check_Fee__c, Credit_Background_Check_Fee_Notes__c,
                            Pet_fee__c, Pet_Policy__c, Pets_allowed__c, 
                            Type_of_Free_Parking__c, Parking_Spaces_at_No_Additional_Charge__c, Additional_Parking_Fee__c,  
                            HOMEtracker__Accessibility_Features__c, HOMEtracker__Description_of_Accessibility_Features__c,
                            HOMEtracker__Property_Type__c, Floor_unit_is_located_on__c,
                            Elevator__c, Smoking_Allowed__c, Amenities__c, Seller_Listing_Instructions__c ,
                            HOMEtracker__Interior__c, HOMEtracker__Exterior__c,Development_address__r.Seller_Listing_Instructions__c,
                            Utilities_Included__c, X3x_Rent_Requirement__c,Municipality_Name__r.County__c,
                            RecordType.Name, Property_Questionnaire_URL__c,Development_address__r.Required_Deposit__c,Development_address__r.Multi_level_unit__c, 
                            Property_Map__c, HOMEtracker__County__c,HOMEtracker__City__c,Development_address__r.Age_Restriction__c ,
                            Development_address__c,Development_address__r.Name,Development_address__r.HOMEtracker__Property_Type__c,Development_address__r.Elevator__c,Development_address__r.Utilities_Included__c,
                            Development_address__r.Credit_Check_Required__c,Development_address__r.Background_Check_Required__c,Development_address__r.Minimum_Credit_Score_to_be_Eligible__c,
                            Development_address__r.Co_Signers_Allowed__c,Development_address__r.Credit_Background_Check_Fee__c,Development_address__r.Credit_Background_Check_Fee_Notes__c,Development_address__r.Pets_allowed__c,
                            Development_address__r.Pet_Policy__c,Development_address__r.Pet_fee__c,Development_address__r.Smoking_Allowed__c,Development_address__r.Amenities__c,Development_address__r.X3x_Rent_Requirement__c,
                            Municipality_Name__r.County_Lookup__r.County_Down_Payment_Assistance_Cert_Text__c,
                                            Municipality_Name__r.County_Lookup__r.County_Rent_Assistance_Cert_Text__c,
                                            Municipality_Name__r.Down_Payment_Assistance_Cert_Text__c,
                                            Municipality_Name__r.Rent_Assistance_Cert_Text__c,                              
                             (Select Name, Image_url__c From Property_Images__r order by Sorting_Sequence_Number__c )
                             FROM 
                            HOMEtracker__Property__c Where Id =: strPropertyId 
                            LIMIT 1
                            ];
       list<Property_Image__c>lstPropertyImage = new list<Property_Image__c>();                     
       lstPropertyImage = PropertyInfo.Property_Images__r;//[Select Id, Name, Image_url__c From Property_Image__c Where Property__c =: strPropertyId order by Sorting_Sequence_Number__c];
               
       objWrapperPropertyInfo = new WrapperPropertyInfo(PropertyInfo,lstPropertyImage);
      
        PropertyInfo = null;
        strPropertyId = null;
        strQuestionaireUrl = null;
        return null;
    }
    
    // method to get the help content in json format
    
    public string getHelpContent()
    { 
        system.debug('Help Content is called' );
        string endPoint = '?json=get_page&id=5129';
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
                    parser.nextToken();
                    helpContent = parser.getText();
                    System.debug('Help Content='+helpContent);
                }
            }   
        }
        catch(Exception ex){
            system.debug('Exception is : '+ex);
        }
        
        }
        return helpContent;
        
    }
    
    
    //Rental Properties
    public class WrapperRentalProperties{
        public HOMEtracker__Property__c property{get;set;}
        public Boolean b_IsEligible{get;set;}
        
        public WrapperRentalProperties(HOMEtracker__Property__c property, Boolean b_IsEligible){
            this.property = property;
            this.b_IsEligible = b_IsEligible;
        }
        
    }
    
    
    //HomwOwnership Properties
    public class WrapperPurchaseProperties{
        public HOMEtracker__Property__c property{get;set;}
        public Boolean b_IsEligible{get;set;}
        
        public WrapperPurchaseProperties(HOMEtracker__Property__c property, Boolean b_IsEligible){
            this.property = property;
            this.b_IsEligible = b_IsEligible;
        }
        
    }
    
    //Property Full Information
    public class WrapperPropertyInfo{
        public HOMEtracker__Property__c property{get;set;}
        public List<Property_Image__c> lstPropertyImg{get;set;}
        public String strQuestionaireUrl{get;set;}
        public list<Application__c> lstPreliminarySubmission{get;set;}
        public WrapperPropertyInfo( HOMEtracker__Property__c property, List<Property_Image__c> lstPropertyImg)
        {
            this.property = property;
            this.lstPropertyImg = lstPropertyImg;
        }
    }
    
    public class PropertyException extends Exception{}
}