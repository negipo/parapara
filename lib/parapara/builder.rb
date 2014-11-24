require 'digest/md5'
require 'pathname'
require 'fileutils'

module Parapara
  class Builder
    def initialize(config)
      @config = config
    end

    def self.build
      Config.all.each do |config|
        builder = self.new(config)
        builder.build
      end
    end

    def build
      puts "building #{@config.text}"
      fetch if require_fetch?
      return unless require_convert?

      image = build_image(@config.file_path)
      write_converted_image(image)
    end

    private

    def fetch
      response = RestClient.get(@config.url)
      FileUtils.mkdir_p(@config.file_path.dirname)
      File.write(@config.file_path, response.body)
    end

    def build_image(file_path)
      raise 'no local or cached file' unless File.exists?(file_path)

      blob = File.open(file_path, 'r').read
      sources = ::Magick::ImageList.new.from_blob(blob).coalesce
      images = ::Magick::ImageList.new
      sources.each_with_index do |source, idx|
        text = get_text(size: sources.size, index: idx, texts: @config.text)
        target = append_text(source, text)
        target.delay = source.delay
        images << target
      end

      images.iterations = 0
      images.
        optimize_layers(Magick::OptimizeLayer).
        to_blob
    end

    def write_converted_image(image)
      FileUtils.mkdir_p(@config.converted_file_path.dirname)
      File.write(@config.converted_file_path, image)
    end

    def append_text(source, text)
      return source unless text

      config = @config
      pointsize, kerning = pointsize_and_kerning(
        image_width: source.columns,
        text: text,
        config: config
      )
      draw = Magick::Draw.new.annotate(source, 0, 0, 0, 0, text) do
        self.font = config.font
        self.fill = config.color
        self.stroke = config.stroke
        self.pointsize = pointsize
        self.kerning = kerning
        self.gravity = Magick::CenterGravity
      end
      source
    end

    def get_text(size: nil, index: nil, texts: nil)
      return texts unless texts.kind_of?(Array)
      splitter = size.to_f / texts.size
      if index.to_f / splitter >= texts.size
        texts[texts.size - 1]
      else
        texts[index / splitter]
      end
    end

    def pointsize_and_kerning(image_width: image_width, text: text, config: config)
      if config.pointsize.kind_of?(Numeric)
        [config.pointsize, config.kerning]
      else
        max_text_size = text.split("\n").sort_by(&:length).last.length
        base = image_width.to_f / max_text_size
        base /= 1.618

        # For double width chars
        if config.pointsize == :half
          [base * 0.9,  base * 0.1]
        else
          [base * 1.8,  base * 0.2]
        end
      end
    end

    def require_fetch?
      !@config.local? && !@config.cache_exists?
    end

    def require_convert?
      !@config.converted_file_exists?
    end
  end
end
