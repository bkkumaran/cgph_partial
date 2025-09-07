trigger UpdateTaksHistoryNotes on Task (after insert, after update)
{
    
     CGPH_Triggers_Custom_Settings__c cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
       
    // get the contact id from the related to id of task
    // tasks will be related to PreApplicant and wee need to find related contact
    // we are suuming that if archive is true then this task is essentially have
    // related record as pre applicant
    system.debug('cgphSettings'+cgphSettings);
    system.debug('Field'+cgphSettings.Update_Taks_History_Notes__c);
    if(cgphSettings != null && cgphSettings.Update_Taks_History_Notes__c)
        
    {
        list<Task> lstTriggeredTasks = new list<Task>([SELECT id,Description,WhatId,Archive__c,
                                                CreatedDate,Subject 
                                                FROM Task 
                                                WHERE id IN : trigger.new AND Archive__c = true ]); 
    set<string> setPreAppIds = new set<string>();
    map<string,string> mapPreAppRelatedToTask = new map<string,string>(); 
    
    if( lstTriggeredTasks != null && lstTriggeredTasks.size() > 0 )
    {
        for(task t : lstTriggeredTasks)
        {
            //setPreAppIds.add(t.WhatId);
            mapPreAppRelatedToTask.put(t.id,t.whatid);
        }
    }
    
    system.debug(' mapPreAppRelatedToTask '+mapPreAppRelatedToTask);
    
    // now we have pre applicant ids get the contact ids
    map<string,PreApplicants__c> mapPreApps = new map<string,PreApplicants__c>();
    list<PreApplicants__c> lstPreApps = new list<PreApplicants__c>([SELECT id,Contact__c 
                FROM PreApplicants__c 
                WHERE id IN :mapPreAppRelatedToTask.values()]);
                
    set<string> setContactIds = new set<string>();
    // create map of pre applicants
    system.debug('Lsit of pre applicants is : '+lstPreApps);
    if( lstPreApps != null && lstPreApps.size() > 0 )
    {
        for(PreApplicants__c preApp : lstPreApps)
        {
            system.debug('preApp is : '+preApp);
            mapPreApps.put(preApp.id,preApp);
            setContactIds.add(preApp.Contact__c);
        }           
    }   
    
    
    map<string,Contact> mapContacts = new map<string,Contact>();
    list<contact> lstCons = new list<Contact>([SELECT id,Activity_Log__c
                FROM Contact 
                WHERE id IN :setContactIds]);   
    if( lstCons != null && lstCons.size() > 0 )
    {
        for(Contact c : lstCons)
        {
            mapContacts.put(c.id,c);
        }
    }
    
    list<Task> lstTaskToBeDeleted = new list<Task>();
    
    list<Contact> lstContactsUpdate = new list<Contact>();
    // now we have all data set up 
    // update the Contacts field with the Task Subject
    if( lstTriggeredTasks != null && lstTriggeredTasks.size() > 0 )
    {
        for(Task t : lstTriggeredTasks)
        {
            Task newTask = new Task(id=t.id);
            lstTaskToBeDeleted.add(newTask);
            // get the contact where what id pre app has lookup of contact
            contact con = new contact();
            string strContactIds = mapPreApps.get(t.whatid).Contact__c; 
            con = mapContacts.get(strContactIds);
            if(con.Activity_Log__c != null)
                con.Activity_Log__c +='\n'+t.CreatedDate.Year()+'.'+(t.CreatedDate.Month()<10?'0':'')+t.CreatedDate.Month()+'.'+(t.CreatedDate.Day()<10?'0':'')+t.CreatedDate.Day()+' '+t.Subject;
            else
                con.Activity_Log__c = t.CreatedDate.Year()+'.'+(t.CreatedDate.Month()<10?'0':'')+t.CreatedDate.Month()+'.'+(t.CreatedDate.Day()<10?'0':'')+t.CreatedDate.Day()+' '+t.Subject;
            
            lstContactsUpdate.add(con);
        }
    }                           
    
    if(lstContactsUpdate != null && lstContactsUpdate.size() > 0)
    {
        system.debug('ListOf Contacts to be updated '+lstContactsUpdate);
        update lstContactsUpdate;
    }
    
    // delete triggered tasks
    if( lstTaskToBeDeleted != null && lstTaskToBeDeleted.size() > 0 )
    {
        system.debug('Tasks to be deleted are '+lstTaskToBeDeleted);
        delete lstTaskToBeDeleted;
    }
  }
}