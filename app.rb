require 'sinatra'
require 'json'
require 'pry'
require 'sidekiq'
require 'sidekiq/web'
require 'net/http'

require "open-uri"
require "nokogiri"
require "selenium-webdriver"
require "sanitize"
require "webdrivers"

require_relative 'lib/daraz_single_page_worker'
require_relative 'lib/daraz_full_page_worker'
require_relative 'daraz'

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379" }
end


class ScraperApp < Sinatra::Base
  get '/' do
    "Hello, world foo!"
  end

  get '/scrape' do
    @jhash = [] 
    uri = URI "http://app.pasapay.com.lvh.me:3000/api/sellers/scrape_requests"
    # Net::HTTP.get_response(uri)
    res = Net::HTTP.get(uri)
    # binding.pry
    @jhash = JSON.parse(res)
    @input = @jhash[0]["daraz_url"]
    @seller =@jhash[0]["seller_id"]
    @permalink = @jhash[0]["permalink"].to_s
    DarazFullPageWorker.perform_async @input, @seller
    uri_post = URI "http://app.pasapay.com.lvh.me:3000/api/sellers/scrape_requests/#{@permalink}.json"
    params = { permalink: @permalink}
    res_post = Net::HTTP.post_form(uri_post, params)
  end  
end
