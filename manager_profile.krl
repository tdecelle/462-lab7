ruleset manager_profile {
	meta {
		use module io.picolabs.lesson_keys
		use module io.picolabs.twilio_v2 alias twilio
			with account_sid = keys:twilio{"account_sid"}
			     auth_token = keys:twilio{"auth_token"}
	}

	global {
		to_notify_number = "19134019979"
		twilio_number = "12017482171"
	}
	
	rule threshold_violation {
		select when manager threshold_violation

		pre {
			threshold = event:attr("threshold_violation")
		}

		twilio:send_sms(to_notify_number,
						twilio_number,
						"Alert: Temperature above " + threshold)
	}
}
