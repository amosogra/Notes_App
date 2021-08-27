
class PushNotification {
  PushNotification({this.title = '', this.body = '', this.dataTitle = '', this.dataBody = ''});

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;

  factory PushNotification.fromJson(dynamic message) {
    return PushNotification(
        title: message?.notification?.name, body: message?.notification?.body, dataTitle: message?.data["title"], dataBody: message?.data["body"]);
  }
}
