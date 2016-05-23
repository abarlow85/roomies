roomies.config(function ($routeProvider){
	$routeProvider
	.when('/', {
		templateUrl: '../partials/login.html'
	})
	// .when('/new_question', {
	// 	templateUrl: '../partials/new_question.html'
	// })
	// .when('/topic/:id', {
	// 	templateUrl: '../partials/topic.html'
	// })
	// .when('/topic/:id/new_answer', {
	// 	templateUrl: '../partials/new_post.html'
	// })
	.otherwise({
		redirectTo: '/'
	})
});