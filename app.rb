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

    def page_link(link_page, curr_page, max_page, uri_base, label)
      if link_page == curr_page || link_page < 1 || link_page > max_page
        haml "%li{class: 'disabled'}\n  %span #{label}"
      else
        url = pagination_url(uri_base, params.merge('page' => link_page))
        haml "%li\n  %a{href: '#{url}'} #{label}"
      end
    end
  end

  get '/list' do
    @result = ImageDirectoryList.new(BASE_DIRECTORY, page, 12, params[:query])

    haml :list
  end

  get '/show/:directory/:page' do
    @image_dir      = ImageDirectory.new(File.join(BASE_DIRECTORY, params[:directory]))
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
