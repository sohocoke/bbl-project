require 'sinatra'
require 'json'

require 'sinatra/base'

class Server < Sinatra::Base

  # a simple GET API for list data.
  get '/apps' do
    # CORS permission for angular dev-phase resources
    # FIXME reduce scope to dev only.
    response['Access-Control-Allow-Origin'] = "*"
    [
      {
        id: "ch-etit"
      },
      {
        id: "ch-prod"
      }
    ].to_json
  end


  # TODO set up a POST endpoint for command exec.


  # start the server if ruby file executed directly
  run! if app_file == $0
end