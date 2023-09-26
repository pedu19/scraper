class DarazFullPageWorker
  include Sidekiq::Worker

  def perform(daraz_url, seller_id)
    # puts "DARAZ: :: #{ daraz_url }"

    @daraz  = Daraz.new(daraz_url, seller_id)
    @daraz.visit_full_page(daraz_url, seller_id)
  end
end
