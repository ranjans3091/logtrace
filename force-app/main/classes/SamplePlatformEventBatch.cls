/**********************************************************************************************
* @Author:      Ranjan Singh 
* @Date:        16th July 2023
* @Description: This class will be used to demonstrate the platform event error logging. Will be used in test classes
***********************************************************************************************/
public class SamplePlatformEventBatch implements Database.Batchable<SObject>,Database.RaisesPlatformEvents{
    /**
     * @Title: afterInsert
     * @Description:This method is the starting point of the batch execution. It retrieves a list of Account records
	 *              with names matching 'Bulk Data Load Test PE%' and returns them for processing in the batch.
	 * @param ctx The batchable context for the current batch execution.
	 * @return A list of Account records to be processed in the batch.
    **/
    public List<Account> start(Database.BatchableContext ctx) 
    {
        return [SELECT Id,Name FROM Account 
                WHERE Name like 'Bulk Data Load Test PE%'
                ORDER BY Name desc LIMIT 2000]; 
    }
    /**
     * @Title: execute
     * @Description:This method processes each Account record in the batch's scope. It calls the errorGeneratorMethod
	 * @param  bc The batchable context for the current batch execution.
	 * @param scope The list of Account records to be processed in the current batch.
	 * @return A list of Account records to be processed in the batch.
    **/
    public void execute(Database.BatchableContext bc, List<SObject> scope) 
    {                 
        for(Account accInst : (List<Account>)scope) 
        {
            errorGeneratorMethod(accInst.Name); //this will throw 3 diffrent types of error.           
        }                                      
    }
    /**
     * @Title: finish
     * @Description:This method is called after the batch execution finishes. It currently has no specific logic implemented
	 *              in this class, but you can add any post-processing logic or cleanup code if required.
	 * @param bc The batchable context for the current batch execution.
    **/
    public void finish(Database.BatchableContext bc) { }
    /**
     * @Title: errorGeneratorMethod
     * @Description:This method generates various types of errors based on the given accountName.
	 * @param accountName The name of the Account record for which the error is being generated.
	 * @throws AccountException When accountName matches 'Bulk Data Load Test PE 201' or 'Bulk Data Load Test PE 1305'.
    **/
    public static void errorGeneratorMethod(String accountName)
    {   
        switch on accountName{
            when 'Bulk Data Load Test PE 7'{
               Account acc = [SELECT Id FROM Account WHERE Id='001234234435w23']; //query exception
            }
            when 'Bulk Data Load Test PE 201'{
                throw new AccountException('New Account Exception.'); 
            }
        }
        
    }            
    
    /**********************************************************************************************
* @Author:      Ranjan Singh 
* @Date:        16th July 2023
* @Description: This class extends the salesforce exception class.
***********************************************************************************************/
    public with sharing class AccountException extends Exception {
        
    }
}