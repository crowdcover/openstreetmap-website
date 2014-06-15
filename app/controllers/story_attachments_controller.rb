class StoryAttachmentsController < ApplicationController

  layout 'site', :except => :rss

  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user, :only => [:create, :delete]

  before_filter :check_database_readable
  before_filter :check_database_writable, :only => [:create]

  def create
    @attachment = StoryAttachment.new(:image => params[:story_attachment][:image])
    respond_to do |format|
      if @attachment.save
        format.html {
          redirect_to("/stories/attachment/#{@attachment.id}")
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

  def delete
    attachment = StoryAttachment.find_by_id(params[:id])
    attachment.destroy!
    # TODO: Then what?
    # TODO: Should StoryAttachment be tied to a user?
    # TODO: Should only the user be able to delete their attachments?
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
        send_file(@attachment.image.path(style), :disposition => 'inline')
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
