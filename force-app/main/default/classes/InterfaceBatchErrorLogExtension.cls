/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        24th July 2023
* @Description: The InterfaceBatchErrorLogExtension class provides a utility method to process a list of BatchApexErrorEvent records
*               and create corresponding ErrorLog__c records to log batch apex errors and exceptions.
*               logging the error information by invoking an external logging extension using LoggerInterface
* @TestClass:   BatchApexErrorEventTest 
***********************************************************************************************/
public with sharing class InterfaceBatchErrorLogExtension implements LoggerInterface{
    /**
     * @Title: execute
     * @Description:Processes a list of BatchApexErrorEvent records and creates ErrorLog__c records to log batch apex errors and exceptions.
	 * @param batchErrorEventList The list of BatchApexErrorEvent records to process.
    **/
    public static void execute(list<BatchApexErrorEvent> batchErrorEventList)
    {
        set<Id> asyncApexJobIds = new set<Id>();
        list<ErrorLog__c> errorLogList = new list<ErrorLog__c>(); 
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
}