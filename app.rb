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
      [params[:page].to_i, 1].max
    end

    def next_page(all_page)
      page >= all_page ? 1 : page.succ
    end

    def encoded_url(*entries)
      URI.encode(url(File.join(*entries), false))
    end

    def dir_link(image_dir)
      if image_dir.subdirs.size == 0
        encoded_url('/show', image_dir.path, '1')
      else
        encoded_url('/list', image_dir.path)
      end
    end

    def page_link(link_page, curr_page, max_page, uri_base, label)
      locals = {
        :link_label => label,
        :link_url   => pagination_url(uri_base, params.merge('page' => link_page)),
      } 

      if link_page == curr_page || link_page < 1 || link_page > max_page
        haml "%li{class: 'disabled'}\n  %span= link_label", :locals => locals
      else
        haml "%li\n  %a{href: link_url}= link_label", :locals => locals
      end
    end
  end

  get '/list' do
    redirect to('/list/')
  end

  get '/list/*?' do
    path = File.join(*params[:splat])
    @result = ImageDirectoryList.new(BASE_DIRECTORY, path, page, 12, params[:query])

    haml :list
  end

  get '/show/*/:page' do
    @image_dir      = ImageDirectory.new(BASE_DIRECTORY, File.join(params[:splat]))
    @next_page      = next_page(@image_dir.images.size)
    @image_filename = @image_dir.images[page - 1]

    haml :show
  end

  get '/images/*' do
    env["PATH_INFO"] = Rack::Utils.escape(File.join(params[:splat]))
    Rack::File.new(BASE_DIRECTORY).call(env)
  end

  run! if app_file == $0
end
