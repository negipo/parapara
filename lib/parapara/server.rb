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

    get '/presentations.json' do
      presentations = Config.all.map do |config|
        {
          path: config.raw_converted_file_path
        }
      end

      json presentations
    end
  end
end
