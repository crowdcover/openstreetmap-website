class GroupMembershipsController < ApplicationController
  layout :choose_layout
  
  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user
  before_filter :check_database_readable
  before_filter :check_database_writable
  
  before_filter :find_group
  before_filter :require_group_lead_or_admin, :except => [:confirm_invite]
 
  
  #show all users in a group
  def index 
    @users = @group.users
    @memberships =  @group.group_memberships
    
    respond_to do |format|
      format.html 
      format.json { render :json => @users.to_json(:only =>[:display_name, :id, :status, :creation_time]) }
    end
  end
   
 
  def update_role
    membership = @group.group_memberships.where(["user_id = ?", params[:user_id]]).first
    role = params[:group_memberships_role]
    if membership.set_role(role)
      flash[:notice] = t 'group.role.success', :user => membership.user.display_name, :title => @group.title
    else
      flash[:error] = t 'group.role.error', :title => @group.title
    end
    redirect_to :action => :index
  end
  
  #remove a user from a group
  def remove
    remove_user =  User.find(params[:user_id])
    membership = @group.group_memberships.where(["user_id = ?", remove_user.id]).first
    
    if membership.destroy
      flash[:notice] = t 'group.remove.success'
    else
      flash[:error] = t 'group.remove.error'
    end
    
    redirect_to :action => :index
  end
  
  #a group lead can invite a user
  def invite
    invited_user = User.find(params[:user_id])
    
    if m = @group.group_memberships.create!(:user_id => invited_user.id, :status => "invited", :role => GroupMembership::Roles::MEMBER)
      
      url = group_user_confirm_invite_url(:group_id => @group.id, :user_id => invited_user.id, :token => m.invite_token)
      msg_params = {"title"=> t('message.new.group_invite_subject', :title => @group.title), 
        "body" => t('message.new.group_invite_body',  :from_user => @user.display_name, :title => @group.title, :url => url, :group_url => group_url(@group) ) }
      @message = Message.new(msg_params)
      @message.body_format = "html"
      @message.to_user_id = invited_user.id
      @message.from_user_id = @user.id
      @message.sent_on = Time.now.getutc

      if @message.save
        flash[:notice] = t 'message.new.invite_sent'
        Notifier.message_notification(@message).deliver
      else
        flash[:error] = t 'message.error.sending'
      end
      
    else
      flash[:error] = t 'group.invite.error_sending'
    end
    
    redirect_to :action => :index
  end
  
  
  #from the user clicking the link
  def confirm_invite
    membership = @user.group_memberships.where(:group_id => @group.id).first
    
    if membership == nil
      flash[:error] = t 'group.invite.not_valid'
    elsif membership.status == "active"
      flash[:notice] = t 'group.invite.already_joined'
    elsif membership.invite_token != params[:token]
      flash[:error] = t 'group.invite.token_invalid'
    elsif membership.invite_token == params[:token]
      
      membership.status = "active"
      membership.invite_token = nil
      
      if membership.save
        flash[:notice] = t 'group.invite.joined'
      else
        flash[:error] = t 'group.invite.problem'
      end
      
    else
      flash[:error] = t 'group.invite.problem'
    end
    
    
    redirect_to @group
  end
  
  private
  
  #permissions to edit group?
  def require_group_lead_or_admin
    unless @group.leadership_includes?(@user) || @user.administrator?
      flash[:error] = t('user.filter.not_an_administrator')
      redirect_to @group
    end
  end
  
  #strong params
  def group_memberships_params
    params.require(:group_memberships).permit(:role) 
  end

  def find_group
    @group = Group.find(params[:group_id])
  end
  

  def choose_layout
    oauth_url = url_for(:controller => :oauth, :action => :authorize, :only_path => true)

    if [ 'api_details' ].include? action_name
      nil
    elsif params[:referer] and URI.parse(params[:referer]).path == oauth_url
      'slim'
    else
      'site'
    end
  end
  
end