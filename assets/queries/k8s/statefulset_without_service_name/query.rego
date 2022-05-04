package Cx  

import data.generic.common as common_lib

CxPolicy[result] {
	statefulset := input.document[i]
	statefulset.kind == "StatefulSet"

	count({x | 	resource := input.document[x];
    			resource.kind == "Service"; 
            	resource.spec.clusterIP == "None"; 
            	statefulset.metadata.namespace == resource.metadata.namespace; 
            	statefulset.spec.serviceName == resource.metadata.name; 
            	not unmatchedLabels( resource.spec.selector, statefulset.spec.template.metadata.labels)
            	}) == 0

	metadata := statefulset.metadata.name

	result := {
		"documentId": input.document[i].id,
		"searchKey": sprintf("metadata.name=%s.spec.serviceName", [metadata]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("metadata.name=%s.spec.serviceName refers to a Headless Service", [metadata]),
		"keyActualValue": sprintf("metadata.name=%s.spec.serviceName doesn't refers to a Headless Service", [metadata]),
		"searchLine": common_lib.build_search_line(["spec", "serviceName"], [])
	}
}

unmatchedLabels(serviceLabels, statefulsetLabels){
    value := serviceLabels[name]
    notContain(value, name , statefulsetLabels)
}

notContain( value, name, list){
	list[name] != value
}else{
	not common_lib.valid_key(list, name)
}
