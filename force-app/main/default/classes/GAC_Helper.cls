/**
 * @description     help method used within the gift aid management process
 * @author          daniel@hyphen8.com
 * @date            30/06/2020
 * @groups          Helpers
 */
public with sharing class GAC_Helper {

    private static GiftAid_Settings__mdt giftAidSettings;
    @TestVisible
    public static GiftAid_Settings__mdt testGiftAidSettings;
    private static Gift_Aid_Configuration__c giftAidConfiguration;


    /**
    * @description          method to return the giftaid settings for the client org
    **/
    public static void getGiftAidSettings(){
        giftAidSettings = !Test.isRunningTest() ?
                            [SELECT Id, Contact_Object__r.QualifiedAPIName, Contact_Tax_Active_Field__r.QualifiedAPIName, Donation_Object__r.QualifiedAPIName, 
                                        Donation_Contact_Field__r.QualifiedAPIName, Donation_GiftAidable_Field__r.QualifiedAPIName, Donation_Gift_Aid_Claim_Field__r.QualifiedAPIName, 
                                        Donation_Gift_Aid_Source__r.QualifiedAPIName, Donation_Gift_Declaration_Field__r.QualifiedAPIName, Donation_Gift_Aid_Status_Field__r.QualifiedAPIName
                                        FROM GiftAid_Settings__mdt
                                        WITH SECURITY_ENFORCED
                                        LIMIT 1] :
                            testGiftAidSettings; 
    }

    /**
    * @description          method to return the giftaid configuration for the client org
    **/
    public static void getGiftAidConfiguration(){
        giftAidConfiguration = Gift_Aid_Configuration__c.getOrgDefaults();
    }


    /**
    * @description          aura enabled method that uses custom settings to dynamically pull in the gift aid declaration for a recordId
    * @param                recordId 
    * @return               Gift_Aid_Declaration__c 
    **/
    @AuraEnabled 
    public static Gift_Aid_Declaration__c getCurrentGiftAidDeclationRecord(String recordId){
        getGiftAidConfiguration();
        String recordQueryString = 'SELECT Id, Active_Date__c, Source__c FROM Gift_Aid_Declaration__c WHERE ' + giftAidConfiguration.Primary_Contact_Field__c + '=recordId AND Active__c = true WITH SECURITY_ENFORCED LIMIT 1';
        List<Gift_Aid_Declaration__c> declarations = Database.query(recordQueryString);
        return declarations.size() > 0 ? declarations[0] : null;
    }


    /**
     * @description     aura enabled method that will deactivate the current contacts GAD
     * @param           recordId
     * @return          String
     */
    @SuppressWarnings('PMD.Security.ApexCRUDViolation')
    @AuraEnabled
    public static string deactiveActiveGAD(String recordId){
        Gift_Aid_Declaration__c gad = [SELECT ID, Active__c, In_Active_date__c 
                                                        FROM Gift_Aid_Declaration__c 
                                                        WHERE Id=:recordId 
                                                        WITH SECURITY_ENFORCED
                                                        LIMIT 1];
        gad.In_Active_date__c = System.today();
        gad.Active__c = false;
        try {
            update gad;
            return 'Success';
        } catch (Exception error){
            return error.getMessage();
        }
    }


    /**
     * @description     method used when a new GAD is inserted and has Find Previous Donations selected
     * @param           mapOfContactToGADs
     * @param           setOfContactIDs
     */
    @SuppressWarnings('PMD.Security-ApexSOQLInjection,PMD.Security-ApexCRUDViolation')
    public static void processHistoricOpportunities(Map<Id,Id> mapOfContactToGADs, Set<Id> setOfContactIDs){
        getGiftAidSettings();
        getGiftAidConfiguration();
        String nullvalue = null;
        String query = 'SELECT Id, ' + giftAidSettings.Donation_Contact_Field__r.QualifiedAPIName + ' FROM ' + giftAidSettings.Donation_Object__r.QualifiedAPIName + ' WHERE ' + giftAidSettings.Donation_Contact_Field__r.QualifiedAPIName + ' IN setOfContactIDs AND ' + giftAidSettings.Donation_GiftAidable_Field__r.QualifiedAPIName + ' = nullvalue';
        List<SObject> listOfDonations = Database.query(query);
        List<SObject> listOfDonationsToUpdate = new List<SObject>();
        for(SObject donation:listOfDonations){
            String contactID = (String)donation.get(giftAidSettings.Donation_Contact_Field__r.QualifiedAPIName);
            Id gadID = mapOfContactToGADs.get(contactID);
            donation.put(giftAidSettings.Donation_Gift_Declaration_Field__r.QualifiedAPIName, gadID);
            listOfDonationsToUpdate.add(donation);
        }
        Database.update(listOfDonationsToUpdate);
    }

    /**
     * @description     method used when a GAD is made inactive and opportuntities are still availalbe for claiming
     * @param           setOfGADIDs
     */
    @SuppressWarnings('PMD.Security-ApexSOQLInjection,PMD.Security-ApexCRUDViolation')
    public static void closeOffUnclaimedOpportunities(Set<Id> setOfGADIDs){
        getGiftAidSettings();
        String giftAidStatus = System.Label.GiftAidClaimNewStatus;
        String giftAidClaim = null;
        String donationQueryString = 'SELECT Id FROM ' + giftAidSettings.Donation_Object__r.QualifiedAPIName + ' WHERE ' + giftAidSettings.Donation_Gift_Declaration_Field__r.QualifiedAPIName + ' IN setofGADIDS AND (' + giftAidSettings.Donation_Gift_Aid_Status_Field__r.QualifiedAPIName + ' = giftAidStatus OR ' + giftAidSettings.Donation_Gift_Aid_Claim_Field__r.QualifiedAPIName +' = giftAidClaim) WITH SECURITY_ENFORCED'; 
        List<SObject> donationRecords = Database.query(donationQueryString);
        List<SObject> listOfDonationsToUpdate = new List<SObject>();
        for(SObject donation:donationRecords){
            donation.put(giftAidSettings.Donation_Gift_Declaration_Field__r.QualifiedAPIName, null);
            donation.put(giftAidSettings.Donation_Gift_Aid_Claim_Field__r.QualifiedAPIName, null);
            listOfDonationsToUpdate.add(donation);
        }
        Database.update(listOfDonationsToUpdate);
    }

    /**
     * @description     get a map of Gift Aid Declarations based on current contacts
     * @param           recordIds
     * @return          Map<Id,Id>
     */
    public static Map<Id,Id> getMapOfContactGADs(Set<Id> recordIds){
        getGiftAidConfiguration();
        String giftAidDeclarationQuery = 'SELECT Id, ' + giftAidConfiguration.Primary_Contact_Field__c + ' FROM Gift_Aid_Declaration__c WHERE ' + giftAidConfiguration.Primary_Contact_Field__c + ' IN recordIds AND Active__c = true WITH SECURITY_ENFORCED';
        List<Gift_Aid_Declaration__c> listOfDeclarations = Database.query(giftAidDeclarationQuery);
        Map<Id,Id> returnMap = new Map<Id, Id>();
        for(Gift_Aid_Declaration__c gad:listOfDeclarations){
            returnMap.put(giftAidConfiguration.Primary_Contact_Field__c, gad.Id);
        }
        return returnMap;
    }
}
