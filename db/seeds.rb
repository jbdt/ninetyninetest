how_long = 4.weeks

time = Time.now.to_datetime - how_long
if (json_companies = Company.update_news)
  Company.all.each do |c|
    p "Rellenando compañía #{c.name}:"
    day = nil
    print "Días: "
    (0..(how_long/3600)).each do |i|
      h = HourSharePrice.create(company: c, share_price: (rand*(200-80)+80), created_at: (time+i.hour))
      if h.created_at.to_date != day
        print ", " if day
        day ||= h.created_at.to_date
        print "#{day}"
      end
      day = h.created_at.to_date
    end
    print "\n"
  end
  Company.update_actual_share_price json_companies
end
