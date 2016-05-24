roomies.controller('loginController', function ($scope, $location, $localStorage, userFactory){
	$scope.newUser = false;

	$scope.splashPage = true;

	if($scope.splashPage == true){
		console.log($scope.splashPage);
		setTimeout(function() {
			$scope.splashPage = false;
			$scope.$apply();
			console.log($scope.splashPage);
		}, 4000);
	}
	$scope.toggleForm = function () {
		if ($scope.newUser == false){
			$scope.newUser = true;
		}
		else {
			$scope.newUser = false;
		}
	}
	$scope.userRegister = function (regUser) {
		console.log(regUser);
		userFactory.register(regUser, function (data){
			if (data.error){
				console.log("error")
			}
			else if(data) {
				$localStorage.user = data
				$location.path('/room');
			}
		})
	}
	$scope.userLogin = function (loginUser) {
		userFactory.login(loginUser, function (data){
			console.log('Logging in: ' + data);
			if (data.error){
				console.log('error');
			}
			else if (data){
				var room_id = data._lastRoom;
				$localStorage.user = data;
				$localStorage.room = data._lastRoom;
				$location.path('/room/' + room_id);
			}
		})
	}
})