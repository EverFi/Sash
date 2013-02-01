
countItems = (obj) ->
  count = 0
  for k, v of obj
    count += 1
  return count

exports.countItems = countItems