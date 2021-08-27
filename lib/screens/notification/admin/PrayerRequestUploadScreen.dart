import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';

class PrayerRequestUploadScreen extends StatefulWidget {
  const PrayerRequestUploadScreen({Key? key}) : super(key: key);

  @override
  _PrayerRequestUploadScreenState createState() => _PrayerRequestUploadScreenState();
}

class _PrayerRequestUploadScreenState extends State<PrayerRequestUploadScreen> {
  TextEditingController descriptionController = TextEditingController();
  String? validator;
  bool enabled = true;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    final loggedUser = Provider.of<auth.User?>(context);
    final themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: themeData.backgroundColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(MySize.size16), topRight: Radius.circular(MySize.size16))),
              child: Padding(
                padding: EdgeInsets.only(top: MySize.size16, left: MySize.size24, right: MySize.size24, bottom: MySize.size16),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Prayer Request Portal".toUpperCase(),
                                  style: AppTheme.getTextStyle(themeData.textTheme.subtitle1, color: themeData.colorScheme.onBackground, fontWeight: 700),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: Spacing.all(6),
                                decoration: BoxDecoration(color: themeData.colorScheme.primary.withAlpha(40), shape: BoxShape.circle),
                                child: Icon(
                                  MdiIcons.check,
                                  color: themeData.colorScheme.primary,
                                  size: MySize.size20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: defaultPadding * 6),
                      Center(child: _buildComposer(themeData)),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeData.accentColor,
                                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    if (descriptionController.text != "") {
                                      //commit changes to cloud firestore...
                                      EasyLoading.showInfo('Please wait..', duration: const Duration(seconds: 5), dismissOnTap: true);
                                      var doc = await FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get();
                                      var user = User.fromJson(doc.data() ?? {});
                                      var data = Map<String, dynamic>();
                                      data['description'] = descriptionController.text;
                                      data['uid'] = user.uid;
                                      data['prayed'] = false;
                                      data['first_name'] = user.firstName;
                                      data['last_name'] = user.lastName;
                                      data['role'] = user.role;
                                      data['gender'] = user.gender;
                                      data['phone'] = user.address?.phone;
                                      data['avatar_url'] = user.avatarUrl;
                                      data['timestamp'] = Timestamp.now();

                                      var commited = await commitToFireStore(data, Constants.prayerRequests);
                                      if (commited) {
                                        EasyLoading.showSuccess("Prayer Request Sent", duration: const Duration(seconds: 5), dismissOnTap: true);
                                      } else {
                                        EasyLoading.showError('Failed to send Prayer Request, please try again..',
                                            duration: const Duration(seconds: 5), dismissOnTap: true);
                                      }

                                      Navigator.of(context).pop();
                                    } else {
                                      await showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Please provide input!'),
                                            content: Text('The description of your message is requied...'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Okay'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('Send Prayers'.toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildComposer(ThemeData? themeData) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: themeData?.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(color: themeData?.cardTheme.shadowColor?.withAlpha(25) ?? const Color(4278190080), offset: const Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
            color: themeData?.cardTheme.color,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              child: TextField(
                maxLines: null,
                controller: descriptionController,
                onChanged: (String value) async {
                  validator = value;
                  //return;
                },
                style: AppTheme.getTextStyle(themeData?.textTheme.bodyText1, fontWeight: 600, letterSpacing: 0.2),
                cursorColor: themeData?.accentColor,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: AppTheme.getTextStyle(themeData?.textTheme.bodyText1,
                        fontWeight: 500, letterSpacing: 0, color: themeData?.colorScheme.onBackground.withAlpha(180)),
                    hintText: 'Type your prayer requests here...'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> commitToFireStore(Map<String, dynamic> data, String _collection) {
    CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore.instance.collection(_collection);
    // Call the user's CollectionReference to add a new user
    return collection.add(data).then((value) async {
      return await value.update({"pid": value.id}).then((v) {
        log("$_collection Added");
        return true;
      });
    }).catchError((error) {
      log("Failed to add document: $error");
      log("Stack Trace: " + error);
      return false;
    });
  }
}
/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CloudFirestoreSearch extends StatefulWidget {
  @override
  _CloudFirestoreSearchState createState() => _CloudFirestoreSearchState();
}

class _CloudFirestoreSearchState extends State<CloudFirestoreSearch> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? Firestore.instance
                .collection('items')
                .where("searchKeywords", arrayContains: name)
                .snapshots()
            : Firestore.instance.collection("items").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.documents[index];
                    return Card(
                      child: Row(
                        children: <Widget>[
                          Image.network(
                            data['imageUrl'],
                            width: 150,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Text(
                            data['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

} */
