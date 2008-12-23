class BillingController < ApplicationController
  before_filter :login_required, :account_owner_required
  before_filter :find_user, :only => [:show, :cancel]
  before_filter :find_subscription, :only => [:show, :invoice, :change_plan]
  
  def show
    @transactions = @subscription.transactions
  end
  
  def invoice
    @transaction = Transaction.find(params[:id])
    @subscription_address = @subscription.subscription_address
    prawnto :inline => false, :filename => "invoice_#{@subscription.id}_#{@transaction.id}.pdf"
  end
  
  def change_plan
    params[:subscription] ||= {}
    @subscription.plan_name = params[:subscription][:plan_name]
    if @subscription.save
      flash[:notice] = "Successfully changed plans"
    else
      flash[:error] = "Error changing plans"
    end
    redirect_to :action => "show"
  end
    
  def change_owner
    @user = User.find(params[:owner_id])
    current_account.owner = @user
    current_account.save!
    flash[:notice] = "Successfully changed account owner"
    redirect_back_or_default('/')
  end
  
  def cancel
    if request.post?
      current_account.suspend!
      reset_session
      flash[:notice] = "Successfully removed account"
      redirect_to login_url
    end
  end
  
  private
  
    def find_user
      @user = current_user
    end    
  
    def find_subscription
      @subscription = current_account.subscription
    end
end
