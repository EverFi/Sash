

containsString = (arr, val) ->
  index = -1
  for i in [0...arr.length]
    if arr[ i ].toString() == val.toString()
      index = i
      break
  return index

exports.containsString = containsString