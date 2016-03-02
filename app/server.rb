require 'sinatra'

set :public, Proc.new { File.join(root, "..", "public") }

get '/' do   
  File.read(File.join('views', 'index.html'))
end
