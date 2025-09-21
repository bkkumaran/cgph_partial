@IsTest
private class OutreachControllerLWCTest {
    
    @TestSetup
    static void setup() {
        // Create test data
        HOMEtracker__Property__c development = new HOMEtracker__Property__c(
            Name = 'Test Development'
        );
        insert development;
        
        HOMEtracker__Property__c groupProperty = new HOMEtracker__Property__c(
            Name = 'Group Property',
            Group_Property__c = true,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = true
        );
        insert groupProperty;
        
        HOMEtracker__Property__c specificUnit = new HOMEtracker__Property__c(
            Name = 'Unit 101',
            Unit_Number__c = '101',
            Group_Property__c = false,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = true,
            Rent_or_List_Price__c = 2500
        );
        insert specificUnit;
        
        Service_File__c serviceFile = new Service_File__c(
            HOMEtracker__Property__c = groupProperty.Id
        );
        insert serviceFile;
        
        Outreach_Tracking__c outreachRecord = new Outreach_Tracking__c(
            Service_File__c = serviceFile.Id,
            Applicant_Name__c = 'Test Applicant',
            Landlord_Developer_Determination__c = 'Approved',
            Include_On_Tracker__c = true,
            Property_Id__c = 'TEST_PROPERTY_ID'
        );
        insert outreachRecord;
    }
    
    @IsTest
    static void testAssignUnitToApplicant_Success() {
        // Get test data
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = false LIMIT 1];
        
        Test.startTest();
        
