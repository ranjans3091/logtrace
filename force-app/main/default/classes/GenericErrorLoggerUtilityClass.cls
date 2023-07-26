/**
* @Author: Ranjan Singh
* @CreatedDate: 21.07.2023
* @description: The GenericErrorLoggerUtilityClass provides utility methods used by the GenericErrorLoggerClass.
* 				 It includes methods to get additional details for specific exception types and limit snapshot details.
*/
public class GenericErrorLoggerUtilityClass {
    /**
* @createdBy: Ranjan Singh
* @description: Gets a snapshot of Salesforce limits and returns them as a formatted string.
* @CreatedDate: 21.07.2023
* @return The formatted string containing a snapshot of Salesforce limits.
*/
    public static string getLimitDetails()
    {
        return 'Number of SOQL queries: '+Limits.getQueries()+' out of '+Limits.getLimitQueries() 	+'\n'+
            'Number of query rows: '+Limits.getQueryRows() +' out of '+Limits.getLimitQueryRows() +'\n'+
            'Number of SOSL queries: '+Limits.getSoslQueries() +' out of '+Limits.getLimitSoslQueries() +'\n'+
            'Number of DML statements: '+Limits.getDmlStatements() +' out of '+Limits.getLimitDmlStatements() 	+'\n'+
            'Number of DML rows: '+Limits.getDmlRows() +' out of '+Limits.getLimitDmlRows() 	+'\n'+
            'Maximum CPU time: '+Limits.getCpuTime() +' out of '+Limits.getLimitCpuTime() 	+'\n'+
            'Maximum heap size: '+Limits.getHeapSize() +' out of '+Limits.getLimitHeapSize() +'\n'+
            'Number of callouts: '+Limits.getCallouts() +' out of '+Limits.getLimitCallouts() +'\n'+
            'Number of Email Invocations: '+Limits.getEmailInvocations() +' out of '+Limits.getLimitEmailInvocations() +'\n'+
            'Number of future calls: '+Limits.getFutureCalls() +' out of '+Limits.getLimitFutureCalls() 	+'\n'+
            'Number of queueable jobs added to the queue: '+Limits.getQueueableJobs() +' out of '+Limits.getLimitQueueableJobs() 	+'\n'+ 
            'Number of Mobile Apex push calls: '+Limits.getMobilePushApexCalls() +' out of '+Limits.getLimitMobilePushApexCalls() ; 		
    }
    /**
* @description: Gets additional details specific to certain exception types and appends them to the error log.
* 				 This method can be extended to handle other types of exceptions as needed.
* @CreatedBy: Ranjan Singh
* @CreatedDate: 21.07.2023
* @param exceptionInstance The exception for which to get additional details.
* @param errorLogInstance The error log instance to which to append the details.
* @return The updated error log instance with additional details, if available.
*/
    public static Error_Log__e getExceptionTypeAddionalDetails(Exception exceptionInstance, Error_Log__e errorLogInstance)
    {
        if(exceptionInstance.getTypeName().containsIgnoreCase('DmlException'))
        {
            DmlException dmleInstance = (DmlException)exceptionInstance;
            errorLogInstance = getDMLExceptionDetails(dmleInstance, errorLogInstance);
        }else if(exceptionInstance.getTypeName().containsIgnoreCase('QueryException'))
        {
            QueryException qeInstance = (QueryException)exceptionInstance;
            errorLogInstance = getQueryExceptionDetails(qeInstance,errorLogInstance);
        }
        return errorLogInstance;
    }
    /**
* @description: Adds DMLException specific details to the error log instance.
* @param de The DMLException for which to add details.
* @param logInstance The error log instance to which to add the details.
* @return The updated error log instance with DMLException details.
* @CreatedDate: 21.07.2023
* @CreatedBy: Ranjan Singh
*/
    public static Error_Log__e getDMLExceptionDetails(DMLException de, Error_Log__e logInstance)
    {
        logInstance.Record_Id__c =  getRecordIdsFromDMLException(de, Trigger.new) ;
        return logInstance;
    }
    /**
* @description: Adds QueryException specific details to the error log instance.
* @param qe The QueryException for which to add details.
* @param logInstance The error log instance to which to add the details.
* @return The updated error log instance with QueryException details.
* @CreatedDate: 21.07.2023
* @CreatedBy: Ranjan Singh
*/
    public static Error_Log__e getQueryExceptionDetails(QueryException qe, Error_Log__e logInstance)
    {
        logInstance.Inaccessible_Fields_Details__c = String.valueOf(qe.getInaccessibleFields());
        return logInstance;
    }
    /**
@Apexdoc (Private Method)
@Title: getRecordIdsFromDMLException
@CreatedBy: Ranjan Singh
@CreatedDate: 21.07.2023
@Description: Helper method to extract record IDs from DMLException and return as a concatenated string.
@param exceptionInstance The DMLException for which to extract record IDs.
@param sobjectList The list of sObjects for which DML operation was attempted.
@return The concatenated string of record IDs separated by commas.
*/
    private static String getRecordIdsFromDMLException(DMLException exceptionInstance, list<SObject> sobjectList)
    {
        String recordIds ;
        if(Trigger.isExecuting  && sobjectList!= null && !sobjectList.isEmpty() && (sobjectList.size() >= exceptionInstance.getNumDml()))
        {
            for(Integer i=0; i< exceptionInstance.getNumDml() ; i++)
            {                
                if(String.isNotEmpty(sobjectList[i].Id))
                {
                    recordIds += sobjectList[i].Id + ',';    
                }        			    
            }
            if(String.isNotEmpty(recordIds))
            {
                recordIds = recordIds.removeEnd(',');    
            }      
        }              
        return recordIds;
    }
}