
require 'rack'
require 'rack/contrib'
require 'sidekiq'
require './app'

run ScraperApp
use Rack::PostBodyContentTypeParser
run Rack::URLMap.new('/' => ScraperApp, '/sidekiq' => Sidekiq::Web)
