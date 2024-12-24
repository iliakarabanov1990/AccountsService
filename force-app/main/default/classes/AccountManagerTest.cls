@isTest
public with sharing class AccountManagerTest {

    @TestSetup
    static void makeData(){
        Database.insert(new Account(Name = 'Test1'), true, AccessLevel.USER_MODE);    
    }

    @isTest
    static void testHttpGet() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Accounts';
        req.httpMethod = 'GET';
        req.addParameter('name', 'Tes');
        req.addParameter('fields', 'name,phone,fax');
        req.addParameter('offset', '0');
        req.addParameter('limit', '10');

        RestContext.response = new RestResponse();
        RestContext.request = req;      

        Test.startTest();
            List<Account> actualResponse = AccountManager.getAccounts();
        Test.stopTest();

        System.assertEquals(1, actualResponse.size(), 'GET method works incorrectlly');
    }


    @isTest
    static void testHttpPost() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Accounts';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"name": "test2"}]');

        RestContext.response = new RestResponse();
        RestContext.request = req;      

        Test.startTest();
            List<Account> actualResponse = AccountManager.createAccounts();
        Test.stopTest();

        System.assertEquals(1, actualResponse.size(), 'POST method works incorrectlly');
    }

    @isTest
    static void testHttpPatch() {

        Account acc = [SELECT Id FROM Account];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Accounts';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('[{"Id": "' + acc.Id + '", "name": "TestPatch"}]');

        RestContext.response = new RestResponse();
        RestContext.request = req;      

        Test.startTest();
            List<Account> actualResponse = AccountManager.updateAccounts();
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Account WHERE Name = 'TestPatch'], 'PATCH method works incorrectlly');
    }

    @isTest
    static void testHttpDelete() {

        Account acc = [SELECT Id FROM Account];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Accounts';
        req.httpMethod = 'DELETE';
        req.addParameter('Id', acc.Id);

        RestContext.response = new RestResponse();
        RestContext.request = req;      

        Test.startTest();
            List<Account> actualResponse = AccountManager.deleteAccount();
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Account], 'DELETE method works incorrectlly');
    }

}