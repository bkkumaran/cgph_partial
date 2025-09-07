trigger ServiceFileActionsTrigger on HOMEtracker__Service_File__c (before insert,before update)
{
    if( ServiceFileActionsHandler.isServiceFileActionsHandlerExecuted == false || Test.isRunningTest()) // avoid recurrion
	    ServiceFileActionsHandler.runActions(trigger.New);
}