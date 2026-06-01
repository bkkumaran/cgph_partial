# Unit Assignment Test Data

This directory contains test data scripts for testing the Unit Assignment user story functionality.

## User Story
As an internal staff member assigning units, I want to view and select from available units within a group property so that I can assign an approved applicant to a specific unit.

## Test Data Structure

### 1. Group Property
- **Sunset Gardens Group Property**
  - Address: 123 Main Street, Seattle, WA 98101
  - Type: Rental property
  - `Group_Property__c = true`
  - Acts as the parent for individual units

### 2. Individual Units (4 units)
- **Unit 1A**: 2 bed/1 bath, $1,500/month
- **Unit 1B**: 2 bed/1 bath, $1,500/month
- **Unit 2A**: 2 bed/1 bath, $1,550/month
- **Unit 2B**: 1 bed/1 bath, $1,350/month

All units have:
- `Group_Property_Parent__c` pointing to the group property
- Status: Available
- Full addresses with unit numbers

### 3. Test Applicants (3 applicants)
- **John Smith** - john.smith@example.com
- **Jane Johnson** - jane.johnson@example.com
- **Mike Davis** - mike.davis@example.com

All applicants have:
- Status: Approved
- Complete contact information
- Associated Service File records

### 4. Outreach Tracking Records
- One record per applicant
- Initially assigned to the **Group Property** (`Property_Unit__c` = Group Property ID)
- Ready for unit assignment testing

## Scripts

### 1. Create Test Data
```bash
# Run in Salesforce Developer Console or VS Code
scripts/apex/unit_assignment_test_data.apex
```
This script creates all the test data and displays summary information.

### 2. Verify Data & Simulate Assignment
```bash
# Run in Salesforce Developer Console or VS Code
scripts/apex/verify_unit_assignment_data.apex
```
This script:
- Verifies all relationships are correct
- Shows the current data structure
- Simulates assigning one applicant to demonstrate the functionality

### 3. Cleanup Test Data
```bash
# Run in Salesforce Developer Console or VS Code
scripts/apex/cleanup_unit_assignment_test_data.apex
```
This script removes all test data when testing is complete.

## Testing Instructions

1. **Run the creation script** to set up test data
2. **Navigate to Outreach Tracking** in Salesforce
3. **Find the group property applicants** (initially assigned to "Sunset Gardens Group Property")
4. **Click the unit assignment link** for any applicant
5. **Verify you can see all 4 individual units** in the selection process
6. **Select a specific unit** and verify the `Property_Unit__c` field updates
7. **Run the verification script** to confirm the assignment worked
8. **Run the cleanup script** when done testing

## Acceptance Criteria Validation

### ✅ AC1: View Available Units
- When clicking unit assignment for a group property applicant
- Should see all properties where `Group_Property_Parent__c` matches the group property ID
- Test data provides 4 different units to choose from

### ✅ AC2: Update Unit Assignment
- When selecting a specific unit
- The applicant's `Property_Unit__c` should update from group property ID to individual unit ID
- Verification script demonstrates this functionality

## Data Relationships

```
Group Property (Sunset Gardens)
├── Individual Units (Group_Property_Parent__c → Group Property)
│   ├── Unit 1A
│   ├── Unit 1B
│   ├── Unit 2A
│   └── Unit 2B
└── Outreach Tracking Records (Property_Unit__c → Group Property initially)
    ├── John Smith → [Can be assigned to any individual unit]
    ├── Jane Johnson → [Can be assigned to any individual unit]
    └── Mike Davis → [Can be assigned to any individual unit]
```

## Notes
- All test data uses realistic but fake information
- Email addresses use example.com domain
- Phone numbers use (206) 555-xxxx format
- Addresses are in Seattle, WA for consistency
- All scripts include debug output for verification