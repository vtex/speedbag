describe 'Man', ->
	man = new Man 'Brian Peter George St. Jean le Baptiste de la Salle Eno'

	it 'should have a name', ->
		expect(man.name).toBe 'Brian Peter George St. Jean le Baptiste de la Salle Eno'

	it 'should be male', ->
		expect(man.gender).toBe 'male'

describe 'Woman', ->
	woman = new Woman 'Princess Diana'

	it 'should have a name', ->
		expect(woman.name).toBe 'Princess Diana'

	it 'should be female', ->
		expect(woman.gender).toBe 'female'

