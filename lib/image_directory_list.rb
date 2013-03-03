require_relative 'image_directory'

class ImageDirectoryList
  attr_reader :total, :entries

  def initialize(path, page, items_per_page)
    all_entries = directory_entries(path)
    @total      = all_entries.size
    @entries    = all_entries[page * items_per_page, items_per_page].map do |entry|
      ImageDirectory.new(File.join(path, entry))
    end
  end

  def size
    @entries.size
  end

  private

  def directory_entries(path)
    Dir.entries(path).select do |entry|
      entry !~ /\A\.{1,2}\z/ && File.directory?(File.join(path, entry))
    end
  end
end
