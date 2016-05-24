roomies.controller('taskDetailsController', function ($scope, $location, $localStorage, taskFactory, messageFactory){
	$scope.room = $localStorage.room;
	$scope.currentUser = $localStorage.user;
	$scope.currentTask = $localStorage.currentTask;
	$scope.messages = [];
	//BACKEND ROUTE DOESN"T TAKE PARAMETER? check taskFactory update and backend tasks controller + routes
	$scope.updateTask = function (taskContent, taskId){
		console.log(taskContent);
		console.log(taskId);
		var task = {};
		task.objective = taskContent.objective;
		task.expiration_date = taskContent.expiration_date;
		task._id = taskId._id;
		taskFactory.updateTask(task, function (data){
			if (data){
				console.log(data);
				// $location.path('/room/' + data._id)
			}
		})
	}
	taskFactory.getTaskById($localStorage.currentTask, function (data){
		console.log(data);
		$scope.messages = data.messages;
	})


	$scope.addMessage = function (message){
		var newMessage = {};
		newMessage._room = $scope.room;
		newMessage._user = $scope.currentUser._id;
		newMessage._task = $scope.currentTask._id;
		newMessage.content = message;
		console.log(newMessage);
		messageFactory.addMessage(newMessage, function (data){
			if (data){
				console.log(data);
				$scope.messages.push(data.messages[data.messages.length - 1]);
			}
		})
	}
})