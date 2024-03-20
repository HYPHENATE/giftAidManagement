/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 20/03/2024
 * @last modified by  : daniel@hyphen8.com
**/
trigger TrgGiftAidOpportunity on Opportunity (before update) {

    Gift_Aid_Configuration__c gacSettings = GAC_Helper.getGacSettings();
    boolean processActive = gacSettings.Process_Gift_Aid__c;
    
    if(processActive){
        Set<ID> contactIds = new Set<ID>();
        for(Opportunity opportunity:trigger.new){
            boolean confirmationField = (boolean)opportunity.get(gacSettings.Gift_Aid_Confirmation_Field__c);
            string contactId = (string)opportunity.get(gacSettings.Primary_Contact_Field__c);
            // if(confirmationField && contactId != null && opportunity.Gift_Aid_Declaration__c == null){
                contactIds.add(contactId);
            // }
        }
        system.debug(contactIds);

        Map<ID, ID> mapOfContactGADs = GAC_Helper.getMapOfContactGADs(contactIds);
        for(Opportunity opportunity:trigger.new){
            boolean confirmationField = (boolean)opportunity.get(gacSettings.Gift_Aid_Confirmation_Field__c);
            string contactId = (string)opportunity.get(gacSettings.Primary_Contact_Field__c);
            // if(confirmationField && contactId != null && opportunity.Gift_Aid_Declaration__c == null){
                if(mapOfContactGADs.containsKey(contactId)){
                    // opportunity.Gift_Aid_Declaration__c = mapOfContactGADs.get(contactId);
                }
            // }
        }
    }

}