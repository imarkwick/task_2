require 'sinatra'
require 'instagram'
require 'twitter'
require 'date'
require 'embedly'
require 'json'

set :public_dir, Proc.new { File.join(root, "..", "public") }

get '/' do

  instagram_connect
  @insta_stream = photo_stream(@client)

  twitter_connect
  @twitter_stream = tweet_stream

  ordered_stream(@insta_stream, @twitter_stream)
  display(@new_stream)

  erb :index
end

private

def ordered_stream(insta_stream, twitter_stream)
  @full_stream = []
  insta_stream.each { |x| @full_stream << x } 
  twitter_stream.each { |x| @full_stream << x }

  sort_by_date(@full_stream)
end

def sort_by_date(stream)
  @new_stream = @full_stream.sort_by { |obj|
    case obj
    when Twitter::Tweet
      Time.at(obj.created_at)
    else
      Time.at(Integer(obj.created_time))
    end
  }
end

def display(stream)
  
  @html = ""

  stream.reverse.each do |obj|
    case obj
    when Twitter::Tweet
      @html << "<blockquote class='twitter-tweet' style='margin-left:auto;margin-right:auto;'>
                <a type='application/json+oembed' href='https://api.twitter.com/1/statuses/oembed.json?url=" + obj.url + "'></a></blockquote>"
    else
      embedly
      @test = @embedly_api.oembed url: obj.link
      
      @html << "<blockquote style='border:1px solid #e8e8e8'><img src='" + @test[0].thumbnail_url + "' /><p>" + @test[0].title + "</p></blockquote>"
    end
  end
end

def tweet_stream
  @twitter_client.user_timeline.take(5)
end

def photo_stream(instagram)
  instagram.user_recent_media.take(5)
end

def twitter_connect
  @twitter_client = Twitter::REST::Client.new { |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  }
end

def instagram_connect
  token = ENV['INSTAGRAM_TOKEN']
  @client = Instagram.client(access_token: token, count: 5)
  @user = @client.user
end

def embedly
  embed_key = ENV['EMBEDLY_KEY']
  @embedly_api = Embedly::API.new key: embed_key, user_agent: 'Mozilla/5.0 (compatible; embedly-ruby/1.9.1;)'
end
