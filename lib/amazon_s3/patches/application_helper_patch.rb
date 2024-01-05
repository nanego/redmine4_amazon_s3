module AmazonS3::Patches::ApplicationHelperPatch
  def thumbnail_tag(attachment)
    link_to(
      image_tag(
        attachment.thumbnail_s3,
        data: {thumbnail: thumbnail_path(attachment)}
      ),
      attachment_path(attachment),
      title: attachment.filename
    )
  end

  # Generates a link to an attachment.
  # Options:
  # * :text - Link text (default to attachment filename)
  # * :download - Force download (default: false)
  def link_to_attachment(attachment, options={})
    if options[:download]
      text = options.delete(:text) || attachment.filename
      url = AmazonS3::Connection.object_url(attachment.disk_filename_s3)
      html_options = options.slice!(:only_path, :filename)
      link_to text, url, html_options
    else
      super
    end
  end
end

ApplicationHelper.class_eval do
  prepend AmazonS3::Patches::ApplicationHelperPatch
end
