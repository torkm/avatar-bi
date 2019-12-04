json.array! @avatars do |avatar|
  json.name               avatar.name
  json.is_moving          avatar.is_moving
  json.user_id            avatar.user_id
  json.curr_station_id    avatar.curr_station_id
  json.last_station_id    avatar.last_station_id
  json.home_station_id    avatar.home_station_id
  json.curr_location_lat  avatar.curr_location_lat
  json.curr_location_long avatar.curr_location_long
  json.last_location_lat  avatar.last_location_lat
  json.last_location_long avatar.last_location_long
  json.train_timetable    avatar.train_timetable
end
