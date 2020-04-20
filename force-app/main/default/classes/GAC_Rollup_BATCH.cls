/**
 * @description     batch rollup class for performing an aggregated result against a gift aid claim
 * @author          daniel@hyphen8.com
 * @date            20/04/2020
 * @group           Rollups
*/

public class GAC_Rollup_BATCH implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Claim_Amount__c FROM Gift_Aid_Claim__c ';
        return Database.getQueryLocator(query);
    }
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
    public void finish(Database.BatchableContext BC){}
}