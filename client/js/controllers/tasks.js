roomies.controller('allTaskController', function ($scope, $route, $window, $localStorage, $location, taskFactory){
	$scope.room = {};
	$scope.currentUser = $localStorage.user
	$scope.tasks = [];
	$scope.users = [];
	$scope.addTask = false;

	$scope.showTaskAdder = function () {
		if ($scope.addTask == false){
			$scope.addTask = true;
		}
		else{
			$scope.addTask = false;
		} 
	}
	if($localStorage.login == true){
		$localStorage.login = false;
		location.reload();
	}

	taskFactory.getRoomById($localStorage.room, function (data){
		$scope.tasks = data.tasks;
		$scope.users = data.users;
		$scope.room = data;
	})

	$scope.createTask = function (taskContent){
		var fullTask = {};
		fullTask.objective = taskContent.objective;
		var fulldate = taskContent.expiration_date + " " + taskContent.expiration_time;
		fullTask.expiration_date = fulldate;
		fullTask.users = taskContent.users;
		fullTask._room = $scope.room;
		taskFactory.createTask(fullTask, function (data){
			if (data){
				$scope.tasks.push(data);
				$scope.newTask = {};
			}
		})
	}
	$scope.removeTask = function (task){
		taskFactory.removeTask(task, function (data){
			if (data){
				$scope.tasks.splice($scope.tasks.indexOf(task), 1);
			}
		})
	}
	$scope.selectTask = function (taskId){
		taskFactory.getTaskById(taskId, function (data){
			if (data){
				$localStorage.currentTask = data;
				$location.path('/task/' + data._id);
			}
		})
	}
	// $scope.completeTask = function (taskId){
	// 	taskFactory.completeTask(taskId, function (data){
	// 		if (data){
	// 			console.log(data);
	// 			$scope.
	// 		}
	// 	})
	// }

})