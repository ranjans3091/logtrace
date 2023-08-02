/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        22th July 2023
* @Description: The BatchApexErrorEventTriggerHandler class is responsible for handling BatchApexErrorEvent platform events Trigger.
*               logging the error information into the organization's error log object or invoking an external logging extension
*               based on the metadata settings. It processes the BatchApexErrorEvent records in the after-insert trigger context.
* @Implements: LoggerInterface
* @TestClass:   BatchApexErrorEventTest , SamplePlatformEventBatch(for data setup) 
***********************************************************************************************/
public with sharing class BatchApexErrorEventTriggerHandler {
    /** 
     * @Title: TRIGGER_METADATA
     * @Description:Constant variable to hold the name of the Custom Metadata Type record used for configuration.
    **/
	public static final string TRIGGER_METADATA = 'Batch_Apex_Error_Utils';
    /**
     * @Title: afterInsert
     * @Description:Processes the BatchApexErrorEvent records in the after-insert trigger context.
	 *              Depending on the custom metadata settings, it either invokes an external logging extension or inserts error information into the organization's error log object.
	 * @param batchErrorEventList The list of BatchApexErrorEvent records to be processed
    **/
    public static void afterInsert(list<BatchApexErrorEvent> batchErrorEventList)
    {
        try
        {
            Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(TRIGGER_METADATA);
            if(errorLogEventInstance?.Is_Extension_Required__c && String.isNotBlank(errorLogEventInstance?.Logging_Extension_Class__c))
            {
                //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
                callExtensionClass(errorLogEventInstance, batchErrorEventList);  
            }
            else
            {
                set<Id> asyncApexJobIds = new set<Id>();
                list<ErrorLog__c> errorLogList = new list<ErrorLog__c>(); // you can change this to your organization's error logging object here or at the custom metadat level
                for(BatchApexErrorEvent batchInst : batchErrorEventList)
                {
                    asyncApexJobIds.add(batchInst.AsyncApexJobId);
                }
                Map<Id,AsyncApexJob> asyncIdJobMap = new Map<Id,AsyncApexJob>([SELECT Id, ApexClass.Name 
                                                                               FROM AsyncApexJob 
                                                                               WHERE Id IN :asyncApexJobIds]
                                                                             );        
                
                for(BatchApexErrorEvent errorLogInstance : batchErrorEventList)
                {
                    errorLogList.add(new ErrorLog__c(
                        Component_Name__c = asyncIdJobMap.get(errorLogInstance.AsyncApexJobId)?.ApexClass.Name ,
                        Error_Message__c = errorLogInstance.Message,
                        Error_Source__c = 'Batch Apex',
                        Exception_Type__c = errorLogInstance.ExceptionType,
                        Stack_Trace__c = errorLogInstance.StackTrace,
                        Phase__c = errorLogInstance.Phase,
                        Record_Id__c = errorLogInstance.JobScope
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
    private static void callExtensionClass(Log_Trace_Utils__mdt errorLogEventInstance, list<BatchApexErrorEvent> batchErrorEventList)
    {
         //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
                Type classType = Type.forName(errorLogEventInstance.Logging_Extension_Class__c);  
                LoggerInterface errorLogInterface = (LoggerInterface)classType.newInstance();
                errorLogInterface.execute(batchErrorEventList);    
    }
}