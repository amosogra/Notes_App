// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:notes_app/models/CheckedIn.dart';
import 'package:notes_app/utils/log.dart';

class User {
  String? uid, sameUid, email, firstName, lastName, role, gender, avatarUrl, notificationKey;
  bool? isOnline, isActive;
  final List<String> searchKeywords;
  Address? address;
  Timestamp? lastModified, lastSignedTimestamp, lastVisitedTimestamp, lastCheckedInTimestamp, regTimestamp, dateOfBirth;
  final List<String>? deviceTokenList;
  final List<String>? images;
  List<CheckedIn>? checkins;

  User({
    this.uid,
    this.sameUid,
    this.email,
    this.checkins,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.role,
    this.gender,
    this.notificationKey,
    this.isOnline,
    this.isActive,
    this.address,
    this.lastModified,
    this.lastSignedTimestamp,
    this.lastVisitedTimestamp,
    this.lastCheckedInTimestamp,
    this.regTimestamp,
    this.avatarUrl,
    this.deviceTokenList,
    required this.searchKeywords,
    this.images,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json["uid"] == null ? null : json["uid"],
      sameUid: json["sameUid"] == null ? "" : json["sameUid"],
      email: json["email"] == null ? null : json["email"],
      checkins: json["checkins"] == null ? [] : List<CheckedIn>.from(json["checkins"].map((checkin) => CheckedIn.fromJson(checkin))),
      dateOfBirth: json["dateOfBirth"],
      firstName: json["first_name"] == null ? null : json["first_name"],
      lastName: json["last_name"] == null ? null : json["last_name"],
      role: json["role"] == null ? null : json["role"],
      gender: json["gender"] == null ? null : json["gender"],
      notificationKey: json["notificationKey"] == null ? null : json["notificationKey"],
      isOnline: json["isOnline"] == null ? false : json["isOnline"],
      isActive: json["isActive"] == null ? false : json["isActive"],
      address: json["address"] == null ? null : Address.fromJson(json["address"]),
      lastModified: json["lastModified"] == null ? null : json["lastModified"],
      lastSignedTimestamp: json["lastSignedTimestamp"] == null ? null : json["lastSignedTimestamp"],
      lastVisitedTimestamp: json["lastVisitedTimestamp"] == null ? null : json["lastVisitedTimestamp"],
      lastCheckedInTimestamp: json["lastCheckedInTimestamp"] == null ? null : json["lastCheckedInTimestamp"],
      regTimestamp: json["regTimestamp"] == null ? null : json["regTimestamp"],
      avatarUrl: json["avatar_url"] == null ? null : json["avatar_url"],
      deviceTokenList: json["deviceTokenList"] == null ? null : List<String>.from(json["deviceTokenList"].map((x) => x)),
      searchKeywords: json["searchKeywords"] == null ? [] : List<String>.from(json["searchKeywords"].map((x) => x)),
      images: json["images"] == null ? [] : List<String>.from(json["images"].map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid == null ? null : uid,
      "sameUid": sameUid == null ? null : sameUid,
      "email": email == null ? null : email,
      "checkins": checkins?.map((checkin) => checkin.toJson()).toList() ?? [],
      "dateOfBirth": dateOfBirth,
      "first_name": firstName == null ? null : firstName,
      "last_name": lastName == null ? null : lastName,
      "role": role == null ? null : role,
      "gender": gender == null ? null : gender,
      "notificationKey": notificationKey == null ? null : notificationKey,
      "isOnline": isOnline == null ? null : isOnline,
      "isActive": isActive == null ? null : isActive,
      "address": address?.toJson(),
      "lastModified": lastModified == null ? null : lastModified,
      "lastSignedTimestamp": lastSignedTimestamp == null ? null : lastSignedTimestamp,
      "lastVisitedTimestamp": lastVisitedTimestamp == null ? null : lastVisitedTimestamp,
      "lastCheckedInTimestamp": lastCheckedInTimestamp == null ? null : lastCheckedInTimestamp,
      "regTimestamp": regTimestamp == null ? null : regTimestamp,
      "avatar_url": avatarUrl == null ? null : avatarUrl,
      "searchKeywords": searchKeywords,
      "deviceTokenList": deviceTokenList == null ? [] : List<String>.from(deviceTokenList!.map((x) => x)),
      "images": images == null ? [] : List<String>.from(images!.map((x) => x)),
    };
  }

  static Map<String, dynamic> discardNull(Map<String, dynamic> json) {
    var r = {}; // remove map keys/values pair
    var u = {}; // update map keys/values pair
    //var a = {}; // add list map keys/values pair

    json.entries.forEach((m) {
      if (m.value == null) {
        r.putIfAbsent(m.key, () => m.value);
      } else {
        if (m.value is Map) {
          var json2 = discardNull((m.value as Map) as Map<String, dynamic>);
          u.putIfAbsent(m.key, () => json2);
        }
      }
    });

    r.forEach((x, y) {
      json.remove(x);
    });

    u.forEach((x, y) {
      json.update(
        x,
        (old) {
          log('OLD: $old');
          log('NEW: $y');
          return y;
        },
      );
    });

    return json;
  }

  static Map<String, dynamic> discardNullOrEmpty(Map<String, dynamic> json) {
    var r = {}; // remove map keys/values pair
    var u = {}; // update map keys/values pair
    json.entries.forEach((m) {
      if (m.value == null || m.value == '') {
        r.putIfAbsent(m.key, () => m.value);
      } else {
        if (m.value is Map) {
          var json2 = discardNullOrEmpty((m.value as Map) as Map<String, dynamic>);
          u.putIfAbsent(m.key, () => json2);
        }
      }
    });

    r.forEach((x, y) {
      json.remove(x);
    });

    u.forEach((x, y) {
      json.update(
        x,
        (old) {
          log('OLD: $old');
          log('NEW: $y');
          return y;
        },
      );
    });

    return json;
  }

  static Map<String, dynamic> discardNullOrEmptyEntriesAndValues(Map<String, dynamic> json) {
    var r = {}; // remove map keys/values pair
    var u = {}; // update map keys/values pair
    json.entries.forEach((m) {
      if (m.value == null || m.value == '' || m.value is List && (m.value as List).isEmpty) {
        r.putIfAbsent(m.key, () => m.value);
      } else {
        if (m.value is Map) {
          if ((m.value as Map).isEmpty) {
            r.putIfAbsent(m.key, () => m.value);
          } else {
            var json2 = discardNullOrEmptyEntriesAndValues((m.value as Map) as Map<String, dynamic>);
            if (json2.isEmpty) {
              r.putIfAbsent(m.key, () => json2);
            } else {
              u.putIfAbsent(m.key, () => json2);
            }
          }
        }
      }
    });

    r.forEach((x, y) {
      json.remove(x);
    });

    u.forEach((x, y) {
      json.update(
        x,
        (old) {
          log('OLD: $old');
          log('NEW: $y');
          return y;
        },
      );
    });

    return json;
  }
}

class PrayerRequester {
  String? pid, uid, firstName, lastName, role, gender, avatarUrl, phone, description;
  bool? prayed;
  Timestamp? timestamp;

