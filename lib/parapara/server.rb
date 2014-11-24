require 'sinatra/json'

module Parapara
  class Server < Sinatra::Application
    set :public_folder, Proc.new { File.join(root, 'static') }

    def self.run!
      Launchy.open("http://#{settings.bind}:#{settings.port}/")
      super
    end

    get '/' do
      erb :index
    end

    get '/slides.json' do
      slides = Config.all.map do |config|
        {
          path: config.raw_converted_file_path,
          text: config.text
        }
      end

      json slides
    end
  end
end
