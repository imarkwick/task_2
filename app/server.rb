require 'sinatra'
require 'instagram'

set :public, Proc.new { File.join(root, "..", "public") }

get '/' do

  client = Instagram.client(access_token: token, count: 5)
  @user = client.user

  @html = ""

  for media_item in client.user_recent_media[0..4]
    @html << "<img src='#{media_item.images.thumbnail.url}' class='medium-12 columns' style='padding:1rem;height:13rem;width:13rem;'><br>"
  end

  erb :index
end

private

def token
  "2611825.905a71f.b7a6bc624157473e8c0ae534156731c3"
end
