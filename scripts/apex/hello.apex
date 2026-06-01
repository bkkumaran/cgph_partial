// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

try {
      // 1. Create Municipality (required for HOMEtracker__Property__c)
      Municipality__c municipality = new Municipality__c(
          Name = 'Test Municipality for Group Property'
      );
      insert municipality;
      System.debug('Municipality ID: ' + municipality.Id);

      // 2. Create Contact (for Service File applicant)
      Contact applicant = new Contact(
          FirstName = 'Test',
          LastName = 'Applicant',
          Email = 'test.applicant@example.com',
          Phone = '555-123-4567'
      );
      insert applicant;
      System.debug('Contact ID: ' + applicant.Id);

      // 3. Create Group Property (Parent) - with all required fields
      HOMEtracker__Property__c groupProperty = new HOMEtracker__Property__c(
          Name = 'Test Group Property - Main Building',              // Required Name field
          Municipality_Name__c = municipality.Id,                    // Required Municipality lookup
          Group_Property__c = true,                                  // Group property flag
          Include_on_Tracker__c = true,                             // Include on tracker
          HOMEtracker__Status__c = 'Available'                      // Important for business logic
      );
      insert groupProperty;
      System.debug('Group Property ID: ' + groupProperty.Id);

      // 4. Create Individual Units (Children) - with all required fields
      List<HOMEtracker__Property__c> units = new List<HOMEtracker__Property__c>();

      units.add(new HOMEtracker__Property__c(
          Name = 'Unit 101 - Test Group Property',                   // Required Name field
          Municipality_Name__c = municipality.Id,                    // Required Municipality lookup
          Unit_Number__c = '101',
          Group_Property__c = false,                                 // Individual unit flag
          Group_Property_Parent__c = groupProperty.Id,               // Link to parent group
          Include_on_Tracker__c = true,                             // Include on tracker
          HOMEtracker__Status__c = 'Available'                      // Important for business logic
      ));

      units.add(new HOMEtracker__Property__c(
          Name = 'Unit 102 - Test Group Property',                   // Required Name field
          Municipality_Name__c = municipality.Id,                    // Required Municipality lookup
          Unit_Number__c = '102',
          Group_Property__c = false,                                 // Individual unit flag
          Group_Property_Parent__c = groupProperty.Id,               // Link to parent group
          Include_on_Tracker__c = true,                             // Include on tracker
          HOMEtracker__Status__c = 'Available'                      // Important for business logic
      ));

      units.add(new HOMEtracker__Property__c(
          Name = 'Unit 103 - Test Group Property',                   // Required Name field
          Municipality_Name__c = municipality.Id,                    // Required Municipality lookup
          Unit_Number__c = '103',
          Group_Property__c = false,                                 // Individual unit flag
          Group_Property_Parent__c = groupProperty.Id,               // Link to parent group
          Include_on_Tracker__c = true,                             // Include on tracker
          HOMEtracker__Status__c = 'Available'                      // Important for business logic
      ));

      insert units;
      System.debug('Unit IDs: ');
      for(HOMEtracker__Property__c unit : units) {
          System.debug('  ' + unit.Name + ': ' + unit.Id);
      }

      // 5. Create Service File (linked to Group Property) - with all required fields
      HOMEtracker__Service_File__c serviceFile = new HOMEtracker__Service_File__c(
          Name = 'Test Service File - Group Property Assignment',    // Required Name field
          HOMEtracker__Applicant__c = applicant.Id,                 // Link to Contact (populates formula fields)
          HOMEtracker__Property__c = groupProperty.Id,              // Link to Group Property initially
          HOMEtracker__Status__c = 'Application in Process',        // Important for business logic
          Priority__c = 1                                         // Required for validation rules
      );
      insert serviceFile;
      System.debug('Service File ID: ' + serviceFile.Id);

      // 6. Create Outreach Tracking (Test Applicant) - ONLY non-formula fields
      Outreach_Tracking__c outreachTracking = new Outreach_Tracking__c(
          Name = 'Test Outreach - Unit Assignment',                  // Required Name field
          Service_File__c = serviceFile.Id,                         // Required Master-Detail relationship
          Landlord_Developer_Determination__c = 'Approved',         // Required for unit assignment
          Tracker_Status__c = 'Primary',                           // Safe status that works with Priority
          Property_Unit__c = null                                   // NULL = associated with group property
          // NOTE: All other fields like Applicant_Name__c, Applicant_Email__c, etc. are formula fields
          // They will be automatically populated from the Service_File__c and Contact relationships
      );
      insert outreachTracking;
      System.debug('Outreach Tracking ID: ' + outreachTracking.Id);

      // 7. Query the record to see the populated formula fields
      Outreach_Tracking__c createdRecord = [
          SELECT Id, Name, Applicant_Name__c, Applicant_Email__c, Applicant_Phone__c,
                 Household_Size__c, Property_Address__c, Property_Id__c
          FROM Outreach_Tracking__c
          WHERE Id = :outreachTracking.Id
      ];

      // 8. Display summary and LWC update instruction
      System.debug('========================================');
      System.debug('TEST DATA CREATION SUCCESSFUL!');
      System.debug('========================================');
      System.debug('Group Property ID: ' + groupProperty.Id);
      System.debug('Service File ID: ' + serviceFile.Id);
      System.debug('Outreach Tracking ID: ' + outreachTracking.Id);
      System.debug('');
      System.debug('Formula Fields Auto-Populated:');
      System.debug('  Applicant Name: ' + createdRecord.Applicant_Name__c);
      System.debug('  Applicant Email: ' + createdRecord.Applicant_Email__c);
      System.debug('  Applicant Phone: ' + createdRecord.Applicant_Phone__c);
      System.debug('  Household Size: ' + createdRecord.Household_Size__c);
      System.debug('  Property Address: ' + createdRecord.Property_Address__c);
      System.debug('  Property ID (Group): ' + createdRecord.Property_Id__c);
      System.debug('');
      System.debug('***** UPDATE YOUR LWC *****');
      System.debug('Replace testPropertyId in rentalApplicantTracker.js line 25 with:');
      System.debug('"' + groupProperty.Id + '"');
      System.debug('');
      System.debug('Available Units for Assignment:');
      for(HOMEtracker__Property__c unit : units) {
          System.debug('  ' + unit.Name + ' (' + unit.Id + ')');
      }

  } catch (Exception e) {
      System.debug('Error creating test data: ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
  }


// 1. Create Development (this is what the LWC expects as propertyId parameter)
  HOMEtracker__Property__c development = new HOMEtracker__Property__c(
      Name = 'Test Development - Main Complex',
      Municipality_Name__c = municipality.Id,  // Use your existing municipality ID
      HOMEtracker__Status__c = 'Available',
      Include_on_Tracker__c = true
  );
  insert development;
  System.debug('Development ID (USE THIS IN LWC): ' + development.Id);

  // 2. Update your existing Group Property to link to Development
  HOMEtracker__Property__c groupPropertyToUpdate = [
      SELECT Id FROM HOMEtracker__Property__c
      WHERE Id = :groupProperty.Id
  ];
  groupPropertyToUpdate.Development_Address__c = development.Id;
  update groupPropertyToUpdate;

  // 3. Update your existing Individual Units to link to Development
  List<HOMEtracker__Property__c> unitsToUpdate = [
      SELECT Id FROM HOMEtracker__Property__c
      WHERE Group_Property_Parent__c = :groupProperty.Id
  ];
  for(HOMEtracker__Property__c unit : unitsToUpdate) {
      unit.Development_Address__c = development.Id;
  }
  update unitsToUpdate;

  // 4. Update Outreach Tracking to have Include_On_Tracker__c = true (if missing)
  Outreach_Tracking__c otToUpdate = [
      SELECT Id FROM Outreach_Tracking__c 
      WHERE Id = :outreachTracking.Id
  ];

  try {
      // 1. Find your existing test records
      System.debug('=== FINDING EXISTING TEST RECORDS ===');

      // Find Municipality (should exist from earlier)
      List<Municipality__c> municipalities = [
          SELECT Id, Name FROM Municipality__c
          WHERE Name LIKE '%Test%'
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];

      if (municipalities.isEmpty()) {
          throw new AuraHandledException('No test municipality found. Please create one first.');
      }
      Municipality__c municipality = municipalities[0];
      System.debug('Found Municipality: ' + municipality.Name + ' (' + municipality.Id + ')');

      // Find Group Property
      List<HOMEtracker__Property__c> groupProperties = [
          SELECT Id, Name, Development_Address__c
          FROM HOMEtracker__Property__c
          WHERE Group_Property__c = true
          AND (Name LIKE '%Test%' OR Name LIKE '%Group%')
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];

      if (groupProperties.isEmpty()) {
          throw new AuraHandledException('No test group property found. Please create one first.');
      }
      HOMEtracker__Property__c groupProperty = groupProperties[0];
      System.debug('Found Group Property: ' + groupProperty.Name + ' (' + groupProperty.Id + ')');

      // Find Individual Units
      List<HOMEtracker__Property__c> units = [
          SELECT Id, Name, Development_Address__c
          FROM HOMEtracker__Property__c
          WHERE Group_Property_Parent__c = :groupProperty.Id
          ORDER BY Name ASC
      ];
      System.debug('Found ' + units.size() + ' individual units');
      for(HOMEtracker__Property__c unit : units) {
          System.debug('  Unit: ' + unit.Name + ' (' + unit.Id + ')');
      }

      // Find Service File
      List<HOMEtracker__Service_File__c> serviceFiles = [
          SELECT Id, Name, HOMEtracker__Property__c
          FROM HOMEtracker__Service_File__c
          WHERE HOMEtracker__Property__c = :groupProperty.Id
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];

      if (serviceFiles.isEmpty()) {
          throw new AuraHandledException('No test service file found linked to group property.');
      }
      HOMEtracker__Service_File__c serviceFile = serviceFiles[0];
      System.debug('Found Service File: ' + serviceFile.Name + ' (' + serviceFile.Id + ')');

      // Find Outreach Tracking
      List<Outreach_Tracking__c> outreachRecords = [
          SELECT Id, Name, Service_File__c
          FROM Outreach_Tracking__c
          WHERE Service_File__c = :serviceFile.Id
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];

      if (outreachRecords.isEmpty()) {
          throw new AuraHandledException('No test outreach tracking found linked to service file.');
      }
      Outreach_Tracking__c outreachTracking = outreachRecords[0];
      System.debug('Found Outreach Tracking: ' + outreachTracking.Name + ' (' + outreachTracking.Id + ')');

      // 2. Create Development record (this is what the LWC needs as propertyId)
      System.debug('=== CREATING DEVELOPMENT RECORD ===');

      HOMEtracker__Property__c development = new HOMEtracker__Property__c(
          Name = 'Test Development - Main Complex',
          Municipality_Name__c = municipality.Id,
          HOMEtracker__Status__c = 'Available',
          Include_on_Tracker__c = true
      );
      insert development;
      System.debug('Created Development: ' + development.Name + ' (' + development.Id + ')');

      // 3. Update Group Property to link to Development
      System.debug('=== UPDATING RELATIONSHIPS ===');

      groupProperty.Development_Address__c = development.Id;
      update groupProperty;
      System.debug('Updated Group Property with Development link');

      // 4. Update Individual Units to link to Development
      for(HOMEtracker__Property__c unit : units) {
          unit.Development_Address__c = development.Id;
      }
      if (!units.isEmpty()) {
          update units;
          System.debug('Updated ' + units.size() + ' units with Development link');
      }

      // 5. Check if Include_On_Tracker__c exists on Outreach_Tracking__c (might be formula field)
      System.debug('=== CHECKING OUTREACH TRACKING ===');

      // Query the updated record to see current state
      Outreach_Tracking__c updatedOT = [
          SELECT Id, Name, Include_On_Tracker__c,
                 Service_File__r.HOMEtracker__Property__r.Development_Address__c,
                 Service_File__r.HOMEtracker__Property__r.Include_on_Tracker__c,
                 Property_Id__c
          FROM Outreach_Tracking__c
          WHERE Id = :outreachTracking.Id
      ];

      System.debug('Outreach Tracking Include_On_Tracker__c: ' + updatedOT.Include_On_Tracker__c);
      System.debug('Property Include_on_Tracker__c: ' + updatedOT.Service_File__r.HOMEtracker__Property__r.Include_on_Tracker__c);
      System.debug('Development Address: ' + updatedOT.Service_File__r.HOMEtracker__Property__r.Development_Address__c);
      System.debug('Property_Id__c (Group): ' + updatedOT.Property_Id__c);

      // 6. Final Summary
      System.debug('');
      System.debug('==========================================');
      System.debug('✅ TEST DATA SETUP COMPLETE!');
      System.debug('==========================================');
      System.debug('Development ID (USE THIS IN LWC): ' + development.Id);
      System.debug('Group Property ID: ' + groupProperty.Id);
      System.debug('Service File ID: ' + serviceFile.Id);
      System.debug('Outreach Tracking ID: ' + outreachTracking.Id);
      System.debug('');
      System.debug('🔧 UPDATE YOUR LWC:');
      System.debug('In rentalApplicantTracker.js line 25, replace:');
      System.debug('testPropertyId = \'a0J1N00001cc8Nt\';');
      System.debug('WITH:');
      System.debug('testPropertyId = \'' + development.Id + '\';');
      System.debug('');
      System.debug('📋 AVAILABLE UNITS FOR ASSIGNMENT:');
      for(HOMEtracker__Property__c unit : units) {
          System.debug('  • ' + unit.Name + ' (' + unit.Id + ')');
      }
      System.debug('');
      System.debug('🎯 TEST YOUR USER STORY:');
      System.debug('1. Navigate to the LWC with Development ID: ' + development.Id);
      System.debug('2. Look for approved applicant: ' + updatedOT.Name);
      System.debug('3. Click "Unit Assignment" button');
      System.debug('4. Select from available units listed above');
      System.debug('==========================================');

  } catch (Exception e) {
      System.debug('❌ ERROR: ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
  }

List<Outreach_Tracking__c> ots = [
    SELECT Id,
           Name,
           Property_Id__c,
           Service_File__r.Priority__c,
           Service_File__r.HOMEtracker__Property__r.Group_Property__c,
           Service_File__r.HOMEtracker__Property__r.Development_address__r.Id
    FROM Outreach_Tracking__c
    WHERE Service_File__r.HOMEtracker__Property__r.Include_on_Tracker__c = true
      AND Include_On_Tracker__c = true
      AND Service_File__r.HOMEtracker__Property__r.Development_address__r.Id != null
];

System.debug('OTS Size: ' + ots.size());

List<Outreach_Tracking__c> matchingOTs = new List<Outreach_Tracking__c>();

for (Outreach_Tracking__c ot : ots) {
    if (ot.Property_Id__c == ot.Service_File__r.HOMEtracker__Property__r.Development_address__r.Id) {
        matchingOTs.add(ot);
        System.debug('-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-');
        System.debug('Matching OT: ' + ot.Name + ' (Id: ' + ot.Property_Id__c + ')');
        System.debug('-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-');
    }
}

System.debug('Matching OTs count: ' + matchingOTs.size());
System.debug('Matching OT Ids: ' + matchingOTs);