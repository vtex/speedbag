(function() {
  var Man, Woman, chai, _ref;

  chai = require('chai');

  chai.should();

  _ref = require('../../build/js/people'), Man = _ref.Man, Woman = _ref.Woman;

  describe('Man', function() {
    var man1;

    man1 = null;
    it('should have a name', function() {
      man1 = new Man('Brian Peter George St. Jean le Baptiste de la Salle Eno');
      return man1.name.should.equal('Brian Peter George St. Jean le Baptiste de la Salle Eno');
    });
    return it('should be male', function() {
      return man1.gender.should.equal('male');
    });
  });

  describe('Woman', function() {
    var woman1;

    woman1 = null;
    it('should have a name', function() {
      woman1 = new Woman('Princess Diana');
      return woman1.name.should.equal('Princess Diana');
    });
    return it('should be female', function() {
      return woman1.gender.should.equal('female');
    });
  });

}).call(this);
