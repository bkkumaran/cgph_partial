import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import Id from '@salesforce/user/Id';

import getOutreachTrackingByProperty from '@salesforce/apex/OutreachControllerLWC.getOutreachTrackingByProperty';
import saveOutreachTrackings from '@salesforce/apex/OutreachControllerLWC.saveOutreachTrackings';
import saveSingleOutreachTracking from '@salesforce/apex/OutreachControllerLWC.saveSingleOutreachTracking';
import assignUnitToApplicant from '@salesforce/apex/OutreachControllerLWC.assignUnitToApplicant';
import cancelUnitAssignment from '@salesforce/apex/OutreachControllerLWC.cancelUnitAssignment';
import getAvailableUnitsForDevelopment from '@salesforce/apex/OutreachControllerLWC.getAvailableUnitsForDevelopment';

// Object and Field references
import OUTREACH_TRACKING_OBJECT from '@salesforce/schema/Outreach_Tracking__c';
import TRACKER_STATUS_FIELD from '@salesforce/schema/Outreach_Tracking__c.Tracker_Status__c';
import SF_PRIORITY_FIELD from '@salesforce/schema/Outreach_Tracking__c.SF_Priority__c';
import CGPH_DETERMINATION_FIELD from '@salesforce/schema/Outreach_Tracking__c.CGPH_Determination__c';

export default class RentalApplicantTrackerMockup extends LightningElement {
    @api developmentName;
    @api propertyId; // Property ID to fetch data for
    @api recordId;
    
    // TODO: Replace with actual property ID for testing
    testPropertyId = 'a0J1N00001cc8Nt'; // Replace with your actual property ID
    
    @track propertyGroups = [];
    @track error = null;
    @track outreachTrackingData = null;
    
    // User permissions and field editability (matching Visualforce logic)
    userId = Id;
    @track isUserCGPHStaff = true; // Default to true for now - should be determined by user profile/role
    @track isUserLandlordDeveloper = true; // Default to true - should be determined by user profile/role
    
    // Properties to hold record type info
    @track outreachTrackingRecordTypeId;
    
    // Dynamic dropdown options populated from Salesforce data
    @track statusOptions = [];
    @track priorityOptions = [];
    @track approvalOptions = [];
    @track determinationOptions = [];
    
