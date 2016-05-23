// load all the things we need
var LocalStrategy = require('passport-local').Strategy;

var mongoose = require('mongoose');
var User = mongoose.model('User');

module.exports = function(passport) {

	// =========================================================================
    // passport session setup ==================================================
    // =========================================================================
    // required for persistent login sessions
    // passport needs ability to serialize and unserialize users out of session

    // used to serialize the user for the session
    passport.serializeUser(function(user, done) {
        done(null, user.id);
    });

    // used to deserialize the user
    passport.deserializeUser(function(id, done) {
        User.findById(id, function(err, user) {
            console.log("deserializeUser")
            done(err, user);
        });
    });

    passport.use('local-register', new LocalStrategy({
        // by default, local strategy uses username and password, we will override with email
        usernameField : 'email',
        passwordField : 'password',
        passReqToCallback : true // allows us to pass back the entire request to the callback
    },
    function(req, email, password, done) {
    	// asynchronous
        // User.findOne wont fire unless data is sent back
    	process.nextTick(function(){
            console.log('getting here')
            console.log(req.body);
    		// find a user whose email is the same as the forms email
        // we are checking to see if the user trying to login already exists
        User.findOne({ 'email' :  email }, function(err, user) {
            // if there are any errors, return the error
            if (err) {
                return done(err);
            }

            // check to see if theres already a user with that email
            if (user) {
                req.flash('error', 'That email is already taken.')
                return done(null, false);
                // req.json({'error':'That email is already taken.'})
            } else {

            	var newUser = new User();
            	newUser.name = req.body.name;
            	newUser.email = email;
            	newUser.password = newUser.generateHash(password);
            	newUser.save(function(err) {
            		if (err) {
            			console.log(err);
            		} else {
                        console.log('saved')
            			return done(null, newUser);
            		}
            	});
            }
    	});
    	});
    }));

    passport.use('local-login', new LocalStrategy ({
    	usernameField : 'email',
    	passwordField : 'password',
    	passReqToCallback : true
    },
    function(req, email, password, done) {
    	User.findOne({'email': email})
        .populate('rooms')
        .populate('tasks')
        .exec(function(err, user){
    		if (err) {
    			return done(err);
    		}
    		if (!user) {
                req.flash('error', 'Incorrect user credentials')
    			return done(null, false);
    		}
    		if (!user.validPassword(password)) {
                req.flash('error', 'Incorrect user credentials')
    			return done(null, false);
    		}
            // console.log(user);
    		return done(null, user);
    	});
    }));
}