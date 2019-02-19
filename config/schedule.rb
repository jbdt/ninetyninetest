every 1.minute do
  [0,20,40].each{|lapse| rake "get_share_price[#{lapse}]"}
end