public class EdisonAHP_PropOnlyCont {
    Public Boolean isMobile {get; set;}

    Public Integer Median {get; set;}
    
    Public Integer ListPrice {get; set;}
    Public Integer Bedrooms {get; set;}
    Public Integer bedCheck {get; set;}
    Public Integer minBed {get; set;}
    Public Integer HOA {get; set;}
    Public Decimal tModIncome {get; set;}
    Public Decimal tMaxMonthlyCost {get; set;}
    Public Decimal tMonthlyCosts {get; set;}
    Public Decimal CostWithSubsidy {get; set;}
    Public Integer propEligInt {get; set;}
    
    
    Public Decimal MortgageRate {get; set;}
    Public Decimal Insurance {get; set;}
    Public Decimal PMI {get; set;}
    Public Double Calc {get; set;}
    Public Integer Subsidy {get; set;}
    
    Public Integer salePrice {get; set;}
    Public Integer dpa {get; set;}
    Public Integer Mortgage {get; set;}
    Public Integer estMonthlyCosts {get; set;}
    Public Decimal percentIncome {get; set;}
    Public Integer appEligInt {get; set;}
    
    Public Integer finalResult {get; set;}
    
    
    
    public EdisonAHP_PropOnlyCont(){
    
        //check if browser is mobile or not
        isMobile = UserInfo.getUiTheme() == 'Theme4t';

        // initialize variables
        finalResult = 0;
        salePrice = NULL;
        dpa = 15000;
        Mortgage = NULL;
        Median=NULL;
        estMonthlyCosts = NULL;
        percentIncome = NULL;
        Integer preAppIdLen = 0;
        PreApplicants__c preapp = NULL;
        propEligInt = 0;
        appEligInt =0;
        minBed = 0;
        bedCheck = 0;
        Calc = 0;

        // get List Price
        String lpParam = ApexPages.currentPage().getParameters().get('lp');
        IF(lpParam == NULL ) {
            ListPrice = 0;
            } ELSE {
            lpParam = lpParam.replaceAll('[^0-9.]', '');
            IF (lpParam == ''){
            ListPrice=0;
            } ELSE {
            ListPrice = Integer.valueOf(lpParam);
            }
            }

        // get Bedrooms
        String brParam = ApexPages.currentPage().getParameters().get('br');
        IF(brParam == NULL ) {
            Bedrooms = 0;
            } ELSE {
            brParam = brParam.replaceAll('[^0-9.]', '');
            IF (brParam == ''){
            Bedrooms =0;
            } ELSE {
            Bedrooms = Integer.valueOf(brParam);
            }
            }
            
        // get HOA
        String hoaParam = ApexPages.currentPage().getParameters().get('hoa');
        IF(hoaParam == NULL ) {
            HOA = 0;
            } ELSE {
            hoaParam  = hoaParam.replaceAll('[^0-9.]', '');
            IF (hoaParam == ''){
            HOA = 0;
            } ELSE {
            HOA = Integer.valueOf(hoaParam);
            }
            }
 
        // get subsidy value
        switch on Bedrooms {
            when 0 {
            Subsidy = 0;
            }
            when 1 {
            Subsidy = 40000;
            }
            When 2 {
            Subsidy = 130000;
            }
            when else {
            Subsidy = 150000;
            } 
        }
  
        // get 4-person median income, income limits for households, eq ratio, tax rate  for Edison
        Municipality__c EdisonIncomeLimit = [SELECT 
                                                Income_Limit__r.X4_Person__c,
                                                Income_Limit__r.HH1_Moderate__c,
                                                Income_Limit__r.HH2_Moderate__c,
                                                Income_Limit__r.HH3_Moderate__c,
                                                Income_Limit__r.HH4_Moderate__c,
                                                Income_Limit__r.HH5_Moderate__c,
                                                Income_Limit__r.HH6_Moderate__c,
                                                Income_Limit__r.HH7_Moderate__c,
                                                Income_Limit__r.HH8_Moderate__c,
                                                Equalization_Ratio__c,
                                                General_Tax_Rate__c
                                            FROM Municipality__c
                                            WHERE Name = 'Edison'
                                            LIMIT 1];
        Median = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.X4_Person__c);
        Decimal eq = EdisonIncomeLimit.Equalization_Ratio__c;
        Decimal tax = EdisonIncomeLimit.General_Tax_Rate__c;
        
