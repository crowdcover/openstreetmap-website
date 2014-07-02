class StoryAttachmentsController < ApplicationController

  layout 'site', :except => :rss

  before_filter :authorize_web, :only => [:create, :destroy]
  before_filter :set_locale
  before_filter :require_user, :only => [:create, :destroy]

  before_filter :check_database_readable
  before_filter :check_database_writable, :only => [:create]

  def create
    @attachment = StoryAttachment.new(
      :image => params[:story_attachment][:image],
      :user  => @user
    )
    respond_to do |format|
      if @attachment.save
        format.html {
          render({ :json => @attachment, :status => :created, :location => @attachment })
        }
        format.json {
          render({ :json => @attachment, :status => :created, :location => @attachment })
        }
      else
        @attachment.errors.set(:image, ['unable to save image'])
        format.html { render :action => 'new' }
        format.json { render :json => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @attachment = StoryAttachment.find(params[:id])
    if @user != @attachment.user
      flash[:error] = t 'story_attachment.destroy.error'
      redirect_to @attachment
    elsif @attachment.destroy
      flash[:notice] = t 'story_attachment.destroy.deleted'
      redirect_to stories_path
    else
      flash[:error] = t 'story_attachment.destroy.error'
      redirect_to @attachment
    end
  end

  def new
    @title = t 'story_attachment.new.title'
    @attachment = StoryAttachment.new
  end

  def show
    style = params.fetch(:style, :large)
    @attachment = StoryAttachment.find(params[:id])
    respond_to do |format|
      format.html {
        path = @attachment.image.path(style)
        if File.exist?(path)
          redirect_to @attachment.image.url(style)
        else
          raise ActionController::RoutingError.new("No StoryAttachment image for id #{params[:id]} with style #{style}")
        end
      }
      format.json {
        render :json => @attachment, :status => :ok, :location => @attachment
      }
    end
  end

  def story_attachment_url(attachment)
    "/stories/attachment/#{attachment.id}"
  end

end
