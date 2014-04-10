class StoriesController < ApplicationController
  layout 'site', :except => :rss
  
  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user, :only => [:new, :edit, :update, :create, :delete]
 
  before_filter :check_database_readable
  before_filter :check_database_writable, :only => [:new, :edit]
  
  before_filter :fix_layers_params, :only => [:update, :create]

  def index
    @title = t 'story.index.title'
    
    if params[:display_name]
      @this_user = User.active.find_by_display_name(params[:display_name])

      if @this_user
        @title = t 'story.index.user_title', :user => @this_user.display_name
        @stories = @this_user.stories
      else
        render_unknown_user params[:display_name]
        return
      end
      
    elsif params[:group_id]
      group = Group.find(params[:group_id])
      if group
        @title = t 'story.index.group_title', :group => group.title
        @stories = group.stories
      else
        render :action => "no_such_entry", :status => :not_found
        return
      end
      
    else
    
      @stories = Story.joins(:user).where(:users => { :status => ["active", "confirmed"] })
 
    end
    
    @page = (params[:page] || 1).to_i
    @page_size = 20

    @stories = @stories.order("created_at DESC")
    @stories = @stories.offset((@page - 1) * @page_size)
    @stories = @stories.limit(@page_size)
    @stories = @stories.includes(:user)
    
  end

  
  def show
    @title = t 'story.show.title'
    @story = Story.find(params[:id])
  end
  
  
  def new
    @title = t 'story.new.title'
    if params[:story]
      @story = Story.new(story_params)
    else
      @story = Story.new()
      @story.layers = {}
      @story.body = {
        "report" => {"title"=>"Report", 
                     "sections"=>[{"title" => "", 
                                  "type" => "", 
                                  "text" => "", 
                                  "link" => ""}
                                  ]
                    },
                         
        "layers"  => {"title"=>"Layers", 
                      "sections"=>[{"title"=> "",
                                    "type" => "layer-ui",
                                    "text" => ""
                                  }                  
                              ]},
        "sites"   => {"title"=>"Sites",
                      "sections"=>[{ "title"=> "",
                                     "type" => "map-nav",
                                     "text" => "",
                                     "links" => [
                                        {"title" => "",
                                         "link" => "",
                                         "text" => ""}
                                         ]
                                   }]
                  }    

        } #body

    end
    
    set_map_location
  end
  
  
  def create
    @story = Story.new(story_params)
    @story.user = @user
    
    if @story.save
      flash[:notice] = t('story.create.success', :title => @story.title)
      redirect_to @story
      
    else
      flash[:error] = t 'story.create.error'
      render 'new'
      
    end
    
  end
  
  
  def edit
    @title = t 'story.edit.title'
    
    @story = Story.find(params[:id])
    if @user != @story.user
      redirect_to @story
      
    end
    
    set_map_location
  end
  
  
  def update
    @story = Story.find(params[:id])
    
    if @user != @story.user
      flash[:error] = t 'story.update.error'
      redirect_to @story
 
    elsif params[:story] and @story.update(story_params)
      flash[:notice] = t('story.update.success', :title => @story.title)
      redirect_to @story
      
    else
      flash[:error] = t 'story.update.error'
      render 'edit'
      
    end
    
  end
  
  def destroy
    @story = Story.find(params[:id])
    
    if @user != @story.user
      flash[:error] = t 'story.destroy.error'
      redirect_to @story
      
    elsif @story.destroy
      flash[:notice] = t 'story.destroy.deleted'
      redirect_to stories_path
      
    else
      flash[:error] = t 'story.destroy.error'
      redirect_to @story
      
    end
    
  end
  

 
  private
  
  #
  # layers param would end up being something like 
  # {"Indigenous"=>true, "Logging"=>true, "Mining"=>false, "Oil"=>true}
  # where the bool = whether the overlay is shown or not
  #
  def fix_layers_params
    layers_status = params[:story].delete(:layers_status).split(",")
    layers = params[:story][:layers]
    new_layers = {}
    layers.each do | layer |
      new_layers[layer] = false
      new_layers[layer] = true if layers_status.include?(layer)
    end
    
    params[:story][:layers] = new_layers

    params
  end
  
  ##
  # return permitted diary entry parameters
  def story_params
    #FIXME for body param
    params.require(:story).permit!
    #params.require(:story).permit(:title, :description, :latitude, :longitude, :layers, :zoom, :body, :group_id, :filename, :layout, :language, :image_url).permit!
  end
  

  ##
  # require that the user is a administrator, or fill out a helpful error message
  # and return them to the user page.
  def require_administrator
    unless @user.administrator?
      flash[:error] = t('user.filter.not_an_administrator')
      redirect_to :controller => 'stories', :action => 'show'
    end
  end

  ##
  # decide on a location for the story
  def set_map_location
    if @story.latitude and @story.longitude
      @lon = @story.longitude
      @lat = @story.latitude
      @zoom = @story.zoom || 4
    elsif @user.home_lat.nil? or @user.home_lon.nil?
      @lon = params[:lon] ||  17.13
      @lat = params[:lat] || -5.09
      @zoom = params[:zoom] || 4
    else
      @lon = @user.home_lon
      @lat = @user.home_lat
      @zoom = 4
    end
  end
end
