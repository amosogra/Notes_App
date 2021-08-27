import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notes_app/authentication/services/service.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/ui/notifiers/overlay.dart';
import 'package:overlay_support/overlay_support.dart';

import 'log.dart';

class Do {
  static Future checkToken(DocumentSnapshot<Map<String, dynamic>> ds) async {
    if (["", null, false, 0].contains((ds.data() ?? {})[Constants.notificationKey])) {
      final FirebaseMessaging _fcm = FirebaseMessaging.instance;
      // On iOS, this helps to take the user permissions
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      String? fcmToken = await _fcm.getToken();
      log("TOKEN: $fcmToken");
      Service service = new Service();
      if (fcmToken != null) {
        return await service.createDeviceGroup((ds.data() ?? {})['uid'], fcmToken).then((notificationKey) async {
          if (notificationKey != null) {
            return await service.updateUserToken((ds.data() ?? {})['uid'], notificationKey).then((done) async {
              if (done) {
                subTopic(service, fcmToken, _fcm);
                var keyList = List.castFrom<dynamic, String>((ds.data() ?? {})['deviceTokenList'] as List? ?? []);
                if (!keyList.contains(fcmToken)) {
                  //if deviceTokenList > 20, purge fcm subscription token list and purge the list as well...
                  if (keyList.length > 20) {
                    var notKey = await service.removeUsersFromDeviceGroup((ds.data() ?? {})['uid'], notificationKey, keyList);
                    if (notKey == null) {
                      //this operation wasn't carried out
                      return notificationKey;
                    }

                    //purge deviceTokenList
                    await ds.reference.update({'deviceTokenList': FieldValue.arrayRemove(keyList)});
                    log('Tokens removed from list: ${keyList.toString()}');
                  }

                  log('Adding token to device list');
                  await ds.reference.update({
                    'deviceTokenList': FieldValue.arrayUnion([fcmToken])
                  });
                  log('Token added to list..');
                  //try push
                  await service.sendDeviceGroupNotification(notificationKey, "Welcome", "Helloooooo... You just singed in from a new device");
                  return notificationKey;
                  //subscribe token to notification_key
                  /* return await service.addUserToDeviceGroup(ds?.data()['uid'], notificationKey, fcmToken).then((notificationKey) async {
                    if (notificationKey == null) {
                      //remove token from user deviceTokenList since it's not on fcm yet
                      await ds.reference.update({
                        'deviceTokenList': FieldValue.arrayRemove([fcmToken])
                      });
                      log('Token removed from list..');
                      return notificationKey;
                    }
                    
                  }); */
                }
              }
              return notificationKey;
            });
          }
          return null;
        });
      }
    }
    return null;
  }

  static void subTopic(Service service, token, FirebaseMessaging _fcm) {
    service.subscribeToTopic("all", token).then((done) {
      if (!done) {
        _fcm.subscribeToTopic('all').then((v) {
          showOverlayNotification((context) {
            return MessageNotification(
              title: 'PUSH NOTIFICATION ATTEPT by ${Constants.appName} Bot',
              subtitle: 'You attempted to subscribe to a push notification topic',
              onReplay: () {
                OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
                toast('I will retry in the future..warm regards.');
              },
            );
          });
        });
      }

      log("Topic Subscribed? ${done ? 'Yes' : 'No'}");
      showOverlayNotification((context) {
        return MessageNotification(
          title: 'PUSH NOTIFICATION by ${Constants.appName} Bot',
          subtitle:
              "${done ? "Congratulations, Your account has been set to recieve push notifications from us." : "Attemt to subscribe your account to a push notification service failed. I will retry in the future, warm regards."}",
          onReplay: () {
            OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
            toast('${done ? 'Congrats!' : 'Nice try!'}');
          },
        );
      });
    });
  }
}
