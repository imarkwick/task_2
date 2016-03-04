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

  ordered_stream(@insta_stream, @twitter_stream)

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
  @insta_stream = @client.user_recent_media.take(5)
end

def ordered_stream(insta_stream, twitter_stream)

  @full_stream = []
  insta_stream.each { |x| @full_stream << x } 
  twitter_stream.each { |x| @full_stream << x }

  sort_by_date(@full_stream)
end

def sort_by_date(stream)
  @new = @full_stream.sort_by { |obj|
    case obj
    when Twitter::Tweet
      Time.at(obj.created_at)
    else
      Time.at(Integer(obj.created_time))
    end
  }
end

def twitter_connect
  @twitter_client = Twitter::REST::Client.new { |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  }
end

def tweet_stream
  @twitter_stream = @twitter_client.user_timeline.take(5)
end


