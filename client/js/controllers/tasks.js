roomies.controller('allTaskController', function ($scope, $localStorage, taskFactory){
	$scope.room = {};
	$scope.currentUser = $localStorage.user
	$scope.currentTask = "";
	$scope.tasks = [];
	$scope.users = [];

	taskFactory.getRoomById($localStorage.room, function (data){
		console.log(data);
		$scope.tasks = data.tasks;
		$scope.users = data.users;
		$scope.room = data;
	})

	$scope.createTask = function (taskContent){
		taskFactory.createTask(taskContent, function (data){
			if (data){
				console.log(data);
				$scope.tasks.push(data);
			}
		})
	}
	$scope.removeTask = function (taskId){
		taskFactory.removeTask(taskId, function (data){
			if (data){
				console.log(data);
				$scope.tasks.splice(tasks.indexOf(taskId), 1);
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