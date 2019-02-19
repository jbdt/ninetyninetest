task :get_share_price, [:lapse] => :environment do |task, args|
  sleep args[:lapse].to_i
  if (json_companies = Company.update_news)
    Company.update_actual_share_price json_companies
  end
end