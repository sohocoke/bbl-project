require 'sinatra'
require 'sinatra/base'

require 'json'

require_relative '../lib/configs'

class Server < Sinatra::Base

  before do
    # CORS permission for angular dev-phase resources
    # FIXME reduce scope to dev only.
    response['Access-Control-Allow-Origin'] = "*"    
    response['Access-Control-Allow-Headers'] = "Content-Type"    
  end

  # needed for serve post requests.
  options '/*' do
    response['Access-Control-Allow-Origin'] = "*"    
    response['Access-Control-Allow-Headers'] = "Content-Type"    
  end

  # a simple GET API for list data.

  get '/apps' do
    deployables.map do |e|
        {
          id: e
        }
    end
    .to_json
  end

  get '/destinations' do
    targets(/.*/).to_json
  end

  # get '/runs' do
  #   # open up on a need-to-know basis.
  #   [].to_json
  # end

  post '/runs' do
    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read

    apps = data['apps']
    destinations = data['destinations']

    # add a run.
    cmds = apps.map do |app|
      "rake app:{package,clone,deploy}[#{app},'(#{destinations.join('|')})']"
    end

    # TODO execute.
    puts "running commands #{cmds}"
    pid = spawn cmds.join ';' 

    # pass back data for easy troubleshooting.
    {
      apps: apps,
      destinations: destinations,
      cmds: cmds,
      pid: pid
    }.to_json
  end

  # TODO set up a POST endpoint for command exec.


  # start the server if ruby file executed directly
  run! if app_file == $0
end