roomies.controller('roomPickController', function ($scope, $route, $location, $localStorage, roomFactory, userFactory, socketFactory){
	$scope.rooms = [];
	$scope.user = $localStorage.user
	
	function modalDismiss(){
		var modal = angular.element(document.getElementById('modal1'));
		modal[0].style.display = "none";
		var overlay = angular.element(document.getElementsByClassName('lean-overlay'))
		overlay[0].style.display = "none";

	}
	
	roomFactory.index(function (data){
		$scope.rooms = data;
	})
	$scope.addNewRoom = function (newRoom){
		newRoom.user = $scope.user
		modalDismiss();
		roomFactory.addNewRoom(newRoom, function (data){
			if (data){
				$localStorage.login = true;
				$localStorage.room = data._id;
				$location.path('/room/' + data._id)
			}
		})
	}
	$scope.chooseRoom = function (room){
		console.log(room);
		var roomData = {};
		roomData._id = room;
		roomData.user = $scope.user._id;
		roomFactory.chooseRoom(roomData, function (data){
			if (data){
				console.log(data);
				socketFactory.emit('userPickedRoom', $scope.user);
				$localStorage.room = data._id;
				$location.path('/room/' + data._id )
			}
		})
	}
})