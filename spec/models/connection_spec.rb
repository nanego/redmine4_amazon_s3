require 'spec_helper'

describe AmazonS3::Connection do

  it "should return the correct url for an object" do
    url = AmazonS3::Connection.object_url("test", "test_folder/")
    expect(url).to eq("https://test-bucket.s3.eu-west-3.amazonaws.com/test_folder/test")
  end

end
