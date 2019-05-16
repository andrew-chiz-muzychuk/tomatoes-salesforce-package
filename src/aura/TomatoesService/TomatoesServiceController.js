({
    init : function(component, event, helper) {
        window.isDeveloper = true;
        component.set('v.columns', [
            {label: 'Date', fieldName: 'created_at', type: 'date', sortable:false},
            {label: 'Name', fieldName: 'clientName', type: 'text', sortable:false},
            {label: 'Tags', fieldName: 'tags', type: 'text', sortable:false}
        ]);
	},
    connect : function(component, event, helper) {
        var action_getTomateToken = component.get("c.getTomateToken");
        action_getTomateToken.setCallback(this, function(response) {
        	try {
	            if (response.getState() === "SUCCESS") {
	            	var result = response.getReturnValue();
	            	if (result == null) {
                        alert("Can't connect to Tomato.es with your token and provider!");
                    } else {
                        console.log('action_getTomateToken -- SUCCESS', result);
                        component.set('v.tomatoesToken', result);
                        if (component.get('v.weeklyView')) {
                            component.set('v.weekFromNow', 0);
                        }
                    }
	            } else {
	            	console.log('action_getTomateToken -- Not(SUCCESS)', response.getError());
	            }
        	} catch (e) {
				console.log('action_getTomateToken -- Exception', e);
        	}
        });

        $A.enqueueAction(action_getTomateToken);
	},
	searchTomatoes : function(component, event, helper) {
		var action_getAllTomates = component.get("c.getAllTomates"); 
        console.log('tomatoesDateFrom -', component.get('v.tomatoesDateFrom'));
        console.log('tomatoesDateTo -', component.get('v.tomatoesDateTo'));
        action_getAllTomates.setParams({
			"dateFrom": component.get('v.tomatoesDateFrom'),
            "dateTo": component.get('v.tomatoesDateTo'),
            "token": component.get('v.tomatoesToken'),
	    });
        action_getAllTomates.setCallback(this, function(response) {
        	try {
	            if (response.getState() === "SUCCESS") {
	            	var result = response.getReturnValue();
	            	console.log('action_getAllTomates -- SUCCESS', result);
	                component.set('v.data', result);
                    component.set('v.dataOriginal', result);
                    
                    var clientNameSet = new Set();
                    result.forEach(function(element) {
                        if (element.clientName != undefined) {
                            clientNameSet.add(element.clientName); 
                        }
                    });
                    var clientNames = [{"label":"", "value":""}];
                    clientNameSet.forEach(function(element) {
                       	clientNames.push({"label":element, "value":element}); 
                    });
                    component.set('v.clientNames', clientNames);
                    
                    console.log('action_getAllTomates -- data',  component.get('v.data'));
	            } else {
	            	console.log('action_getAllTomates -- Not(SUCCESS)', response.getError());
	            }
        	} catch (e) {
				console.log('action_getAllTomates -- Exception', e);
        	}
        });

        $A.enqueueAction(action_getAllTomates);
    },
    
    searchWeeklyTomatoes : function(component, event, helper) {
		var action_getAllTomates = component.get("c.getWeeklyTomatoes"); 
        console.log('tomatoesDateFrom -', component.get('v.tomatoesDateFrom'));
        console.log('tomatoesDateTo -', component.get('v.tomatoesDateTo'));
        action_getAllTomates.setParams({
			"weekFromNow": component.get('v.weekFromNow'),
            "token": component.get('v.tomatoesToken'),
	    });
        action_getAllTomates.setCallback(this, function(response) {
        	try {
	            if (response.getState() === "SUCCESS") {
	            	var result = response.getReturnValue();
	            	console.log('action_getAllTomates -- SUCCESS', result);
	                component.set('v.data', result.tomatoesList);
                    component.set('v.dataOriginal', result.tomatoesList);
                    component.set('v.weekLabel', result.from + " - " + result.to);

                    var clientNameSet = new Set();
                    result.tomatoesList.forEach(function(element) {
                        if (element.clientName != undefined) {
                            clientNameSet.add(element.clientName); 
                        }
                    });
                    var clientNames = [{"label":"", "value":""}];
                    clientNameSet.forEach(function(element) {
                       	clientNames.push({"label":element, "value":element}); 
                    });
                    component.set('v.clientNames', clientNames);
                } else {
	            	console.log('action_getAllTomates -- Not(SUCCESS)', response.getError());
	            }
        	} catch (e) {
				console.log('action_getAllTomates -- Exception', e);
        	}
        });

        $A.enqueueAction(action_getAllTomates);
    },
    
    previousWeek : function(component, event, helper) {
		component.set('v.weekFromNow', component.get('v.weekFromNow')+1);
        console.log('weekFromNow', component.get('v.weekFromNow'));
    },
    
    nextWeek : function(component, event, helper) {
		component.set('v.weekFromNow', component.get('v.weekFromNow')-1);
        console.log('weekFromNow', component.get('v.weekFromNow'));
	},
    
    changeView : function(component, event, helper) {
		component.set('v.weeklyView', !component.get('v.weeklyView'));
        console.log('weeklyView', component.get('v.weeklyView'));
        if (component.get('v.weeklyView')) {
            component.set('v.weekFromNow', 0);
        } else {
            component.set('v.data', []);
            component.set('v.dataOriginal', []);
        }
	},
    
    filterChange : function(component, event, helper) {
		component.set('v.selectedName', event.getParam("value"));
        console.log('selectedName', event.getParam("value"));
	},
    
    filter : function(component, event, helper) {
		var name = component.get('v.selectedName');
        if (name != "") {
            var newData = [];
            var data = component.get('v.dataOriginal');
            data.forEach(function(element) {
                if (element.clientName == name) {
                	newData.push(element);
                }
                //newTomato.put('id', curTomato.tomatoId);
                //newTomato.put('created_at', curTomato.created_at);
                //newTomato.put('updated_at', curTomato.updated_at);
                //newTomato.put('tags', curTomato.tags);
                //newTomato.put('clientName', curTomato.clientName);
                //newData.push({});
            });
            component.set('v.data', newData);
        } else {
            component.set('v.data', component.get('v.dataOriginal'));
        }
	}
})