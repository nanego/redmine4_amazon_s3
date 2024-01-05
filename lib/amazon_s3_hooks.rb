# This class hooks into Redmine's View Listeners in order to add content to the page
class AmazonS3Hooks < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = {})
    javascript_include_tag 'redmine_s3.js', :plugin => 'redmine_s3_aws'
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'amazon_s3/configuration'
      require_relative 'amazon_s3/connection'
      require_relative 'amazon_s3/thumbnail'
      require_relative 'amazon_s3/patches/application_helper_patch'
      require_relative 'amazon_s3/patches/attachment_patch'
      require_relative 'amazon_s3/patches/attachments_controller_concern'
    end
  end
end
