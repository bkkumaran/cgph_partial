trigger QuestionaryEligibilityChecking on Application__c (before insert) 
{
	List<Application__c> lstApplications = trigger.new;
    CGPH_Triggers_Custom_Settings__c cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
    if(cgphSettings != null && cgphSettings.Questionary_Eligibility_Checking__c){
        if(trigger.isInsert|| Trigger.isUpdate){
         //   PreAppEncodeIdTriggerHandler objPreappHandler = new PreAppEncodeIdTriggerHandler ();
            QuestionaryEligibilityCheckingHandler.createEligibilityReportForQuestionary(lstApplications);
        }
    }
}