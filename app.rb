#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new "Meduzorium.db"
	@db.results_as_hash = true
end

before do
       init_db
end

configure do
	init_db
       @db.execute 'create table if not exists "Posts" ("id" integer primary key autoincrement,"created_date" date,"content" text,"username" text)';  
  	@db.execute 'create table if not exists "Comments" ("id" integer primary key autoincrement,"created_date" date,"content" text, "post_id" integer)';  
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc';

	erb :index			
end

get '/new' do
	erb :new
end

post '/new' do
      content = params[:content]
      username = params[:username]	
        if content.length <= 0
	@error = "Type text"
	return erb :new
	end

	@db.execute "insert into posts (content,created_date,username) values (?,datetime(),?)",[content,username];
	redirect to ('/')

end

get "/details/:id" do
	post_id = params[:id]
	results = @db.execute 'select * from Posts where id = ?', [post_id];
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id =?',[post_id];

	erb :details
end

post "/details/:id" do
	post_id = params[:id]
	content = params[:content]
	if content.length <=0
	@error = "Enter the comment!"
	erb "!"
	sleep(1)
	redirect to ('/details/' +post_id)
	end

	@db.execute "insert into comments (content,created_date,post_id) values (?,datetime(),?)",[content,post_id];
 	redirect to ('/details/' + post_id)
end
	