roomies.controller('taskDetailsController', function ($scope, $localStorage, taskFactory, messageFactory){
	$scope.room = $localStorage.room;
	$scope.user = $localStorage.user;
	$scope.currentTask = $localStorage.currentTask;
	$scope.tasks = [];

	$scope.getTask = function (taskId){
		taskFactory.getTaskById(taskId, function (data){
			if (data){
				console.log(data)
				$scope.currentTask = data;
			}
		})
	}
	$scope.updateTask = function (taskContent, taskId){
		taskFactory.updateTask(taskContent, function (data){
			if (data){
				console.log(data);

			}
		})
	}

	$scope.addMessage = function (Message){
		var newMessage = {};
		newMessage._room = $scope.room;
		newMessage._user = $scope.user;
		newMessage._task = $scope.currentTask;
		newMessage.content = Message;
		console.log(newMessage);
		messageFactory.addMessage(newMessage, function (data){
			if (data){
				console.log(data);
			}
		})
	}
})