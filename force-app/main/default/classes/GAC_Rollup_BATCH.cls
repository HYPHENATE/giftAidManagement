/**
 * @description     batch rollup class for performing an aggregated result against a gift aid claim
 * @author          daniel@hyphen8.com
 * @date            20/04/2020
 * @group           Rollups
*/
public class GAC_Rollup_BATCH implements Database.Batchable<sObject>{
    
    /**
     * @description     The querylocation within the batch class to find claims that need have their rollups run
     * @param           Database.BatchableContext BC
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        string allowedstatus = 'New';
        String query = 'SELECT Id,Claim_Amount__c FROM Gift_Aid_Claim__c WHERE Status__c=allowedstatus ';
        return Database.getQueryLocator(query);
    }

    /**
     * @description     the execution process for this batch class
     * @param           Database.BatchableContext BC
     * @param           List<Gift_Aid_Claim__c gacs
    */
    public void execute(Database.BatchableContext BC, List<Gift_Aid_Claim__c> gacs){
        List<Gift_Aid_Claim__c> gaClaims = new List<Gift_Aid_Claim__c>();
        for( Gift_Aid_Claim__c gac : gacs){
            AggregateResult[] claimedAmountOpps = [SELECT Sum(Amount)total FROM Opportunity WHERE Gift_Aid_Claim__c=:gac.Id];
            Object claimAmountObject = claimedAmountOpps[0].get('total');
            decimal claimAmount = 0;
            if(claimAmountObject!=null){
                claimAmount = (decimal)claimAmount;
            }
            gac.Claim_Amount__c = claimAmount;
            gaClaims.add(gac);
        }
        update gaClaims;
    }

    /**
     * @description     this is the finish method on this batch class just output a debug log of what has happened
     * @param           Database.Batchable BC
     */
    public void finish(Database.BatchableContext BC){}
}