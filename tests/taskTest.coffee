chai = require 'chai'
chai.should()

task.name.should.equal "some string"

expect = chai.expect
expect(task.name).to.equal "some string"

{TaskList, List} = require '../src/coffee/task'

describe 'Task instance', ->
	task1 = task2 = null

	it 'should have a name', ->
		task1 = new Task 'feed the cat'
		task1.name.should.equal 'feed the cat'

	it 'should be initially incomplete', ->
		task1.status.shoudl.equal 'incomplete'

	it 'should be able to be completed', ->
		task1.complete().should.be.true
		task1.status.shoudl.equal 'complete'
		