        //get calculation values from custom settings
        CGPH_Profile_Custom_Settings__c cs = CGPH_Profile_Custom_Settings__c.getOrgDefaults();
        MortgageRate = cs.Mortgage_Rate__c/100;
        Insurance = cs.Insurance_4_Bedroom__c;
        PMI = cs.PMI_Rate_for_LTV_90__c;
        
        //get Theoretical highest moderate buyer's income    
        tModIncome = tModIncomeGet(Bedrooms,Median);
        
        //get Theoretical highest monthly cost allowed to be affordable by highest moderate buyer
        tMaxMonthlyCost = tMaxMonthlyCostGet(tModIncome);
        
        //get Theoretical highest moderate buyer's monthly costs for this property w/o subsidies
        tMonthlyCosts = tMonthlyCostsGet(ListPrice,HOA,eq,tax,MortgageRate,Insurance,PMI);
        
        //get reduced sale price
        salePrice = ListPrice-Subsidy;
        
        //get Theoretical highest moderate buyer's monthly costs for this property with subsidies and down payment assistance
        CostWithSubsidy = tMonthlyCostsGet(salePrice,HOA,eq,tax,MortgageRate,Insurance,PMI);
       //property eligibility determination 0, undetermined, 1, eligible, 2, too low, 3, too high
        IF(ListPrice == 0 || Bedrooms == 0){
            propEligInt = 0;
        } ELSE {
        IF(CostWithSubsidy > tMaxMonthlyCost){
            propEligInt = 3;
        } ELSE {
        IF(tMonthlyCosts < tMaxMonthlyCost){
            propEligInt = 2;
        } ELSE {
            propEligInt = 1;
        }
        }
        }
     
        //Calculate final result = 0 = not calculated, 1 = ELIGIBLE, 2 = income > mod, 3 = Property too low, 4 = property too high, 5 = hhs too big, 6 = expenses too high
        IF(ListPrice == 0 || Bedrooms == 0){
            finalResult=0;
        } ELSE {
        IF(propEligInt == 2) {
            finalResult = 3;
        } ELSE {
        IF(propEligInt == 3) {
            finalResult = 4;
        } ELSE {
        finalResult = 1;
        }
        }
        }

        
   }
        
        Public Decimal tModIncomeGet(Integer b,Integer m){
        Decimal tModIncomeSet = 0;
        switch on b {
            when 1 {
                tModIncomeSet = 0.7*((m * (0.7+0.8))/2);
            }   
            when 2 {
                tModIncomeSet = 0.7*(m * 0.9);
            }
            when 3 {
            tModIncomeSet = 0.7 * ((m * (1+1.08))/2);
            }
            when 4 {
            tModIncomeSet = 0.7*( m *1.16);
            }
            when 5 {
            tModIncomeSet = 0.7*(m *1.16);
            }
            when else {
            tModIncomeSet = 0;
            }
        }
        return tModIncomeSet;
    }
    
    Public Decimal tMaxMonthlyCostGet(Decimal x){
        Decimal tMaxMonthlyCostSet = x *0.28/12;
        return tMaxMonthlyCostSet;
    
    }
    
    Public Decimal tMonthlyCostsGet(Integer lp,Integer h,Decimal eq, Decimal tax, Decimal mort, Decimal ins, Decimal pmi){
        Decimal tMonthlyCostsSet = ((lp*0.95)*(mort/12))/(1 - math.pow(Double.valueof(1+(mort/12)),(-1*30*12)))+h+ins+(((lp*eq)/10000)*(tax/12))+((lp*0.95)/1000*(( pmi*1000 /12)));
        return tMonthlyCostsSet;
    }
   
        
}