json.array! @stations do |station|
  json.id station.id
  json.name station.name
  json.railway_id station.railway_id
  json.railway_jname station.railway.jname
  json.lat station.lat
  json.long station.long
end

# json.id @station.id
# json.name @station.name
# json.railway_id @station.railway_id
# json.railway_jname @station.railway.jname
# json.lat @station.lat
# json.long @station.long



