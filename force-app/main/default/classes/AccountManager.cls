@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountManager {

    @HttpGet
    global static List<Account> getAccounts() {

        RestRequest request = RestContext.request;
        Set<String> fieldSet = new Set<String>();
        Map<String, Object> acctBinds = new Map<String, Object>{'accountName'=>'', 'offsetCount'=>0, 'limitCount'=>0};
            
        if(request.params.containsKey('name')) { acctBinds.put('accountName', '%' + String.escapeSingleQuotes(request.params.get('name')) + '%'); }
        if(request.params.containsKey('fields')) { fieldSet.addAll(String.escapeSingleQuotes(request.params.get('fields')).toLowerCase().split(',')); }
        if(!fieldSet.contains('name')) { fieldSet.add('name'); }
        
        if(!request.params.containsKey('offset') || !request.params.containsKey('limit')) { 
            RestContext.response.statusCode = 400;
           	throw new AccountManagerException('wrong parameters: ' + request.requestURI);
        }

        try{
            acctBinds.put('offsetCount', Integer.valueOf(request.params.get('offset'))); 
            acctBinds.put('limitCount', Integer.valueOf(request.params.get('limit')));
        } catch(Exception e){
            RestContext.response.statusCode = 400;
            throw new AccountManagerException('wrong parameters: ' + e.getMessage());
        }  
     
        return Database.queryWithBinds(' SELECT ' + String.join(fieldSet, ', ') +
                                       ' FROM Account ' + (acctBinds.get('accountName') == '' ? '' : 
                                       ' WHERE Name LIKE :accountName') + 
                                       ' ORDER BY Name' +
                                       ' LIMIT :limitCount OFFSET :offsetCount', 
                                       		acctBinds, AccessLevel.USER_MODE);
    }

    @HttpPost
    global static List<Account> createAccounts() {
        
        List<Account> accs = (List<Account>)JSON.deserialize(RestContext.request.requestbody.tostring(), List<Account>.class);    

        try {
            Database.insert(accs, true, AccessLevel.USER_MODE); 
        } catch (Exception e) { 
            RestContext.response.statusCode = 400;
            throw new AccountManagerException(e.getMessage());          
        }
        
        return accs;
    }  
    
    @HttpPatch
    global static List<Account> updateAccounts() {
        
		List<Account> accs = (List<Account>)JSON.deserialize(RestContext.request.requestbody.tostring(), List<Account>.class);
        
        try {
            Database.update(accs, true, AccessLevel.USER_MODE);
        } catch (Exception e) { 
        	RestContext.response.statusCode = 400;
            throw new AccountManagerException(e.getMessage());
        }

        return accs;
    }
    
    @HttpDelete
    global static List<Account> deleteAccount() {
 
        String accountId = RestContext.request.params.get('Id');
        List<Account> accs = [SELECT Id FROM Account WHERE Id = :accountId WITH USER_MODE LIMIT 1];

        if(accs.size() == 0) { 
            RestContext.response.statusCode = 400;
            throw new AccountManagerException('Account with ID ' + accountId + ' is not exist!');      	
        }

        Account acc = accs[0];

        try {
            Database.delete(acc, true, AccessLevel.USER_MODE); 
        } catch (Exception e) { 
            RestContext.response.statusCode = 400;
            throw new AccountManagerException(e.getMessage());           
        }

        return accs;
    }
    
    private class AccountManagerException extends Exception {}   
}