class Micropost < ApplicationRecord
  belongs_to :user
  # set default order when query to most recent
  default_scope -> {order(created_at: :desc)}
  # associate image with model by CarrierWave
  mount_uploader  :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size 

  private 
    # validate the size of an uploaded picture
    def picture_size
      if(picture.size > 5.megabytes )
        errors.add(:picture, "Should be less than 5MB")
      end
    end
end
