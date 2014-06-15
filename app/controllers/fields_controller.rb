class FieldsController < ApplicationController

  layout false
  before_filter :check_api_readable
  before_filter :check_api_writable
  # before_filter :setup_user_auth
  # before_filter :authorize, only: [:create, :edit, :update, :destroy]
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
#   def show
#   end

  # POST /presets
  def create
    raise OSM::APIBadUserInput.new("No json was given") unless params[:json]
    @field = Field.new(field_params)

    @field.save!

    respond_to do |format|
      format.json { render :action => :show }
#      format.xml { render :action => :show }
    end
  end

  # PATCH/PUT /presets/1
  def update
    if @field.update(field_params)
      render action: 'show'
    end
  end

  # DELETE /presets/1
  def destroy
    @field.destroy
    #render action: 'index'
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
