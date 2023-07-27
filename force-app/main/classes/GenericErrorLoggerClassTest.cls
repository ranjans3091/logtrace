@isTest
private class GenericErrorLoggerClassTest {
    @isTest
    private static void testDMLLogException() {
      Test.startTest(); 
      try
       {
          insert new Account(Rating='Hot');
       }catch(Exception ee)
       {
        GenericErrorLoggerClass.logException(ee,'GenericErrorLoggerClassTest');
        Test.getEventBus().deliver(); 
       }
       Test.stopTest();
       System.assertEquals(1, [SELECT Id FROM ErrorLog__c].size());
    }
    @isTest
    private static void testQueryLogException() {
      Test.startTest(); 
      try
       {
          Account acc = [SELECT Id FROM Account WHERE Id='001234234435w23'];
       }catch(Exception ee)
       {
        GenericErrorLoggerClass.logException(ee,'GenericErrorLoggerClassTest');
        Test.getEventBus().deliver(); 
       }
       Test.stopTest();
       System.assertEquals(1, [SELECT Id FROM ErrorLog__c].size());
    }
    @isTest
    private static void testInterfaceExtendedClass() {
        Test.startTest(); 
        Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(ErrorLogEventTriggerHandler.TRIGGER_METADATA);
        list<Error_Log__e> errorLogList = new list<Error_Log__e>();
        errorLogList.add(new Error_Log__e(Error_Message__c='Test Error',
                                          Error_Source__c = 'Apex',
                                          Component_Name__c = 'GenericErrorLoggerClassTest'
                                         )
                        );
        ErrorLogEventTriggerHandler.callExtensionClass(errorLogEventInstance, errorLogList);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM ErrorLog__c].size());
    }
}