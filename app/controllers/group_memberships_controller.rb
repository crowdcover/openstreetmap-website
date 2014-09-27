class GroupMembershipsController < ApplicationController
  layout :choose_layout
  
  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user
  before_filter :check_database_readable
  before_filter :check_database_writable
  
  before_filter :find_group
  before_filter :require_group_lead_or_admin
 
  
  #show all users in a group
  def index 
    @users = @group.users
    @memberships =  @group.group_memberships
    
    respond_to do |format|
      format.html 
      format.json { render :json => @users.to_json(:only =>[:display_name, :id, :creation_time]) }
    end
  end
  
  #add a user to a group
  def create
    
  end
 
 
  def update_role
    membership = @group.group_memberships.where(["user_id = ?", params[:user_id]]).first
    role = params[:group_memberships_role]
    if membership.set_role(role)
      flash[:notice] = t 'group.role.success', :user => membership.user.display_name, :title => @group.title
    else
      flash[:error] = t 'group.role.error', :title => @group.title
    end
    redirect_to :back
  end
  
  #remove a user from a group
  def destroy
    
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