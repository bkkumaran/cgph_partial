public class EdisonAHPcontroller {
    Public Boolean isMobile {get; set;}
    
    Public String preAppId {get; set;}
    Public Integer preAppCheck {get; set;}
    Public Integer preAppInc {get; set;}
    Public Integer preAppIncInt {get; set;}
    Public Integer preAppHHS {get; set;}
    Public String preAppURL {get; set;}
    Public String preAppEmail {get; set;}
    Public String preAppName {get; set;}
    Public Integer downpayment {get; set;}
    Public Integer dpCheck {get; set;}
    Public Integer dpMin {get; set;}
    Public Integer modIncLim {get; set;}
    Public Integer Median {get; set;}
     
    Public String display {get; set;}
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
    
    
    
    public EdisonAHPcontroller (){
    
        //check if browser is mobile or not
        isMobile = UserInfo.getUiTheme() == 'Theme4t';

        // display eligibility calculations or not
        display = ApexPages.currentPage().getParameters().get('display');
/*TEMP DELETE WHEN DONE
display = 'show';
 */   
        // initialize variables
        finalResult = 0;
        preAppCheck = NULL;
        preAppInc = NULL;
        preAppIncInt = 0;
        preAppHHS = 0;
        preAppName = NULL;
        preAppEmail = NULL;
        preAppURL = NULL;
        modIncLim = 0;
        downPayment = NULL;
        salePrice = NULL;
        dpa = 15000;
        dpMin=0;
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
        dpCheck=0;
        
    
        // get pre-app info
        preAppId = ApexPages.currentPage().getParameters().get('code');
        
/*TEMP DELETE WHEN DONE
preAppId='a1CVF0000013WcH';
*/
        // pre-applicant id check: 0 = blank, 1 = id match, 2 = id not good;
        IF (preAppId == NULL) {
        preAppCheck = 0;
        } ELSE {
        preAppIdLen = preAppId.length();
        IF(preAppIdLen == 15 || preAppIdLen == 18){
            preapp = [SELECT Annual_Income__c, Household_Size__c, First_Name__c, Last_Name__c,Email__c,Profile_URL__c FROM PreApplicants__c WHERE Id =: preAppID LIMIT 1];
            preAppInc = Integer.valueOf(preApp.Annual_Income__c);
            preAppHHS = Integer.valueOf(preApp.Household_Size__c);
            preAppName = preApp.First_Name__c.left(1)+'.'+preApp.Last_Name__c.left(1)+'.' ;
            preAppEmail = preApp.Email__c;
            preAppURL = preApp.Profile_URL__c;
        preAppCheck = 1;
        
        } ELSE {
        preAppCheck = 2;
        preAppId = NULL;
        }
       
        }

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
        
        // get Down Payment Amount
        String dpParam = ApexPages.currentPage().getParameters().get('dp');
        IF(dpParam == NULL ) {
            downPayment = 0;
            } ELSE {
            dpParam = dpParam.replaceAll('[^0-9.]', '');
            IF (dpParam == ''){
            downPayment =0;
            } ELSE {
            downPayment = Integer.valueOf(dpParam);
            }
            }

            
/*TEMPORARY  
ListPrice = 300000;
Bedrooms = 3;
HOA = 200;
downPayment = 20000;
*/
      
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
        
        //get Mortgage Amount
        Mortgage = ListPrice - Subsidy - downPayment - dpa;
        
        // Down Payment Check (0 = missing data, 1 = OK, 2 = dp less than 5% of ListPrice
        IF(ListPrice == NULL || ListPrice == 0 || downpayment == NULL){
        dpCheck = 0;
        } ELSE {
        dpMin = Integer.valueOf(salePrice*0.05);
        IF(downpayment < dpMin ){
        dpCheck = 2;
        } ELSE {
        dpCheck = 1;
        }
        }
        
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
        
        IF(propEligInt == 1){
        
        //estimated monthly costs
        estMonthlyCosts = estMonthlyCostsGet(Mortgage, salePrice, MortgageRate, HOA, Insurance, eq, tax );
                
        //calculate household size / bedroom size eligibility check
        //bedCheck = 0 - nothing, 1 - eligible, 2- not eligibile
        
        /*
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH1_Moderate__c);
        */
        
        //get minimum bedroom size and relevant income limit using preApp household size
        IF(preAppHHS == 0){
        modIncLim = 0;
        minBed = 0;
        bedCheck = 0;
        }
        IF(preAppHHS == 1){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH1_Moderate__c);
        minBed = 0;
        }
        IF(preAppHHS == 2){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH2_Moderate__c);
        minBed = 0;
        }
        IF(preAppHHS == 3){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH3_Moderate__c);
        minBed = 2;
        }
        IF(preAppHHS == 4){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH4_Moderate__c);
        minBed = 2;
        }
        IF(preAppHHS == 5){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH5_Moderate__c);
        minBed = 3;
        }
        IF(preAppHHS == 6){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH6_Moderate__c);
        minBed = 3;
        }
        IF(preAppHHS == 7){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH7_Moderate__c);
        minBed = 4;
        }
        IF(preAppHHS == 8){
        modIncLim = Integer.valueOf(EdisonIncomeLimit.Income_Limit__r.HH8_Moderate__c);
        minBed = 4;
        }
        
        // check income and income limit
        IF(preAppInc > modIncLim ){
        preAppIncInt = 2;
        } ELSE {
        preAppIncInt = 1;
        }
        
        // check bedrooms and household size
        IF(Bedrooms >= minBed){
        bedCheck = 1;
        } ELSE {
        bedCheck =2;
        }
        
        //estimated monthly costs as percent of income
        percentIncome = (Decimal.valueOf(estMonthlyCosts))/(Decimal.valueOf(preAppInc)/12) ;
        }

        //applicant income eligibility determination = 0,nothing, 1, eligible, 2 not eligibile
        
        IF(ListPrice == 0 || Bedrooms == 0){
            appEligInt=0;
        } ELSE {
        IF(percentIncome > 0.33) {
            appEligInt = 2; 
        } ELSE {
            appEligInt = 1; 
        }
        }
        
        //Calculate final result = 0 = not calculated, 1 = ELIGIBLE, 2 = income > mod, 3 = Property too low, 4 = property too high, 5 = hhs too big, 6 = expenses too high
        IF (preAppIncInt == 0 && propEligInt == 0 && bedCheck == 0 && appEligInt == 0){
        finalResult=0;
        } ELSE {        
        IF(preAppIncInt == 2) {
            finalResult = 2;
        } ELSE {
        IF(propEligInt == 2) {
            finalResult = 3;
        } ELSE {
        IF(propEligInt == 3) {
            finalResult = 4;
        } ELSE {
        IF(bedCheck == 2) {
            finalResult = 5;
        } ELSE {
        IF(bedCheck == 2) {
            finalResult = 5;
        } ELSE {
        IF(appEligInt== 2) {
            finalResult = 6;
        } ELSE {
        finalResult = 1;
        }
        }
        }
        }
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
    
    Public Integer estMonthlyCostsGet(Integer Mortgage, Integer salePrice,Decimal MortgageRate,Integer HOA,Decimal Insurance, Decimal eq, Decimal tax){
        Integer estMonthlyCostsSet = 0;
        Decimal costCalc = 0;
        IF( Mortgage/salePrice>0.9501) {
            costCalc = Mortgage*0.009/12;
        } ELSE {
        IF( Mortgage/salePrice>0.9001) {
            costCalc = Mortgage*0.0078/12;
        } ELSE {
        IF( Mortgage/salePrice>0.8501) {
            costCalc = Mortgage*0.0052/12;
        } ELSE {
        IF( Mortgage/salePrice>0.8001) {
            costCalc = Mortgage*0.0032/12;
        } ELSE {
          costCalc = 0;  
        }    
        }    
        }    
        }
        estMonthlyCostsSet = Integer.valueOf(     ((Mortgage)*(MortgageRate/12))/(1 - math.pow(Double.valueof(1+(MortgageRate/12)),(-1*30*12)))+HOA+Insurance+((salePrice * eq/100 * tax/100 )/12)+costCalc     );
        return estMonthlyCostsSet;
    }

        
}