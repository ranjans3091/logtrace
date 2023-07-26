/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        24th July 2023
* @Description: The InterfaceFlowErrorLogExtension class implements the LoggerInterface and 
*				provides a method to convert platform event records of type FlowExecutionErrorEvent into custom object records of type ErrorLog__c and 
*				insert them into the database.
*				This class can be extended or customized based on your organization's error logging object and requirements.
* @Implements:  LoggerInterface
* @TestClass:   BatchApexErrorEventTest 
***********************************************************************************************/
public with sharing class InterfaceFlowErrorLogExtension implements LoggerInterface {
    /**
     * @Title: execute
     * @Description:This method processes a list of FlowExecutionErrorEvent records and logs the flow execution errors in the specified error logging object.
	 * 				For each FlowExecutionErrorEvent, it creates an ErrorLog__c record and populates it with relevant error information from the FlowExecutionErrorEvent.
	 * 				The ErrorLog__c records are then inserted into the database using a bulk insert operation.
	 *  @param flowErrorEventList The list of FlowExecutionErrorEvent records containing flow execution error details.
    **/
    public static void execute(list<FlowExecutionErrorEvent> flowErrorEventList)
    {
        list<ErrorLog__c> errorLogList = new list<ErrorLog__c>(); // you can change this to your organization's error logging object here or at the custom metadat level
        for(FlowExecutionErrorEvent flowErrorInstance : flowErrorEventList)
        {
            //instantiate the error logging object and feed the error information from PE 
            errorLogList.add(new ErrorLog__c(
                Record_Id__c = flowErrorInstance.RelatedRecordId, 
                Error_Message__c = flowErrorInstance.ErrorMessage,
                Component_Name__c = flowErrorInstance.FlowApiName,
                Current_User__c = flowErrorInstance.UserId,
                Error_Source__c = 'Flow',
                Exception_Type__c = flowErrorInstance.EventType,
                Flow_Element_Type__c = flowErrorInstance.ElementType,
                Flow_Element_API_Name__c = flowErrorInstance.ElementApiName,
                Flow_Context_Record_Id__c = flowErrorInstance.ContextRecordId,
                Flow_Context_Object__c = flowErrorInstance.ContextObject
            ));  
        }
        list<DataBase.SaveResult> errorLogSaveResults = Database.insert(errorLogList);
    }
}