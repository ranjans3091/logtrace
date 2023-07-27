trigger ErrorLogEventTrigger on Error_Log__e (after insert) {
    if(Log_Trace_Utils__mdt.getInstance(ErrorLogEventTriggerHandler.TRIGGER_METADATA).Is_Logging_Needed__c)//Logs will not be registered, if checkbox is false 
    {
        ErrorLogEventTriggerHandler.afterInsert(Trigger.new); 
    }
}