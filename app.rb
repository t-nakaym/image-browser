require 'sinatra/base'
require 'sinatra/paginate'


BASE_DIRECTORY = ARGV[0]

Struct.new('Result', :total, :size, :entries)

class App < Sinatra::Base
  register Sinatra::Paginate

  set :haml, :format => :html5

  helpers do
    def page
      [params[:page].to_i - 1, 0].max
    end

    def directory_entries(dir)
      Dir.entries(dir).select do |entry|
        entry !~ /\A\.{1,2}\z/ && File.directory?(File.join(dir, entry))
      end
    end

    def image_entries(base_dir, dir)
      Dir.entries(File.join(base_dir, dir)).select do |entry|
        entry =~ /\.jpe?g\z/ || entry =~ /\.png\z/
      end
    end

    def thumbnail_entry(base_dir, dir)
      image_entries(base_dir, dir).first
    end
  end

  get '/list' do
    all_entries = directory_entries(BASE_DIRECTORY)
    entries = all_entries[page * 10, 10]
    entries.map! do |entry|
      thumbnail = File.join('/images', entry, thumbnail_entry(BASE_DIRECTORY, entry))
      [entry, thumbnail]
    end
    @result = Struct::Result.new(all_entries.size, entries.size, entries)

    haml :list
  end

  get '/show/:directory/:page' do
    images          = image_entries(BASE_DIRECTORY, params[:directory])
    @all_pages_num  = images.size
    @current_page   = params[:page].to_i
    @next_page      = @current_page.succ > @all_pages_num ? 1 : @current_page.succ
    @image_filename = images[@current_page - 1]

    haml :show
  end

  get '/images/*' do
    env["PATH_INFO"] = Rack::Utils.escape(File.join(params[:splat]))
    Rack::File.new(BASE_DIRECTORY).call(env)
  end

  run! if app_file == $0
end
