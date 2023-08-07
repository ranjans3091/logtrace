/**
 * @isTest
 * The `PurgeLogControllerTest` class contains test methods for the `PurgeLogController` class.
 */
@isTest
private class PurgeLogControllerTest {
	 @isTest
    private static void testPurgeLogRecords()
    {
        PurgeLogController.ResultWrapper result = PurgeLogController.purgeLogRecords('Custom_Log_Error_Utils');
        System.assertEquals(false, result.hasError, 'Record purged successfully!!');
        
    }
     @isTest
    private static void testNegetivePurgeLogRecords()
    {
         PurgeLogController.ResultWrapper result = PurgeLogController.purgeLogRecords(null);
         System.assertEquals(true, result.hasError, 'Error Occured');
    }
}