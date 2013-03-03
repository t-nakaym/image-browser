class ImageDirectory
  attr_reader :path, :images

  def initialize(path)
    @path   = path
    @images = image_entries(path)
  end

  def basename
    File.basename(@path)
  end

  def thumbnail
    @images.first
  end

  private

  def image_entries(dir)
    Dir.entries(dir).select do |entry|
      entry =~ /\.jpe?g\z/i || entry =~ /\.png\z/i
    end
  end
end
