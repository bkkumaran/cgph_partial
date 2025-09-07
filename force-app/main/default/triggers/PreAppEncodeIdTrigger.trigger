trigger PreAppEncodeIdTrigger on PreApplicants__c (after Insert,before update) {
    List<PreApplicants__c> lstPreApplicant = trigger.new;
    CGPH_Triggers_Custom_Settings__c cgphSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
    if(cgphSettings != null && cgphSettings.Pre_Applicant_Id_Encode__c == true ){
        if(trigger.isInsert || (trigger.isUpdate && trigger.isBefore)){
            PreAppEncodeIdTriggerHandler objPreappHandler = new PreAppEncodeIdTriggerHandler ();
            objPreappHandler.updatePreAppEncodedId();
        }
    }
}