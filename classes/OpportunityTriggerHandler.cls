public class OpportunityTriggerHandler {
    private final Map<Id,Opportunity> newMapOpportunity; //local variables
    private final Map<Id,Opportunity> oldMapOpportunity;
    //constructor
    public OpportunityTriggerHandler (Map<Id,Opportunity> newMapOpportunity,Map<Id,Opportunity> oldMapOpportunity){
        this.newMapOpportunity = newMapOpportunity;
        this.oldMapOpportunity = oldMapOpportunity;
    }
    
    public void beforeUpdate(){
         OpportunityTriggerServices.validateContactRoleStage(newMapOpportunity);
    }
    
    //Similar logic can be inserted for public void beforeInsert(){} etc when needed

}