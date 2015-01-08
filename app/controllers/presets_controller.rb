class PresetsController < ApplicationController

  layout false
  before_filter :check_api_readable
  before_filter :check_api_writable
  # skip_before_filter :verify_authenticity_token, :only => [:create]
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
    raise OSM::APIBadUserInput.new("No json was given") unless request.raw_post
    data = ActiveSupport::JSON.decode(request.raw_post)
    @preset = Preset.new(:json => ActiveSupport::JSON.encode(data))
    @preset.user = @user

    @preset.save!

    respond_to do |format|
      format.any { render :json => {:id => @preset.id} }
#      format.xml { render :action => :show }
    end
  end

  # PATCH/PUT /presets/1
  def update
    data = ActiveSupport::JSON.decode(request.raw_post)
    data.delete("id");
    if has_permission?
      if @preset.update(:json => ActiveSupport::JSON.encode(data))
        respond_to do |format|
          # FIXME: Ideally this should return the whole object.
          format.any { render :json => {:id => @preset.id} }
          # format.any {render :json => ActiveSupport::JSON.encode(@preset)}
        end
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
    if has_permission?
      @preset.destroy
      render :json => {success: 'Preset Deleted'}
    else
      render :json => {error: 'Not enough permissions'}
    end
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
