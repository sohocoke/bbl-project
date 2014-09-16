require 'sinatra'
require 'sinatra/base'

require 'securerandom'
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
    this_run_id = exec_cmds cmds

    # pass back data for easy troubleshooting.
    {
      apps: apps,
      targets: targets,
      cmds: cmds,
      run_id: this_run_id
    }.to_json
  end

  get '/runs/:run_id' do
    run_id = params[:run_id]

    # serve up the details for the run.
    {
      run_id: run_id,
      log: fetch_log(run_id),
      options: [
        :cancel,  # TODO wrap in availability condition
        :requeue  # TODO wrap in availability condition
      ]
    }.to_json
  end


  #= util

  def run_id
    SecureRandom.uuid
  end

  def fetch_log(run_id)
    File.read "log/#{run_id}.log"
  end


  #= util - mutating

  def exec_cmds( cmds )
    this_run_id = run_id

    puts "running commands #{cmds} with run_id #{this_run_id}"

    spawn cmds.join(';'), :err => :out, :out => ["log/#{this_run_id}.log", 'w']

    this_run_id
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end