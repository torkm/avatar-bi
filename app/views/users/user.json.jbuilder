json.array! @users do |user|
  json.name               user.name
  json.this_travel_time   user.this_travel_time
  json.total_travel_time  user.total_travel_time
end
