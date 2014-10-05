class GroupsController < ApplicationController
  layout 'site'

  before_filter :authorize_web
  before_filter :check_api_readable
  before_filter :set_locale
  after_filter  :compress_output
  around_filter :api_call_handle_error,
                :api_call_timeout
  before_filter :require_user, 
                :except => [
                  :index, 
                  :show
                ]

  before_filter :find_group,
                :only => [
                  :show,
                  :edit,
                  :update,
                  :destroy,
                  :leave,
                  :become_leader,
                  :schema
                ]
                
  before_filter :require_group_lead_or_admin, :except => [:index, :new, :create, :show, :leave, :become_leader, :presets]

  ##
  # An index of Groups.
  def index
    @groups = Group.where('')
  end
  
  ##
  # The form for creating a new group.
  #
  def new
    @group = Group.new
  end

  ##
  # Process the POST'ing of the new group form.
  def create
    @group = Group.new(group_params)
    
    if @group.save
      if defined?(@user)
        @group.group_memberships.create!(:user_id => @user.id, :status => "active", :role => GroupMembership::Roles::LEADER)
      end
      
      flash[:notice] = t 'group.create.success', :title => @group.title
      redirect_to group_url(@group)
    else
      render :action => "new"
    end
  end

  ##
  # Details page for one group.
  def show
  end

  ##
  # Form to edit an existing group,
  def edit
  end

  ##
  # Process the PUT'ing of an existing group.
  def update   
    if @group.update_attributes(group_params)

      flash[:notice] = t 'group.update.success', :title => @group.title
      redirect_to group_url(@group)
    else
      render :action => "edit"
    end
  end

  ##
  # Delete an entire group.
  def destroy
    if @group.destroy
      flash[:notice] = t 'group.destroy.success', :title => @group.title
    else
      flash[:error] = t 'group.destroy.error', :title => @group.title
    end
    redirect_to groups_url
  end


  ##
  # Remove a member from a group.
  def leave
    group_membership = @group.group_memberships.find_by_user_id(@user.id)
    if group_membership.blank?
      flash[:error] = t 'group.leave.not_in_group', :title => @group.title
    elsif group_membership.destroy
      flash[:notice] = t 'group.leave.success', :title => @group.title
    else
      flash[:error] = t 'group.leave.error', :title => @group.title
    end
    redirect_to :back
  end

  ##
  # 
  def become_leader
    group_membership = @group.group_memberships.find_by_user_id(@user.id)
    if group_membership.blank?
      flash[:error] = t 'group.lead.not_in_group', :title => @group.title
    elsif @group.leaders.count == 0 && group_membership.set_role(GroupMembership::Roles::LEADER)
      flash[:notice] = t 'group.lead.success', :title => @group.title
    else
      flash[:error] = t 'group.lead.error', :title => @group.title
    end
    redirect_to :back
  end

  
  #preset / schema show
  def schema
    
    if request.post? 
      
      if params[:preset][:id].empty?
        @preset = @group.preset
        if @preset
          @preset.group = nil
          @preset.save
          flash[:notice] = "Preset/Schema removed from group"
        end
      else
        @preset = Preset.find(params[:preset][:id])
        if @preset
          @preset.group = @group
          @preset.save
          flash[:notice] = "Preset/Schema added to group"
        end
      end
      
      @preset = nil
      @preset_id = nil
      @available_presets =  Preset.available
      redirect_to :action => 'schema'
      
      return
    end
    
    #get 
    @preset = @group.preset || nil
    @preset_id = @group.preset.nil? ? nil : @group.preset.id
    @available_presets = @group.preset.nil? ?  Preset.available : Preset.available + [@preset]
    
    
  end
  
  #list of all presets with groups
  def presets
    @presets = Preset.all
  end


private

  ##
  # return permitted message parameters
  def group_params
    params.require(:group).permit(:title, :description, :lat, :lon)
  end
  
  def find_group
    @group = Group.find(params[:id])
  end
  
  #permissions to edit group?
  def require_group_lead_or_admin
    unless @group.leadership_includes?(@user) || @user.administrator?
      flash[:error] = t('user.filter.not_an_administrator')
      redirect_to @group
    end
  end
  
end
