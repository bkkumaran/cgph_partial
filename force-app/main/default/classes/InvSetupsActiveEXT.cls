public class InvSetupsActiveEXT {
    Public List<TS_Contract__c> setupList {get; set;}
    Public Integer setupCount {get; set;}
    Public Integer setupCountAll {get; set;}
    Public Integer rowStart {get; set;}
    Public String alpha {get; set;}
    Public Integer count_A {get; set;}
    Public Integer count_B {get; set;}
    Public Integer count_C {get; set;}
    Public Integer count_D {get; set;}
    Public Integer count_E {get; set;}
    Public Integer count_F {get; set;}
    Public Integer count_G {get; set;}
    Public Integer count_H {get; set;}
    Public Integer count_I {get; set;}
    Public Integer count_J {get; set;}
    Public Integer count_K {get; set;}
    Public Integer count_L {get; set;}
    Public Integer count_M {get; set;}
    Public Integer count_N {get; set;}
    Public Integer count_O {get; set;}
    Public Integer count_P {get; set;}
    Public Integer count_Q {get; set;}
    Public Integer count_R {get; set;}
    Public Integer count_S {get; set;}
    Public Integer count_T {get; set;}
    Public Integer count_U {get; set;}
    Public Integer count_V {get; set;}
    Public Integer count_W {get; set;}
    Public Integer count_X {get; set;}
    Public Integer count_Y {get; set;}
    Public Integer count_Z {get; set;}
        
        
    public InvSetupsActiveEXT() {

        
        alpha = ApexPages.currentPage().getParameters().get('a');
        String rowStartString = ApexPages.currentPage().getParameters().get('r');
        if (rowStartString == ''){rowStartString = '0';}
        rowStart = integer.valueof(rowStartString);
        
        count_A = 0;
        count_B = 0;
        count_C = 0;
        count_D = 0;
        count_E = 0;
        count_F = 0;
        count_G = 0;
        count_H = 0;
        count_I = 0;
        count_J = 0;
        count_K = 0;
        count_L = 0;
        count_M = 0;
        count_N = 0;
        count_O = 0;
        count_P = 0;
        count_Q = 0;
        count_R = 0;
        count_S = 0;
        count_T = 0;
        count_U = 0;
        count_V = 0;
        count_W = 0;
        count_X = 0;
        count_Y = 0;
        count_Z = 0;
        
        
        Integer i = 1;
        
        setupList = [
            SELECT
                Id,
                Name,
            Name_Alpha_1__c,
                Mark_Complete__c,
                Invoicing_Status__c,
                Client_Type__c,
                Dept__c,
                Contracts_List__c,
                Invoice_List__c,
                Properties_List__c,
                Invoicing_Notes__c,
                Invoice_Message__c,
                Status_Sort__c
            
            FROM TS_Contract__c
            WHERE
                ActiveTS__c = TRUE AND
                Invoicing_Status__c != 'Not Applicable' AND
                Invoicing_Status__c != 'Invoices Completed' AND
                Name_Alpha_1__c = :alpha
            ORDER BY Name
        ];
        
        setupCount = setupList.size();
        IF(setupCount == 0) { setupList = NULL;}


        IF(setupCount > rowStart){
            while (i < rowStart){
                setupList.remove(0);
                i++;
                }
            }
        
        List<TS_Contract__c> setupListAll = [
            SELECT Id, Name_Alpha_1__c 
            FROM TS_Contract__c
            WHERE
                ActiveTS__c = TRUE AND
                Invoicing_Status__c != 'Not Applicable' AND
                Invoicing_Status__c != 'Invoices Completed'
        ];
        
        setupCountAll = setupListAll.size();
        IF(setupCountAll == 0) {
            setupListAll = NULL;
        } ELSE {
            
            //loop list to count
            for (TS_Contract__c x : setupListAll){
                IF(x.Name_Alpha_1__c == 'A') {count_A++; }
                IF(x.Name_Alpha_1__c == 'B') {count_B++; }
                IF(x.Name_Alpha_1__c == 'C') {count_C++; }
                IF(x.Name_Alpha_1__c == 'D') {count_D++; }
                IF(x.Name_Alpha_1__c == 'E') {count_E++; }
                IF(x.Name_Alpha_1__c == 'F') {count_F++; }
                IF(x.Name_Alpha_1__c == 'G') {count_G++; }
                IF(x.Name_Alpha_1__c == 'H') {count_H++; }
                IF(x.Name_Alpha_1__c == 'I') {count_I++; }
                IF(x.Name_Alpha_1__c == 'J') {count_J++; }
                IF(x.Name_Alpha_1__c == 'K') {count_K++; }
                IF(x.Name_Alpha_1__c == 'L') {count_L++; }
                IF(x.Name_Alpha_1__c == 'M') {count_M++; }
                IF(x.Name_Alpha_1__c == 'N') {count_N++; }
                IF(x.Name_Alpha_1__c == 'O') {count_O++; }
                IF(x.Name_Alpha_1__c == 'P') {count_P++; }
                IF(x.Name_Alpha_1__c == 'Q') {count_Q++; }
                IF(x.Name_Alpha_1__c == 'R') {count_R++; }
                IF(x.Name_Alpha_1__c == 'S') {count_S++; }
                IF(x.Name_Alpha_1__c == 'T') {count_T++; }
                IF(x.Name_Alpha_1__c == 'U') {count_U++; }
                IF(x.Name_Alpha_1__c == 'V') {count_V++; }
                IF(x.Name_Alpha_1__c == 'W') {count_W++; }
                IF(x.Name_Alpha_1__c == 'X') {count_X++; }
                IF(x.Name_Alpha_1__c == 'Y') {count_Y++; }
                IF(x.Name_Alpha_1__c == 'Z') {count_Z++; }
            }
            }
            
    }

    public pageReference save(){
        update setupList;
        PageReference pg = new PageReference('https://cgph--c.vf.force.com/apex/NoSlipCheckAll?r='+rowStart+'&a='+alpha+'&e=0');
        pg.setRedirect(true);
        return pg;
        
    }
    public pageReference cancel(){
        PageReference pg = new PageReference('https://cgph--c.vf.force.com/apex/NoSlipCheckAll?r='+rowStart+'&a='+alpha+'&e=0');
        pg.setRedirect(true);
        return pg;
        
    }

}