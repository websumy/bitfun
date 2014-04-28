class CommentsController < ApplicationController
  before_filter :load_obj_and_build_comment, only: :create
  load_resource except: :create
  authorize_resource

  def create
    unless params[:comment][:parent_id].blank?
      parent = @obj.comment_threads.find(params[:comment][:parent_id]) rescue nil

      @comment.parent = parent if parent && parent.allowed_to_answer?
    end

    if @comment.save
      render partial: 'comments/comment', locals: { comment: @comment },
             layout: false, status: :created
    else
      render nothing: true, status: 400
    end
  end

  def destroy
    if @comment.destroy
      render json: @comment, status: :ok
    else
      render nothing: true, status: 400
    end
  end

  def vote
    vote = params[:type] != 'dislike'
    if current_user.voted_as_when_voted_for(@comment) != vote
      @comment.vote voter: current_user, vote: vote
    end
    render json: likes_data
  end

  def unvote
    current_user.unvote_for @comment
    render json: likes_data
  end

  private

  def load_obj_and_build_comment
    data = params[:comment]
    @obj = Comment.find_commentable(data[:commentable_type], data[:commentable_id])
    @comment = Comment.build_from(@obj, current_user.id, data[:body])
  end

  def likes_data
    {
        score: @comment.cached_votes_score,
        vote: current_user.voted_as_when_voted_for(@comment)
    }
  end
end