    // Wire to get object info (needed for picklist values)
    @wire(getObjectInfo, { objectApiName: OUTREACH_TRACKING_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            console.log('Object info received:', data);
            // Get the default record type ID (first one, or Master if available)
            const recordTypes = data.recordTypeInfos;
            const recordTypeIds = Object.keys(recordTypes);
            
            // Look for Master record type first, otherwise use the first one
            let selectedRecordTypeId = recordTypeIds.find(id => 
                recordTypes[id].name === 'Master' || recordTypes[id].master
            ) || recordTypeIds[0];
            
            this.outreachTrackingRecordTypeId = selectedRecordTypeId;
            console.log('Selected record type ID:', selectedRecordTypeId);
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }
    
    // Wire to get Status picklist values
    @wire(getPicklistValues, { 
        recordTypeId: '$outreachTrackingRecordTypeId', 
        fieldApiName: TRACKER_STATUS_FIELD 
    })
    wiredStatusPicklistValues({ error, data }) {
        console.log('wiredStatusPicklistValues called with:', {
            recordTypeId: this.outreachTrackingRecordTypeId,
            fieldApiName: TRACKER_STATUS_FIELD,
            data: data,
            error: error
        });
        
        if (data) {
            console.log('Status picklist values received:', data);
            this.statusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Updated statusOptions:', this.statusOptions);
        } else if (error) {
            console.error('Error fetching status picklist values:', error);
            this.statusOptions = [...this._defaultStatusOptions];
            console.log('Using default statusOptions:', this.statusOptions);
        } else {
            console.log('Status picklist wire called but no data or error yet');
        }
    }

    customParam1;
    customParam2;
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            // Get URL parameters
            this.recordId = currentPageReference.state?.c__recordId || null;
            console.log('Record ID from attribute:', this.recordId);
            this.propertyId = this.recordId ? this.recordId : this.propertyId;
            console.log('Property ID from attribute:', this.propertyId);
        }
    }
    
    // Wire to get Priority picklist values
    // @wire(getPicklistValues, { 
    //     recordTypeId: '$outreachTrackingRecordTypeId', 
    //     fieldApiName: SF_PRIORITY_FIELD 
    // })
    // wiredPriorityPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('Priority picklist values received:', data);
    //         this.priorityOptions = data.values.map(item => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //     } else if (error) {
    //         console.error('Error fetching priority picklist values:', error);
    //         this.priorityOptions = [...this._defaultPriorityOptions];
    //     }
    // }
    
    // // Wire to get CGPH Determination picklist values
    // @wire(getPicklistValues, { 
    //     recordTypeId: '$outreachTrackingRecordTypeId', 
    //     fieldApiName: CGPH_DETERMINATION_FIELD 
    // })
    // wiredDeterminationPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('CGPH Determination picklist values received:', data);
    //         const options = data.values.map(item => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //         // Use same values for both approval and determination dropdowns
    //         this.approvalOptions = [...options];
    //         this.determinationOptions = [...options];
    //     } else if (error) {
    //         console.error('Error fetching CGPH determination picklist values:', error);
    //         this.approvalOptions = [...this._defaultApprovalOptions];
    //         this.determinationOptions = [...this._defaultDeterminationOptions];
    //     }
    // }
    
    // Transform Salesforce data to component format
    transformDataToPropertyGroups(data) {
        if (!data || typeof data !== 'object') {
            this.propertyGroups = [];
            return;
        }
        
        const groups = [];
        let groupIndex = 0;
        
        // Convert each property in the data map to a property group
        Object.keys(data).forEach(propertyKey => {
            const listWrapper = data[propertyKey];
            if (!listWrapper || !listWrapper.otList) return;
            
            // Get property name from first record or use a default
            const firstRecord = listWrapper.otList[0];
            const propertyName = firstRecord?.Outreach_Tracker_Property_Name__c || 
                               firstRecord?.Property_Address__c || 
                               `Property ${String.fromCharCode(65 + groupIndex)}`;

            console.table(listWrapper.otList);

            const applicants = listWrapper.otList.map(ot => this.transformOutreachTrackingToApplicant(ot));
            console.table(applicants);
            
            groups.push({
                id: propertyKey,
                name: propertyName,
                applicants: applicants
            });
            
            groupIndex++;
        });
        
        this.propertyGroups = groups;
    }
    
    // Transform individual Outreach_Tracking__c record to applicant format
    transformOutreachTrackingToApplicant(ot) {
        const applicant = {
            id: ot.Id,
            unitType: this.buildUnitTypeString(ot),
            //status: this.mapTrackerStatusToStatus(ot.Tracker_Status__c) || 'Hidden',
            status: ot.Tracker_Status__c,
            unit: ot.Property_Unit__r?.Unit_Number__c || ot.Property_Unit__r?.Name || ot.Unit__c || '',
            //priority: ot.SF_Priority__c || this.mapPriorityCalc(ot.Priority_Calc__c),
            priority: ot.SF_Priority__c,
            applicantName: ot.Applicant_Name__c || '',
            peopleInHousehold: ot.Household_Size__c || 0,
            email: ot.Applicant_Email__c,
            phone: ot.Applicant_Phone__c,
            dateCGPHAdded: this.formatDate(ot.Date_CGPH_Added_Name__c),
            dateMarkedPrimary: this.formatDate(ot.Date_Marked_Primary__c),
            //approvalDenial: ot.CGPH_Determination__c || 'Pending',
            approvalDenial: ot.Landlord_Developer_Determination__c,
            approveDenyDate: this.formatDate(ot.CGPH_Approval_Denial_Date__c),
            notes: ot.Landlord_Developer_Notes__c || '',
            approvedForFullReview: this.isApprovedForFullReview(ot),
            approvedForFullReviewText: this.isApprovedForFullReview(ot) ? 'Yes' : 'No',
            fullReviewCGPHBegan: this.formatDate(ot.Date_Eligibility_Review_Began__c),
            //cgphDetermination: ot.CGPH_Determination__c || 'Pending',
            cgphDetermination: ot.CGPH_Determination__c,
            dateOfDetermination: this.formatDate(ot.CGPH_Approval_Denial_Date__c),
            
            // Flagged applicant indicators (matching Visualforce functionality)
            isFlaggedForOutreach: ot.Service_File__r?.Pre_Applicant__r?.Flagged_for_Outreach__c || false,
            flaggedOutreachNotes: ot.Service_File__r?.Pre_Applicant__r?.Flagged_for_Outreach_Notes__c || '',
            preApplicantId: ot.Service_File__r?.Pre_Applicant__r?.Id || '',
            
            // Unit assignment properties
            hasSpecificUnit: ot.Property_Unit__c != null,
            isGroupProperty: ot.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c || false,
            propertyUnitId: ot.Property_Unit__c,
            developmentId: ot.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Id,
            canAssignUnit: (ot.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c && 
                           ot.Landlord_Developer_Determination__c === 'Approved' && 
                           ot.Property_Unit__c == null),
            
            // Store original SF record for updates
            __originalRecord: ot
        };
        
        // Add dynamic styling classes
        applicant.rowCssClass = this.getRowCssClass(applicant);
        applicant.textCssClass = this.getTextCssClass(applicant);
        
        return applicant;
    }
    
    // Get CSS class for row background color based on Tracker_Status__c and Landlord_Developer_Determination__c
    getRowCssClass(applicant) {
        const status = applicant.status;
        const approvalDenial = applicant.approvalDenial;
        const isApproved = approvalDenial === 'Approved';
        const baseClass = 'editable-row';
        
        let statusClass = '';
        switch(status) {
            case 'Primary':
                statusClass = isApproved ? 'status-primary-approved' : 'status-primary';
                break;
            case 'Backup':
                statusClass = isApproved ? 'status-backup-approved' : 'status-backup';
                break;
            case 'Hidden':
                statusClass = isApproved ? 'status-hidden-approved' : 'status-hidden';
                break;
            case 'Flagged':
                statusClass = isApproved ? 'status-flagged-approved' : 'status-flagged';
                break;
            case 'Removed':
                statusClass = isApproved ? 'status-removed-approved' : 'status-removed';
                break;
            default:
                statusClass = '';
        }
        
        return `${baseClass} ${statusClass}`.trim();
    }
    
    // Get CSS class for text styling based on Landlord_Developer_Determination__c (following Visualforce logic)
    getTextCssClass(applicant) {
        const determination = applicant.approvalDenial;
        const status = applicant.status;
        
        // In Visualforce, all approved applicants get blue text (except removed which gets white)
        if (determination === 'Approved') {
            if (status === 'Removed') {
                return ''; // White text handled by status-removed-approved CSS class
            } else {
                return 'approved-text'; // Blue text for all other approved applicants
            }
        }
        
        return ''; // No special text styling for non-approved
    }
    
    // Field editability methods (matching Visualforce permissions)
    
    // Check if a field is editable based on user role and field type
    isFieldEditable(fieldName) {
        // CGP&H Staff editable fields (matching Visualforce <apex:inlineEditSupport>)
        const cgphEditableFields = [
            'status',              // Tracker_Status__c
            'dateCGPHAdded',      // Date_CGPH_Added_Name__c  
            'dateMarkedPrimary'   // Date_Marked_Primary__c
        ];
        
        // Landlord/Developer editable fields (matching Visualforce <apex:inlineEditSupport>)
        const landlordEditableFields = [
            'approvalDenial',     // Landlord_Developer_Determination__c
            'approveDenyDate'     // Landlord_Developer_Determination_Date__c
        ];
        
        // Notes field requires special flow - making it read-only for now
        // (In Visualforce it links to a separate flow for editing)
        
        if (this.isUserCGPHStaff && cgphEditableFields.includes(fieldName)) {
            return true;
        }
        
        if (this.isUserLandlordDeveloper && landlordEditableFields.includes(fieldName)) {
            return true;
        }
        
        return false; // All other fields are read-only
    }
    
    // Get the disabled attribute for input fields
    getFieldDisabled(fieldName) {
        return !this.isFieldEditable(fieldName);
    }
    
    // Getter methods for template use (field disabled state - OPPOSITE of editable)
    get isUnitTypeDisabled() { return !this.isFieldEditable('unitType'); }
    get isStatusDisabled() { return !this.isFieldEditable('status'); }
    get isUnitDisabled() { return !this.isFieldEditable('unit'); }
    get isPriorityDisabled() { return !this.isFieldEditable('priority'); }
    get isApplicantNameDisabled() { return !this.isFieldEditable('applicantName'); }
    get isPeopleInHouseholdDisabled() { return !this.isFieldEditable('peopleInHousehold'); }
    get isEmailDisabled() { return !this.isFieldEditable('email'); }
    get isPhoneDisabled() { return !this.isFieldEditable('phone'); }
    get isDateCGPHAddedDisabled() { return !this.isFieldEditable('dateCGPHAdded'); }
    get isDateMarkedPrimaryDisabled() { return !this.isFieldEditable('dateMarkedPrimary'); }
    get isApprovalDenialDisabled() { return !this.isFieldEditable('approvalDenial'); }
    get isApproveDenyDateDisabled() { return !this.isFieldEditable('approveDenyDate'); }
    get isNotesDisabled() { return !this.isFieldEditable('notes'); }
    get isApprovedForFullReviewDisabled() { return !this.isFieldEditable('approvedForFullReview'); }
    get isFullReviewCGPHBeganDisabled() { return !this.isFieldEditable('fullReviewCGPHBegan'); }
    get isCgphDeterminationDisabled() { return !this.isFieldEditable('cgphDetermination'); }
    get isDateOfDeterminationDisabled() { return !this.isFieldEditable('dateOfDetermination'); }
    
    // Update CSS classes for a specific applicant after field changes
    updateApplicantStyling(recordId) {
        // Create a new array to trigger reactivity
        const updatedPropertyGroups = [...this.propertyGroups];
        
        updatedPropertyGroups.forEach(propertyGroup => {
            propertyGroup.applicants.forEach(applicant => {
                if (applicant.id === recordId) {
                    // Recalculate CSS classes based on current field values
                    applicant.rowCssClass = this.getRowCssClass(applicant);
                    applicant.textCssClass = this.getTextCssClass(applicant);
                }
            });
        });
        
        // Update the property groups to trigger re-render
        this.propertyGroups = updatedPropertyGroups;
    }
    
    // Helper methods for data transformation
    buildUnitTypeString(ot) {
        const unitInfo = ot.Property_Unit__r?.Unit_Number__c || ot.Unit__c || '';
        const rent = ot.Property_Rent_or_List_Price__c;
        if (rent) {
            return `${unitInfo} for $${rent}`;
        }
        return unitInfo || 'Unit information not available';
    }
    
    mapTrackerStatusToStatus(trackerStatus) {
        const statusMap = {
            'Applied': 'Applied',
            'Under Review': 'Under Review', 
            'Approved': 'Approved',
            'Denied': 'Denied',
            'Waitlisted': 'Waitlisted'
        };
        return statusMap[trackerStatus] || 'Applied';
    }
    
    mapPriorityCalc(priorityCalc) {
        if (priorityCalc <= 3) return 'High';
        if (priorityCalc <= 6) return 'Medium';
        return 'Low';
    }
    
    isApprovedForFullReview(ot) {
        return ot.Date_Eligibility_Review_Began__c || ot.Date_Ready_for_Eligibility_Review__c;
    }
    
    formatDate(dateValue) {
        if (!dateValue) return '';
        try {
            return new Date(dateValue).toISOString().split('T')[0];
        } catch (e) {
            return dateValue;
        }
    }
    
    // Fallback hardcoded data (keep as backup if no propertyId provided)
    _hardcodedPropertyGroups = [
        {
            id: 'property-a',
            name: 'Property A - Luxury Tower East',
            applicants: [
                {
                    id: 'a1',
                    unitType: '1 bedroom units for $2,500',
                    status: 'Primary',
                    unit: 'A101',
                    priority: 'High',
                    applicantName: 'Sarah Johnson (Primary + Approved)',
                    peopleInHousehold: 2,
                    email: 'sarah.j@email.com',
                    phone: '(555) 123-4567',
                    dateCGPHAdded: '2025-01-15',
                    dateMarkedPrimary: '2025-01-16',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-20',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-21',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-25',
                    // Flagged data for testing
                    isFlaggedForOutreach: false,
                    flaggedOutreachNotes: '',
                    preApplicantId: 'pre1'
                },
                {
                    id: 'a2',
                    unitType: '2 bedroom units for $3,200',
                    status: 'Backup',
                    unit: 'A205',
                    priority: 'Medium',
                    applicantName: 'Michael Roberto (Backup + Approved - Warning!)',
                    peopleInHousehold: 3,
                    email: 'mike.a@gmail.com',
                    phone: '(555) 987-6543',
                    dateCGPHAdded: '2025-01-10',
                    dateMarkedPrimary: '2025-01-12',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: '',
                    // Flagged data for testing - this applicant is flagged
                    isFlaggedForOutreach: true,
                    flaggedOutreachNotes: 'Previous rental history shows late payments and property damage concerns',
                    preApplicantId: 'pre2'
                },
                {
                    id: 'a3',
                    unitType: '1 bedroom units for $2,500',
                    status: 'Hidden',
                    unit: 'A301',
                    priority: 'High',
                    applicantName: 'Lisa Marie (Hidden)',
                    peopleInHousehold: 1,
                    email: 'lisa.t@yahoo.com',
                    phone: '(555) 345-6789',
                    dateCGPHAdded: '2025-01-08',
                    dateMarkedPrimary: '2025-01-09',
                    approvalDenial: 'Denied',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-19',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-24',
                    // Flagged data for testing
                    isFlaggedForOutreach: false,
                    flaggedOutreachNotes: '',
                    preApplicantId: 'pre3'
                }
            ]
        },
        {
            id: 'property-b',
            name: 'Property B - Garden View Apartments',
            applicants: [
                {
                    id: 'b1',
                    unitType: '1 bedroom units for $2,800',
                    status: 'Approved',
                    unit: 'B301',
                    priority: 'High',
                    applicantName: 'Jennifer Marie ',
                    peopleInHousehold: 1,
                    email: 'jen.d@outlook.com',
                    phone: '(555) 456-7890',
                    dateCGPHAdded: '2025-01-08',
                    dateMarkedPrimary: '2025-01-09',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-15',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-16',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-22'
                },
                {
                    id: 'b2',
                    unitType: '2 bedroom units for $3,500',
                    status: 'Under Review',
                    unit: 'B105',
                    priority: 'Medium',
                    applicantName: 'Robert Kim',
                    peopleInHousehold: 2,
                    email: 'rob.k@email.com',
                    phone: '(555) 234-5678',
                    dateCGPHAdded: '2025-01-12',
                    dateMarkedPrimary: '2025-01-14',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'b3',
                    unitType: '1 bedroom units for $2,800',
                    status: 'Waitlisted',
                    unit: 'B207',
                    priority: 'Low',
                    applicantName: 'Amanda Rodriguez',
                    peopleInHousehold: 1,
                    email: 'amanda.r@mail.com',
                    phone: '(555) 567-8901',
                    dateCGPHAdded: '2025-01-05',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                }
            ]
        },
        {
            id: 'property-c',
            name: 'Property C - Downtown Loft Complex',
            applicants: [
                {
                    id: 'c1',
                    unitType: 'Studio units for $2,100',
                    status: 'Waitlisted',
                    unit: 'C150',
                    priority: 'Low',
                    applicantName: 'David Christopher',
                    peopleInHousehold: 1,
                    email: 'david.m@edu.com',
                    phone: '(555) 321-0987',
                    dateCGPHAdded: '2025-01-12',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'c2',
                    unitType: '2 bedroom units for $3,800',
                    status: 'Denied',
                    unit: 'C275',
                    priority: 'Medium',
                    applicantName: 'Amanda Elizabeth',
                    peopleInHousehold: 4,
                    email: 'amanda.e@home.net',
                    phone: '(555) 654-3210',
                    dateCGPHAdded: '2025-01-05',
                    dateMarkedPrimary: '2025-01-06',
                    approvalDenial: 'Denied',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Denied',
                    dateOfDetermination: '2025-01-18'
                },
                {
                    id: 'c3',
                    unitType: 'Studio units for $2,100',
                    status: 'Applied',
                    unit: 'C180',
                    priority: 'High',
                    applicantName: 'James William',
                    peopleInHousehold: 1,
                    email: 'james.c@tech.com',
                    phone: '(555) 789-0123',
                    dateCGPHAdded: '2025-01-14',
                    dateMarkedPrimary: '2025-01-15',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                }
            ]
        },
        {
            id: 'property-d',
            name: 'Property D - Riverside Towers',
            applicants: [
                {
                    id: 'd1',
                    unitType: '3 bedroom units for $4,200',
                    status: 'Under Review',
                    unit: 'D401',
                    priority: 'High',
                    applicantName: 'Maria Elena',
                    peopleInHousehold: 5,
                    email: 'maria.g@family.com',
                    phone: '(555) 111-2222',
                    dateCGPHAdded: '2025-01-10',
                    dateMarkedPrimary: '2025-01-11',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-17',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'd2',
                    unitType: '2 bedroom units for $3,600',
                    status: 'Applied',
                    unit: 'D205',
                    priority: 'Medium',
                    applicantName: 'Kevin Park Smith',
                    peopleInHousehold: 3,
                    email: 'kevin.p@work.org',
                    phone: '(555) 333-4444',
                    dateCGPHAdded: '2025-01-13',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'd3',
                    unitType: '1 bedroom units for $2,900',
                    status: 'Approved',
                    unit: 'D102',
                    priority: 'High',
                    applicantName: 'Rachel Anne',
                    peopleInHousehold: 2,
                    email: 'rachel.w@live.com',
                    phone: '(555) 555-6666',
                    dateCGPHAdded: '2025-01-07',
                    dateMarkedPrimary: '2025-01-08',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-16',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-17',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-23'
                }
            ]
        }
    ];

    @track isLoading = false;
    @track nextPropertyLetter = 'E';
    
    // Component lifecycle
    async connectedCallback() {
        console.log('connectedCallback called');
        console.log('Current URL:', window.location.href);
        //get url
        console.log('Property ID from attribute:', this.propertyId);

        // Initialize dropdown options with defaults first
        this.setDefaultDropdownOptions();
        
        // For testing: use hardcoded test property ID if no propertyId is provided
        if (!this.propertyId) {
            // Uncomment the line below to test with real Salesforce data
            this.propertyId = this.testPropertyId;
            
            // Comment out the line below when testing with real data
            // this.propertyGroups = this._hardcodedPropertyGroups;
            // return;
        }
        
        // Load data from Salesforce if propertyId is provided
        if (this.propertyId) {
            await this.loadOutreachTrackingData();
        } else {
            // Use hardcoded sample data as fallback
            this.propertyGroups = this._hardcodedPropertyGroups;
            // Apply styling to hardcoded data
            this.applyDynamicStylingToPropertyGroups();
            this.setDefaultDropdownOptions();
        }
    }
    
    // Load outreach tracking data from Salesforce
    async loadOutreachTrackingData() {
        try {
            this.isLoading = true;
            this.error = null;
            
            console.log('Loading data for property ID:', this.propertyId);
            
            const data = await getOutreachTrackingByProperty({ propertyId: this.propertyId });
            
            if (data) {
                console.log('Outreach Tracking Data received:', data);
                console.table(data);
                this.outreachTrackingData = data;
                //this.populateDropdownOptions(data);
                this.transformDataToPropertyGroups(data);
            } else {
                console.log('No data returned from Apex method');
                this.propertyGroups = [];
                this.setDefaultDropdownOptions();
            }
            
        } catch (error) {
            console.error('Error loading outreach tracking data:', error);
            this.error = error;
            this.propertyGroups = [];
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to load data: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
    
    // Populate dropdown options from Salesforce data
    populateDropdownOptions(data) {
        const statusValues = new Set();
        const priorityValues = new Set();
        const approvalValues = new Set();
        const determinationValues = new Set();
        
        // Extract unique values from all records
        Object.keys(data).forEach(propertyKey => {
            const listWrapper = data[propertyKey];
            if (listWrapper && listWrapper.otList) {
                listWrapper.otList.forEach(ot => {
                    // Status options from Tracker_Status__c
                    if (ot.Tracker_Status__c) {
                        console.log('Found Tracker_Status__c:', ot.Tracker_Status__c);
                        statusValues.add(ot.Tracker_Status__c);
                    }
                    
                    // Priority options from SF_Priority__c 
                    if (ot.SF_Priority__c) {
                        console.log('Found SF_Priority__c:', ot.SF_Priority__c);
                        priorityValues.add(ot.SF_Priority__c);
                    }
                    
                    // Approval/Denial options from CGPH_Determination__c
                    if (ot.CGPH_Determination__c) {
                        console.log('Found CGPH_Determination__c:', ot.CGPH_Determination__c);
                        approvalValues.add(ot.CGPH_Determination__c);
                        determinationValues.add(ot.CGPH_Determination__c);
                    }
                });
            }
        });
        
        // Convert Sets to dropdown option arrays with defaults merged
        this.statusOptions = this.createDropdownOptions(statusValues, this._defaultStatusOptions);
        this.priorityOptions = this.createDropdownOptions(priorityValues, this._defaultPriorityOptions);
        console.table(this.priorityOptions);
        this.approvalOptions = this.createDropdownOptions(approvalValues, this._defaultApprovalOptions);
        this.determinationOptions = this.createDropdownOptions(determinationValues, this._defaultDeterminationOptions);
        
        console.log('Populated dropdown options:', {
            status: this.statusOptions,
            priority: this.priorityOptions,
            approval: this.approvalOptions,
            determination: this.determinationOptions
        });
    }
    
    // Create dropdown options by merging unique values with defaults
    createDropdownOptions(uniqueValues, defaultOptions) {
        const allValues = new Set();
        
        // Add default options first
        // defaultOptions.forEach(option => allValues.add(option.value));
        
        // Add unique values from data
        uniqueValues.forEach(value => {
            if (value !== null && value !== undefined) {
                // Convert to string and trim
                const stringValue = String(value).trim();
                if (stringValue) {
                    allValues.add(stringValue);
                }
            }
        });
        
        // Convert to dropdown option format and sort
        return Array.from(allValues)
            .sort()
            .map(value => ({ label: value, value: value }));
    }
    
    // Set default dropdown options when no data is available
    setDefaultDropdownOptions() {
        this.statusOptions = [...this._defaultStatusOptions];
        this.priorityOptions = [...this._defaultPriorityOptions];
        this.approvalOptions = [...this._defaultApprovalOptions];
        this.determinationOptions = [...this._defaultDeterminationOptions];
        
        console.log('Set default dropdown options');
    }
    
    // Apply dynamic styling to all applicants in property groups
    applyDynamicStylingToPropertyGroups() {
        this.propertyGroups.forEach(property => {
            property.applicants.forEach(applicant => {
                // Ensure flagged properties exist for sample data
                if (applicant.isFlaggedForOutreach === undefined) {
                    applicant.isFlaggedForOutreach = false;
                    applicant.flaggedOutreachNotes = '';
                    applicant.preApplicantId = '';
                }
                
                applicant.rowCssClass = this.getRowCssClass(applicant);
                applicant.textCssClass = this.getTextCssClass(applicant);
            });
        });
    }

    // Default/fallback options if no data is available
    _defaultStatusOptions = [
        { label: 'Applied', value: 'Applied' },
        { label: 'Under Review', value: 'Under Review' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' },
        { label: 'Waitlisted', value: 'Waitlisted' }
    ];

    _defaultPriorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    _defaultApprovalOptions = [
        // { label: 'Pending', value: 'Pending' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' }
    ];

    _defaultDeterminationOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' },
        { label: 'Pending', value: 'Pending' }
    ];

    async handleFieldChange(event) {
        const applicantId = event.target.dataset.id;
        const propertyId = event.target.dataset.property;
        const field = event.target.dataset.field;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        
        // Check if user has permission to edit this field (matching Visualforce permissions)
        if (!this.isFieldEditable(field)) {
            console.warn(`User does not have permission to edit field: ${field}`);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Permission Denied',
                message: `You do not have permission to edit the ${field} field`,
                variant: 'warning'
            }));
            return;
        }
        
        // Update the applicant record in the property group
        const propertyIndex = this.propertyGroups.findIndex(prop => prop.id === propertyId);
        if (propertyIndex !== -1) {
            const applicantIndex = this.propertyGroups[propertyIndex].applicants.findIndex(app => app.id === applicantId);
            if (applicantIndex !== -1) {
                // Create a new array to trigger reactivity
                const updatedPropertyGroups = [...this.propertyGroups];
                updatedPropertyGroups[propertyIndex].applicants[applicantIndex][field] = value;
                
                // Special handling for checkbox display text
                if (field === 'approvedForFullReview') {
                    updatedPropertyGroups[propertyIndex].applicants[applicantIndex].approvedForFullReviewText = value ? 'Yes' : 'No';
                }
                
                // Automatic date population when Tracker_Status__c changes
                if (field === 'status') {
                    const applicant = updatedPropertyGroups[propertyIndex].applicants[applicantIndex];
                    const currentDate = new Date().toISOString().split('T')[0]; // Format: YYYY-MM-DD
                    
                    // Auto-populate Date_CGPH_Added_Name__c if blank and status is Primary or Backup
                    if ((value === 'Primary' || value === 'Backup') && !applicant.dateCGPHAdded) {
                        updatedPropertyGroups[propertyIndex].applicants[applicantIndex].dateCGPHAdded = currentDate;
                    }
                    
                    // Auto-populate Date_Marked_Primary__c if blank and status is Primary
                    if (value === 'Primary' && !applicant.dateMarkedPrimary) {
                        updatedPropertyGroups[propertyIndex].applicants[applicantIndex].dateMarkedPrimary = currentDate;
                    }
                }
                
                // Update CSS classes immediately if status or approval fields changed
                if (field === 'status' || field === 'approvalDenial') {
                    const applicant = updatedPropertyGroups[propertyIndex].applicants[applicantIndex];
                    applicant.rowCssClass = this.getRowCssClass(applicant);
                    applicant.textCssClass = this.getTextCssClass(applicant);
                }
                
                this.propertyGroups = updatedPropertyGroups;
                
                // Save to Salesforce if we have original record and propertyId (not using fallback data)
                const applicant = updatedPropertyGroups[propertyIndex].applicants[applicantIndex];
                if (this.propertyId && applicant.__originalRecord) {
                    await this.saveFieldToSalesforce(applicant, field, value, updatedPropertyGroups[propertyIndex].applicants[applicantIndex]);
                }
                
                // Show success message
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: `${field} updated successfully for ${applicant.applicantName}`,
                    variant: 'success'
                }));
            }
        }
    }
    
    // Save individual field changes to Salesforce
    async saveFieldToSalesforce(applicant, field, value, updatedApplicant) {
       //try {
            const originalRecord = applicant.__originalRecord;
            let fieldMapping = this.mapFieldToSalesforceField(field, value);
            
            // Handle automatic date updates when status changes
            if (field === 'status') {
                const additionalUpdates = {};
                
                // Check if Date_CGPH_Added_Name__c was auto-populated
                if ((value === 'Primary' || value === 'Backup') && 
                    updatedApplicant.dateCGPHAdded && 
                    !applicant.__originalRecord.Date_CGPH_Added_Name__c) {
                    additionalUpdates.Date_CGPH_Added_Name__c = updatedApplicant.dateCGPHAdded;
                }
                
                // Check if Date_Marked_Primary__c was auto-populated
                if (value === 'Primary' && 
                    updatedApplicant.dateMarkedPrimary && 
                    !applicant.__originalRecord.Date_Marked_Primary__c) {
                    additionalUpdates.Date_Marked_Primary__c = updatedApplicant.dateMarkedPrimary;
                }
                
                // Merge additional updates with the main field mapping
                fieldMapping = { ...fieldMapping, ...additionalUpdates };
            }
            
            const recordToUpdate = {
                Id: originalRecord.Id,
                ...fieldMapping
            };
            
            console.log('Saving record to Salesforce:', JSON.stringify(recordToUpdate, null, 2));
            console.log('Field mapping:', JSON.stringify(fieldMapping, null, 2));
            
            // Try the alternative single record method first
            try {
                const recordString = JSON.stringify(recordToUpdate);
                console.log('Calling saveSingleOutreachTracking with:', recordString);
                const result = await saveSingleOutreachTracking({ recordData: recordString });
                console.log('Single record save result:', result);
            } catch (singleError) {
                console.log('Single record method failed, trying array method:', singleError);
                
                // Fallback to array method
                const recordsToUpdate = [recordToUpdate];
                console.log('Records array:', JSON.stringify(recordsToUpdate, null, 2));
                await saveOutreachTrackings({ updates: recordsToUpdate });
            }
            
            // Update the original record in memory to keep it in sync
            this.updateOriginalRecord(originalRecord.Id, fieldMapping);
            
            // Update CSS classes if status or approval fields changed (affects colors)
            if (field === 'status' || field === 'approvalDenial') {
                this.updateApplicantStyling(originalRecord.Id);
            }
            
        //} 
        
         // catch (error) {
        //     console.error('Error saving to Salesforce:', error);
        //     console.error('Error details:', JSON.stringify(error));
            
        //     let errorMessage = 'Failed to save changes to Salesforce';
        //     if (error.body && error.body.message) {
        //         errorMessage += ': ' + error.body.message;
        //     } else if (error.message) {
        //         errorMessage += ': ' + error.message;
        //     }
            
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'Error',
        //         message: errorMessage,
        //         variant: 'error'
        //     }));
        // }
    }
    
    // Map component field to Salesforce field
    mapFieldToSalesforceField(field, value) {
        const fieldMapping = {
            'status': { 'Tracker_Status__c': value },
            'priority': { 'SF_Priority__c': value },
            'applicantName': { 'Applicant_Name__c': value },
            'peopleInHousehold': { 'Household_Size__c': value },
            'email': { 'Applicant_Email__c': value },
            'phone': { 'Applicant_Phone__c': value },
            'dateCGPHAdded': { 'Date_CGPH_Added_Name__c': value },
            'dateMarkedPrimary': { 'Date_Marked_Primary__c': value },
            'approvalDenial': { 'Landlord_Developer_Determination__c': value },
            'approveDenyDate': { 'CGPH_Approval_Denial_Date__c': value },
            'notes': { 'Landlord_Developer_Notes__c': value },
            'fullReviewCGPHBegan': { 'Date_Eligibility_Review_Began__c': value },
            'cgphDetermination': { 'CGPH_Determination__c': value },
            'dateOfDetermination': { 'CGPH_Approval_Denial_Date__c': value }
        };
        
        return fieldMapping[field] || {};
    }
    
    // Update the original record in memory
    updateOriginalRecord(recordId, fieldMapping) {
        this.propertyGroups.forEach(propertyGroup => {
            propertyGroup.applicants.forEach(applicant => {
                if (applicant.__originalRecord && applicant.__originalRecord.Id === recordId) {
                    // Create a new mutable copy of the original record
                    const updatedOriginalRecord = { ...applicant.__originalRecord };
                    
                    // Apply the field updates to the mutable copy
                    Object.keys(fieldMapping).forEach(sfField => {
                        updatedOriginalRecord[sfField] = fieldMapping[sfField];
                    });
                    
                    // Replace the original record with the updated mutable copy
                    applicant.__originalRecord = updatedOriginalRecord;
                }
            });
        });
    }

    handleInventoryClick() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Development Inventory',
            message: 'This would show available units and inventory status',
            variant: 'info'
        }));
    }

    handleRemovedClick() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Removed Applicants',
            message: 'This would show previously removed applicants',
            variant: 'info'
        }));
    }

    handleContactClick() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Development Contact',
            message: 'Contact: John Smith, Development Manager\nPhone: (555) 999-0000\nEmail: john.smith@luxuryapartments.com',
            variant: 'info'
        }));
    }

    handleAddProperty(event) {
        const propertyId = event.target.dataset.property;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Add Property',
            message: `This would add a new property similar to ${propertyId}`,
            variant: 'info'
        }));
    }

    handleRemoveProperty(event) {
        const propertyId = event.target.dataset.property;
        
        // Find property name for confirmation message
        const property = this.propertyGroups.find(p => p.id === propertyId);
        const propertyName = property ? property.name : propertyId;
        
        // Remove the property from the array
        this.propertyGroups = this.propertyGroups.filter(prop => prop.id !== propertyId);
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Property Removed',
            message: `${propertyName} has been successfully removed`,
            variant: 'success'
        }));
    }

    handleAddNewProperty() {
        const newPropertyId = `property-${this.nextPropertyLetter.toLowerCase()}`;
        const newProperty = {
            id: newPropertyId,
            name: `Property ${this.nextPropertyLetter} - New Development`,
            applicants: []
        };

        this.propertyGroups = [...this.propertyGroups, newProperty];
        
        // Increment the next property letter
        this.nextPropertyLetter = String.fromCharCode(this.nextPropertyLetter.charCodeAt(0) + 1);
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: `New property ${newProperty.name} added successfully`,
            variant: 'success'
        }));
    }

    async handleRefresh() {
        if (this.propertyId) {
            // Reload data from Salesforce
            await this.loadOutreachTrackingData();
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Data refreshed successfully from Salesforce',
                variant: 'success'
            }));
        } else {
            // Simulate refresh for sample data
            this.isLoading = true;
            setTimeout(() => {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Sample data refreshed successfully',
                    variant: 'success'
                }));
            }, 1000);
        }
    }

    // Unit Assignment Methods

    /**
     * Handle unit assignment button click
     * Opens unit selection modal for approved group property applicants
     */
    async handleAssignUnit(event) {
        const applicantId = event.target.dataset.applicantId;
        const propertyId = event.target.dataset.propertyId;
        
        // Find the applicant record
        const applicant = this.findApplicantById(applicantId);
        if (!applicant) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record not found',
                variant: 'error'
            }));
            return;
        }
        
        // Validate applicant is eligible for unit assignment
        if (!applicant.canAssignUnit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Not Eligible',
                message: 'Unit assignment is only available for approved group property applicants without a specific unit',
                variant: 'warning'
            }));
            return;
        }
        
        try {
            // Get available units for the development
            const availableUnits = await getAvailableUnitsForDevelopment({ 
                developmentId: applicant.developmentId 
            });
            
            if (!availableUnits || availableUnits.length === 0) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No Units Available',
                    message: 'No individual units are available for assignment in this development',
                    variant: 'info'
                }));
                return;
            }
            
            // Show unit selection dialog (would typically be a modal, but using simple prompt for now)
            const unitOptions = availableUnits.map(unit => 
                `${unit.Unit_Number__c || unit.Name} - $${unit.Rent_or_List_Price__c || 'Price TBD'}`
            ).join('\n');
            
            const selectedIndex = parseInt(prompt(
                `Select unit for ${applicant.applicantName}:\n\n${unitOptions}\n\nEnter number (0-${availableUnits.length - 1}) or cancel:`
            ));
            
            if (selectedIndex >= 0 && selectedIndex < availableUnits.length) {
                await this.confirmUnitAssignment(applicantId, availableUnits[selectedIndex].Id, availableUnits[selectedIndex]);
            }
            
        } catch (error) {
            console.error('Error in handleAssignUnit:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to load available units: ' + error.body?.message || error.message,
                variant: 'error'
            }));
        }
    }
    
    /**
     * Confirm unit assignment selection and update the record
     */
    async confirmUnitAssignment(applicantId, unitId, unitRecord) {
        try {
            // Confirm the assignment
            const confirmMessage = `Assign ${unitRecord.Unit_Number__c || unitRecord.Name} to this applicant? This will update their unit association from the group property to this specific unit.`;
            
            if (!confirm(confirmMessage)) {
                return;
            }
            
            // Call Apex method to update the record
            const result = await assignUnitToApplicant({
                outreachTrackingId: applicantId,
                propertyUnitId: unitId
            });
            
            // Show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Unit Assigned',
                message: result,
                variant: 'success'
            }));
            
            // Refresh the data to show the updated unit information
            await this.loadOutreachTrackingData();
            
        } catch (error) {
            console.error('Error in confirmUnitAssignment:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Assignment Failed',
                message: 'Failed to assign unit: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        }
    }
    
    /**
     * Handle cancel unit assignment (return to group property)
     */
    async handleCancelUnitAssignment(event) {
        const applicantId = event.target.dataset.applicantId;
        
        const applicant = this.findApplicantById(applicantId);
        if (!applicant) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record not found',
                variant: 'error'
            }));
            return;
        }
        
        // Confirm the cancellation
        const confirmMessage = `Cancel unit assignment for ${applicant.applicantName}? This will return them to the group property association.`;
        
        if (!confirm(confirmMessage)) {
            return;
        }
        
        try {
            // Call Apex method to cancel the assignment
            const result = await cancelUnitAssignment({
                outreachTrackingId: applicantId
            });
            
            // Show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Assignment Cancelled',
                message: result,
                variant: 'success'
            }));
            
            // Refresh the data to show the updated information
            await this.loadOutreachTrackingData();
            
        } catch (error) {
            console.error('Error in handleCancelUnitAssignment:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Cancellation Failed',
                message: 'Failed to cancel unit assignment: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        }
    }
    
    /**
     * Helper method to find applicant by ID across all property groups
     */
    findApplicantById(applicantId) {
        for (const propertyGroup of this.propertyGroups) {
            const found = propertyGroup.applicants.find(applicant => applicant.id === applicantId);
            if (found) {
                return found;
            }
        }
        return null;
    }
}