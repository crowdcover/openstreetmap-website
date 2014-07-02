class StoriesController < ApplicationController
  layout 'site', :except => :rss
  
  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user, :only => [:index, :new, :edit, :update, :create, :delete, :toggle_draft]
 
  before_filter :check_database_readable
  before_filter :check_database_writable, :only => [:new, :edit, :update, :create, :delete, :toggle_draft]
  

  def index
    @title = t 'story.index.title'
    
    @title = t 'story.index.user_title', :user => @user.display_name
    @stories = @user.stories
    
    @page = (params[:page] || 1).to_i
    @page_size = 20

    @stories = @stories.order("created_at DESC")
    @stories = @stories.offset((@page - 1) * @page_size)
    @stories = @stories.limit(@page_size)
    @stories = @stories.includes(:user)
    
  end

  
  def show
    @story = Story.find(params[:id])
    @title = t 'story.show.title', :title => @story.title
  end
  
  
  def new
    @title = t 'story.new.title'
    if params[:story]
      @story = Story.new(story_params)
    else
      @story = Story.new(Story.default_params)
    end
    
    set_map_location
  end
  
  
  def create
    @story = Story.new(story_params)
    @story.user = @user
      
    if params[:commit] == "Save as Draft"
      @story.draft = true
    else
      @story.draft = false
    end

    if @story.save
      flash[:notice] = t('story.create.success', :title => @story.title)
      redirect_to @story
      
    else
      flash[:error] = t 'story.create.error'

      set_map_location
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

    if params[:commit] == "Save as Draft"
      @story.draft = true
    else
      @story.draft = false
    end
    
    if @user != @story.user
      flash[:error] = t 'story.update.error'
      redirect_to @story
 
    elsif params[:story] and @story.update(story_params)
      flash[:notice] = t('story.update.success', :title => @story.title)
      redirect_to @story
      
    else
      flash[:error] = t 'story.update.error'
      set_map_location
      render 'edit'
      
    end
    
  end
  
  def toggle_draft
    @story = Story.find(params[:story_id])

    if @story.draft
      @story.draft = false
    else
      @story.draft = true
    end

    if @user != @story.user
      flash[:error] = t 'story.update.error'
      redirect_to stories_path
    elsif @story.save
      flash[:notice] = t('story.update.success', :title => @story.title)
      redirect_to stories_path
    else
      flash[:error] = t 'story.update.error'
      redirect_to stories_path
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
      @lon = params[:lon] ||  22.83
      @lat = params[:lat] || -2.877
      @zoom = params[:zoom] || 5
    else
      @lon = @user.home_lon
      @lat = @user.home_lat
      @zoom = 4
    end
  end
  
  
end