  PrayerRequester({
    this.uid,
    this.pid,
    this.firstName,
    this.lastName,
    this.role,
    this.gender,
    this.phone,
    this.description,
    this.prayed,
    this.timestamp,
    this.avatarUrl,
  });

  factory PrayerRequester.fromJson(Map<String, dynamic> json) {
    return PrayerRequester(
      uid: json["uid"] == null ? null : json["uid"],
      pid: json["pid"] == null ? null : json["pid"],
      firstName: json["first_name"] == null ? null : json["first_name"],
      lastName: json["last_name"] == null ? null : json["last_name"],
      role: json["role"] == null ? null : json["role"],
      gender: json["gender"] == null ? null : json["gender"],
      phone: json["phone"] == null ? '' : json["phone"],
      prayed: json["prayed"] == null ? false : json["prayed"],
      description: json["description"] == null ? null : json["description"],
      timestamp: json["timestamp"] == null ? null : json["timestamp"],
      avatarUrl: json["avatar_url"] == null ? null : json["avatar_url"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid == null ? null : uid,
      "pid": pid == null ? null : pid,
      "first_name": firstName == null ? null : firstName,
      "last_name": lastName == null ? null : lastName,
      "role": role == null ? null : role,
      "gender": gender == null ? null : gender,
      "phone": phone == null ? null : phone,
      "prayed": prayed == null ? null : prayed,
      "description": description == null ? null : description,
      "timestamp": timestamp == null ? null : timestamp,
      "avatar_url": avatarUrl == null ? null : avatarUrl,
    };
  }
}

class TxInfo {
  final txref, mcref, status;
  final double credit;
  final Timestamp timestamp;

  TxInfo({
    this.txref,
    this.mcref,
    this.status,
    required this.credit,
    required this.timestamp,
  });

  factory TxInfo.fromJson(Map<String, dynamic> json) {
    return TxInfo(
      txref: json['txref'],
      mcref: json['mcref'],
      status: json['status'],
      credit: pick(json['credit']).asDoubleOrThrow(),
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "txref": txref,
      "mcref": mcref,
      "status": status,
      "credit": credit,
      "timestamp": timestamp,
    };
  }
}

class Address {
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? postcode;
  String? country;
  String? state;
  String? phone;

  Address({
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postcode,
    this.country,
    this.state,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        company: json["company"] == null ? '' : json["company"],
        address1: json["address_1"] == null ? '' : json["address_1"],
        address2: json["address_2"] == null ? '' : json["address_2"],
        city: json["city"] == null ? '' : json["city"],
        postcode: json["postcode"] == null ? '' : json["postcode"],
        country: json["country"] == null ? '' : json["country"],
        state: json["state"] == null ? '' : json["state"],
        phone: json["phone"] == null ? '' : json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "company": company == null ? null : company,
        "address_1": address1 == null ? null : address1,
        "address_2": address2 == null ? null : address2,
        "city": city == null ? null : city,
        "postcode": postcode == null ? null : postcode,
        "country": country == null ? null : country,
        "state": state == null ? null : state,
        "phone": phone == null ? null : phone,
      };
}
