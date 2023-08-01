/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        20th July 2023
* @Description: Trigger handler class for ErrorLogEventTrigger.
*               The ErrorLogEventTriggerHandler class handles the platform event trigger for Error_Log__e events.
*               It provides a mechanism to process and log the error events based on custom metadata settings.
*               logging the error information into the organization's error log object or invoking an external logging extension using LoggerInterface
* @TestClass:   GenericErrorLoggerClassTest 
***********************************************************************************************/
public class ErrorLogEventTriggerHandler {
    /**
     * @Title: TRIGGER_METADATA
     * @Description:Constant variable to hold the name of the Custom Metadata Type record used for configuration.
    **/
    public static final string TRIGGER_METADATA = 'Custom_Log_Error_Utils';
    /**
     * @Title: afterInsert
     * @Description:Method invoked after the insertion of Error_Log__e platform event records.
	 *              It processes the events and logs them based on custom metadata settings.
	 * @param errorEventList The list of Error_Log__e platform event records to be processed.
    **/
    public static void afterInsert(list<Error_Log__e> errorEventList)
    {
        try
        {
            Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(TRIGGER_METADATA);
            if(errorLogEventInstance?.Is_Extension_Required__c && String.isNotBlank(errorLogEventInstance?.Logging_Extension_Class__c))
            {
                //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
                callExtensionClass(errorLogEventInstance, errorEventList);                       
            }else
            {
                list<ErrorLog__c> errorLogList = new list<ErrorLog__c>();  // you can change this to your organization's error logging object here or at the custom metadat level
                for(Error_Log__e errorLogInstance : errorEventList)
                {
                    errorLogList.add(new ErrorLog__c(
                        Error_Message__c = errorLogInstance.Error_Message__c,
                        Error_Source__c = errorLogInstance.Error_Source__c,
                        Exception_Type__c = errorLogInstance.Exception_Type__c,
                        Stack_Trace__c = errorLogInstance.Error_Stacktrace__c,
                        Line_Number__c = errorLogInstance.Line_Number__c,
                        Limits__c = errorLogInstance.Limits_Snapshot__c,
                        Inaccessible_Fields_Details__c = errorLogInstance.Inaccessible_Fields_Details__c,
                        Record_Id__c = errorLogInstance.Record_Id__c,
                        Current_User__c = errorLogInstance.Current_User__c,
                        Component_Name__c = errorLogInstance.Component_Name__c
                    ));
                }
                list<DataBase.SaveResult> errorLogSaveResults = Database.insert(errorLogList);
            }
            
        }catch(Exception ee)
        {
            if (EventBus.TriggerContext.currentContext().retries < 4) 
            {
                // Condition isn't met, so try again later.
                throw new EventBus.RetryableException( 'Condition is not met, so retrying the trigger again' );
            }else
            {
                // Trigger was retried enough times so give up and
                // resort to alternative action.
                //probably add a seperate record into error log of platform event type  
            }
        }  
    }
    @TestVisible
    private static void callExtensionClass(Log_Trace_Utils__mdt errorLogEventInstance, list<Error_Log__e> errorEventList)
    {
        //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
        Type classType = Type.forName(errorLogEventInstance.Logging_Extension_Class__c);  
        LoggerInterface errorLogInterface = (LoggerInterface)classType.newInstance();
        errorLogInterface.execute(errorEventList);    
    }
}