roomies.controller('roomPickController', function ($scope, $route, $location, $localStorage, roomFactory, userFactory){
	$scope.rooms = [];
	$scope.user = $localStorage.user
	
	if($localStorage.login == true){
		$localStorage.login = false;
		location.reload();
	}

	roomFactory.index(function (data){
		$scope.rooms = data;
	})
	$scope.addNewRoom = function (newRoom){
		newRoom.user = $scope.user
		roomFactory.addNewRoom(newRoom, function (data){
			if (data){
				$localStorage.login = true;
				$localStorage.room = data._id;
				$location.path('/room/' + data._id)
			}
		})
	}
	$scope.chooseRoom = function (room){
		var roomData = {};
		roomData._id = room;
		roomData.user = $scope.user;
		roomFactory.chooseRoom(roomData, function (data){
			if (data){
				$localStorage.room = data._id;
				$location.path('/room/' + data._id )
			}
		})
	}
})