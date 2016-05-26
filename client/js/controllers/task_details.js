roomies.controller('taskDetailsController', function ($scope, $location, $localStorage, taskFactory, messageFactory, socketFactory){
	$scope.room = $localStorage.room;
	$scope.currentUser = $localStorage.user;
	$scope.currentTask = $localStorage.currentTask;
	$scope.currentTask.expiration_day = $scope.currentTask.expiration_date.slice(0,10);
	$scope.currentTask.expiration_hour = $scope.currentTask.expiration_date.slice(11,13);
	$scope.currentTask.expiration_min = $scope.currentTask.expiration_date.slice(14,16);
	$scope.messages = [];
	

	$scope.back = function () {
		$location.path('/room/' + $scope.room);	
	}
	$scope.updateTask = function (taskContent, taskId){
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
		fullTask._id = taskId._id;
		taskFactory.updateTask(fullTask, function (data){
			if (data){
				$location.path('/room/' + data._id)
				socketFactory.emit('task');
				location.reload();
			}
		})
	}
	$scope.$watch('Task', function (){
		console.log('watching');
	}, true);
	taskFactory.getTaskById($localStorage.currentTask, function (data){
		$scope.messages = data.messages;
	})

	socketFactory.on('emitNewMessage', function (dataArray){
		taskFactory.getTaskById($localStorage.currentTask, function (data){
			$scope.messages = data.messages;
		})
	})
	$scope.addMessage = function (message){
		var newMessage = {};
		newMessage._room = $scope.room;
		newMessage._user = $scope.currentUser._id;
		newMessage._task = $scope.currentTask._id;
		newMessage.content = message;
		// console.log(newMessage);
		messageFactory.addMessage(newMessage, function (data){
			if (data){
				$scope.messages.push(data.messages[data.messages.length - 1]);
				$scope.message = "";
				var messageData = data.messages[data.messages.length-1]
				var dataArray = [messageData._user._id, messageData._user.name, messageData.content]
				console.log(dataArray)
				socketFactory.emit('newMessage', dataArray);
			}
		})
	}
})