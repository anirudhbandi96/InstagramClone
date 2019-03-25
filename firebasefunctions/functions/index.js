const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase Anirudh Bandi!");
});

exports.observeFollowing = functions.database.ref('/following/{followerId}/{followingId}').onCreate( (data,context) => {
  //let's logout some messages
  var followerId = context.params.followerId;
  var followingId = context.params.followingId;
  console.log('User: ' + followerId + 'is following: ' + followingId);

  //trying to figure out fcmToken to send a push message
  return admin.database().ref('/users/'+followingId).once('value',(snapshot) => {

    var userBeingFollowed = snapshot.val();
    console.log("user usename: " + userBeingFollowed.username + " fcmToken: " + userBeingFollowed.fcmToken);

 return admin.database().ref('/users/' + followerId).once('value', snapshot => {

   var userFollowing = snapshot.val();
   var message = {
     notification: {
       title: "You now have a new follower!",
       body: userFollowing.username + " is now following you"
     },
     data:{
       followerId : followerId
     },
     token : userBeingFollowed.fcmToken
   }

   admin.messaging().send(message)
     .then((res) => {
       // Response is a message ID string.
       console.log('Successfully sent message:', res);
       return res;
     })
     .catch((error) => {
       console.log('Error sending message:', error);
     });


 })

})
});

exports.sendPushNotifications = functions.https.onRequest((req,res) => {
  res.send("attempting to send push notification")
  console.log("LOGGER -- Trying to send push message ...")

  // admin.messaging().sendToDevice(token, payload)

  var uid = 'ZCy3SxRWNGSZX6zlfnIZLkN5URt1';

  return admin.database().ref('/users/'+uid).once('value',(snapshot) => {

    var user = snapshot.val();
    console.log("user usename: " + user.username + " fcmToken: " + user.fcmToken);

    var message = {
      notification: {
        title: "push notification TITLE HERE",
        body: "body over here is our message body..."
      },
      token : user.fcmToken
    }

    admin.messaging().send(message)
      .then((res) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', res);
        return res;
      })
      .catch((error) => {
        console.log('Error sending message:', error);
      });


  })

  //var fcmToken = 'cVonBfEl1X0:APA91bFV45SQ7CcTd2pDfXgyGz34Ej58YcItJKQ6KZ7WFUAYEe7f5nrBuu69bIQ9S_IWyaUBW2l75U3ud3reFutMrQ4ndu-3aSNBxol4S9bNPMRBjB7JsOl4831iajdrADPYxzlJXNWs';

  // See documentation on defining a message payload.
  // var message = {
  //   notification: {
  //     title: "push notification TITLE HERE",
  //     body: "body over here is our message body..."
  //   },
  //   data: {
  //     score: '850',
  //     time: '2:45'
  //   },
  //   token: fcmToken
  // };
  //
  // // Send a message to the device corresponding to the provided
  // // registration token.


  })
