public with sharing class IncomeCalcExt {

    public String showSimple {get; set;}
    public String showYTD {get; set;}
    public String showPaystubs {get; set;}
    public String showSelect {get; set;}

    public String showSimpleB {get; set;}
    public String showYTDB {get; set;}
    public String showPaystubsB {get; set;}

    public String styleSimple {get; set;}
    public String styleYTD {get; set;}
    public String stylePaystubs {get; set;}



    public IncomeCalcExt(ApexPages.StandardController controller) {
    showSimple ='false';
    showYTD ='false';
    showPaystubs ='false';
    showSelect ='true';
    
    showSimpleB ='true';
    showYTDB ='true';
    showPaystubsB ='true';
    
    styleSimple ='inactiveB';
    styleYTD ='inactiveB';
    stylePaystubs ='inactiveB';
    }

    public void doShowSimple() {
    showSimple='true';
    showYTD='false';
    showPaystubs='false';
    showSelect='false';
    styleSimple='activeB';
    styleYTD='inactiveB';
    stylePaystubs='inactiveB';
    showSimpleB ='true';
    showYTDB ='false';
    showPaystubsB ='false';
    }  

    public void doShowYTD() {
    showSimple ='false';
    showYTD ='true';
    showPaystubs ='false';
    showSelect ='false';
    styleSimple='inactiveB';
    styleYTD='activeB';
    stylePaystubs='inactiveB';
    showSimpleB ='false';
    showYTDB ='true';
    showPaystubsB ='false';
    
    }
    public void doShowPaystubs() {
    showSimple ='false';
    showYTD ='false';
    showPaystubs ='true';
    showSelect ='false';
    styleSimple='inactiveB';
    styleYTD='inactiveB';
    stylePaystubs='activeB';
    showSimpleB ='false';
    showYTDB ='false';
    showPaystubsB ='true';
    }

    
}