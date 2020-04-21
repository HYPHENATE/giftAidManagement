/**
 * @description     DataFactory class for supporting with the creation of data for testing
 * @author          daniel@hyphen8.com
 * @date            19/04/2020
 * @group           Tests
*/
@isTest
public with sharing class GA_DataFactory {
    
    /**
     * @description     in memory is used to confirm if we should be creating the records or just returing them
    */
    public static boolean inMemory;

    /**
     * @description     method to create our custom setting
     * @return          Gift_Aid_Configuration__c
    */
    public static Gift_Aid_Configuration__c createGiftAidConfiguration(){
        Gift_Aid_Configuration__c gacCS = new Gift_Aid_Configuration__c();
        gacCs.Claim_back_year__c = 4;
        gacCS.GAC_Review_Status__c = 'In Review';
        gacCS.Gift_Aid_Rate__c = 25;
        gacCS.Months_between_claims__c = 1;
        gacCS.Process_Gift_Aid__c = true;
        gacCS.Send_batch_completion_email__c = true;
        gacCS.Primary_Contact_Field__c = 'Gift_Aid_Contact__c';
        gacCS.Gift_Aid_Confirmation_Field__c = 'Giftable_Record__c';

        if(!inMemory){
            insert gacCS;
        }
        return gacCS;
    }

    
    /**
     * @description     create a user
     * @param           ID profileid
     * @param           string firstName
     * @param           string lastName
     * @return          User
    */
    public static User createUser(id profileid, string firstName, string lastName){
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = firstName,
            LastName = lastName, 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        if(!inMemory){
            insert user;
        }
        return user;
    }

    /**
     * @description     create an Account
     * @param           string name of the Account
     * @return          Account
    */
    public static Account createAccount(string name){
        Account account = new Account(Name=name);
        if(!inMemory){
            insert account;
        }
        return account;
    }

    /**
     * @description     create a Contact
     * @param           string accountId for the Account we are linking the contact to
     * @param           string firstName
     * @param           string lastName
     * @return          Contact
    */
    public static Contact createContact(string accountId, string firstName, string lastName){
        Contact contact = new Contact(FirstName=firstName, LastName=lastName, AccountID=accountid);
        if(!inMemory){
            insert contact;
        }
        return contact;
    }

    /**
     * @description     create a Gift Aid Claim
     * @param           date startDate
     * @return          Gift_Aid_Claim__c
    */
    public static Gift_Aid_Claim__c createGiftAidClaim(date startDate){
        Gift_Aid_Claim__c giftAidClaim = new Gift_Aid_Claim__c(Claim_start_date__c=startDate);
        if(!inMemory){
            insert giftAidClaim;
        }
        return giftAidClaim;
    }

    /**
     * @description     create an Opportunity record
     * @param           string oppName
     * @param           string accountId
     * @param           date closeDate
     * @param           string stageName
     * @param           decimal amount
     * @param           string gacId
     * @return          Opportunity
    */
    public static Opportunity createOpportunity(string oppName, string accountId, date closeDate, string stageName, decimal amount, string gacId){
        Opportunity opportunity = new Opportunity(Name=oppName,AccountId=accountId,CloseDate=closeDate,StageName=stageName,Amount=amount, Gift_Aid_Claim__c=gacId);
        if(!inMemory){
            insert opportunity;
        }
        return opportunity;
    }

    /**
     * @description     create a list Opportunities 
     * @param           string oppName
     * @param           string accountId
     * @param           date closeDate
     * @param           string stageName
     * @param           decimal amount
     * @param           string gacId
     * @param           integer noOfOpportunities
     * @return          List<Opportunity>
    */
    public static List<Opportunity> createOpportunityList(string oppName, string accountId, date closeDate, string stageName, decimal amount, string gacId, integer noOfOpportunities){
        List<Opportunity> listOfOpportunity = new List<Opportunity>();
        for(Integer i=0;i<noOfOpportunities;i++) {
            Opportunity opportunity = new Opportunity(Name=oppName + ' ' + i,AccountId=accountId,CloseDate=closeDate,StageName=stageName,Amount=amount, Gift_Aid_Claim__c=gacId);
            listOfOpportunity.add(opportunity);
        }
        if(!inmemory){
            insert listOfOpportunity;
        }
        return listOfOpportunity;
    }

}