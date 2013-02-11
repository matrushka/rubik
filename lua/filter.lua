local bucket = {}
for key,row_js in ipairs(redis.call('lrange','rubik:metrics:{{key}}',0,-1)) do
  local row = cjson.decode(row_js)
  local timestamp = row["t"]
  if (timestamp >= {{start}}) and (timestamp < {{stop}}) then
    table.insert(bucket, cjson.encode(row))
  end
end

return bucket