class Comment < ApplicationRecord
  belongs_to :post, class_name: "Post"
  belongs_to :author, class_name: "User"
  has_many :likes, dependent: :destroy

  def like_count
    self.likes.count
  end
  
end
