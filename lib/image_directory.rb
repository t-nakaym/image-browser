class ImageDirectory
  attr_reader :basedir, :path, :images, :subdirs

  def initialize(basedir, path)
    @basedir = basedir
    @path    = path
    @images  = image_entries(File.join(basedir, path))
    @subdirs = directory_entries(File.join(basedir, path))
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

  def directory_entries(path)
    Dir.entries(path).select do |entry|
      entry !~ /\A\.{1,2}\z/ && File.directory?(File.join(path, entry))
    end
  end
end
