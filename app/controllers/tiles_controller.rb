class TilesController < ApplicationController

  layout false
  before_filter :check_api_readable
  before_filter :check_api_writable
  before_filter :setup_user_auth
  before_filter :authorize, only: [:create, :update, :destroy]
  before_filter :require_moderator, only: [:create, :update, :destroy]
  before_filter :set_locale
  around_filter :api_call_handle_error, :api_call_timeout
  after_filter :compress_output
  before_action :set_tile, only: [:show, :update, :destroy]

  # GET /tiles
  def index
    @tiles = Tile.all

    respond_to do |format|
      format.js { render :action => :index }
      format.json { render :action => :index }
    end
  end

  # GET /tiles/1
  def show
  end

  # POST /tiles
  def create
    raise OSM::APIBadUserInput.new("No code was given") unless params[:tile][:code]
    raise OSM::APIBadUserInput.new("No keyid was given") unless params[:tile][:keyid]
    raise OSM::APIBadUserInput.new("No name was given") unless params[:tile][:name]
    raise OSM::APIBadUserInput.new("No attribution was given") unless params[:tile][:attribution]
    raise OSM::APIBadUserInput.new("No url was given") unless params[:tile][:url]
    raise OSM::APIBadUserInput.new("No subdomains was given") unless params[:tile][:subdomains]
    raise OSM::APIBadUserInput.new("No base_layer was given") unless params[:tile][:base_layer]
    raise OSM::APIBadUserInput.new("No description was given") unless params[:tile][:description]
    @tile = Tile.new(tile_params)

    @tile.save!

    respond_to do |format|
      format.json { render :action => :show }
    end
  end

  # PATCH/PUT /tiles/1
  def update
    if @tile.update(tile_params)
      render action: 'show'
    end
  end

  # DELETE /tile/1
  def destroy
    @tile.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tile
      @tile = Tile.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tile_params
      params.require(:tile).permit(:code,:keyid, :name,:attribution, :url, :subdomains, :base_layer, :description)
    end
end