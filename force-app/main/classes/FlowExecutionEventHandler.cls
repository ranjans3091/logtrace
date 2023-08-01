/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        26th July 2023
* @Description: Handler class for FlowExecutionErrorEventFlow Flow.
*               The FlowExecutionEventHandler class is invoked from FlowExecutionErrorEventFlow to log flow related error info to Error Log object.
*               It provides a mechanism to process and log the error events based on custom metadata settings.
* @TestClass:   TBD 
***********************************************************************************************/
public with sharing class FlowExecutionEventHandler {
    /**
     * @Title: TRIGGER_METADATA
     * @Description:Constant variable to hold the name of the Custom Metadata Type record used for configuration.
    **/
    public static final string TRIGGER_METADATA = 'Flow_Error_Logging_Utils';
    /**
     * @Title: afterInsert
     * @Description:Invocable method that handles the insertion of error logs based on FlowExecutionErrorEvent platform events.
	 *              It processes the events and logs them based on custom metadata settings.
	 * @param flowErrorEventList A list of FlowExecutionErrorEvent records containing error information from Flow executions.
    **/
    @InvocableMethod(label='Insert Error Log' description='Error Log will stire data from FlowExecutionErrorEvent' category= 'FlowExecutionErrorEvent')
    public static void insertFlowErrorEventLog(list<FlowExecutionErrorEvent> flowErrorEventList)
    {
        try
        {
            Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(TRIGGER_METADATA);
            if(errorLogEventInstance?.Is_Extension_Required__c && String.isNotBlank(errorLogEventInstance?.Logging_Extension_Class__c))
            {
                //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
                callExtensionClass(errorLogEventInstance, flowErrorEventList);                     
            }else
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
        }catch(Exception ee)
        {
            
        }
    }
    @TestVisible
    private static void callExtensionClass(Log_Trace_Utils__mdt errorLogEventInstance, list<FlowExecutionErrorEvent> flowErrorEventList)
    {
        //Dynamically fetch the extension handler class and invoke the method. You can create a new class extending LoggerInterface and write your logging logic there.
        Type classType = Type.forName(errorLogEventInstance.Logging_Extension_Class__c);  
        LoggerInterface errorLogInterface = (LoggerInterface)classType.newInstance();
        errorLogInterface.execute(flowErrorEventList);    
    }
}