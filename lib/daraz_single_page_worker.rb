class DarazSinglePageWorker
  include Sidekiq::Worker

  def perform(url, seller)
    # puts url
    @daraz  = Daraz.new(url, seller)
    @daraz.visit_single_page(url, seller) 
  end
end
