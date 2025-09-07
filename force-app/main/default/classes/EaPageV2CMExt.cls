public class EaPageV2CMExt {
        public List<Municipality_Preference__c> getMP{get; set;}
    public List<Campaign> getCampaign {get; set;}
    public List<HOMEtracker__Property__c> getProperty {get; set;}
    public Integer countMP {get; set;}
    public String pId {get; set;}
    public String cId {get; set;}
    
    public EaPageV2CMExt(ApexPages.StandardController controller) {
        pId = apexpages.currentpage().getparameters().get('id');
        cId = apexpages.currentpage().getparameters().get('cId');
        
        getCampaign = [SELECT Id, Muni_Pref_Type_Needed__c, Date_Calculation_CM_Import__c FROM Campaign WHERE Id = :cId];
        getProperty = [SELECT Id, Municipality_Name__r.Id FROM HOMEtracker__Property__c WHERE Id = :pId];
        
        String MPType = getCampaign[0].Muni_Pref_Type_Needed__c;
        String MuniId = getProperty[0].Municipality_Name__r.Id;
        DateTime MinDate = getCampaign[0].Date_Calculation_CM_Import__c;
        
        getMp = [SELECT Id
                FROM Municipality_Preference__c
                WHERE
                Municipality__r.Id = :MuniId
                AND
                Status__c = 'Active'
                AND
                Type__c = :MPType
                AND
                LastModifiedDate > :MinDate
                ];
        countMp = getMp.size();
}
}