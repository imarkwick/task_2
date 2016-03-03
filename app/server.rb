require 'sinatra'
require 'instagram'
require 'twitter'
require 'date'

set :public, Proc.new { File.join(root, "..", "public") }

get '/' do

  instagram_connect
  photo_stream

  twitter_connect
  tweet_stream

  erb :index
end

private

def token
  ENV['INSTAGRAM_TOKEN']
end

def instagram_connect
  @client = Instagram.client(access_token: token, count: 5)
  @user = @client.user
end

def photo_stream
  created = @client.user_recent_media.take(5).first.created_time
  @media_items = @client.user_recent_media.take(5)
end

def insta_date(item)
  DateTime.strptime(item.created_time,'%s')
end

def twitter_connect
  @twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end
end

def tweet_stream
  @stream = @twitter_client.user_timeline.take(5)
end


