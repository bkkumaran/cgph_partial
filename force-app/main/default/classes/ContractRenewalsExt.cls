public with sharing class ContractRenewalsExt {
    public List<Contract> listActivePast {get; set;}
    public List<Contract> list01 {get; set;}
    public List<Contract> list02 {get; set;}
    public List<Contract> list03 {get; set;}
    public List<Contract> list04 {get; set;}
    public List<Contract> list05 {get; set;}
    public List<Contract> list06 {get; set;}
    public List<Contract> list07 {get; set;}
    public List<Contract> list08 {get; set;}
    public List<Contract> list09 {get; set;}
    public List<Contract> list10 {get; set;}
    public List<Contract> list11 {get; set;}
    public List<Contract> list12 {get; set;}
    
    public date tDay {get; set;}
    public Integer tYear {get; set;}
    public String mt01 {get; set;}
    public String mt02 {get; set;}
    public String mt03 {get; set;}
    public String mt04 {get; set;}
    public String mt05 {get; set;}
    public String mt06 {get; set;}
    public String mt07 {get; set;}
    public String mt08 {get; set;}
    public String mt09 {get; set;}
    public String mt10 {get; set;}
    public String mt11 {get; set;}
    public String mt12 {get; set;}

    
    public ContractRenewalsExt(ApexPages.StandardController controller) {
        Integer zTest=0;
        
        listActivePast = [SELECT Id, EndDate FROM Contract
                   WHERE (Renewal_Complete__c = false) AND (Active_Past_End_Date__c= TRUE)
                   ORDER BY EndDate ASC];
        tDay = date.today();
        
        Integer earliestMonth = 1;
        
        IF (listActivePast.size() == 0) {
            tYear = System.Today().year();
            earliestMonth = System.Today().month();
            } ELSE {
            earliestMonth = listActivePast[0].EndDate.month();
            tYear = listActivePast[0].EndDate.year();
            }
            
        
        
        Integer m01 = earliestMonth;
        Integer m02 = 0;
        Integer m03 = 0;
        Integer m04 = 0;
        Integer m05 = 0;
        Integer m06 = 0;
        Integer m07 = 0;
        Integer m08 = 0;
        Integer m09 = 0;
        Integer m10 = 0;
        Integer m11 = 0;
        Integer m12 = 0;
        if (m01+1 > 12) { m02 = 13-m01;} else { m02 = m01+1; }
        if (m02+1 > 12) { m03 = 13-m02;} else { m03 = m02+1; }
        if (m03+1 > 12) { m04 = 13-m03;} else { m04 = m03+1; }
        if (m04+1 > 12) { m05 = 13-m04;} else { m05 = m04+1; }
        if (m05+1 > 12) { m06 = 13-m05;} else { m06 = m05+1; }
        if (m06+1 > 12) { m07 = 13-m06;} else { m07 = m06+1; }
        if (m07+1 > 12) { m08 = 13-m07;} else { m08 = m07+1; }
        if (m08+1 > 12) { m09 = 13-m08;} else { m09 = m08+1; }
        if (m09+1 > 12) { m10 = 13-m09;} else { m10 = m09+1; }
        if (m10+1 > 12) { m11 = 13-m10;} else { m11 = m10+1; }
        if (m11+1 > 12) { m12 = 13-m11;} else { m12 = m11+1; } 
        
        Integer my01 = 0;
        Integer my02 = 0; if (m02 < m01) my02=1;
        Integer my03 = 0; if (m03 < m01) my03=1;
        Integer my04 = 0; if (m04 < m01) my04=1;
        Integer my05 = 0; if (m05 < m01) my05=1;
        Integer my06 = 0; if (m06 < m01) my06=1;
        Integer my07 = 0; if (m07 < m01) my07=1;
        Integer my08 = 0; if (m08 < m01) my08=1;
        Integer my09 = 0; if (m09 < m01) my09=1;
        Integer my10 = 0; if (m10 < m01) my10=1;
        Integer my11 = 0; if (m11 < m01) my11=1;
        Integer my12 = 0; if (m12 < m01) my12=1;

        mt01 = monthText(m01, my01);
        mt02 = monthText(m02, my02);
        mt03 = monthText(m03, my03);
        mt04 = monthText(m04, my04);
        mt05 = monthText(m05, my05);
        mt06 = monthText(m06, my06);
        mt07 = monthText(m07, my07);
        mt08 = monthText(m08, my08);
        mt09 = monthText(m09, my09);
        mt10 = monthText(m10, my10);
        mt11 = monthText(m11, my11);
        mt12 = monthText(m12, my12);
         
        list01 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt01) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list02 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt02) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list03 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt03) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list04 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt04) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list05 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt05) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list06 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt06) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list07 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt07) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list08 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt08) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list09 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt09) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];    
        list10 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt10) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list11 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt11) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];
        list12 = [SELECT Id, Name, Contract_End_Month__c, StartDate, EndDate, Current_Billing_Status__c, Active_Past_End_Date__c, Easy_Renewal__c, Next_Contract_ID__c, Renewal_Notes__c FROM Contract
                   WHERE (Renewal_Complete__c = false) AND ((Contract_End_Month__c=: mt12) AND((Current_Billing_Status__c=:'Active Under Contract')OR(Current_Billing_Status__c=:'Active without Contract')))
                   ORDER BY EndDate ASC, Name ASC];                                                                                   
    }
    
    public String monthText (Integer num, Integer yer) {
        String textYear = String.valueOf(tYear + yer);
        String numText = String.valueOf(num);
        if (num < 10) {
            numText = '0' + numText;
        }

        if (num == 1) {return textYear + ' ' + numText + ' Jan';}
        if (num == 2) {return textYear + ' ' + numText + ' Feb';}
        if (num == 3) {return textYear + ' ' + numText + ' Mar';}
        if (num == 4) {return textYear + ' ' + numText + ' Apr';}
        if (num == 5) {return textYear + ' ' + numText + ' May';}
        if (num == 6) {return textYear + ' ' + numText + ' Jun';}
        if (num == 7) {return textYear + ' ' + numText + ' Jul';}
        if (num == 8) {return textYear + ' ' + numText + ' Aug';}
        if (num == 9) {return textYear + ' ' + numText + ' Sep';}
        if (num == 10) {return textYear + ' ' + numText + ' Oct';}
        if (num == 11) {return textYear + ' ' + numText + ' Nov';}
        if (num == 12) {return textYear + ' ' + numText + ' Dec';}

        return 'n/a';
}

    public String[] getMonths() {
        return new String[]{mt01,mt02,mt03,mt04,mt05,mt06,mt07,mt08,mt09,mt10,mt11,mt12};
            }
            
       public PageReference save() {
       update list01 ;
       update list02 ;
       update list03 ;
       update list04 ;
       update list05 ;
       update list06 ;
       update list07 ;
       update list08 ;
       update list09 ;
       update list10 ;
       update list11 ;
       update list12 ; 
      return ApexPages.CurrentPage();
    }
}