trigger BatchApexErrorEventTrigger on BatchApexErrorEvent (after insert) {
    if(Log_Trace_Utils__mdt.getInstance(BatchApexErrorEventTriggerHandler.TRIGGER_METADATA).Is_Logging_Needed__c)//Logs will not be registered, if checkbox is false 
    {
        BatchApexErrorEventTriggerHandler.afterInsert(Trigger.new);
    }
}