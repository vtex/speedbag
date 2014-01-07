
describe 'App Module', ->

  # load the controller's module
  beforeEach module 'app'

  HelloController = scope = null

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    HelloController = $controller 'HelloController',
      $scope: scope

  it 'should have 3 awesome things in the list', ->
    expect(scope.awesomeThings.length).toBe(3)
