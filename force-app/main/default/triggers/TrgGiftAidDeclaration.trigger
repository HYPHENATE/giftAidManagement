/**
 * @description trigger on the gift declaration record to support with linking automatically declarations to opportunities
 * @author      daniel@hyphen8.com
 * @date        30/06/2020
 */
trigger TrgGiftAidDeclaration on Gift_Aid_Declaration__c (after insert, after update) {

    // get custom settings to confirm if Processes are active
    Gift_Aid_Configuration__c gacSettings = GAC_Helper.getGacSettings();
    boolean processActive = gacSettings.Process_Gift_Aid__c;

    // if process is active we run
    if(processActive){

        // insert only portion of trigger
        if(trigger.isinsert){

            // map of contact ID to their Gift Aid Declaration ID
            Map<ID, ID> mapOfContactToGADs = new Map<ID, ID>();

            // set of Contact IDs
            Set<ID> setOfContactIDs = new Set<ID>();

            // loop through the gift Aid declarations if required and add to Sets and Maps above
            for(Gift_Aid_Declaration__c gad:trigger.new){
                if(gad.Find_Previous_Donations__c == true){
                    setOfContactIDs.add(gad.Contact__c);
                    mapOfContactToGADs.put(gad.Contact__c, gad.Id);
                }
            }

            // process the historic records
            GAC_Helper.processHistoricOpportunities(mapOfContactToGADs, setOfContactIDs);
        }

        // update only portion of trigger
        if(trigger.isupdate){
            
            // set for storing the GADIds in
            Set<ID> setOfGADIDs = new Set<ID>();

            // loop through the declarations and if set to inactive add to the set
            for(Gift_Aid_Declaration__c gad:trigger.new){
                if(gad.Active__c == false && gad.Active__c != trigger.OldMap.get(gad.Id).Active__c){
                    setOfGADIDs.add(gad.Id);
                }
            }

            // process the historic records ensuring they can not be claimed by mistake
            GAC_Helper.closeOffUnclaimedOpportunities(setOfGADIDs);
        }

    }

}