class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = Post.all.order("created_at DESC")
  end

  def show 
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save!
      redirect_to post_path(@post)
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    
    if @post.update!
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end