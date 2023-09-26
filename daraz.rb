class Daraz
  attr_reader :daraz_url, :seller, :url

  def initialize(daraz_url, seller)
    @daraz_url = daraz_url
    puts "hello :: #{ daraz_url }"
  end

  def visit_full_page(daraz_url, seller)
    @driver = Selenium::WebDriver.for :chrome
    @driver.get daraz_url.to_s
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
    len_of_page = @driver.execute_script("window.scrollTo(0, len_of_page =
      (document.body.scrollHeight)); return len_of_page")
    match = false
    while match == false
      last_count = len_of_page
      sleep(3)
      len_of_page = @driver.execute_script("window.scrollTo(0, len_of_page =
        (document.body.scrollHeight)); return len_of_page")
      if last_count == len_of_page
        match = true
      end
    end
    @urls = []
    @doc = Nokogiri::HTML(open(daraz_url.to_s))
    @json_string = @doc.xpath("//script [@type = 'application/ld+json']").map(&:text)
    @json_data = JSON.parse(@json_string[1])
    list_item = @json_data["itemListElement"]
    list_item.each do |li|
      @urls = li["url"]
      DarazSinglePageWorker.perform_async @urls, seller
      puts @urls.to_s
    end
    # driver.find_element_by_xpath("//a[contains(text(),'Next')]").click()
    @driver.quit
  end

  def visit_single_page(url, seller)
    @seller_id = seller
    @doc = Nokogiri::HTML(open(url.to_s))
    @json_string = @doc.xpath("//script [@type = 'application/ld+json']").map(&:text)
    @json_data = JSON.parse(@json_string[0])
    @title = @json_data["name"]
    @shop_name = @json_data["offers"]["seller"]["name"]
    @price = @json_data["offers"]["lowPrice"]
    @quantity = @json_data["offers"]["inventoryLevel"].nil? ? 0 : @json_data["offers"]["inventoryLevel"]["value"]
    @image = @json_data["image"]
    @description = Sanitize.fragment(@json_data["description"], Sanitize::Config::RESTRICTED)
    uri = URI("http://app.pasapay.com.lvh.me:3000/api/daraz_products")
    params = { seller_id: @seller_id,
      current_shop: @shop_name,
      title: @title,
      price: @price,
      quantity: @quantity,
      description: @description,
      image: @image}
    res = Net::HTTP.post_form(uri, params)
  end
end
