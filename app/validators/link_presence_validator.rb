class LinkPresenceValidator < ActiveModel::Validator

  def validate(record)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML)
    document = LibXML::XML::Document.string(markdown.render(record.description))
    if document.find('//a').length > 0
      record.errors[:description] << 'Links are not permitted in the report description.'
    end
  end

end
