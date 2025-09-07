public class PropertyInventoryController_L {
    Public HOMETracker__Property__c dev {get; set;}
    Public String devID {get; set;}
    Public List<HOMETracker__Property__c> unitList {get; set;}
    
    public PropertyInventoryController_L (){
        devID= apexpages.currentpage().getparameters().get('d');
        dev= [SELECT id, Name, Google_Tracker_Link__c, Rental_or_Sale_Development__c FROM HOMEtracker__Property__c WHERE id=:devID LIMIT 1];

        unitList = [
            SELECT
                Id,
                Name,
                HOMEtracker__Status__c,
                Rental_or_Sale_Development__c,
                Outreach_Stage__c,
                Listing_Stage__c,
                Unit_Number__c,
                HOMEtracker__Monthly_Rent__c,
                HOMEtracker__Purchase_Price__c,
                HOMEtracker__List_Price__c,
                HOMEtracker__Current_HOA_Condo_Fees__c,
                Group_Property_Parent__r.HOMEtracker__Current_HOA_Condo_Fees__c,
                Group_Property_Parent__r.HOMEtracker__Purchase_Price__c,
                Group_Property_Parent__r.HOMEtracker__List_Price__c,
                Group_Property_Parent__r.HOMEtracker__Monthly_Rent__c,
                Group_Property_Parent__r.Income_Level__c,
                Group_Property_Parent__r.HOMEtracker__Number_of_Bedrooms__c,
                Group_Property_Parent__r.Bedroom_Count__c,
                Publish_Outreach_Tracker__c,
                Publish_Property_Inventory__c,
                Income_Level__c,
                HOMEtracker__Number_of_Bedrooms__c,
                Bedroom_Count__c,
                Floor_unit_is_located_on__c,
                Date_unit_will_be_availalbe__c,
                Target_Cert_Date_Order__c,
                Current_Lease_Date__c,
                Include_on_Tracker__c,
                Group_Property_Parent__c,
                Group_Property__c,
                Outreach_Timelines_Count__c,
                Landlord_Developer_Approval_Target__c,
                Inventory_Sort__c,
                Building_Number__c,
                Initial_Leaseup_Sale_Phase__c,
                Current_renter__r.Name,
                HOMEtracker__Owner__r.Name,
                HOMEtracker__Current_Owner_Service_File__r.Id,
                HOMEtracker__Current_Owner_Service_File__r.Current_Lease__r.Lease_Begin__c,
                HOMEtracker__Current_Owner_Service_File__r.Current_Lease__r.Lease_end_Date__c ,
                HOMEtracker__Current_Owner_Service_File__r.Current_Lease__r.Lease_Image_URL__c,
                HOMEtracker__Current_Owner_Service_File__r.Current_Lease__r.Lease_PDF__c,
                HOMEtracker__Current_Owner_Service_File__r.Current_Lease__r.Lease_PDF_Link__c,
                Current_Outreach_Timeline__r.Target_Outreach_Date__c
            FROM
                HOMEtracker__Property__c
            WHERE
                Exclude_From_Inventory__c = false AND
                Development_address__r.Id = :devId AND
                Group_Property__c = false
            ORDER BY
                Initial_Leaseup_Sale_Phase__c ASC, Inventory_Sort__c ASC, Target_Cert_Date_Order__c ASC, Name ASC
            ];

    }
     
}