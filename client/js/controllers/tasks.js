roomies.controller('allTaskController', function ($scope, $route, $window, $localStorage, $location, taskFactory, socketFactory){
	$scope.room = {};
	$scope.currentUser = $localStorage.user
	$scope.tasks = [];
	$scope.users = [];
	$scope.newUser = "";

	socketFactory.on('userJoinedRoom', function (userObject){
		console.log(userObject);
		$scope.newUser = userObject.name
		console.log($scope.newUser);
		$scope.newUserShowing = true;
		var userAlreadyExists = false;
		for (user in $scope.users) {
			if ($scope.users[user]._id == userObject._id) {
				userAlreadyExists = true;
			}
		}
		if (!userAlreadyExists) {
			$scope.users.push(userObject)
		}
		$scope.$apply();
		setTimeout(function () {
			$scope.newUserShowing = false;
			$scope.$apply();
		}, 6000);
	})
	socketFactory.on('newTask', function (dataArray){
		console.log("newTask Socket")
		taskFactory.getRoomById($localStorage.room, function (data){
			$scope.tasks = data.tasks;
			$scope.users = data.users;
			$scope.room = data;
			var taskUsers = dataArray[1]
			for (user in taskUsers) {
				console.log(taskUsers);
				if (taskUsers[user]._id == $scope.currentUser._id) {
					alert('You have a new task:\n' + dataArray[0]);
				}
			}
		})
	})
	socketFactory.on('getTaskDeletedOrCompleted', function (var1){
		taskFactory.getRoomById($localStorage.room, function (data){
			taskCompletedCssUpdate(data);
			$scope.tasks = data.tasks;
			$scope.users = data.users;
			$scope.room = data;
		})
	})

	taskFactory.getRoomById($localStorage.room, function (data){
		taskCompletedCssUpdate(data);
		$scope.tasks = data.tasks;
		$scope.users = data.users;
		$scope.room = data;
	})
	function taskCompletedCssUpdate(data) {
		for (var i = 0; i < data.tasks.length; i ++){
			console.log(data.tasks[i]);
			if (data.tasks[i].completed == "completed"){
				data.tasks[i].expiration_date = "Completed";
			}
		}
	}
	$scope.createTask = function (taskContent){
		if (taskContent.expiration_time == 'PM' && taskContent.expiration_hour != '12'){
			var parsed = parseInt(taskContent.expiration_hour);
			parsed += 12;
			taskContent.expiration_hour = String(parsed);
			console.log(taskContent.expiration_hour);
		}
		if (taskContent.expiration_time == 'AM' && taskContent.expiration_hour == '12'){
			taskContent.expiration_hour = '00';
			console.log(taskContent.expiration_hour);
		}
		var fullTask = {};
		fullTask.objective = taskContent.objective;
		var fulldate = taskContent.expiration_date + " " + taskContent.expiration_hour+':'+taskContent.expiration_minute;
		console.log(fulldate);
		fullTask.expiration_date = fulldate;
		fullTask.users = taskContent.users;
		fullTask._room = $scope.room;
		taskFactory.createTask(fullTask, function (data){
			modalDismiss();
			if (data){
				$scope.tasks.push(data);
				$scope.newTask = {};
				socketFactory.emit('task', [fullTask.objective, fullTask.users, fullTask.expiration_date]);
			}
		})
	}
	//fixing materialize's terrible design
	function modalDismiss(){
		var modal = angular.element(document.getElementById('modal1'));
		modal[0].style.display = "none";
		var overlay = angular.element(document.getElementsByClassName('lean-overlay'))
		overlay[0].style.display = "none";
		console.log('dismissing');

	}
	$scope.modalShow = function () {
		var modal = angular.element(document.getElementById('modal1'));
		modal[0].style.display = "block";
		var overlay = angular.element(document.getElementsByClassName('lean-overlay'))
		overlay[0].style.display = "block";
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
	$scope.completeTask = function (taskId){
		taskFactory.completeTask(taskId, function (data){
			if (data){
				console.log(data);
				// data.expiration_date = "Completed";
				$scope.tasks[$scope.tasks.indexOf(taskId)].expiration_date = "Completed";
				$scope.tasks[$scope.tasks.indexOf(taskId)].completed = "completed";
			}
		})
	}

})