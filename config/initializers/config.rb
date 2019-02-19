class Settings
  def self.env
    YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
  end

  def self.api_connection
    env[:api_connection]
  end

  def self.api_response
    env[:api_response]
  end

  def self.time_series
    env[:time_series]
  end
end
