/**
 * @description     batch rollup class for performing an aggregated result against a gift aid claim
 * @author          daniel@hyphen8.com
 * @date            20/04/2020
 * @group           Rollups
*/
public class GAC_Rollup_BATCH implements Database.Batchable<sObject>, Database.Stateful{

    // set out custom settings to be public
    public Gift_Aid_Configuration__c gacCS = Gift_Aid_Configuration__c.getOrgDefaults();
    
    // set a global decimal for amount
    public decimal processedAmount;

    // set a global integer for number of records
    public integer processedRecordCount;

    /**
     * @description     The querylocation within the batch class to find claims that need have their rollups run
     * @param           Database.BatchableContext BC
     */
    public Database.QueryLocator start(Database.BatchableContext context){
        string allowedStatus = 'New';
        String query = 'SELECT Id,Claim_Amount__c,Claim_start_date__c, Claim_end_date__c FROM Gift_Aid_Claim__c WHERE Status__c=:allowedStatus ';
        return Database.getQueryLocator(query);
    }

    /**
     * @description     the execution process for this batch class
     * @param           Database.BatchableContext BC
     * @param           List<Gift_Aid_Claim__c gacs
    */
    public void execute(Database.BatchableContext context, List<Gift_Aid_Claim__c> gacs){

        integer numberOfMonths = integer.valueof(gacCS.Months_between_claims__c);

        // set up a list for update   
        List<Gift_Aid_Claim__c> gaClaims = new List<Gift_Aid_Claim__c>();

        // lop through the list of GACs found
        for( Gift_Aid_Claim__c gac : gacs){

            // get list of values
            List<Decimal> aggregatedAmounts = GAC_Rollup_BATCH_Helper.getAggregatedAmount(gac.Id);
            
            // set claim amount
            gac.Claim_Amount__c = aggregatedAmounts[0];

            // calculate the claim end date
            date claimEndDate = gac.Claim_Start_Date__c.addMonths(numberOfMonths).addDays(-1);

            // set claim end date
            gac.Claim_end_date__c = claimEndDate;

            // if claimenddate was yesterday move to In Review
            if(claimEndDate==system.today().addDays(-1)){
                gac.Status__c = gacCS.GAC_Review_Status__c;
            }

            // add the claim for update
            gaClaims.add(gac);

            // set public values
            processedAmount = aggregatedAmounts[0];
            processedRecordCount = integer.valueof(aggregatedAmounts[1]);

        }
        update gaClaims;
    }

    /**
     * @description     this is the finish method on this batch class just output a debug log of what has happened
     * @param           Database.Batchable BC
     */
    public void finish(Database.BatchableContext context){
        
        // check if the email notification sending is enabled
        if(gacCS.Send_batch_completion_email__c){
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:context.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Gift Aid Claim Processing Completed ' + a.Status);
            mail.setPlainTextBody('This claim has a total of ' + processedRecordCount + ' income records related to it with a value of £' + processedAmount + '.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}