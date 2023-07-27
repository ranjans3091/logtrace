/**
 * @Author: Ranjan Singh
 * Created Date: 21.07.2023
 * @description: The GenericErrorLoggerClass provides a utility method to log exceptions in Salesforce
 *               as platform events for error tracking and analysis.
 */
public class GenericErrorLoggerClass {
	/**
	 * Created By: Ranjan Singh
     * @description: Logs the given exception as a platform event for error tracking.
     * @param exceptionInstance The exception to be logged.
     * @param componentName The name of the component where the exception occurred.
     */
    public static void logException(System.Exception exceptionInstance, String componentName)
    {
        Error_Log__e errorLogInstance = new Error_Log__e(
        												 Component_Name__c = componentName,
            											 Current_User__c = UserInfo.getUserId(),
            											 Error_Message__c = exceptionInstance.getMessage(),
            											 Error_Stacktrace__c = exceptionInstance.getStackTraceString(),
            											 Error_Source__c = String.valueOf(Request.getCurrent().getQuiddity()),
        												 Exception_Type__c = exceptionInstance.getTypeName(),
            											 Limits_Snapshot__c = GenericErrorLoggerUtilityClass.getLimitDetails(),
            											 Line_Number__c =  exceptionInstance.getLineNumber()
        												);
        
        errorLogInstance = GenericErrorLoggerUtilityClass.getExceptionTypeAddionalDetails(exceptionInstance, errorLogInstance);
        system.debug('errorLogInstance**'+errorLogInstance);
        EventBus.publish(errorLogInstance);
    }
}