trigger OpportunityTrigger on Opportunity (before insert, before update) {
    
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.newMap,Trigger.oldMap); //instantiate the object
    
    if(Trigger.isBefore){
        if(trigger.isUpdate){
            handler.beforeUpdate();
        }
    }
    
    //similar logic can be inserted for Trigger.isAfter, Trigger.isInsert when needed

}