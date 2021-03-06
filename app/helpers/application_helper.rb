module ApplicationHelper

  def new_notification(user, notice_id, notice_type)
    notice = user.notifications.build(notice_id: notice_id,
    notice_type: notice_type, sender_id: current_user.id)
    return notice
  end

  #Returns object user is being notified about
  def notification_source(notice, notice_type)
    r = nil
    r = FriendRequest.find(notice.notice_id) if ['friend_request', 'friend_accept'].include?(notice_type)
    r = Comment.find(notice.notice_id) if notice_type == 'comment'
    r = Comment.find(notice.notice_id) if notice_type == 'like-comment'
    r = Post.find(notice.notice_id) if notice_type == 'like-post'
    return r unless notice_type.include?('comment')
    Post.find(r.post_id)
  end

end
