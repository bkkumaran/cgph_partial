@IsTest
public class UpdateTaskHistoryNotesTest
{
  public testmethod static  void unitTest()
   {
   	
   	
   		//Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Update_Taks_History_Notes__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Update_Taks_History_Notes__c){
                    cgphTriggersSettings.Update_Taks_History_Notes__c = true;
                    upsert cgphTriggersSettings;
                }
            }
        }
   	          
       //creating contact
       Contact con =new Contact();
       con.LastName='TestLast';
       con.FirstName='TestFirst';
       insert con;
           
       //creating pre-applicant
      PreApplicants__c preAppl =new PreApplicants__c();
       preAppl.Name='Test Pre-Applicant';
       preAppl.First_Name__c='FirstName';
       preAppl.Last_Name__c='LastName';
       preAppl.Contact__c=con.Id;
       insert preAppl;
       
       Task task =new Task();
       task.OwnerId=UserInfo.getUserId();
       task.Subject='Test Subject';
       task.WhatId=preAppl.Id;
       task.Status='In Progress';
       task.Priority='Normal';
       task.Archive__c=true;
       insert task;
   	   
   	   
   	   list<Contact> lstContact = new list<Contact>();
   	   lstContact = [SELECT id,Activity_Log__c FROM Contact WHERE id =: con.id];
	   list<Task> lstTask = new list<Task>([SELECT id FROM Task WHERE id =: task.id]);
		system.assertEquals(lstContact.size() , 1); // confirm we find on matching contact
		system.assertNotEquals(lstContact[0].Activity_Log__c,null); // verify trigger runs and has updated the activity log
		system.assertEquals(lstTask.size(),0);// task is deleted by trigger
   }
}