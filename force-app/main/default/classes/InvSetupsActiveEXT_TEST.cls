@ISTEST
public class InvSetupsActiveEXT_TEST {
	private static testmethod void InvSetupsActiveEXT_TEST(){
        
        Account objAcct = new Account();
        objAcct.Name = 'Test';
        INSERT objAcct;
        
        TS_Contract__c objTS = new TS_Contract__c();
        objTS.Name='Test';
        objTS.Client_Type__c = 'Public';
        objTS.ActiveTS__c = true;
        objTS.Related_Account__c = objAcct.Id;
        INSERT objTS;
        
        TS_Contract__c objTS2 = new TS_Contract__c();
        objTS2.Name='Test2';
        objTS2.Client_Type__c = 'Public';
        objTS2.ActiveTS__c = true;
        objTS2.Related_Account__c = objAcct.Id;
        INSERT objTS2;
        
        TS_Contract__c objTS3 = new TS_Contract__c();
        objTS3.Name='Test3';
        objTS3.Client_Type__c = 'Public';
        objTS3.ActiveTS__c = true;
        objTS3.Related_Account__c = objAcct.Id;
        INSERT objTS3;
        
	    
        
        ApexPages.currentPage().getParameters().put('id', objTS.id);
        ApexPages.currentPage().getParameters().put('r', '1');
        ApexPages.currentPage().getParameters().put('a', 'T');
	    InvSetupsActiveEXT InvSetupsActiveEXT_TEST  = new InvSetupsActiveEXT();
        
        InvSetupsActiveEXT_TEST.cancel();
        InvSetupsActiveEXT_TEST.save();

}
}