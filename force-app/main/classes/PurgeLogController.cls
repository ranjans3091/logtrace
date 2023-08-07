/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        1st August 2023
* @Description: The 'PurgeLogController' class provides functionality to purge log records based on specified criteria.
* @TestClass:   PurgeLogControllerTest 
***********************************************************************************************/
public with sharing class PurgeLogController {
   /**
    * @Title: SUCCESS_MESSAGE
    * @Description:Constant variable to hold the success message.
    **/
    private static final string SUCCESS_MESSAGE = ' Log deleted Successfully !!';
    private static final string CUSTOM_ERROR_MESSAGE = 'Incorrect data setup. Please check custom metadata configuration!!';

    /**
    * @Title: ERROR_DAYS
    * @Description:Constant variable to hold the default error days.
    **/
    private static final Integer ERROR_DAYS = 100;
	/**
	 * @Author: Ranjan Singh
     * @Description: Purges log records based on the specified log type.
     * It provides a method `purgeLogRecords` to perform the purging operation.
     * @param logType The type of log to be purged.
     * @return A `ResultWrapper` instance containing the purge status message.
     */
    @AuraEnabled
    public static ResultWrapper purgeLogRecords(String logType)
    {
        ResultWrapper wrapperInstance; 
        try
        {
            Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(logType);
            String purgeObject =  (errorLogEventInstance?.Is_Purging_Required_for_Logging__c && errorLogEventInstance?.Purging_Object__c!= null) ? errorLogEventInstance.Purging_Object__c:'ErrorLog__c';
            Integer purgingDays = (errorLogEventInstance?.Is_Purging_Required_for_Logging__c && errorLogEventInstance?.Log_Purging_Days__c!= null) ? (Integer)errorLogEventInstance?.Log_Purging_Days__c: ERROR_DAYS;
            if(purgingDays!=null && String.isNotBlank(purgeObject))
            {
                String logTracePurgeQuery = 'SELECT Id FROM '+ purgeObject + ' WHERE CreatedDate < LAST_N_DAYS:'+purgingDays;
                list<sObject> logList = Database.query(logTracePurgeQuery);
                Database.delete(logList);
                wrapperInstance = new ResultWrapper(logList.size() + SUCCESS_MESSAGE, false);
            }else
            {
                wrapperInstance = new ResultWrapper(CUSTOM_ERROR_MESSAGE, true);
            }
        }catch(QueryException qe)
        {
          GenericErrorLoggerClass.logException(qe, 'PurgeLogController');
          wrapperInstance = new ResultWrapper(qe.getMessage(), true);
        }catch(DMLException de)
        {
            GenericErrorLoggerClass.logException(de, 'PurgeLogController');
            wrapperInstance = new ResultWrapper(de.getDMLMessage(0), true);
        }catch(Exception ee)
        {
          GenericErrorLoggerClass.logException(ee, 'PurgeLogController');
          wrapperInstance = new ResultWrapper(ee.getMessage(), true);
        }
        return wrapperInstance;
    }

    public class ResultWrapper
    {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean hasError;
        public ResultWrapper(String message, Boolean hasError)
        {   
            this.hasError = hasError;
            this.message = message;
        }
    }
}