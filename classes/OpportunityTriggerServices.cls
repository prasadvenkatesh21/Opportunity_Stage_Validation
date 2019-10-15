public class OpportunityTriggerServices {
    
    public static void validateContactRoleStage(Map<Id,Opportunity> newMapOpportunity){
        
        Map<String, List<String>> OpptyContactRoleMap = new Map<String,List<String>>(); //To store Opportunity Stages and corressponding list of required contact roles
        Map<Id,Opportunity> oppCRMap = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Role  FROM OpportunityContactRoles) FROM Opportunity WHERE Id IN :newMapOpportunity.keySet()]);
		//^ load all the opportunities and corresponding opportunity contact role from trigger.new context
		//
        for(Opportunity_Stage_Setting__mdt oss: [Select Opportunity_Stage__c ,Contact_Role__c  FROM Opportunity_Stage_Setting__mdt]){
            if(OpptyContactRoleMap.get(oss.Opportunity_Stage__c) == null){ //check if stage already exists as key
                OpptyContactRoleMap.put(oss.Opportunity_Stage__c,new List<String>()); //if not put the key(Opportunity stage) and instantiate the list
                OpptyContactRoleMap.get(oss.Opportunity_Stage__c).add(oss.Contact_Role__c);//Add the contact role to value (list)
            } else{
                OpptyContactRoleMap.get(oss.Opportunity_Stage__c).add(oss.Contact_Role__c); //is stage already exists add the contact role to value (list)
            }
            
        }
        
        for (Opportunity o :newMapOpportunity.values()) {
            Map<String, List<String>> localMap = OpptyContactRoleMap; //copy to loacl variable to keep the gloabl value untouched
            for(OpportunityContactRole ocr: oppCRMap.get(o.Id).OpportunityContactRoles){ //iterate through contact roles for the opportunity
                if(localMap.get(o.StageName).contains(ocr.Role)){ 
                    Integer index = localMap.get(o.StageName).indexOf(ocr.Role); //get the index of role from the list since it exists in the opportunity
                    localMap.get(o.StageName).remove(index); // remove it from the list
                }
            }
            
            if(localMap.get(o.StageName).size() > 0){ // Check if there are any remaning contact roles that are not present in the opportuntiy //&& OpptyContactRoleMap.containsKey(o.StageName)
                o.addError(string.join(localMap.get(o.StageName),', ') +' Contact Role is required to move the Opportunity to '+o.StageName); //converting list to string to display legibly
            }
        } 
    }
}