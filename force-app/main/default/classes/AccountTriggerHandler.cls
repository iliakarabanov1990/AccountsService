public class AccountTriggerHandler extends TriggerHandler{
   
    public override void beforeUpdate() { updateAccountSource2(); } 
    public override void beforeInsert() { updateAccountSource2(); }
    
	private void updateAccountSource2() {
        for(sObject accObj : Trigger.new) {    
            Account acc = (Account)accObj;
            acc.AccountSource2__c = acc.AccountSource == 'Other' ? 'Other' : '';         
        }    
    }
}