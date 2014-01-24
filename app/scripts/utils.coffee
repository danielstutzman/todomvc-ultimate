Utils =
  uuid: ->
    i = undefined
    random = undefined
    uuid = ""
    i = 0
    while i < 32
      random = Math.random() * 16 | 0
      uuid += "-"  if i is 8 or i is 12 or i is 16 or i is 20
      uuid += ((if i is 12 then 4 else ((if i is 16 then (random & 3 | 8) else random)))).toString(16)
      i++
    uuid

  pluralize: (count, word) ->
    (if count is 1 then word else word + "s")

  store: (namespace, data) ->
    if arguments.length > 1
      localStorage.setItem namespace, JSON.stringify(data)
    else
      store = localStorage.getItem(namespace)
      (store and JSON.parse(store)) or []

module.exports = Utils
