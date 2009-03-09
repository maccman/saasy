namespace :subs do
  # This really does need to be run daily (e.g. at 12:01 am), since
  # it only finds subscriptions due on that particular day
  task :daily => [:environment] do
    Lockfile('subs_daily_lock', :retries => 0) do
      # Keep the same time so as
      # to avoid a race condition
      time = Time.now.midnight
      
      Subscription.in_state(:trial).due(time + 2.days).each {|sub|
        SubscriptionMailer.deliver_trial_expiring(sub)
      }
      
      Subscription.due(time).each {|sub| 
        if sub.renew!
          SubscriptionMailer.deliver_charge_success(sub)
        else
          SubscriptionMailer.deliver_charge_failure(sub)
        end
      }
      
      Subscription.in_state(:error).due(time - 3.days).each {|sub| 
        if sub.renew!
          SubscriptionMailer.deliver_charge_success(sub)
        else
          SubscriptionMailer.deliver_second_charge_failure(sub)
        end
      }
      
      Subscription.in_state(:error).due(time - 6.days).each {|sub| 
        if sub.renew!
          SubscriptionMailer.deliver_charge_success(sub)
        else
          ## You may want to disable the person's
          ## account here, but initally I'm going
          ## to do it manually
          # sub.account.disable!
          SubscriptionMailer.deliver_account_failure(sub.account)
        end
      }
    end
  end
end