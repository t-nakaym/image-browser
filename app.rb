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

  get '/' do
    all_entries = Dir.entries(BASE_DIRECTORY).select do |entry|
      entry !~ /\A\.{1,2}\z/ && File.directory?(File.join(BASE_DIRECTORY, entry))
    end

    @entries = all_entries[page * 10, 10]
    @result = Struct::Result.new(all_entries.size, @entries.size, @entries)

    haml :list, :format => :html5
  end

  run! if app_file == $0
end
