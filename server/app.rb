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
    platform_folded = deployables.map do |deployable|
      deployable.gsub( /-(#{platforms.join('|')}$)/, '')
    end .uniq

    platform_folded.map do |e|
        {
          id: e
        }
    end
    .to_json
  end

  get '/targets' do
    targets(/.*/).to_json
  end

  get '/runs/:run_id' do
    run_id = params[:run_id]

    # serve up the details for the run.
    {
      run_id: run_id,
      log: log(run_id),
      options: [
        :cancel,
      ]
    }.to_json
  end

  post '/runs' do
    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read

    apps = data['apps']
    targets = data['targets']

    # create the commands for the run.
    cmds = apps.map do |app|
      "rake app:deploy[#{app},'(#{targets.join('|')})']"
    end

    # execute.
    exec_cmds cmds

    # pass back data for easy troubleshooting.
    {
      apps: apps,
      targets: targets,
      cmds: cmds,
      pid: pid,
      run_id: run_id(pid)
    }.to_json
  end


  #= util

  def run_id( pid )
    "#{Time.new.to_i}_#{pid}"
  end

  def log(run_id)
  end


  #= util - mutating

  def exec_cmds( cmds )
    puts "running commands #{cmds}"
    pid = spawn cmds.join ';' 

    # TODO capture output
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end