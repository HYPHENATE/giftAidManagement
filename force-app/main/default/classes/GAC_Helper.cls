/**
 * @description     helper methods used within contacts and opportunities
 * @author          daniel@hyphen8.com
 * @date            30/06/2020
 * @groups          Helpers
 */
public with sharing class GAC_Helper {
    
    /**
     * @description     aura enabled method to check if a contact has an active Gift Aid Declaration
     * @param           string recordId
     * @return          Gift_Aid_Declaration__c
     */
    @AuraEnabled
    public static Gift_Aid_Declaration__c getGiftAidDeclaration(string recordId){
        try {
            return [SELECT ID, Active_Date__c, Source__c FROM Gift_Aid_Declaration__c WHERE Contact__c=:recordId AND Active__c = true LIMIT 1];
        } catch (Exception e){
            return null;
        }
    }


    /**
     * @description     aura enabled method that will deactivate the current contacts GAD
     * @param           string recordId
     * @return          string
     */
    @AuraEnabled
    public static string deactiveActiveGAD(string recordId){
        Gift_Aid_Declaration__c gad = [SELECT ID, Active__c, In_Active_date__c FROM Gift_Aid_Declaration__c WHERE ID=:recordId LIMIT 1];
        gad.In_Active_date__c = system.today();
        gad.Active__c = false;
        try {
            update gad;
            return 'Success';
        } catch (Exception e){
            string errorMessage = e.getMessage();
            return errorMessage;
        }
        
    }


    /**
     * @description     method  used when a new GAD is inserted and has Find Previous Donations selected
     * @param           Map<ID, ID> mapOfContactToGADs
     * @param           Set<ID> setOfContactIDs
     */
    public static void processHistoricOpportunities(Map<ID, ID> mapOfContactToGADs, Set<ID> setOfContactIDs){

        Gift_Aid_Configuration__c gacSettings = Gift_Aid_Configuration__c.getOrgDefaults();
        string contactField = gacSettings.Primary_Contact_Field__c;
        string nullvalue = null;
        string query = 'SELECT ID, Gift_Aid_Declaration__c, ' + contactField + ' FROM Opportunity WHERE ' + contactField + ' IN: setOfContactIDs AND Gift_Aid_Claim__c=:nullvalue';
        List<Opportunity> listOfOpportunities = Database.query(query);
        system.debug('listOfOpportunities > ' + listOfOpportunities);
        
        List<Opportunity> listOfOpportunitiesToUpdate = new List<Opportunity>();

        for(Opportunity opportunity:listOfOpportunities){
            string contactID = (string)opportunity.get(contactField);
            ID gadID = mapOfContactToGADs.get(contactID);
            opportunity.Gift_Aid_Declaration__c = gadID;
            listOfOpportunitiesToUpdate.add(opportunity);
        }

        database.update(listOfOpportunitiesToUpdate);
    }

    /**
     * @description     method used when a GAD is made inactive and opportuntities are still availalbe for claiming
     * @param           Set<ID> setOfGADIDs
     */
    public static void closeOffUnclaimedOpportunities(Set<ID> setOfGADIDs){

        List<Opportunity> listOfOpportunities = [SELECT ID, Gift_Aid_Declaration__c FROM Opportunity WHERE (Gift_Aid_Claim_Status__c=:'New' OR Gift_Aid_Claim__c=:null) AND Gift_Aid_Declaration__c IN:setOfGADIDs];

        List<Opportunity> listOfOpportunitiesToUpdate = new List<Opportunity>();

        for(Opportunity opportunity:listOfOpportunities){
            opportunity.Gift_Aid_Declaration__c = null;
            opportunity.Gift_Aid_Claim__c = null;
            listOfOpportunitiesToUpdate.add(opportunity);
        }

        database.update(listOfOpportunitiesToUpdate);
    }

    /**
     * @description     method to get gift aid settings
     * @return          boolean
     */
    public static Gift_Aid_Configuration__c getGacSettings(){
        Gift_Aid_Configuration__c gacSettings = Gift_Aid_Configuration__c.getOrgDefaults();
        return gacSettings;
    }


    /**
     * @description     get a map of Gift Aid Declarations based on current contacts
     * @param           Set<ID> contactIds
     * @return          Map<ID, ID> mapOfContactGADs
     */
    public static Map<ID, ID> getMapOfContactGADs(Set<ID> contactIds){
        List<Gift_Aid_Declaration__c> listOfGADs = [SELECT ID, Contact__c FROM Gift_Aid_Declaration__c WHERE Contact__c IN:contactIds AND Active__c=:true];
        Map<ID, ID> mapOfContactGADs = new Map<ID, ID>();
        for(Gift_Aid_Declaration__c gad:listOfGADs){
            mapOfContactGADs.put(gad.Contact__c, gad.Id);
        }
        return mapOfContactGADs;
    }
}
