public class OpportunityTriggerServices {
    
    public static void validateContactRoleStage(Map<Id,Opportunity> newMapOpportunity, Map<Id,Opportunity> oldMapOpportunity){
		final string CLOSEDWON = 'Closed/Won';
		final string CLOSEDLOST = 'Closed/Lost';
        
        Map<String, List<String>> OpptyContactRoleMap = new Map<String,List<String>>(); //To store Opportunity Stages and corressponding list of required contact roles
        Map<Id,Opportunity> oppCRMap = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Role  FROM OpportunityContactRoles) FROM Opportunity WHERE Id IN :newMapOpportunity.keySet()]);
        //^ load all the opportunities and corresponding opportunity contact role from trigger.new context
        
        Schema.DescribeFieldResult oppStage = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> oppStageValues = oppStage.getPicklistValues(); //store all StageName picklist values
        List<String> oppStageValueLabel = new List<String>();
        for(Schema.PicklistEntry pe:oppStageValues ) oppStageValueLabel.add(pe.getLabel()); //create a list of all the picklist label
        
        
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
            List<String> pickListValues = copyRangeOf(oppStageValueLabel,oppStageValueLabel.indexOf(newMapOpportunity.get(o.Id).StageName));
            //^ copy all stages from the top to new version stage name
            
            if(o.StageName == CLOSEDLOST){
                Integer index = pickListValues.indexOf(CLOSEDWON);
                pickListValues.remove(index);
            }//remove closedwon from the list when opportunity is being closed lost, remove more stagenames depending on the requirement
            
            for(OpportunityContactRole ocr: oppCRMap.get(o.Id).OpportunityContactRoles){ //iterate through contact roles for the opportunity
                for(String picklist:pickListValues ){//check for every stagename from the top to new version stage name
                    if(localMap.get(picklist).contains(ocr.Role)){
                        Integer index = localMap.get(picklist).indexOf(ocr.Role); //get the index of role from the list since it exists in the opportunity
						localMap.get(picklist).remove(index);
                    } 
                }  
            }
            
            Set<String> displayRoles = new Set<String>(); //set to eliminate the duplicate contact roles while displaying
            for(String picklist:pickListValues){
            	displayRoles.addAll(localMap.get(picklist));
            }
            
            
            if(displayRoles.size() > 0){
                 o.addError(String.join(new List<String>(displayRoles), ', ') +' Contact Role/s is/are required to move the Opportunity to '+o.StageName ); 
            }
 
        }
    }
    
    private static List<String> copyRangeOf(List<String> picklists, Integer last){
        Integer elements = last + 1;
        while (picklists.size() > elements) picklists.remove(elements);
        return picklists;
    }
    
    //overloaded method incase we want to consider stagename between old version and new version
    /*private static List<String> copyRangeOf(List<String> picklists,Integer first, Integer last){
        if(last>first){
            for (Integer i = 0; i < first; i++) picklists.remove(0);
        	Integer elements = last - first + 1;
        	while (picklists.size() > elements) picklists.remove(elements);
        	return picklists;
        }else{
            List<String> output = new List<String>();
            output.add(picklists[last]);
            return output;
        }
        
    }*/
}