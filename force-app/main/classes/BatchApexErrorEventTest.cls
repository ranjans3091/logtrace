@isTest
private with sharing class BatchApexErrorEventTest {
    static testmethod void testLoadData()
    {
        List<sObject> ls = Test.loadData(Account.sObjectType, 'AccountList');          
        list<Account> accountList = [SELECT Id,Name FROM Account];        
        try
        {                    
            Test.startTest();        
            Database.executeBatch(new SamplePlatformEventBatch(),2000); 
            
            Test.stopTest();  
            Test.getEventBus().deliver(); 
            Assert.areEqual(1, Limits.getPublishImmediateDML());
        }catch(Exception ee){}
        Test.getEventBus().deliver(); 
        Assert.areEqual([SELECT Id FROM ErrorLog__c].size(), 1); // Succeeds       
        
    }
     @isTest static void testValidFlowEvent()
    {        
        Test.startTest();        
        list<FlowExecutionErrorEvent> flowErrorEventList = new list<FlowExecutionErrorEvent>();
        flowErrorEventList.add(new FlowExecutionErrorEvent(ErrorMessage = 'Custom Flow Exception',
                                                           FlowApiName = 'TestFlowAPIName')); //publishing a standard flow is not available.
        //This standard flow error event only invoked from screen flow. Thus we cannot use autolauched flow for test coverage.
        FlowExecutionEventHandler.insertFlowErrorEventLog(flowErrorEventList);     
        
        
        Test.stopTest();
        
        list<ErrorLog__c> errorLogList = [SELECT Id 
                                          FROM ErrorLog__c];
        System.assertEquals(1, errorLogList.size()); 
    }
    @isTest
    private static void testInterfaceBatchExtendedClass() {
        Test.startTest(); 
        Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(BatchApexErrorEventTriggerHandler.TRIGGER_METADATA);
        list<BatchApexErrorEvent> errorLogList = new list<BatchApexErrorEvent>();
        errorLogList.add(new BatchApexErrorEvent(Message='Test Error',
                                                 ExceptionType = 'Apex'
                                                )
                        );
        BatchApexErrorEventTriggerHandler.callExtensionClass(errorLogEventInstance, errorLogList);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM ErrorLog__c].size());
    }
    @isTest
    private static void testInterfaceFlowExtendedClass() {
        Test.startTest(); 
        Log_Trace_Utils__mdt errorLogEventInstance = Log_Trace_Utils__mdt.getInstance(FlowExecutionEventHandler.TRIGGER_METADATA);
        list<FlowExecutionErrorEvent> errorLogList = new list<FlowExecutionErrorEvent>();
        errorLogList.add(new FlowExecutionErrorEvent(ErrorMessage='Test Error',
                                                     FlowApiName = 'Test Screen Flow'
                                                    )
                        );
        FlowExecutionEventHandler.callExtensionClass(errorLogEventInstance, errorLogList);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM ErrorLog__c].size());
    }
}