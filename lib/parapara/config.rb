require 'erb'

module Parapara
  class Config
    def initialize(data)
      @data = default.merge(data)
    end

    def self.all
      YAML.load_file('config/presentation.yml').map do |data|
        Config.new(data)
      end
    end

    def url
      @data[:url]
    end

    def file_path
      if local?
        @data[:file_path]
      else
        cache_file_path
      end
    end

    def converted_file_path
      Pathname.new("static#{raw_converted_file_path}")
    end

    def raw_converted_file_path
      "/converted/#{key}"
    end

    def text
      @data[:text]
    end

    def font
      @data[:font]
    end

    def color
      @data[:color]
    end

    def stroke
      @data[:stroke]
    end

    def pointsize
      @data[:pointsize]
    end

    def kerning
      @data[:kerning] || @data[:pointsize].to_f / 3
    end

    def local?
      !@data[:file_path].nil?
    end

    def cache_exists?
      File.exists?(cache_file_path)
    end

    private

    def default
      @default ||= YAML.load(ERB.new(File.read('config/default.yml')).result)
    end

    def key
      Digest::MD5.hexdigest(@data.inspect)
    end

    def cache_file_path
      Pathname.new("tmp/cache/#{key}")
    end
  end
end
