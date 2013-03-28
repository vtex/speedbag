(function() {
  var Task, TaskList, chai, _ref;

  chai = require('chai');

  chai.should();

  _ref = require('build/js/task.js'), Task = _ref.Task, TaskList = _ref.TaskList;

  describe('Task', function() {
    var task1, task2;

    task1 = task2 = null;
    it('should have a name', function() {
      task1 = new Task('feed the cat');
      return task1.name.should.equal('feed the cat');
    });
    it('should be initially incomplete', function() {
      return task1.status.should.equal('incomplete');
    });
    it('should be able to be completed', function() {
      task1.complete().should.be["true"];
      return task1.status.should.equal('complete');
    });
    it('sould be able to be dependent on another task', function() {
      task1 = new Task('wash dishes');
      task2 = new Task('dry dishes');
      task2.dependsOn(task1);
      task2.status.should.equal('dependent');
      task2.parent.should.equal(task1);
      return task1.child.should.equal(task2);
    });
    return it('should refuse completion if is depedent on an uncompleted task', function() {
      return (function() {
        return task2.complete();
      }).should["throw"]("Dependent task 'wash dishes' is not completed.");
    });
  });

  describe('TaskList', function() {
    var taskList;

    taskList = null;
    it('should start with no tasks', function() {
      taskList = new TaskList;
      taskList.tasks.length.should.equal(0);
      return taskList.length.should.equal(0);
    });
    it('should accept new tasks as tasks', function() {
      var task;

      task = new Task('buy milk');
      taskList.add(task);
      taskList.tasks[0].name.should.equal('buy milk');
      return taskList.length.should.equal(1);
    });
    it('should accept new tasks as string', function() {
      taskList.add('take out garbage');
      taskList.tasks[1].name.should.equal('take out garbage');
      return taskList.length.should.equal(2);
    });
    it('should remove tasks', function() {
      var i;

      i = taskList.length - 1;
      taskList.remove(taskList.tasks[i]);
      return expect(taskList.tasks[i]).to.not.be.ok;
    });
    return it('should print out the list', function() {
      var desiredOutput, task0, task1, task2, task3, task4;

      taskList = new TaskList;
      task0 = new Task('buy milk');
      task1 = new Task('go to store');
      task2 = new Task('another task');
      task3 = new Task('sub-task');
      task4 = new Task('sub-sub-task');
      taskList.add(task0);
      taskList.add(task1);
      taskList.add(task2);
      taskList.add(task3);
      taskList.add(task4);
      task0.dependsOn(task1);
      task4.dependsOn(task3);
      task3.dependsOn(task2);
      task1.complete();
      desiredOutput = "Tasks\n\n- buy milk (depends on 'go to store')\n- go to store (completed)\n- another task\n- sub-task (depends on 'another task')\n- sub-sub-task (depends on 'sub-task')\n";
      return taskList.print().should.equal(desiredOutput);
    });
  });

}).call(this);
