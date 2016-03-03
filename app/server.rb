require 'sinatra'
require 'instagram'
require 'twitter'

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
  @html = ""
  for media_item in @client.user_recent_media[0..4]
    @html << "<img src='#{media_item.images.thumbnail.url}' class='medium-12 columns' style='padding:1rem;height:13rem;width:13rem;border:1px solid #e8e8e8;border-radius:5px;'><br>"
  end
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
  puts @twitter_client.user_timeline[0].created_at

  @stream = @twitter_client.user_timeline[0..4]
  puts @stream.length
end


