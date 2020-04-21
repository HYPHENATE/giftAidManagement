/**
 * @description     test class for GAC_Rollup_BATCH
 * @author          daniel@hyphen8.com
 * @date            19/04/2020
 * @group           Tests
*/
@isTest
public with sharing class GAC_Rollup_BATCH_Test {
    
    /**
     * @description     basic test with one opp
    */
    public static testmethod void testOfBatchApexClass(){

        GA_DataFactory.inMemory = false;
        Gift_Aid_Configuration__c gacCS = GA_DataFactory.createGiftAidConfiguration();
        Account account = GA_DataFactory.createAccount('MAIN ACCOUNT');
        Contact contact = GA_DataFactory.createContact(account.Id, 'MAIN', 'CONTACT');
        Gift_Aid_Claim__c gaClaim = GA_DataFactory.createGiftAidClaim(system.today());
        Opportunity opportunity = GA_DataFactory.createOpportunity('MAIN OPPORTUNITY', account.Id, system.today(), 'Prospecting', 10000.00, gaClaim.Id);
        Test.startTest();
            GAC_Rollup_BATCH gacRollupBatch = new GAC_Rollup_BATCH();
            Id batchId = Database.executeBatch(gacRollupBatch);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10000.00, [SELECT Claim_Amount__c FROM Gift_Aid_Claim__c WHERE ID=:gaClaim.Id LIMIT 1].Claim_Amount__c, 'Expected amount found on gift aid claim');
    }

    /**
     * @description     basic test with one opp settings status to review
    */
    public static testmethod void testOfBatchApexClassChangeStatus(){

        GA_DataFactory.inMemory = false;
        Gift_Aid_Configuration__c gacCS = GA_DataFactory.createGiftAidConfiguration();
        system.debug(gacCS);
        Account account = GA_DataFactory.createAccount('MAIN ACCOUNT');
        Contact contact = GA_DataFactory.createContact(account.Id, 'MAIN', 'CONTACT');
        date startDate = system.today().addMonths(-1);
        Gift_Aid_Claim__c gaClaim = GA_DataFactory.createGiftAidClaim(startDate);
        Opportunity opportunity = GA_DataFactory.createOpportunity('MAIN OPPORTUNITY', account.Id, system.today(), 'Prospecting', 10000.00, gaClaim.Id);

        Test.startTest();
            GAC_Rollup_BATCH gacRollupBatch = new GAC_Rollup_BATCH();
            Id batchId = Database.executeBatch(gacRollupBatch);
        Test.stopTest();

        Gift_Aid_Claim__c gacRecord = [SELECT Claim_end_date__c, Claim_Amount__c, Status__c FROM Gift_Aid_Claim__c WHERE ID=:gaClaim.Id LIMIT 1];
        // after the testing stops, assert records were updated properly
        System.assertEquals(10000.00, gacRecord.Claim_Amount__c, 'Expected amount found on gift aid claim');
        System.assertEquals(gacCS.GAC_Review_Status__c, gacRecord.Status__c, 'Status of Gift Aid Claim is correct');
    }

    /**
     * @description     basic test with 100 opp settings status to review
    */
    public static testmethod void testOfBatchApexClassChangeStatus100(){

        GA_DataFactory.inMemory = false;
        Gift_Aid_Configuration__c gacCS = GA_DataFactory.createGiftAidConfiguration();
        system.debug(gacCS);
        Account account = GA_DataFactory.createAccount('MAIN ACCOUNT');
        Contact contact = GA_DataFactory.createContact(account.Id, 'MAIN', 'CONTACT');
        date startDate = system.today().addMonths(-1);
        Gift_Aid_Claim__c gaClaim = GA_DataFactory.createGiftAidClaim(startDate);
        List<Opportunity> opportunity = GA_DataFactory.createOpportunityList('MAIN OPPORTUNITY', account.Id, system.today(), 'Prospecting', 10000.00, gaClaim.Id, 100);

        Test.startTest();
            GAC_Rollup_BATCH gacRollupBatch = new GAC_Rollup_BATCH();
            Id batchId = Database.executeBatch(gacRollupBatch);
        Test.stopTest();

        Gift_Aid_Claim__c gacRecord = [SELECT Claim_end_date__c, Claim_Amount__c, Status__c FROM Gift_Aid_Claim__c WHERE ID=:gaClaim.Id LIMIT 1];
        // after the testing stops, assert records were updated properly
        System.assertEquals(1000000.00, gacRecord.Claim_Amount__c, 'Expected amount found on gift aid claim');
        System.assertEquals(gacCS.GAC_Review_Status__c, gacRecord.Status__c, 'Status of Gift Aid Claim is correct');
    }

    /**
     * @description     basic test with 1000 opp settings status to review
    */
    public static testmethod void testOfBatchApexClassChangeStatus1000(){

        GA_DataFactory.inMemory = false;
        Gift_Aid_Configuration__c gacCS = GA_DataFactory.createGiftAidConfiguration();
        system.debug(gacCS);
        Account account = GA_DataFactory.createAccount('MAIN ACCOUNT');
        Contact contact = GA_DataFactory.createContact(account.Id, 'MAIN', 'CONTACT');
        date startDate = system.today().addMonths(-1);
        Gift_Aid_Claim__c gaClaim = GA_DataFactory.createGiftAidClaim(startDate);
        List<Opportunity> opportunity = GA_DataFactory.createOpportunityList('MAIN OPPORTUNITY', account.Id, system.today(), 'Prospecting', 10000.00, gaClaim.Id, 1000);

        Test.startTest();
            GAC_Rollup_BATCH gacRollupBatch = new GAC_Rollup_BATCH();
            Id batchId = Database.executeBatch(gacRollupBatch);
        Test.stopTest();

        Gift_Aid_Claim__c gacRecord = [SELECT Claim_end_date__c, Claim_Amount__c, Status__c FROM Gift_Aid_Claim__c WHERE ID=:gaClaim.Id LIMIT 1];
        // after the testing stops, assert records were updated properly
        System.assertEquals(10000000.00, gacRecord.Claim_Amount__c, 'Expected amount found on gift aid claim');
        System.assertEquals(gacCS.GAC_Review_Status__c, gacRecord.Status__c, 'Status of Gift Aid Claim is correct');
    }

    /**
     * @description     basic test with 5000 opp settings status to review
    */
    public static testmethod void testOfBatchApexClassChangeStatus5000(){

        GA_DataFactory.inMemory = false;
        Gift_Aid_Configuration__c gacCS = GA_DataFactory.createGiftAidConfiguration();
        system.debug(gacCS);
        Account account = GA_DataFactory.createAccount('MAIN ACCOUNT');
        Contact contact = GA_DataFactory.createContact(account.Id, 'MAIN', 'CONTACT');
        date startDate = system.today().addMonths(-1);
        Gift_Aid_Claim__c gaClaim = GA_DataFactory.createGiftAidClaim(startDate);
        List<Opportunity> opportunity = GA_DataFactory.createOpportunityList('MAIN OPPORTUNITY', account.Id, system.today(), 'Prospecting', 10000.00, gaClaim.Id, 5000);

        Test.startTest();
            GAC_Rollup_BATCH gacRollupBatch = new GAC_Rollup_BATCH();
            Id batchId = Database.executeBatch(gacRollupBatch);
        Test.stopTest();

        Gift_Aid_Claim__c gacRecord = [SELECT Claim_end_date__c, Claim_Amount__c, Status__c FROM Gift_Aid_Claim__c WHERE ID=:gaClaim.Id LIMIT 1];
        // after the testing stops, assert records were updated properly
        System.assertEquals(50000000.00, gacRecord.Claim_Amount__c, 'Expected amount found on gift aid claim');
        System.assertEquals(gacCS.GAC_Review_Status__c, gacRecord.Status__c, 'Status of Gift Aid Claim is correct');
    }
}