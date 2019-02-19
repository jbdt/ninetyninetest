class ApplicationController < ActionController::Base
  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == SecureRandom.hex(5) && password == SecureRandom.hex(5)
    end
  end
end