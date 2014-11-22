module Parapara
  class Config
    def initialize(data)
      @data = default.merge(data)
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
      Pathname.new("tmp/converted/#{key}")
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

    def local?
      !@data[:file_path].nil?
    end

    def cache_exists?
      File.exists?(cache_file_path)
    end

    private

    def default
      @default ||= YAML.load_file('config/default.yaml')
    end

    def key
      Digest::MD5.hexdigest(@data.inspect)
    end

    def cache_file_path
      Pathname.new("tmp/cache/#{key}")
    end
  end
end
