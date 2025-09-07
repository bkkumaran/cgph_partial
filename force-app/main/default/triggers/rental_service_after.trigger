trigger rental_service_after on HOMEtracker__Service_File__c (after insert, after update, after delete, after undelete) {
system.debug('$$$$ trigger called ');
system.debug(Limits.getCpuTime()+' out of  '+Limits.getLimitCpuTime());
    if(Test.isRunningTest() || ServiceFileActionsHandler.isRental_Service_AfterExecuted == false){
        
if (trigger.isInsert || trigger.isUpdate) {
    		ServiceFileActionsHandler.isRental_Service_AfterExecuted = true;
            Map<id, HOMEtracker__Property__c> propsToUpdate = new Map<id, HOMEtracker__Property__c>();
            Map<id, HOMEtracker__Property__c> propCheckClearOwner = new Map<id, HOMEtracker__Property__c>(); 
            Map<id, HOMEtracker__Service_File__c> filesToUpdate = new Map<id, HOMEtracker__Service_File__c>();
        
 
            boolean statusChanged;
            boolean applicantChanged;
            boolean propertyChanged;
                                
            for ( HOMEtracker__Service_File__c svf : trigger.new ) {
                
                // if it's a new service file or if the status has changed, set statusChanged to true; otherwise it's false
                statusChanged = (trigger.isInsert || ( trigger.oldMap.get(svf.id).HOMEtracker__status__c != svf.HOMEtracker__status__c));
                applicantChanged = (trigger.isInsert || (svf.HOMEtracker__applicant__c != null && trigger.oldMap.get(svf.id).HOMEtracker__applicant__c != svf.HOMEtracker__applicant__c));
                propertyChanged = (trigger.isInsert || (svf.HOMEtracker__property__c != null && trigger.oldMap.get(svf.id).HOMEtracker__property__c != svf.HOMEtracker__property__c));
         
                               // changes to property
                // - when purchased, set property's owner and co-owner, and last purchase price, and status
                // - when appraisal is filled in, copy to property
        
                if (svf.HOMEtracker__Property__c != null) {
                    HOMEtracker__property__c thisProp;
                    if (statusChanged || applicantChanged || propertyChanged ) {
                        if (svf.HOMEtracker__Status__c == 'Current Renter') {
                            thisProp = new HOMEtracker__Property__c(id=svf.HOMEtracker__Property__c, Current_renter__c = svf.HOMEtracker__Applicant__c,
                                                            /*status__c = 'Owner Occupied',*/
                                                            HOMEtracker__Current_Owner_Service_File__c = svf.id);} 
                        // if service file status is not current renter, 
                        else propCheckClearOwner.put(svf.HOMEtracker__Property__c, null);
   
                    }
                    if (thisProp != null) {
                        propsToUpdate.put(thisProp.id, thisProp);
                    }          
                }    
            }                                             
            
            // check properties where service file ownership has changed
            // if property homeowner is set to service file applicant and shouldn't be,
            // set property homeowner/co-owner to blank
           propCheckClearOwner =  new Map<ID, HOMEtracker__Property__c>([select id, Current_renter__c, HOMEtracker__Status__c, HOMEtracker__Current_Owner_Service_File__c from HOMEtracker__Property__c where id in :propCheckClearOwner.keySet()]);
            
            for (HOMEtracker__Service_File__c svf : trigger.new) {
                if (propCheckClearOwner.get(svf.HOMEtracker__Property__c) != null && (propCheckClearOwner.get(svf.HOMEtracker__Property__c).Current_renter__c == svf.HOMEtracker__Applicant__c)) {
                    id propId = svf.HOMEtracker__Property__c;
                    if (propsToUpdate.get(propId) == null) {
                        propsToUpdate.put(propId, new HOMEtracker__Property__c(id = propId));
                    }
                    if (propCheckClearOwner.get(propId).Current_renter__c == svf.HOMEtracker__Applicant__c) {
                        propsToUpdate.get(propId).Current_renter__c = null;
                    }
                    if (propCheckClearOwner.get(svf.HOMEtracker__Property__c).HOMEtracker__Current_Owner_Service_File__c == svf.id) {
                        propsToUpdate.get(propId).HOMEtracker__Current_Owner_Service_File__c = null;
                    }
                    
                }
           }
            //update properties
            if (!propsToUpdate.isEmpty()) {
                update propsToUpdate.values();
            }
            
    }
   }
 }