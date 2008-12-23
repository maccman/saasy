class SubscriptionAddressesController < ApplicationController
  before_filter :login_required, :account_owner_required
  before_filter :find_subscription_address
  
  def edit
  end
  
  def update
    if @subscription_address.update_attributes(params[:subscription_address])
      flash[:notice] = "Successfully updated invoice information"
      redirect_to :controller => "billing"
    else
      flash.now[:error] = "Error updating invoice information"
      render :action => "edit"
    end
  end
  
  private
  
    def find_subscription_address
      @subscription_address = current_account.subscription.subscription_address
    end
end
