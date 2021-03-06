require 'byebug'
enable :sessions


def login?
  if session[:username].nil?
    return false
  else
    return true
  end
end

def username
  return session[:username]
end


get '/' do
  # Look in app/views/index.erb
  @all_post = Post.all
  erb :'/posts/all_posts'
end


get '/users/create' do

  erb :'/users/create_user'
end


post '/users/create_user' do
  @user = User.create(name: params[:name], username: params[:username], email:params[:email], password: params[:password])

  erb :'/users/create_user_success'
end


get '/posts/new' do
  if session[:username] != nil
    erb :'/posts/new_post'
  else
    erb :'/users/invalid'
  end

end


get '/users/login' do
  erb :'/users/login'
end


post '/users/login' do

  @user = User.authenticate(params[:email], params[:password])
   if @user
     session[:username] = @user[:username]
     redirect '/'
   else
     erb :'/users/invalid'
   end

end

get '/logout' do
  session[:username] = nil
  redirect "/"
end

post '/posts/new' do

 @user = User.find_by username: session[:username]
  @user.posts.create(subject: params[:subject], url: params[:URL])

  redirect '/'
end


get '/posts/:post_id' do
  @post = Post.find(params[:post_id])
  @comments = @post.comments
  @post_votes = @post.post_votes
  @post_sum = 0
  @post_votes.each do |v|
    @post_sum = @post_sum + v.vote
  end
  @comments.each do |comment|
    @comment_votes = comment.comment_votes
    @comment_sum = 0
    @comment_votes.each do |v|
      @comment_sum = @comment_sum + v.vote
    end
  end
  erb :'/posts/particular_post'
end



post '/posts/add_comment/:post_id' do
  @user = User.find_by username: session[:username]
  @user.comments.create(body: params[:body], post_id: params[:post_id])
  id = params[:post_id]

  redirect "/posts/#{id}"
end


get '/users/:id' do
  @user = User.find params[:id]
  @post = @user.posts
  @comment = @user.comments

  erb :"/users/particular_user"
end

get "/posts/:id/:vote" do
  @user = User.find_by username: session[:username]
  if @user.post_votes.find_by post_id: params[:id]
    vote = @user.post_votes.find_by post_id: params[:id]
    vote.vote= params[:vote]
    vote.save
  else
    @user.post_votes.create(post_id: params[:id], vote: params[:vote])
  end
end

get "/comments/:id/:vote" do
  @user = User.find_by username: session[:username]
  if @user.comment_votes.find_by comment_id: params[:id]
    vote = @user.comment_votes.find_by comment_id: params[:id]
    vote.vote= params[:vote]
    vote.save
  else
    @user.comment_votes.create(comment_id: params[:id], vote: params[:vote])

end

id = params[:id]
  redirect "/posts/#{id}"
end









