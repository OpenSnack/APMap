class Site < ActiveRecord::Base
    has_many :aps
    self.primary_key = "uuid"
    mount_uploader :map, SitemapUploader
end