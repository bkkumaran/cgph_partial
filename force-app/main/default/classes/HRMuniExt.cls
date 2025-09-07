public class HRMuniExt {
    public String over {get; set;}
    public List<Municipality__c> listMunis {get; set;}
    
    public user cUser {get; set;}
    public String userName {get; set;}
    public String displayName {get; set;}
    public Integer listMunisCount {get; set;}
    public List<String> allList {get; set;}
    
   
    public HRMuniExt(ApexPages.StandardController controller) {
        
        over = apexpages.currentpage().getparameters().get('name');
        cUser = new User();
        cUser=[SELECT Id, FirstName, LastName FROM User WHERE Id=:userinfo.getuserId()];
        displayName = cUser.LastName;        
        
        IF(over == null){userName = cUser.LastName;}
        ELSE {userName = over; displayName = over;}
        listMunis = [SELECT Id, HR_PName_Calc__c, Name, HR_FormAssembly_Code__c, HR_Program_Website_Link__c, HR_Active_Applicant_Pool__c FROM Municipality__c WHERE HR_Active_Program__c = true AND HR_Program_Coordinator__r.LastName = :userName ORDER BY Name];
        listMunisCount = listMunis.size();
        IF(listMunisCount == 0){
        listMunis = [SELECT Id, HR_PName_Calc__c, Name, HR_FormAssembly_Code__c, HR_Program_Website_Link__c, HR_Active_Applicant_Pool__c FROM Municipality__c WHERE HR_Active_Program__c = true ORDER BY Name];
        listMunisCount = listMunis.size();
        displayName = 'All';        
        }
        
        
        List<String> muniIds = new String[50];
        Integer idCount = 0;
        String MunID ='0';
        
        do{
            Municipality__c listMunisSingle = listMunis.get(idCount);
            MunId = listMunisSingle.Id ;
            muniIds.add(idCount,MunId);
            idCount++;
        } while (idCount < listMunisCount);
        
        allList = muniIds;
        
    }
    
}