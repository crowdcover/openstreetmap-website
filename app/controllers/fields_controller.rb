class FieldsController < ApplicationController

  layout false
  before_filter :check_api_readable
  before_filter :check_api_writable
  # before_filter :setup_user_auth
  before_filter :authorize, only: [:create, :edit, :update, :destroy]
  before_filter :require_user, only: [:create, :edit, :update, :destroy]
  before_filter :set_locale
  around_filter :api_call_handle_error, :api_call_timeout
  after_filter :compress_output
  before_action :set_field, only: [:show, :edit, :update, :destroy]

  # GET /fields
  def index
    @fields = Field.all

    respond_to do |format|
      format.json { render :action => :index }
      format.js { render :action => :index }
#      format.xml { render :action => :show }
    end
  end

#   # GET /presets/1
  def show
  end

  # POST /presets
  def create
    raise OSM::APIBadUserInput.new("No json was given") unless request.raw_post
    data = ActiveSupport::JSON.decode(request.raw_post)
    puts data
    @field = Field.new(:json => ActiveSupport::JSON.encode(data))

    @field.save!

    respond_to do |format|
      format.any {render :json => {:id => @field.id}}
      # format.json { render :action => :show }
#      format.xml { render :action => :show }
    end
  end

  # PATCH/PUT /presets/1
  def update
    data = ActiveSupport::JSON.decode(request.raw_post)
    data.delete("name");
    data.delete("id");
    if has_permission?
      if @field.update(:json => ActiveSupport::JSON.encode(data))
        respond_to do |format|
          # FIXME: Ideally this should return the whole object
          format.any {render :json => {:id => @field.id}}
          # format.any {render :json => ActiveSupport::JSON.encode(@field)}
        end
      end
    else
      render :json => {:error => 'Not enough permissions'}
    end
  end

  # DELETE /presets/1
  def destroy
    @field.destroy
    #render action: 'index'
  end

  def has_permission?
    if (@field.user != @user)
      return false
    else
      return true
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_field
      @field = Field.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def field_params
      params.permit(:json)
    end
end
