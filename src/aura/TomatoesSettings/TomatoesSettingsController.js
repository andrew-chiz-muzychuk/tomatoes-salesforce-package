({
	init : function(component, event, helper) {
		var action_getTomatoSettings = component.get("c.getTomatoesSettings");
        action_getTomatoSettings.setCallback(this, function(response) {
        	try {
	            if (response.getState() === "SUCCESS") {
	            	var result = response.getReturnValue();
	            	console.log('action_getTomatoSettings -- SUCCESS', result);
	                component.set('v.provider', result[0]);
                    component.set('v.token', result[1]);
	            } else {
	            	console.log('action_getTomatoSettings -- Not(SUCCESS)', response.getError());
	            }
        	} catch (e) {
				console.log('action_getTomatoSettings -- Exception', e);
        	}
        });

        $A.enqueueAction(action_getTomatoSettings);		
	},
    
    save : function(component, event, helper) {
		var action_setTomatoSettings = component.get("c.setTomatoesSettings");
        action_setTomatoSettings.setParams({
			"provider": component.get('v.provider').toLowerCase(),
            "token": component.get('v.token'),
	    });
        action_setTomatoSettings.setCallback(this, function(response) {
        	try {
	            if (response.getState() === "SUCCESS") {
	            	var result = response.getReturnValue();
	            	console.log('action_setTomatoSettings -- SUCCESS', result);
                    alert("Settings saved");
	            } else {
	            	console.log('action_setTomatoSettings -- Not(SUCCESS)', response.getError());
	            }
        	} catch (e) {
				console.log('action_setTomatoSettings -- Exception', e);
        	}
        });

        $A.enqueueAction(action_setTomatoSettings);		
	}
})