/**
 * @description     helper class to support processing of GAC_Rollup_Batch
 * @author          daniel@hyphen8.com
 * @date            19/04/2020
 * @group           Helper
*/
public with sharing class GAC_Rollup_BATCH_Helper {

    /**
     * @description     method that will return an aggregate list based on an id
     * @param           gacId
     * @return          List<Decimal> returnDecimalList
    */
    public static List<Decimal> getAggregatedAmount(string gacId){

        List<Decimal> returnDecimalList = new List<Decimal>();
        
        // get the total amount for the claim
        AggregateResult[] claimedAmountOpps = [SELECT Count(ID)recordCount, Sum(Amount)total FROM Opportunity WHERE Gift_Aid_Claim__c=:gacId];
        
        // get the amount as an object
        Object claimAmountObject = claimedAmountOpps[0].get('total');
        // set our return decimal
        decimal claimAmount = 0;
        // confirm we have returned a value and set it
        if(claimAmountObject!=null){
            claimAmount = (decimal)claimAmountObject;
        }

        // add claim amount to record list
        returnDecimalList.add(claimAmount);
        
        // get the record count as an object
        Object recordCountObject = claimedAmountOpps[0].get('recordCount');
        // set out record count;
        decimal recordCount = 0;
        if(recordCountObject!=null){
            recordCount = (decimal)recordCountObject;
        }

        // add record count to list
        returnDecimalList.add(recordCount);
        
        // return the decimal value
        return returnDecimalList;
    }
}