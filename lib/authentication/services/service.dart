import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/utils/log.dart';

class Service {
  Future<DocumentSnapshot<Map<String, dynamic>>> register(email, password, uid, profilePhotoUrl, upliner) async {
    await FirebaseFirestore.instance.collection(Constants.users).doc(uid).set({
      'uid': uid,
      'sameUid': uid,
      'email': email,
      'user': true,
      'payed': false,
      'password': password,
      'role': Role.visitor,
      'test': true,
      'upliner': upliner,
      'refId': upliner,
      'downliners': [],
      'starter_boards': [uid],
      'starter_board': {
        'level1': false,
        'level2': false,
        'level3': false,
      },
      'regTimestamp': Timestamp.now(),
      'lastSignedTimestamp': Timestamp.now(),
      'lastVisitedTimestamp': Timestamp.now(),
      "isOnline": true,
      'isAffiliate': false,
      'isActive': false,
      'occupyStarter': true,
      'deviceTokenList': [],
      'avatar_url': profilePhotoUrl,
    });

    //as soon as its set, send new user a default kite
    var data = await getNewUser(uid);
    return data;
  }

  Future<List<QueryDocumentSnapshot>> search(String text, String uid) async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> newRequests = [];
    QuerySnapshot<Map<String, dynamic>> userDocuments = await FirebaseFirestore.instance.collection(Constants.users).get();
    var usersToSearch = userDocuments.docs.where((element) => element.data()['uid'] != uid).toList();

    log("all users: ${userDocuments.docs.length}");

    for (var doc in usersToSearch) {
      if (text != "" && doc.data()['username'].toString().contains(text)) {
        log(doc.data()['username']);
        newRequests.add(doc);
      }
    }
    return newRequests;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getNewUser(String uid) async {
    var newUser = await FirebaseFirestore.instance.collection(Constants.users).doc(uid).get();
    log("Finding new user:");
    log(newUser.data().toString());
    return newUser;
  }

  Future<bool> updateUserToken(uid, token) async {
    return await FirebaseFirestore.instance.collection(Constants.users).doc(uid).update({Constants.notificationKey: token}).then((r) {
      return true;
    });
  }

  convertToList(data) {
    List list = [];
    list.add(data);
    return list;
  }

  Future<bool> sendNotification(token, title, message) async {
    try {
      var url = '${Constants.domain}/.netlify/functions/send-notification';
      var header = {"Content-Type": "application/json"};
      var request = {
        "notification": {"title": title, "body": message, "sound": "default"},
        "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "clickaction": "FLUTTERNOTIFICATIONCLICK", "title": title, "body": message},
        "priority": "high",
        "to": token
      };

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE PUSH TO TOKEN: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error sending notification to individual: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return jsonDecode(response.body)['success'] == 1;
    } catch (e) {
      log(e);
      return false;
    }
  }

  Future sendDeviceGroupNotification(notificationKey, title, message) async {
    try {
      var url = '${Constants.domain}/.netlify/functions/send-group-notification';
      var header = {"Content-Type": "application/json"};
      var request = {
        "notification": {"title": title, "body": message, "sound": "default"},
        "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "clickaction": "FLUTTERNOTIFICATIONCLICK", "title": title, "body": message},
        "priority": "high",
        "to": notificationKey
      };

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE PUSH TO DEVICE GROUP: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error sending device group notification: ${response.statusCode} - ${response.reasonPhrase}');
      }

      /*The response message lists the registration tokens (registration_ids/notification_key) that failed to receive the message:*/
      /*{
        "success": 1,
        "failure": 2,
        "failed_registration_ids": ["regId1", "regId2"]
      };*/
      return jsonDecode(response.body);
    } catch (e) {
      log(e);
      return null;
    }
  }

  Future<bool> sendPushNotificationToAll(topic, title, message) async {
    try {
      var url = '${Constants.domain}/.netlify/functions/send-push-to-all';
      var header = {"Content-Type": "application/json"};
      var request = {
        "notification": {"title": title, "body": message, "sound": "default"},
        "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "clickaction": "FLUTTERNOTIFICATIONCLICK", "title": title, "body": message},
        "priority": "high",
        "to": "/topics/$topic"
      };

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE PUSH TO ALL: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error sending push notification to all: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      log(e);
      return false;
    }
  }

  Future<bool> subscribeToTopic(topic, token) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/sub-fcm-topic";
      var header = {"Content-Type": "application/json"};
      var request = {"topic": topic, "token": token};

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE SUB TO TOPIC: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error subscribing to topic: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      log(e);
      return false;
    }
  }

  Future<bool> validateToken(token) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/validate-token";
      var header = {"Content-Type": "application/json"};
      var request = {"token": token};

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE VALIDATE TOKEN: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error validating token: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      log(e);
      return false;
    }
  }

  Future createDeviceGroup(String? uid, String token) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/create-device-group";
      var header = {"Content-Type": "application/json"};
      var request = {
        "operation": "create",
        "notification_key_name": uid,
        "registration_ids": [token]
      };

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE CREATE DEVICE GROUP: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error creating user device group: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return jsonDecode(response.body)['notification_key'];
    } catch (e) {
      log(e);
      return null;
    }
  }

  Future addUserToDeviceGroup(String? uid, String? notificationKey, String? token) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/add-device-group";
      var header = {"Content-Type": "application/json"};
      var request = {
        "operation": "add",
        "notification_key": notificationKey,
        "notification_key_name": uid,
        "registration_ids": [token]
      };

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE ADD TO GROUP: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error adding device to group: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return jsonDecode(response.body)['notification_key'];
    } catch (e) {
      log(e);
      return null;
    }
  }

  Future removeUsersFromDeviceGroup(String? uid, String? notificationKey, List<String> tokens) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/remove-device-group";
      var header = {"Content-Type": "application/json"};
      var request = {"operation": "remove", "notification_key": notificationKey, "notification_key_name": uid, "registration_ids": tokens};

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE REMOVE DEVICE FROM USER DEVICE GROUP: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error removing device from group: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return jsonDecode(response.body)['notification_key'];
    } catch (e) {
      log(e);
      return null;
    }
  }

  Future retrieveNotificationKey(String uid) async {
    try {
      var url = "${Constants.domain}/.netlify/functions/retrieve-notification-key";
      var header = {"Content-Type": "application/json"};
      var request = {"uid": uid};

      var client = new Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      log("FCM RESPONSE RETRIEVE NOTIFICATION KEY: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Error retrieving notification key: ${response.statusCode} - ${response.reasonPhrase}');
      }

      return response.body;
    } catch (e) {
      log(e);
      return null;
    }
  }
}
