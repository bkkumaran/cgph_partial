public class extBT {
    public String showRefreshBT {get; set;}
    public String hideRefreshBT {get; set;}
    public List<Billing_Term__c> listBT {get; set;}
    public List<Billing_Term__c> listBTA {get; set;}
    public List<Billing_Term__c> listBTB {get; set;}
    public List<Billing_Term__c> listBTC {get; set;}
    public List<Billing_Term__c> listBTD {get; set;}
    public List<Billing_Term__c> listBTE {get; set;}
    public List<Billing_Term__c> listHR1 {get; set;}
    public List<Billing_Term__c> listHR2 {get; set;}
    public Billing_Term__c BTFile {get; set;}
    
    public String[] getTableA2E(){
    return new String[]{'A','B','C','D','E'};
    }
    
    public extBT(ApexPages.StandardController controller) {
    
        showRefreshBT='false';
        hideRefreshBT='true';

        listBT = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c=null)
                   ORDER BY Order_Calc__c ASC];
        listBTA = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='A')
                   ORDER BY Order_Calc__c ASC];
        listBTB = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='B')
                   ORDER BY Order_Calc__c ASC];
        listBTC = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='C')
                   ORDER BY Order_Calc__c ASC];
        listBTD = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='D')
                   ORDER BY Order_Calc__c ASC];             
        listBTE = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='E')
                   ORDER BY Order_Calc__c ASC];
        listHR1 = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='HR1')
                   ORDER BY Order_Calc__c ASC];
        listHR2 = [SELECT Id, BT_Table_Number__c, List_Order__c, Term_Category__c, Name, BTService__c, Term_Description__c, Fee_Budget_Text__c,  Fee_text__c, BT_Not_to_Exceed_Amount__c
                   FROM Billing_Term__c
                   WHERE (BT_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND BT_Exclude_from_Summary__c = false AND BT_Table_Number__c='HR2')
                   ORDER BY Order_Calc__c ASC];
    }    

    public void saveBT(){
        update listBT;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }

    public void saveBTA(){
        update listBTA;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }

    public void saveBTB(){
        update listBTB;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }

    public void saveBTC(){
        update listBTC;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }

    public void saveBTD(){
        update listBTD;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }

    public void saveBTE(){
        update listBTE;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }
    public void saveHR1(){
        update listHR1;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }
    public void saveHR2(){
        update listHR2;
        showRefreshBT = 'true';
        hideRefreshBT = 'false';
            }
                
     public pageReference save(){
         update BTFile;
         PageReference pg = new PageReference('/'+BTFile.Id);
         return pg;
    }
}