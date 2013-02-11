require 'sinatra/base'
require 'sinatra/paginate'


BASE_DIRECTORY = ARGV[0]

Struct.new('Result', :total, :size, :entries)

class App < Sinatra::Base
  register Sinatra::Paginate

  helpers do
    def page
      [params[:page].to_i - 1, 0].max
    end
  end

  get '/list' do
    all_entries = Dir.entries(BASE_DIRECTORY).select do |entry|
      entry !~ /\A\.{1,2}\z/ && File.directory?(File.join(BASE_DIRECTORY, entry))
    end

    @entries = all_entries[page * 10, 10]
    @result = Struct::Result.new(all_entries.size, @entries.size, @entries)

    haml :list, :format => :html5
  end

  get '/show/:directory/:page' do
    all_entries     = Dir.entries(File.join(BASE_DIRECTORY, params[:directory]))
    image_entries   = all_entries.select {|entry| entry =~ /\.jpe?g\z/ || entry =~ /\.png\z/ }
    @all_pages_num  = image_entries.size
    @current_page   = params[:page].to_i
    @next_page      = @current_page.succ > @all_pages_num ? 0 : @current_page.succ
    @image_filename = image_entries[@current_page]

    haml :show, :format => :html5
  end

  get '/images/*' do
    env["PATH_INFO"] = Rack::Utils.escape(File.join(params[:splat]))
    Rack::File.new(BASE_DIRECTORY).call(env)
  end

  run! if app_file == $0
end
