= Welcome to Saasy

Saasy is a Rails app that bills and authenticates, so you don't have to.
The idea is that you host Saasy on a subdomain, and communicate with it using SSO/REST protocols. 
That means you're free to do more interesting coding.

*At the moment this is alpha code - use at your own risk*

I'd like to thank Made by Many (http://madebymany.co.uk) for supporting this project.

Alex MacCaw 

http://eribium.org 
info@eribium.org

== Screenshots

* Billing         - http://github.com/maccman/saasy/tree/master/doc/Saasy_Billing.png
* Sign up         - http://github.com/maccman/saasy/tree/master/doc/Saasy_Signup.png
* Edit profile    - http://github.com/maccman/saasy/tree/master/doc/Sassy_Edit_Profile.png
* Example Invoice - http://github.com/maccman/saasy/tree/master/doc/invoice.pdf

== Overview

* Subscription management
* Recurring billing
* Credit card management
* User authentication and SSO

== Features

* No local credit card storage
* Automated billing script that should be run nightly
* Configurable subscription plans (price/duration)
* SSL protection for account creation (and when updating CC info)
* Account can have multiple users, interface for adding more
* Trial ending mailer
* Invoice mailer
* Automated notification and retry of failed renewals
* Plan upgrade/downgrades
* PDF invoices
* Forgot password retrieval
* OpenID support
* Shared secret SSO
* Credit card verification
* REST API for users and subscriptions

== Getting Started

# cp config/database.example.yml config/database.yml
# cp config/application.example.yml config/application.yml
# cp config/subscription.example.yml config/subscription.yml
# rake db:schema:load
# Setup a cron job to run `rake subs:daily` daily
# configure application.yml
# configure subscriptions.yml
# script/server -p 3001

== Gateways
  
Currently the following gateways are supported:
* Braintree
* TrustCommerce
* PaymentExpress

== Choosing a Gateway

Braintree seems to be a good choice, and they're friendly to Railers to:
* http://groups.google.com/group/rails-business/msg/53da3705df6063a2

== Test transactions

As far as I could tell, Braintree are the only Gateway that lets you
test transactions without signing up.
* http://dev.braintreepaymentsolutions.com/test-transaction/

== SSO (single sign on)

I've implemented a simple SSO using shared secrets.
have a look at lib/sso.rb for more information.

== Gotchas

I've made some extensions to various plugins/libs which I've
yet to push back:

* Extended ActiveMerchant's Braintree and Trust Commerce gateways (see initializers)
* Edited acts_as_state_machine:
  * Added named_scope 'in_state'
  * Stopped it overriding any states I specified before creation
  * Make it update all the attributes on save, not just the state column
* Used the Rails 2.2 version of prawnto (http://github.com/filiptepper/prawnto/tree/master) 
* Edited ssl_requirement so that it's disabled in development/test mode.
* Rails error_messages_for now uses spans, instead of divs, to be standards compliant
* Add a float component to Prawn (see initializers)
