roomies.controller('allTaskController', function ($scope, $route, $window, $localStorage, $location, taskFactory, socketFactory){
	$scope.room = {};
	$scope.currentUser = $localStorage.user
	$scope.tasks = [];
	$scope.users = [];
	$scope.newUser = "";

	if($localStorage.login == true){
		$localStorage.login = false;
		location.reload();
	}
	socketFactory.on('userJoinedRoom', function (userName){
		$scope.newUser = userName
		console.log($scope.newUser);
		$scope.newUserShowing = true;
		$scope.$apply()
		setTimeout(function () {
			$scope.newUserShowing = false;
			console.log('timing out');
			$scope.$apply()
		}, 6000);
	})
	socketFactory.on('newTask', function (var1, var2, var3){
		taskFactory.getRoomById($localStorage.room, function (data){
			$scope.tasks = data.tasks;
			$scope.users = data.users;
			$scope.room = data;
		})
	})
	socketFactory.on('getTaskDeletedOrCompleted', function (var1){
		taskFactory.getRoomById($localStorage.room, function (data){
			$scope.tasks = data.tasks;
			$scope.users = data.users;
			$scope.room = data;
		})
	})

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
				socketFactory.emit('task', [fullTask.objective, fullTask.users, fullTask.expiration_date]);
			}
		})
	}
	$scope.removeTask = function (task){
		taskFactory.removeTask(task, function (data){
			if (data){
				$scope.tasks.splice($scope.tasks.indexOf(task), 1);
				socketFactory.emit('taskDeletedOrCompleted');
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