ruleset io.picolabs.lesson_keys {
  meta {
    key twilio {
          "account_sid": "AC7dcd0f44af0bfb9033a4f2e231579017", 
          "auth_token" : "8136354c2e5cd9aab90f148a20a97028"
    }
    provides keys twilio to io.picolabs.use_twilio_v2
	provides keys twilio to wovyn_base
	provides keys twilio to manager_profile
  }
}
