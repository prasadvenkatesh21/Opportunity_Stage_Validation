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
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opportunity1 = new Opportunity(AccountId = account1.Id, Name= 'Test Opportunity 1', CloseDate = date.newInstance(2020, 11, 21),
                                                   StageName = 'Prospecting');
        opportunityList.add(opportunity1);
        opportunity1 = new Opportunity(AccountId = account1.Id, Name= 'Test Opportunity 2', CloseDate = date.newInstance(2021, 09, 21),
                                                   StageName = 'Proposal');
        opportunityList.add(opportunity1);
        insert opportunityList;
        
        
    }
    
    //unhappy path testing
    @isTest static void changeOpportunityStageNoCR(){
        Account acc1 = [Select Id FROM Account Limit 1];
       	Opportunity opp1 = [Select StageName FROM Opportunity WHERE AccountId = :acc1.Id and Name = 'Test Opportunity 1'];
        string systemErrorMessage;
        String validationErrorMessage;
        
        try{
            validationErrorMessage = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, Influencer, Decision Maker Contact Role/s is/are required to move the Opportunity to Identify Decision';
            opp1.StageName = 'Identify Decision Makers';
            update opp1;
        }catch(System.Exception ex){
            systemErrorMessage = ex.getMessage();
            
        }
        System.debug(systemErrorMessage);
        System.assertEquals(true,systemErrorMessage.contains(validationErrorMessage),'Influencer, Decision Maker Contact Role/s is/are required to move the Opportunity to Identify Decision may not exist' );
        //^optional message to help dubugging in the future if Opportunity Stage Settings are changes
    }
    
    //happpy path testing
    @isTest static void changeOpportunityStageWithCR(){
        Account acc1 = [Select Id FROM Account Limit 1];
        Opportunity opp1 = [Select StageName FROM Opportunity WHERE AccountId = :acc1.Id and Name = 'Test Opportunity 2'];
        Contact con1 = [Select Id FROM Contact WHERE AccountId = :acc1.Id Limit 1];
        string systemErrorMessage;
        String validationErrorMessage;
        try{
            validationErrorMessage = null;
            List<OpportunityContactRole> OCRList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = new OpportunityContactRole(Role = 'Finance', ContactId = con1.Id,OpportunityId = opp1.Id); //create associated opportunity contact role
            OCRList.add(ocr1);
            ocr1 = new OpportunityContactRole(Role = 'Finance', ContactId = con1.Id,OpportunityId = opp1.Id); 
            OCRList.add(ocr1);
            ocr1 = new OpportunityContactRole(Role = 'Influencer', ContactId = con1.Id,OpportunityId = opp1.Id); 
            OCRList.add(ocr1);
            ocr1 = new OpportunityContactRole(Role = 'Decision Maker', ContactId = con1.Id,OpportunityId = opp1.Id); //create associated opportunity contact role
            OCRList.add(ocr1);
            ocr1 = new OpportunityContactRole(Role = 'IT', ContactId = con1.Id,OpportunityId = opp1.Id); 
            OCRList.add(ocr1);
            ocr1 = new OpportunityContactRole(Role = 'Executive Sponsor', ContactId = con1.Id,OpportunityId = opp1.Id); 
            OCRList.add(ocr1);
            insert OCRList;
            opp1.StageName = 'Closed/Lost';
            update opp1;
        }catch(System.Exception ex){
            systemErrorMessage = ex.getMessage();
        }
        System.assertEquals(validationErrorMessage,systemErrorMessage, 'Check changeOpportunityStageWithCR method');
    }
    
    
    
}