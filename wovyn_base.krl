ruleset wovyn_base {
	meta {
		use module io.picolabs.subscription alias Subscriptions
		use module io.picolabs.wrangler alias wrangler
		use module io.picolabs.lesson_keys
		use module io.picolabs.twilio_v2 alias twilio
			with account_sid =  keys:twilio{"account_sid"}
				 auth_token = 	keys:twilio{"auth_token"}

		use module temperature_store 

		use module sensor_profile

		shares __testing
	}

	global {
		__testing = {
			"queries": [],
			"events": [
				{ "domain": "wovyn", "type": "heartbeat" },
				{ "domain": "wovyn", "type": "heartbeat", "attrs": [ "genericThing" ] }
			]
		}

		twilio_number = "12017482171"
	}

	rule auto_accept {
	  select when wrangler inbound_pending_subscription_added
	  fired {
	  	Tx_role = event:attr("wellKnown_Tx").klog("wellKnown_Tx")
		raise wrangler event "pending_subscription_approval"
		  attributes event:attrs
	  }
	}

	rule process_heartbeat {
		select when wovyn heartbeat

		pre {
			genericThing = event:attr("genericThing").klog("GenericThing").head()
			temperature = genericThing{"data"}{"temperature"}.klog("TEMPERATURE").head()
		}

		if (not genericThing.isnull()) then 
			send_directive("say", {"something": "Hello"})
		fired {
			raise wovyn event "new_temperature_reading" 
				attributes { "temperature": temperature, "timestamp": time:now() }
		} 
	}

	rule find_high_temps {
		select when wovyn new_temperature_reading
		
		pre {
			temperature = event:attr("temperature")
			temperatureF = temperature["temperatureF"].klog("temperatureF").head()
		}

		send_directive("say", {"recieved": "Y"})
		
		fired {
			raise wovyn event "threshold_violation"
				attributes event:attrs if temperatureF > sensor_profile:get_threshold()
		}
	}

	rule threshold_violation {
		select when wovyn threshold_violation

		pre {
			threshold = sensor_profile:get_threshold().klog("Threshold")
			eci = Subscriptions:established("Tx_role", "manager").head(){"Tx"}.klog("Subscription eci from wovyn")
		} 

		event:send({
			  "eci": eci,
			  "eid": "threshold_violation",
			  "domain": "manager",
			  "type": "threshold_violation",
			  "attrs": { "threshold_violation":threshold }
			  })
	}
}
