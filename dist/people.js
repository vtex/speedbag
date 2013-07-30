(function() {
  var Man, Woman, root;

  Man = (function() {
    function Man(name) {
      this.name = name;
      this.gender = 'male';
    }

    return Man;

  })();

  Woman = (function() {
    function Woman(name) {
      this.name = name;
      this.gender = 'female';
    }

    return Woman;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Man = Man;

  root.Woman = Woman;

}).call(this);
