roomies.controller('allTaskController', function ($scope, $localStorage, $location, taskFactory){
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
		var fullTask = {};
		fullTask.objective = taskContent.objective;
		fullTask.expiration_date = taskContent.expiration_date;
		fullTask.users = taskContent.users;
		fullTask._room = $scope.room;
		taskFactory.createTask(fullTask, function (data){
			if (data){
				$scope.tasks.push(data);
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