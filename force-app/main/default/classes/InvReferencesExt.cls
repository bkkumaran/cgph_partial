public with sharing class InvReferencesExt {
    
    Public List<Invoice_Reference__c> listIR {get; set;}
    Public Integer listIRsize {get; set;}
    Public String InvSetupID {get; set;}
    
    public InvReferencesExt(ApexPages.StandardController controller) {
        
        InvSetupID = ApexPages.currentPage().getParameters().get('id');
        
        listIR = [
            SELECT Id, Name, Order__c, Order_Calc__c, Archive__c
            FROM Invoice_Reference__c
            WHERE Invoice_Setup__r.Id = :InvSetupID
            ORDER BY Order_Calc__c ASC
            ];
        
                listIRsize = listIR.size();

                IF (listIRsize == 0) {
            listIR = NULL;
        }        
            
    }
    public pageReference save(){
        update listIR;
        PageReference pg = new PageReference('https://cgph.lightning.force.com/lightning/r/TS_Contract__c/' + InvSetupID + '/view' );
        pg.setRedirect(true);
        return pg;
        
    }

}