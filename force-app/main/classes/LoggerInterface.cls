/**********************************************************************************************
* @Author:      Ranjan Singh
* @Date:        19th July 2023
* @Description: The LoggerInterface is a global interface in Salesforce Apex that provides a standardized method to execute logging operations.
*				Classes that implement this interface must define the 'execute' method to handle logging of Salesforce sObjects.
*				This interface can be extended or customized based on your organization's error logging object and requirements.
***********************************************************************************************/ 
global interface LoggerInterface {
    /**
     * @Title: execute
     * @Description:This method is used to perform logging operations on a list of Salesforce sObjects.
     * 				Implementing classes must define this method to handle the specific logging logic.
	 * @param sobjList The list of sObjects to be logged.
    **/
	void execute(list<sObject> sobjList);
}