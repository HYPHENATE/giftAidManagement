/**
 * @description     invocable method that will run from a GiftAidClaim to link Opportunities for processing to it
 * @author          daniel@hyphen8.com
 * @date            30/06/2020
 * @groups          Gift Aid Claim
 */
public with sharing class GAC_Invocable {
   
    /**
     * @description     invocable method that will take a Gift Aid Claim ID and find all opportunities that need linking to it
     *                  this process will run one at a time never in bulk
     * @param           List<Gift_Aid_Claim__c> gacsToProcess
     */
    @InvocableMethod(label='Link Opportunities To Claims' description='Lookup for Opportunities and Links them to the Appropriate Claim')
    public static void updateDefaultEntitlements(List<Gift_Aid_Claim__c> gacsToProcess) {

        // list of opps for updating
        List<Opportunity> listOfOpportunitiesToUpdate = new List<Opportunity>();

        // check to make sure only 1 record is being processed
        if(gacsToProcess.size() == 1){

            // list of opps suitable for adding to the gift aid claim
            //List<Opportunity> listOfOpportunity = [SELECT ID FROM Opportunity WHERE IsWon=:True AND Gift_Aid_Claim__c=:null AND Gift_Aid_Declaration__c!=null];

            List<Opportunity> listOfOpportunity = new List<Opportunity>();

            // loop through GAC claims being processed should only ever been one in this process
            for(Gift_Aid_Claim__c gac:gacsToProcess){
            
                // loop through the opps and add to the GAC
                for(Opportunity opportunity:listOfOpportunity){
            
                    opportunity.Gift_Aid_Claim__c = gac.Id;
            
                    listOfOpportunitiesToUpdate.add(opportunity);
            
                }
            
            }

        }

        // update the opps
        database.update(listOfOpportunitiesToUpdate);

        if(listOfOpportunitiesToUpdate.size() > 0){
            GAC_Rollup_Batch gacRollupBatch = new GAC_Rollup_BATCH();
            database.executeBatch(gacRollupBatch, 1);
        }
    
    }

}