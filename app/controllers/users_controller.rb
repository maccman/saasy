class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :activate]
  before_filter :account_owner_required, :only => [:index, :add_user, :unsuspend, :destroy]
  before_filter :find_user, :only => [:current, :show, :edit, :update, :unsuspend, :destroy]
  
  def index
    @users = current_account.users.all
  end
  
  def current
    respond_to do |format|
      format.html { 
        flash.keep
        redirect_to :action => "index" 
      }
      format.xml  { render :xml => @user }
    end
  end

  def new
    @user = User.new
    @subscription = Subscription.new
    @subscription.plan_name = params[:plan_name] || 'basic'
    @subscription_address = SubscriptionAddress.new
    @subscription_address.country = "United States"
  end
  
  def add_user
    if request.post?
      @user = User.new(params[:user])
      @user.account = current_user.account
      @user.password_confirmation = @user.password
      if @user.save
        UserMailer.deliver_account_information(@user)
        flash[:notice] = "Successfully created user"
        redirect_to :action => "index"
      else
        flash.now[:error] = "Errors creating user"
      end
    else
      @user = User.new
      @user.password = ActiveSupport::SecureRandom.hex(5)
    end
  end
  
  def show
    respond_to do |format|
      format.html { render :action => :edit }
      format.xml  { render :xml => @user }
    end
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @subscription = Subscription.new(params[:subscription])
    @subscription.state = 'trial'
    @subscription.plan_name ||= 'basic'
    @subscription.card = params[:card]
    @account = Account.new
    @subscription_address = SubscriptionAddress.new(params[:subscription_address])
    # We have to check if the records are valid before saving 
    # since (even in a transaction) the callbacks are called
    [@user, @subscription, @subscription_address].each {|ins|
      raise ActiveRecord::RecordInvalid.new(ins) unless ins.valid?
    }
    User.transaction do
      @user.save!
      @account.owner = @user
      @account.save!
      @user.update_attribute(:account, @account)
      @subscription.account = @account
      @subscription.save!
      @subscription_address.subscription = @subscription
      @subscription_address.save!
    end
    @account.activate!
    flash[:notice] = "Thanks for signing up!  We're sending you an email " \
                     "with your activation code"
    redirect_to '/login'
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There were some errors setting up that account"
    render :action => 'new'
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:id]) unless params[:id].blank?
    case
    when (!params[:id].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue"
      redirect_to '/login'
    when params[:id].blank?
      flash[:error] = "The activation code was missing. " \
                      "Please follow the URL from your email"
      redirect_to '/login'
    else 
      flash[:error]  = "We couldn't find a user with that activation code " \
                        "-- check your email? Or maybe you've already activated " \
                        "-- try signing in"
      redirect_to '/login'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated"
      redirect_to :action => :show, :id => @user.id
    else
      flash.now[:error] = "There were some errors"
      render :action => :edit
    end
  end
  
  def unsuspend
    @user.unsuspend!
    flash[:notice] = "Successfully unsuspend user"
    redirect_to :action => "index"
  end
  
  def destroy
    if current_user == @user
      flash[:error] = "You can't deactivate yourself"
      redirect_to :action => :index
    else
      @user.suspend!
      flash[:notice] = "Successfully deactivated user"
      redirect_to :action => :index
    end
  end

  private
  
    def find_user
      if account_owner? && params[:id]
        @user = current_user.account.users.find(params[:id])
      else
        @user = current_user
      end
    end
end
