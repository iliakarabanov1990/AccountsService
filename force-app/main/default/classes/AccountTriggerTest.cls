@isTest
private class AccountTriggerTest {

    @isTest
    static void TestUpdateAccountWithSource() {

        List<Account> accts = new List<Account>();
        accts.add(new Account(Name='Test Account1', AccountSource = 'Other'));
        accts.add(new Account(Name='Test Account2', AccountSource = 'Web'));
        
        Test.startTest();
            Database.insert(accts, true, AccessLevel.USER_MODE);
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Account WHERE AccountSource2__c = 'Other'], 'Wrong filling AccountSource2__c in Account when AccountSource = Other');
        System.assertEquals(1, [SELECT Count() FROM Account WHERE AccountSource2__c = ''], 'Wrong filling AccountSource2__c in Account when AccountSource != Other');
    }
}