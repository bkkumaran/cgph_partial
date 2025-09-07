public class DevTimelineCheckExt {
    public List<HOMEtracker__Property__c> getUnits {get; set;}
    public HOMEtracker__Property__c property {get; set;}
    public Integer countUnits {get; set;}
    
    public DevTimelineCheckExt(ApexPages.StandardController controller) {
        property = (HOMETracker__Property__c )controller.getRecord();
    
        getUnits = [
            SELECT Id
            FROM HOMEtracker__Property__c
            WHERE Development_address__c = :property.Id AND
            HOMEtracker__Status__c != 'Not administered directly by CGP&H' AND
            HOMEtracker__Status__c != 'Sold Out of Program' AND
            Current_Outreach_Timeline__c = NULL
            ];  

        countUnits = getUnits.size();
    }

}