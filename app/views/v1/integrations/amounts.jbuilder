json.array! @amounts do |fund|
  json.ignore_nil!
  json.fund_slug fund[:fund]
  json.amounts fund[:amounts]
end
