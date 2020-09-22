class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    type = type_subject?(params)[0]
    @subject = type_subject?(params)[1]
    notice = "#{type}"
    return unless @subject

    if already_liked?(type)
      dislike(type)
    else
      @like = @subject.likes.build(user_id: current_user.id)

      if @like.save!
        flash[:notice] = "#{notice} liked!"
        redirect_back(fallback_location: root_path)
      else
        flash[:notice] = "#{notice} like failed!"
      end
    end
  end

  private

  def type_subject?(params)
    type = 'post' if params.key?('post_id')
    type = 'comment' if params.key?('comment_id')
    subject = Post.find(params[:post_id]) if type == 'post'
    subject = Comment.find(params[:comment_id]) if type == 'comment'
    [type, subject]
  end

  def already_liked?(type)
    result = false
    if type == 'post'
      result = Like.where(user_id: current_user.id,
                          post_id: params[:post_id]).exists?
    end
    if type == 'comment'
      result = Like.where(user_id: current_user.id,
                          comment_id: params[:comment_id]).exists?
    end
    result
  end

  def dislike(type)
    @like = Like.find_by(post_id: params[:post_id]) if type == 
                                                          'post'
    @like = Like.find_by(comment_id: params[:comment_id]) if type == 
                                                          'comment'
    return unless @like

    @like.destroy
  end

end