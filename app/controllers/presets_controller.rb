class PresetsController < ApplicationController

  layout false
  before_filter :check_api_readable
  before_filter :check_api_writable
  before_filter :authorize, only: [:create, :edit, :update, :destroy]
  before_filter :require_user, only: [:create, :edit, :update, :destroy]
  before_filter :set_locale
  around_filter :api_call_handle_error, :api_call_timeout
  after_filter :compress_output
  before_action :set_preset, only: [:show, :edit, :update, :destroy, :has_permission?]

  # GET /presets
  def index
    @presets = Preset.all

    respond_to do |format|
      format.json { render :action => :index }
      format.js { render :action => :index }
#      format.xml { render :action => :show }
    end
  end

  # GET /presets/1
  def show
  end

  # POST /presets
  def create
    raise OSM::APIBadUserInput.new("No json was given") unless params[:json]
    @preset = Preset.new(preset_params)
    @preset.user = @user

    @preset.save!

    respond_to do |format|
      format.json { render :action => :show }
#      format.xml { render :action => :show }
    end
  end

  # PATCH/PUT /presets/1
  def update
    if has_permission?
      if @preset.update(preset_params)
        render action: 'show'
      end
    else
      # Can't raise the usual exception because this is a JSON API.
      render :json => {:error => 'Not enough permissions'}
    end
  end

  # Get the individual Preset to edit while checking permissions.
  def edit
    if has_permission?
      render action: 'show'
    else 
      render :json => {:error => 'Not enough permissions'}
    end
  end

  ##
  # Returns true if the current user has enough permissions to edit the 
  # Preset.
  def has_permission?
    owner_groups = @preset.user.groups
    if (@user.groups & owner_groups).length > 0
      return true
    else
      return false
    end
  end


  # DELETE /presets/1
  def destroy
    @preset.destroy
    #render action: 'index'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_preset
      @preset = Preset.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def preset_params
      params.permit(:json)
    end
end
