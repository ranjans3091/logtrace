/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        24th July 2023
* @Description: The InterfaceErrorLogExtension class implements the LoggerInterface and 
*				provides a method to convert platform event records of type Error_Log__e into custom object records of type ErrorLog__c and insert them into the database.
* @Implements:  LoggerInterface
* @TestClass:   GenericErrorLoggerClassTest 
***********************************************************************************************/
public with sharing class InterfaceErrorLogExtension implements LoggerInterface {
    /**
     * @Title: execute
     * @Description:Converts a list of platform event records of type Error_Log__e into custom object records of type ErrorLog__c and inserts them into the database.
	 * @param logEventList The list of platform event records to be processed and inserted into the database.
    **/
    public static void execute(list<Error_Log__e> logEventList)
    {
        list<ErrorLog__c> errorLogList = new list<ErrorLog__c>();
 		for(Error_Log__e errorLogInstance : logEventList)
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
                Current_User__c = errorLogInstance.Current_User__c
            ));
        }
        list<DataBase.SaveResult> errorLogSaveResults = Database.insert(errorLogList);
    }
}