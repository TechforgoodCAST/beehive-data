json.array! @durations do |fund|
  json.ignore_nil!
  json.fund_slug fund[:fund]
  json.durations fund[:durations]
end
