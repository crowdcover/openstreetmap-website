require 'pry-debugger'

class StoryAttachmentsController < ApplicationController

  before_filter :authorize_web
  before_filter :set_locale
  before_filter :require_user, :only => [:create, :delete]

  before_filter :check_database_readable
  before_filter :check_database_writable, :only => [:create]

  def create
    attachment = StoryAttachment.new(:image => params[:story_attachment][:image])
    if attachment.save
      redirect_to("/stories/attachment/#{attachment.id}")
    else
      @attachment = attachment
      @attachment.errors.set(:image, ['unable to save image'])
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
    @title = t 'story.attachment.new.title'
    @attachment = StoryAttachment.new
  end

  def show
    style = params.fetch(:style, :large)
    attachment = StoryAttachment.find_by_id(params[:id])
    send_file(attachment.image.path(style),
      :disposition => 'inline'
    )
  end

end
