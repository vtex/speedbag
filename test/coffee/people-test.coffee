chai = require 'chai'
chai.should()

path = require 'path'
buildPath = path.resolve(process.cwd(), 'build/js')
console.log 'Using build path:', buildPath

{Man, Woman} = require buildPath + '/people.js'	

describe 'Man', ->
	man1 = null

	it 'should have a name', ->
		man1 = new Man 'Brian Peter George St. Jean le Baptiste de la Salle Eno'	
		man1.name.should.equal 'Brian Peter George St. Jean le Baptiste de la Salle Eno'

	it 'should be male', ->
		man1.gender.should.equal 'male'

describe 'Woman', ->
	woman1 = null

	it 'should have a name', ->
		woman1 = new Woman 'Princess Diana'	
		woman1.name.should.equal 'Princess Diana'

	it 'should be female', ->
		woman1.gender.should.equal 'female'

