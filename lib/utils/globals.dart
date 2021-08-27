import 'package:notes_app/models/user_model.dart';

class Globals {
  static Globals _singleton = new Globals._internal();

  factory Globals() {
    return _singleton;
  }

  Globals._internal();

  List<String> selectedType = [];

  User? _user;
  User? updateBoardUser(User? user) => _user = user;

  User? _globalUser;
  User? updateGlobalUser(User? globalUser) => _globalUser = globalUser;

  User? getBoardUser() => _user;
  User? get boardUser => _user;
  User? getGlobalUser() => _globalUser;
  User? get globalUser => _globalUser;
}
