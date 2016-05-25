roomies.controller('roomPickController', function ($scope, $route, $location, $localStorage, roomFactory, userFactory){
	$scope.roomAdd = false;
	$scope.rooms = [];
	$scope.user = $localStorage.user
	
	if($localStorage.login == true){
		$localStorage.login = false;
		location.reload();
	}
	$scope.showRoomAdder = function () {
		if ($scope.roomAdd == false){
			$scope.roomAdd = true;
		}
		else{
			$scope.roomAdd = false;
		} 
	}
	roomFactory.index(function (data){
		$scope.rooms = data;
	})
	$scope.addNewRoom = function (newRoom){
		newRoom.user = $scope.user
		roomFactory.addNewRoom(newRoom, function (data){
			if (data){
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