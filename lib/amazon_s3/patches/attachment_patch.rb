require "#{Rails.root}/app/models/attachment"

module AmazonS3::Patches::AttachmentPatch

  def put_to_s3
    if @temp_file && (@temp_file.size > 0) && errors.blank?
      self.disk_directory = target_directory
      sha = Digest::SHA256.new
      Attachment.create_diskfile(filename, disk_directory) do |f|
        self.disk_filename = File.basename f.path
        logger.info("Saving attachment '#{disk_filename_s3}' (#{@temp_file.size} bytes)") if logger
        AmazonS3::Connection.put(disk_filename_s3, filename, @temp_file, self.content_type)
      end
      self.digest = sha.hexdigest
    end
    @temp_file = nil

    if content_type.blank? && filename.present?
      self.content_type = Redmine::MimeType.of(filename)
    end
    # Don't save the content type if it's longer than the authorized length
    if self.content_type && self.content_type.length > 255
      self.content_type = nil
    end
  end

  def delete_from_s3
    logger.debug("Deleting #{disk_filename_s3}")
    AmazonS3::Connection.delete(disk_filename_s3)
  end

  # Prevent file uploading to the file system to avoid change file name
  def files_to_final_location; end

  # Returns the full path the attachment thumbnail, or nil
  # if the thumbnail cannot be generated.
  def thumbnail_s3(options = {})
    return unless thumbnailable?

    size = options[:size].to_i
    if size > 0
      # Limit the number of thumbnails per image
      size = (size / 50) * 50
      # Maximum thumbnail size
      size = 800 if size > 800
    else
      size = Setting.thumbnails_size.to_i
    end
    size = 100 unless size > 0
    target = "#{id}_#{digest}_#{size}.thumb"
    update_thumb = options[:update_thumb] || false
    begin
      AmazonS3::Thumbnail.get(self.disk_filename_s3, target, size, update_thumb)
    rescue => e
      logger.error "An error occured while generating thumbnail for #{disk_filename_s3} to #{target}\nException was: #{e.message}" if logger
      return
    end
  end

  def disk_filename_s3
    path = disk_filename
    path = File.join(disk_directory, path) unless disk_directory.blank?
    path
  end

  def generate_thumbnail_s3
    thumbnail_s3(update_thumb: true)
  end

end

Attachment.class_eval do

  prepend AmazonS3::Patches::AttachmentPatch

  attr_accessor :s3_access_key_id, :s3_secret_acces_key, :s3_bucket, :s3_bucket
  after_validation :put_to_s3
  after_create :generate_thumbnail_s3
  before_destroy :delete_from_s3

end
