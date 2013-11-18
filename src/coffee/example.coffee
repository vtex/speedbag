class Man
  constructor: (@name) ->
    @gender = 'male'

class Woman
  constructor: (@name) ->
    @gender = 'female'

root = exports ? window
root.Man = Man
root.Woman = Woman