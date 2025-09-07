public class DevTimelineCheckExt2 {
        public List<HOMEtracker__Property__c> getUnits {get; set;}
    public HOMEtracker__Property__c development {get; set;}
    public Integer countUnits {get; set;}
    
    public DevTimelineCheckExt2(PropertyInventoryController controller) {
        String devID2 = apexpages.currentpage().getparameters().get('d');
        development = [SELECT id, Name, Google_Tracker_Link__c, Rental_or_Sale_Development__c FROM HOMEtracker__Property__c WHERE id=:devID2 LIMIT 1];
    
        getUnits = [
            SELECT Id
            FROM HOMEtracker__Property__c
            WHERE Development_address__c = :development.Id AND
            HOMEtracker__Status__c != 'Not administered directly by CGP&H' AND
            HOMEtracker__Status__c != 'Sold Out of Program' AND
            Current_Outreach_Timeline__c = NULL
            ];  

        countUnits = getUnits.size();
    }

}