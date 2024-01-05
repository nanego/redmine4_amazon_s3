require_relative 'lib/amazon_s3_hooks'

Redmine::Plugin.register :redmine_s3_aws do
  name 'AmazonS3'
  version '0.0.1'
  description 'Use Amazon S3 as a storage engine for attachments'
  url 'https://github.com/jhovad/redmine4_amazon_s3'
  author 'Josef Hovad'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.4' if Rails.env.test?
end
