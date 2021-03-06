class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  has_many :posts, class_name: "Post", foreign_key: "author_id",
  dependent: :destroy
  has_many :comments, class_name: "Comment", foreign_key: "author_id"
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :sent_requests, -> { where confirmed: false}, class_name: "FriendRequest",
  foreign_key: "user_id"

  has_many :pending_requests, -> { where confirmed: false}, class_name: "FriendRequest",
  foreign_key: "friend_id"

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  devise :omniauthable, omniauth_providers: %i[facebook]

  validate :avatar_size

  def friends
    friends_i_sent_inv = FriendRequest.where(user_id: id, confirmed: true).pluck(:friend_id)
    friends_i_received_inv = FriendRequest.where(friend_id: id, confirmed: true).pluck(:user_id)
    ids = friends_i_sent_inv + friends_i_received_inv
    User.where(id: ids)
  end

  def friend_with?(user)
    FriendRequest.confirmed_record?(id, user.id)
  end

  def send_request(user)
    sent_requests.create(friend_id: user.id)
  end

  def possible_friend?(user)
    !FriendRequest.reacted?(id, user.id)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      user.avatar = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def after_confirmation
    welcome_email
  end

  private

  def avatar_size
    errors.add(:avatar, 'should be smaller than 1MB') if avatar.size > 1.megabytes
  end

  def welcome_email
    UserMailer.welcome_email(self).deliver
  end

end
