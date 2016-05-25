roomies.controller('allTaskController', function ($scope, $route, $window, $localStorage, $location, taskFactory){
	$scope.room = {};
	$scope.currentUser = $localStorage.user
	$scope.tasks = [];
	$scope.users = [];

	taskFactory.getRoomById($localStorage.room, function (data){
		$scope.tasks = data.tasks;
		$scope.users = data.users;
		$scope.room = data;
	})

	$scope.createTask = function (taskContent){
		if (taskContent.expiration_time == 'PM'){
			var parsed = parseInt(taskContent.expiration_hour);
			parsed += 12;
			taskContent.expiration_hour = String(parsed);
			console.log(taskContent.expiration_hour);
		}
		var fullTask = {};
		fullTask.objective = taskContent.objective;
		var fulldate = taskContent.expiration_date + " " + taskContent.expiration_hour+':'+taskContent.expiration_minute + " " + taskContent.expiration_time;
		console.log(fulldate);
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