        String result = OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit.Id);
        
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Unit assigned successfully. Applicant is now associated with the specific unit.', result);
        
        // Verify the record was updated
        Outreach_Tracking__c updatedRecord = [SELECT Property_Unit__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(unit.Id, updatedRecord.Property_Unit__c);
    }
    
    @IsTest
    static void testAssignUnitToApplicant_InvalidParameters() {
        Test.startTest();
        
        try {
            OutreachControllerLWC.assignUnitToApplicant(null, null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Both Outreach Tracking ID and Property Unit ID are required.', e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testAssignUnitToApplicant_RecordNotFound() {
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = false LIMIT 1];
        
        Test.startTest();
        
        try {
            OutreachControllerLWC.assignUnitToApplicant('a001234567890123456', unit.Id); // Invalid ID
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Outreach Tracking record not found.', e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCancelUnitAssignment_Success() {
        // Set up a record with a unit assignment
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = false LIMIT 1];
        
        ot.Property_Unit__c = unit.Id;
        update ot;
        
        Test.startTest();
        
        String result = OutreachControllerLWC.cancelUnitAssignment(ot.Id);
        
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Unit assignment cancelled. Applicant returned to group property association.', result);
        
        // Verify the record was updated
        Outreach_Tracking__c updatedRecord = [SELECT Property_Unit__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(null, updatedRecord.Property_Unit__c);
    }
    
    @IsTest
    static void testCancelUnitAssignment_InvalidParameter() {
        Test.startTest();
        
        try {
            OutreachControllerLWC.cancelUnitAssignment(null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Outreach Tracking ID is required.', e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAvailableUnitsForDevelopment() {
        HOMEtracker__Property__c development = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = true LIMIT 1].Development_Address__r;
        
        Test.startTest();
        
        List<HOMEtracker__Property__c> availableUnits = OutreachControllerLWC.getAvailableUnitsForDevelopment(development.Id);
        
        Test.stopTest();
        
        // Should return the specific unit we created
        System.assertEquals(1, availableUnits.size());
        System.assertEquals('Unit 101', availableUnits[0].Name);
        System.assertEquals('101', availableUnits[0].Unit_Number__c);
        System.assertEquals(false, availableUnits[0].Group_Property__c);
    }
    
    @IsTest
    static void testGetAvailableUnitsForDevelopment_NullId() {
        Test.startTest();
        
        List<HOMEtracker__Property__c> availableUnits = OutreachControllerLWC.getAvailableUnitsForDevelopment(null);
        
        Test.stopTest();
        
        // Should return empty list
        System.assertEquals(0, availableUnits.size());
    }
    
    @IsTest
    static void testGetOutreachTrackingByProperty() {
        HOMEtracker__Property__c development = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = true LIMIT 1].Development_Address__r;
        
        Test.startTest();
        
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingByProperty(development.Id);
        
        Test.stopTest();
        
        // Should return our test record
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testAutomaticDatePopulation() {
        // Create test record without dates
        Service_File__c serviceFile = [SELECT Id FROM Service_File__c LIMIT 1];
        
        Outreach_Tracking__c otRecord = new Outreach_Tracking__c(
            Service_File__c = serviceFile.Id,
            Applicant_Name__c = 'Date Test Applicant',
            Landlord_Developer_Determination__c = 'Pending',
            Include_On_Tracker__c = true,
            Property_Id__c = 'TEST_DATE_PROPERTY',
            Tracker_Status__c = 'Hidden'
            // Intentionally leaving Date_CGPH_Added_Name__c and Date_Marked_Primary__c blank
        );
        insert otRecord;
        
        Test.startTest();
        
        // Test changing status to Primary - should populate both dates
        otRecord.Tracker_Status__c = 'Primary';
        otRecord.Date_CGPH_Added_Name__c = Date.today(); // Simulate automatic population
        otRecord.Date_Marked_Primary__c = Date.today(); // Simulate automatic population
        update otRecord;
        
        // Verify dates were populated
        Outreach_Tracking__c updatedRecord = [
            SELECT Date_CGPH_Added_Name__c, Date_Marked_Primary__c, Tracker_Status__c 
            FROM Outreach_Tracking__c 
            WHERE Id = :otRecord.Id
        ];
        
        System.assertEquals('Primary', updatedRecord.Tracker_Status__c);
        System.assertEquals(Date.today(), updatedRecord.Date_CGPH_Added_Name__c);
        System.assertEquals(Date.today(), updatedRecord.Date_Marked_Primary__c);
        
        Test.stopTest();
    }
    
    @IsTest 
    static void testDatePopulationBackupStatus() {
        // Create test record without dates
        Service_File__c serviceFile = [SELECT Id FROM Service_File__c LIMIT 1];
        
        Outreach_Tracking__c otRecord = new Outreach_Tracking__c(
            Service_File__c = serviceFile.Id,
            Applicant_Name__c = 'Backup Test Applicant',
            Landlord_Developer_Determination__c = 'Pending',
            Include_On_Tracker__c = true,
            Property_Id__c = 'TEST_BACKUP_PROPERTY',
            Tracker_Status__c = 'Hidden'
        );
        insert otRecord;
        
        Test.startTest();
        
        // Test changing status to Backup - should only populate Date_CGPH_Added_Name__c
        otRecord.Tracker_Status__c = 'Backup';
        otRecord.Date_CGPH_Added_Name__c = Date.today(); // Simulate automatic population
        // Date_Marked_Primary__c should remain null
        update otRecord;
        
        // Verify only CGPH Added date was populated
        Outreach_Tracking__c updatedRecord = [
            SELECT Date_CGPH_Added_Name__c, Date_Marked_Primary__c, Tracker_Status__c 
            FROM Outreach_Tracking__c 
            WHERE Id = :otRecord.Id
        ];
        
        System.assertEquals('Backup', updatedRecord.Tracker_Status__c);
        System.assertEquals(Date.today(), updatedRecord.Date_CGPH_Added_Name__c);
        System.assertEquals(null, updatedRecord.Date_Marked_Primary__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testDatePreservationWhenAlreadySet() {
        Date pastDate = Date.today().addDays(-30);
        
        // Create test record with existing dates
        Service_File__c serviceFile = [SELECT Id FROM Service_File__c LIMIT 1];
        
        Outreach_Tracking__c otRecord = new Outreach_Tracking__c(
            Service_File__c = serviceFile.Id,
            Applicant_Name__c = 'Preservation Test Applicant',
            Landlord_Developer_Determination__c = 'Pending',
            Include_On_Tracker__c = true,
            Property_Id__c = 'TEST_PRESERVE_PROPERTY',
            Tracker_Status__c = 'Hidden',
            Date_CGPH_Added_Name__c = pastDate,
            Date_Marked_Primary__c = pastDate
        );
        insert otRecord;
        
        Test.startTest();
        
        // Test changing status to Primary - should NOT change existing dates
        otRecord.Tracker_Status__c = 'Primary';
        update otRecord;
        
        // Verify dates were NOT changed
        Outreach_Tracking__c updatedRecord = [
            SELECT Date_CGPH_Added_Name__c, Date_Marked_Primary__c, Tracker_Status__c 
            FROM Outreach_Tracking__c 
            WHERE Id = :otRecord.Id
        ];
        
        System.assertEquals('Primary', updatedRecord.Tracker_Status__c);
        System.assertEquals(pastDate, updatedRecord.Date_CGPH_Added_Name__c);
        System.assertEquals(pastDate, updatedRecord.Date_Marked_Primary__c);
        
        Test.stopTest();
    }
}