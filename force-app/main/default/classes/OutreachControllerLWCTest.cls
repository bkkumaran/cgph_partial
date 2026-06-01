@IsTest
private class OutreachControllerLWCTest {

    @TestSetup
    static void setup() {
        // Create Municipality (required for Property)
        Municipality__c municipality = new Municipality__c(
            Name = 'Test Municipality'
        );
        insert municipality;

        // Create test development
        HOMEtracker__Property__c development = new HOMEtracker__Property__c(
            Name = 'Test Development',
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        );
        insert development;

        // Group property for testing bulk applicant scenarios
        HOMEtracker__Property__c groupProperty = new HOMEtracker__Property__c(
            Name = 'Group Property',
            Group_Property__c = true,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        );
        insert groupProperty;

        // Create a few individual units within the development
        List<HOMEtracker__Property__c> units = new List<HOMEtracker__Property__c>();
        units.add(new HOMEtracker__Property__c(
            Name = 'Unit 101',
            Unit_Number__c = '101',
            Group_Property__c = false,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        ));
        units.add(new HOMEtracker__Property__c(
            Name = 'Unit 102',
            Unit_Number__c = '102',
            Group_Property__c = false,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        ));
         // Unit 103 is excluded from tracker to test filtering logic
        units.add(new HOMEtracker__Property__c(
            Name = 'Unit 103',
            Unit_Number__c = '103',
            Group_Property__c = false,
            Development_Address__c = development.Id,
            Include_on_Tracker__c = false,
            Municipality_Name__c = municipality.Id
        ));
        insert units;

        // Create Contact (required for Pre-Applicant)
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Applicant'
        );
        insert con;

        // Create Pre-Applicant
        PreApplicants__c preApplicant = new PreApplicants__c(
            Contact__c = con.Id,
            Name = 'Test Applicant',
            Last_Name__c = 'Applicant',
            Email__c = 'test@test.com',
            City__c = 'TestCity',
            Phone__c = '1234567890',
            Postal_Code__c = '12345',
            Street__c = 'TestStreet',
            State__c = 'NJ',
            Annual_Income__c = 50000,
            Household_Size__c = '2',
            Flagged_for_Outreach__c = false,
            Most_Recent_Update__c = Datetime.now()
        );
        insert preApplicant;

        // Create Service Files
        List<HOMEtracker__Service_File__c> serviceFiles = new List<HOMEtracker__Service_File__c>();
        serviceFiles.add(new HOMEtracker__Service_File__c(
            HOMEtracker__Property__c = groupProperty.Id,
            Pre_Applicant__c = preApplicant.Id,
            Priority__c = 1
        ));
        serviceFiles.add(new HOMEtracker__Service_File__c(
            HOMEtracker__Property__c = units[0].Id,
            Pre_Applicant__c = preApplicant.Id,
            Priority__c = 2
        ));
        insert serviceFiles;

        // Create Outreach Tracking records
        // Note: Include_on_Tracker__c is a formula field, can't set it directly
        List<Outreach_Tracking__c> outreachRecords = new List<Outreach_Tracking__c>();
        
        // Primary applicant for the group property
        outreachRecords.add(new Outreach_Tracking__c(
            Service_File__c = serviceFiles[0].Id,
            Tracker_Status__c = 'Primary',
            Move_to_Removed_Report__c = false
        ));
        
        // Backup applicant for individual unit
        outreachRecords.add(new Outreach_Tracking__c(
            Service_File__c = serviceFiles[1].Id,
            Tracker_Status__c = 'Backup',
            Move_to_Removed_Report__c = false
        ));
        
        // Already removed applicant - should be filtered out
        outreachRecords.add(new Outreach_Tracking__c(
            Service_File__c = serviceFiles[0].Id,
            Tracker_Status__c = 'Removed',
            Move_to_Removed_Report__c = true
        ));
        insert outreachRecords;
        
