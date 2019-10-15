@isTest
public class OpportunityTriggerServicesTest {
    
    @testSetup static void createData(){
        
        Account account1 = new Account(Name = 'Test Account 1');
        insert account1;
        
        List<Contact> contactList =new List<Contact>();  
        Contact contact1 = new Contact(FirstName = 'Test',LastName= 'Contact 1', Email = 'testcontact1@example.com',AccountId = account1.Id);
        contactList.add(contact1);
        contact1 = new Contact(FirstName = 'Test',LastName= 'Contact 2', Email = 'testcontact2@example.com',AccountId = account1.Id);
        contactList.add(contact1);
        contact1 = new Contact(FirstName = 'Test',LastName= 'Contact 3', Email = 'testcontact3@example.com',AccountId = account1.Id);
        contactList.add(contact1);
        contact1 = new Contact(FirstName = 'Test',LastName= 'Contact 4', Email = 'testcontact4@example.com',AccountId = account1.Id);
        contactList.add(contact1);
        contact1 = new Contact(FirstName = 'Test',LastName= 'Contact 5', Email = 'testcontact5@example.com',AccountId = account1.Id);
        contactList.add(contact1);
        insert contactList;
        
        Opportunity opportunity1 = new Opportunity(AccountId = account1.Id, Name= 'Test Opportunity 1', CloseDate = date.newInstance(2020, 11, 21),
                                                   StageName = 'Prospecting');
        insert opportunity1;
        
    }
    
    //unhappy path testing
    @isTest static void changeOpportunityStageNoCR(){
        Opportunity opp1 = [Select StageName FROM Opportunity WHERE Account.Name = 'Test Account 1'];
        string systemErrorMessage;
        String validationErrorMessage;
        
        try{
            validationErrorMessage = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, Decision Maker Contact Role is required to move the Opportunity to Identify Decision';
            opp1.StageName = 'Identify Decision Makers';
            update opp1;
        }catch(System.Exception ex){
            systemErrorMessage = ex.getMessage();
        }
        
        System.assertEquals(true,systemErrorMessage.contains(validationErrorMessage),'Decision Maker Contact Role is required to move the Opportunity to Identify Decision may not exist' );
        //^optional message to help dubugging in the future if Opportunity Stage Settings are changes
    }
    
    //happpy path testing
    @isTest static void changeOpportunityStageWithCR(){
        Account acc1 = [Select Id FROM Account Limit 1];
        Opportunity opp1 = [Select StageName FROM Opportunity WHERE AccountId = :acc1.Id];
        Contact con1 = [Select Id FROM Contact WHERE AccountId = :acc1.Id Limit 1];
        string systemErrorMessage;
        String validationErrorMessage;
        try{
            validationErrorMessage = null;
            OpportunityContactRole ocr1 = new OpportunityContactRole(Role = 'Finance', ContactId = con1.Id,OpportunityId = opp1.Id); //create associated opportunity contact role
            insert ocr1;
        }catch(System.Exception ex){
            systemErrorMessage = ex.getMessage();
        }
        
        System.assertEquals(validationErrorMessage,systemErrorMessage, 'Check changeOpportunityStageWithCR method');
    }
    
    
    
}