require 'sinatra/base'
require 'sinatra/paginate'
require 'sinatra/twitter-bootstrap'
require_relative 'lib/image_directory_list'
require_relative 'lib/image_directory'


BASE_DIRECTORY = ARGV[0]

class App < Sinatra::Base
  register Sinatra::Paginate
  register Sinatra::Twitter::Bootstrap::Assets

  set :haml, :format => :html5

  helpers do
    def page
      [params[:page].to_i - 1, 0].max
    end

    def next_page(current_page, all_page)
      current_page >= all_page ? 1 : current_page.succ
    end
  end

  get '/list' do
    @result = ImageDirectoryList.new(BASE_DIRECTORY, page, 12)

    haml :list
  end

  get '/show/:directory/:page' do
    @image_dir      = ImageDirectory.new(File.join(BASE_DIRECTORY, params[:directory]))
    @current_page   = params[:page].to_i
    @next_page      = next_page(@current_page, @image_dir.images.size)
    @image_filename = @image_dir.images[@current_page - 1]

    haml :show
  end

  get '/images/*' do
    env["PATH_INFO"] = Rack::Utils.escape(File.join(params[:splat]))
    Rack::File.new(BASE_DIRECTORY).call(env)
  end

  run! if app_file == $0
end
