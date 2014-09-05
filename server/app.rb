require 'sinatra'
require 'sinatra/base'

require 'json'

require_relative '../lib/configs'

class Server < Sinatra::Base

  # a simple GET API for list data.

  get '/apps' do
    # CORS permission for angular dev-phase resources
    # FIXME reduce scope to dev only.
    response['Access-Control-Allow-Origin'] = "*"
    deployables.map do |e|
        {
          id: e
        }
    end
    .to_json
  end

  get '/destinations' do
    response['Access-Control-Allow-Origin'] = "*"
    targets(/.*/).to_json
  end


  # TODO set up a POST endpoint for command exec.


  # start the server if ruby file executed directly
  run! if app_file == $0
end