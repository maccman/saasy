class SubscriptionsController < ApplicationController
  before_filter :login_required, :account_owner_required
  before_filter :find_subscription, :only => [:show, :edit, :update]
  ssl_required  :edit, :update
  
  def show
    respond_to do |format|
      format.html { 
        flash.keep 
        redirect_to :controller => "billing" 
      }
      format.xml  { render :xml => @subscription }
    end
  end
  
  def edit
  end
    
  def update
    @subscription.card = params[:card]
    if @subscription.save
      flash[:notice] = "Successfully updated card"
      redirect_to :action => "show"
    else
      flash.now[:error] = "Errors updating card"
      render :action => "edit"
    end
  end
  
  private   
  
    def find_subscription
      @subscription = current_account.subscription
    end
end