        // Update first record to Approved status
        // Done separately because picklist validation might fail on insert
        outreachRecords[0].Landlord_Developer_Determination__c = 'Approved';
        update outreachRecords[0];
    }

    //Query tests - making sure we get the right data back
    
    @IsTest
    static void testGetOutreachTrackingByProperty_Success() {
        HOMEtracker__Property__c development = [SELECT Id FROM HOMEtracker__Property__c WHERE Name = 'Test Development' LIMIT 1];

        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingByProperty(development.Id);
        Test.stopTest();

        // Just verify method executes without error
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @IsTest
    static void testGetOutreachTrackingByProperty_ExcludesRemovedRecords() {
        HOMEtracker__Property__c development = [SELECT Id FROM HOMEtracker__Property__c WHERE Name = 'Test Development' LIMIT 1];

        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingByProperty(development.Id);
        Test.stopTest();

        // Verify no removed records are returned
        Integer removedCount = 0;
        for (String key : result.keySet()) {
            for (Outreach_Tracking__c ot : result.get(key).otList) {
                if (ot.Move_to_Removed_Report__c == true) {
                    removedCount++;
                }
            }
        }
        System.assertEquals(0, removedCount, 'Should not include records moved to removed report');
    }

    @IsTest
    static void testGetOutreachTrackingByProperty_NullId() {
        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingByProperty(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for null input');
    }

    // getOutreachTrackingBySingleProperty tests

    @IsTest
    static void testGetOutreachTrackingBySingleProperty_NullId() {
        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingBySingleProperty(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for null input');
    }

    @IsTest
    static void testGetOutreachTrackingBySingleProperty_Success() {
        HOMEtracker__Property__c groupProperty = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = true LIMIT 1];

        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingBySingleProperty(groupProperty.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @IsTest
    static void testGetOutreachTrackingBySingleProperty_ExcludesRemovedRecords() {
        HOMEtracker__Property__c groupProperty = [SELECT Id FROM HOMEtracker__Property__c WHERE Group_Property__c = true LIMIT 1];

        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingBySingleProperty(groupProperty.Id);
        Test.stopTest();

        Integer removedCount = 0;
        for (String key : result.keySet()) {
            for (Outreach_Tracking__c ot : result.get(key).otList) {
                if (ot.Move_to_Removed_Report__c == true) {
                    removedCount++;
                }
            }
        }
        System.assertEquals(0, removedCount, 'Should not include records moved to removed report');
    }

    @IsTest
    static void testGetOutreachTrackingBySingleProperty_GroupPropertyWithChildren() {
        // Set up a parent group property and a child unit linked via Group_Property_Parent__c
        Municipality__c municipality = [SELECT Id FROM Municipality__c LIMIT 1];

        HOMEtracker__Property__c parentProperty = new HOMEtracker__Property__c(
            Name = 'Parent Group Property',
            Group_Property__c = true,
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        );
        insert parentProperty;

        HOMEtracker__Property__c childUnit = new HOMEtracker__Property__c(
            Name = 'Child Unit A',
            Unit_Number__c = '201',
            Group_Property__c = false,
            Group_Property_Parent__c = parentProperty.Id,
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        );
        insert childUnit;

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        PreApplicants__c preApplicant = [SELECT Id FROM PreApplicants__c LIMIT 1];

        HOMEtracker__Service_File__c sf = new HOMEtracker__Service_File__c(
            HOMEtracker__Property__c = childUnit.Id,
            Pre_Applicant__c = preApplicant.Id,
            Priority__c = 3
        );
        insert sf;

        Outreach_Tracking__c ot = new Outreach_Tracking__c(
            Service_File__c = sf.Id,
            Tracker_Status__c = 'Primary',
            Move_to_Removed_Report__c = false
        );
        insert ot;

        Test.startTest();
        Map<String, OutreachControllerLWC.ListWrapper> result = OutreachControllerLWC.getOutreachTrackingBySingleProperty(parentProperty.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        // The child unit OT should be included because its property's Group_Property_Parent__c = parentProperty.Id
        Integer totalRecords = 0;
        for (String key : result.keySet()) {
            totalRecords += result.get(key).numOfOTs;
        }
        System.assert(totalRecords > 0, 'Should return OT records for child units of the parent group property');
    }

    // Save methods bulk and single record updates
    
    @IsTest
    static void testSaveOutreachTrackings_Success() {
        Outreach_Tracking__c ot = [SELECT Id, Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Tracker_Status__c = 'Backup' LIMIT 1];
        ot.Landlord_Developer_Notes__c = 'Test Note';

        List<Outreach_Tracking__c> updates = new List<Outreach_Tracking__c>{ot};

        Test.startTest();
        String result = OutreachControllerLWC.saveOutreachTrackings(updates);
        Test.stopTest();

        System.assertEquals('Success', result, 'Should return Success');
		
        // Verify the update actually happened
        Outreach_Tracking__c updatedRecord = [SELECT Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals('Test Note', updatedRecord.Landlord_Developer_Notes__c, 'Record should be updated');
    }

    @IsTest
    static void testSaveOutreachTrackings_BulkUpdate() {
        List<Outreach_Tracking__c> otList = [SELECT Id, Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Move_to_Removed_Report__c = false LIMIT 2];
        
        for (Outreach_Tracking__c ot : otList) {
            ot.Landlord_Developer_Notes__c = 'Bulk update test note';
        }

        Test.startTest();
        String result = OutreachControllerLWC.saveOutreachTrackings(otList);
        Test.stopTest();

        System.assertEquals('Success', result);
        
        // Make sure all records got updated
        
        List<Outreach_Tracking__c> updatedRecords = [SELECT Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Id IN :otList];
        for (Outreach_Tracking__c updated : updatedRecords) {
            System.assertEquals('Bulk update test note', updated.Landlord_Developer_Notes__c, 'All records should be updated');
        }
    }

    @IsTest
    static void testSaveOutreachTrackings_EmptyList() {
        Test.startTest();
        String result = OutreachControllerLWC.saveOutreachTrackings(new List<Outreach_Tracking__c>());
        Test.stopTest();

        System.assertEquals('No records to update', result, 'Should handle empty list');
    }

    @IsTest
    static void testSaveOutreachTrackings_NullList() {
        Test.startTest();
        String result = OutreachControllerLWC.saveOutreachTrackings(null);
        Test.stopTest();

        System.assertEquals('No records to update', result);
    }
    
    
    @IsTest
    static void testSaveSingleOutreachTracking_Success() {
        Outreach_Tracking__c ot = [SELECT Id, Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Tracker_Status__c = 'Backup' LIMIT 1];
        ot.Landlord_Developer_Notes__c = 'Single Save Test';

        String recordData = JSON.serialize(ot);

        Test.startTest();
        String result = OutreachControllerLWC.saveSingleOutreachTracking(recordData);
        Test.stopTest();

        System.assertEquals('Success', result, 'Should return Success');
        
        Outreach_Tracking__c updatedRecord = [SELECT Landlord_Developer_Notes__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals('Single Save Test', updatedRecord.Landlord_Developer_Notes__c, 'Record should be updated');
    }

    @IsTest
    static void testSaveSingleOutreachTracking_InvalidJSON() {
        String invalidJson = 'This is not valid JSON';

        Test.startTest();
        try {
            OutreachControllerLWC.saveSingleOutreachTracking(invalidJson);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected - test passes
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

	
    // Unit assignment workflow tests
    @IsTest
    static void testAssignUnitToApplicant_Success() {
        Outreach_Tracking__c ot = [
            SELECT Id
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Primary'
            AND Move_to_Removed_Report__c = false
            LIMIT 1
        ];
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];

        Test.startTest();
        String result = OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit.Id);
        Test.stopTest();

        // Just verify no exception thrown
        System.assertNotEquals(null, result, 'Should return a result');
		
        // Confirm the unit was actually assigned
        Outreach_Tracking__c updatedRecord = [SELECT Property_Unit__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(unit.Id, updatedRecord.Property_Unit__c);
    }

    @IsTest
    static void testAssignUnitToApplicant_Reassignment() {
        // Test changing from one unit to another
        Outreach_Tracking__c ot = [
            SELECT Id
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Primary'
            AND Move_to_Removed_Report__c = false
            LIMIT 1
        ];
        HOMEtracker__Property__c unit1 = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];
        HOMEtracker__Property__c unit2 = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '102' LIMIT 1];

        // Assign first unit
        OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit1.Id);

        Test.startTest();
        // Reassignment to different unit
        String result = OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit2.Id);
        Test.stopTest();

        // Verify reassignment succeeded
        Outreach_Tracking__c updatedRecord = [SELECT Property_Unit__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(unit2.Id, updatedRecord.Property_Unit__c, 'Unit should be reassigned to new unit');
    }

    @IsTest
    static void testAssignUnitToApplicant_InvalidParameters() {
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];

        Test.startTest();
			
        // Try with null OT ID
        try {
            OutreachControllerLWC.assignUnitToApplicant(null, unit.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
		
        // Try with null Unit ID
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        try {
            OutreachControllerLWC.assignUnitToApplicant(ot.Id, null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }

        Test.stopTest();
    }

    @IsTest
    static void testAssignUnitToApplicant_RecordNotFound() {
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];

        // Get actual Outreach_Tracking__c prefix for fake ID
        List<Outreach_Tracking__c> existingOT = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        String prefix = String.valueOf(existingOT[0].Id).substring(0, 3);
        String fakeId = prefix + '000000000000AAA';

        Test.startTest();
        try {
            OutreachControllerLWC.assignUnitToApplicant(fakeId, unit.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testAssignUnitToApplicant_NotApproved() {
         // Should fail if applicant isn't approved yet
        Outreach_Tracking__c ot = [
            SELECT Id
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Backup'
            LIMIT 1
        ];
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];

        Test.startTest();
        try {
            OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testAssignUnitToApplicant_NotGroupProperty() {
        // Unit assignment only works for group properties
        Outreach_Tracking__c ot = [
            SELECT Id
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Backup'
            LIMIT 1
        ];

        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '102' LIMIT 1];

        Test.startTest();
        try {
            OutreachControllerLWC.assignUnitToApplicant(ot.Id, unit.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected (will fail on approval or group property check)
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    
    @IsTest
    static void testCancelUnitAssignment_Success() {
        Outreach_Tracking__c ot = [
            SELECT Id
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Primary'
            AND Move_to_Removed_Report__c = false
            LIMIT 1
        ];
        HOMEtracker__Property__c unit = [SELECT Id FROM HOMEtracker__Property__c WHERE Unit_Number__c = '101' LIMIT 1];

        ot.Property_Unit__c = unit.Id;
        update ot;

        Test.startTest();
        String result = OutreachControllerLWC.cancelUnitAssignment(ot.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return a result');

        Outreach_Tracking__c updatedRecord = [SELECT Property_Unit__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(null, updatedRecord.Property_Unit__c, 'Unit assignment should be cleared');
    }

    @IsTest
    static void testCancelUnitAssignment_NoExistingAssignment() {
        // Should still work even if no unit was assigned
        Outreach_Tracking__c ot = [
            SELECT Id, Property_Unit__c
            FROM Outreach_Tracking__c
            WHERE Tracker_Status__c = 'Primary'
            AND Move_to_Removed_Report__c = false
            LIMIT 1
        ];
        
        ot.Property_Unit__c = null;
        update ot;

        Test.startTest();
        String result = OutreachControllerLWC.cancelUnitAssignment(ot.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return a result');
    }

    @IsTest
    static void testCancelUnitAssignment_InvalidParameter() {
        Test.startTest();
        try {
            OutreachControllerLWC.cancelUnitAssignment(null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testCancelUnitAssignment_RecordNotFound() {
        List<Outreach_Tracking__c> existingOT = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        String prefix = String.valueOf(existingOT[0].Id).substring(0, 3);
        String fakeId = prefix + '000000000000AAA';

        Test.startTest();
        try {
            OutreachControllerLWC.cancelUnitAssignment(fakeId);
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    // Available units query
    @IsTest
    static void testGetAvailableUnitsForDevelopment_Success() {
        HOMEtracker__Property__c development = [SELECT Id FROM HOMEtracker__Property__c WHERE Name = 'Test Development' LIMIT 1];

        Test.startTest();
        List<HOMEtracker__Property__c> availableUnits = OutreachControllerLWC.getAvailableUnitsForDevelopment(development.Id);
        Test.stopTest();

        // Just verify method executes and returns a list
        System.assertNotEquals(null, availableUnits, 'Should return a list');
        System.assert(availableUnits.size() >= 0, 'Should return a valid list');
    }

    @IsTest
    static void testGetAvailableUnitsForDevelopment_NullId() {
        Test.startTest();
        List<HOMEtracker__Property__c> availableUnits = OutreachControllerLWC.getAvailableUnitsForDevelopment(null);
        Test.stopTest();

        System.assertEquals(0, availableUnits.size(), 'Should return empty list for null input');
    }

    @IsTest
    static void testGetAvailableUnitsForDevelopment_NoUnitsAvailable() {
        Municipality__c municipality = [SELECT Id FROM Municipality__c LIMIT 1];
        HOMEtracker__Property__c emptyDevelopment = new HOMEtracker__Property__c(
            Name = 'Empty Development',
            Include_on_Tracker__c = true,
            Municipality_Name__c = municipality.Id
        );
        insert emptyDevelopment;

        Test.startTest();
        List<HOMEtracker__Property__c> availableUnits = OutreachControllerLWC.getAvailableUnitsForDevelopment(emptyDevelopment.Id);
        Test.stopTest();

        System.assertEquals(0, availableUnits.size(), 'Should return empty list when no units available');
    }

   
   // Applicant removal workflow 
    @IsTest
    static void testConfirmApplicantRemoval_Success() {
        Outreach_Tracking__c ot = [SELECT Id, Applicant_Name__c FROM Outreach_Tracking__c WHERE Move_to_Removed_Report__c = false AND Tracker_Status__c != 'Removed' LIMIT 1];
        ot.Tracker_Status__c = 'Removed';
        update ot;

        Test.startTest();
        String result = OutreachControllerLWC.confirmApplicantRemoval(ot.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return a result');
		
        // Verify it's marked for the removal report
        Outreach_Tracking__c updatedRecord = [SELECT Move_to_Removed_Report__c FROM Outreach_Tracking__c WHERE Id = :ot.Id];
        System.assertEquals(true, updatedRecord.Move_to_Removed_Report__c, 'Should be moved to removal report');
    }

    @IsTest
    static void testConfirmApplicantRemoval_InvalidStatus() {
        // Can't confirm removal unless status is 'Removed'
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c WHERE Tracker_Status__c != 'Removed' AND Move_to_Removed_Report__c = false LIMIT 1];

        Test.startTest();
        try {
            OutreachControllerLWC.confirmApplicantRemoval(ot.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testConfirmApplicantRemoval_AlreadyMoved() {
        // Can't move to removed report twice
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c WHERE Move_to_Removed_Report__c = true LIMIT 1];

        Test.startTest();
        try {
            OutreachControllerLWC.confirmApplicantRemoval(ot.Id);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testConfirmApplicantRemoval_InvalidParameter() {
        Test.startTest();
        try {
            OutreachControllerLWC.confirmApplicantRemoval(null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testConfirmApplicantRemoval_RecordNotFound() {
        List<Outreach_Tracking__c> existingOT = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        String prefix = String.valueOf(existingOT[0].Id).substring(0, 3);
        String fakeId = prefix + '000000000000AAA';

        Test.startTest();
        try {
            OutreachControllerLWC.confirmApplicantRemoval(fakeId);
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Exception expected
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }

    // ListWrapper utility class tests
    @IsTest
    static void testListWrapperClass_WithRecords() {
        List<Outreach_Tracking__c> otList = [SELECT Id FROM Outreach_Tracking__c LIMIT 5];

        Test.startTest();
        OutreachControllerLWC.ListWrapper wrapper = new OutreachControllerLWC.ListWrapper(otList);
        Test.stopTest();

        System.assertEquals(otList.size(), wrapper.numOfOTs, 'Should have correct count');
        System.assertEquals(otList[0].Id, wrapper.firstOfList, 'Should have correct first ID');
        System.assertEquals(otList, wrapper.otList, 'Should have correct list');
    }

    @IsTest
    static void testListWrapperClass_EmptyList() {
        List<Outreach_Tracking__c> emptyList = new List<Outreach_Tracking__c>();

        Test.startTest();
        OutreachControllerLWC.ListWrapper wrapper = new OutreachControllerLWC.ListWrapper(emptyList);
        Test.stopTest();

        System.assertEquals(0, wrapper.numOfOTs, 'Should have zero count');
        System.assertEquals(null, wrapper.firstOfList, 'Should have null first ID');
        System.assertEquals(emptyList, wrapper.otList, 'Should have empty list');
    }

    @IsTest
    static void testListWrapperClass_NullList() {
        Test.startTest();
        OutreachControllerLWC.ListWrapper wrapper = new OutreachControllerLWC.ListWrapper(null);
        Test.stopTest();

        System.assertEquals(0, wrapper.numOfOTs, 'Should have zero count for null list');
        System.assertEquals(null, wrapper.firstOfList, 'Should have null first ID for null list');
    }

    @IsTest
    static void testListWrapperClass_SingleRecord() {
        Outreach_Tracking__c ot = [SELECT Id FROM Outreach_Tracking__c LIMIT 1];
        List<Outreach_Tracking__c> singleList = new List<Outreach_Tracking__c>{ot};

        Test.startTest();
        OutreachControllerLWC.ListWrapper wrapper = new OutreachControllerLWC.ListWrapper(singleList);
        Test.stopTest();

        System.assertEquals(1, wrapper.numOfOTs, 'Should have count of 1');
        System.assertEquals(ot.Id, wrapper.firstOfList, 'Should have correct ID');
    }

    @IsTest
    static void testIsGroupProperty_GroupProperty() {
        // Get the group property created in setup
        HOMEtracker__Property__c groupProperty = [
            SELECT Id, Group_Property__c
            FROM HOMEtracker__Property__c
            WHERE Group_Property__c = true
            LIMIT 1
        ];

        Test.startTest();
        Boolean result = OutreachControllerLWC.isGroupProperty(groupProperty.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for group property');
    }

    @IsTest
    static void testIsGroupProperty_IndividualProperty() {
        // Get an individual unit property created in setup
        HOMEtracker__Property__c individualProperty = [
            SELECT Id, Group_Property__c
            FROM HOMEtracker__Property__c
            WHERE Group_Property__c = false
            LIMIT 1
        ];

        Test.startTest();
        Boolean result = OutreachControllerLWC.isGroupProperty(individualProperty.Id);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for individual property');
    }

    @IsTest
    static void testIsGroupProperty_NullPropertyId() {
        Test.startTest();
        Boolean result = OutreachControllerLWC.isGroupProperty(null);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for null property ID');
    }

    @IsTest
    static void testIsGroupProperty_InvalidPropertyId() {
        // Create a fake ID that doesn't exist
        Id fakeId = 'a0J000000000000AAA';

        Test.startTest();
        Boolean result = OutreachControllerLWC.isGroupProperty(fakeId);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for invalid property ID');
    }
}