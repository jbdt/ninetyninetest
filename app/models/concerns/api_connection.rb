require 'active_support/concern'
require 'net/http'

module ApiConnection
  RETRIES = Settings.api_connection[:call_api_retries]
  TEST_API = Settings.api_connection[:testapi]

  def self.call_api(uri='')
    url = URI("#{TEST_API}#{uri}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'

    begin
      retries ||= 0
      response = http.request(request)
      JSON.parse(response.read_body)
    rescue => e
      logger.error("#{e}")
      sleep 1
      if (retries += 1) <= RETRIES
        logger.info("Retrying... #{retries} of #{RETRIES}")
        retry
      end
      nil
    end
  end

end