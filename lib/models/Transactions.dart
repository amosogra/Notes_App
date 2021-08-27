import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_pick/deep_pick.dart';

class BCredit {
  final String cid, name, image;
  final String? paymentCode, txref, mcref, status, accountId, narration, paymentType;
  final double credit;
  final bool regulatory;
  final Timestamp timestamp;

  BCredit({
    required this.cid,
    required this.name,
    required this.image,
    this.txref,
    this.mcref,
    this.status,
    this.accountId,
    this.narration,
    this.paymentCode,
    this.paymentType,
    required this.credit,
    required this.regulatory,
    required this.timestamp,
  });

  factory BCredit.fromJson(Map<String, dynamic> json) {
    return BCredit(
      cid: json['cid'],
      name: json['name'],
      image: json['image'],
      txref: json['txref'],
      mcref: json['mcref'],
      status: json['status'],
      accountId: json['accountId'],
      narration: json['narration'],
      paymentCode: json['paymentCode'],
      paymentType: json['paymentType'],
      credit: pick(json['credit']).asDoubleOrThrow(),
      regulatory: json['regulatory'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cid": cid,
      "name": name,
      "image": image,
      "txref": txref,
      "mcref": mcref,
      "status": status,
      "accountId": accountId,
      "narration": narration,
      "paymentCode": paymentCode,
      "paymentType": paymentType,
      "credit": credit,
      "regulatory": regulatory,
      "timestamp": timestamp,
    };
  }

  static double getTotalCredit(List<BCredit> bcredits) {
    var prices = bcredits.map((bcredit) {
      return bcredit.credit;
    }).toList();
    var totalCredit = 0.00;
    for (int i = 0; i < prices.length; i++) {
      totalCredit = totalCredit + prices[i];
    }

    return totalCredit;
  }
}

class BDebit {
  final String did, name, image;
  final double debit;
  final bool regulatory;
  final Timestamp timestamp;

  BDebit({
    required this.did,
    required this.name,
    required this.image,
    required this.debit,
    required this.regulatory,
    required this.timestamp,
  });

  factory BDebit.fromJson(Map<String, dynamic> json) {
    return BDebit(
      did: json['did'],
      name: json['name'],
      image: json['image'],
      debit: pick(json['debit']).asDoubleOrThrow(),
      regulatory: json['regulatory'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "did": did,
      "name": name,
      "image": image,
      "debit": debit,
      "regulatory": regulatory,
      "timestamp": timestamp,
    };
  }

  static double getTotalDebit(List<BDebit> bdebits) {
    var prices = bdebits.map((bdebit) {
      return bdebit.debit;
    }).toList();
    var totalDebit = 0.00;
    for (int i = 0; i < prices.length; i++) {
      totalDebit = totalDebit + prices[i];
    }

    return totalDebit;
  }
}

class ECredit {
  final String cid, name, image;
  final String? txref, mcref, status, accountId, narration, paymentCode, paymentType;
  final double credit;
  final bool regulatory;
  final Timestamp timestamp;

  ECredit({
    required this.cid,
    required this.name,
    required this.image,
    this.txref,
    this.mcref,
    this.status,
    this.accountId,
    this.narration,
    this.paymentCode,
    this.paymentType,
    required this.credit,
    required this.regulatory,
    required this.timestamp,
  });

  factory ECredit.fromJson(Map<String, dynamic> json) {
    return ECredit(
      cid: json['cid'],
      name: json['name'],
      image: json['image'],
      txref: json['txref'],
      mcref: json['mcref'],
      credit: pick(json['credit']).asDoubleOrThrow(),
      status: json['status'],
      accountId: json['accountId'],
      narration: json['narration'],
      paymentCode: json['paymentCode'],
      paymentType: json['paymentType'],
      regulatory: json['regulatory'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cid": cid,
      "name": name,
      "image": image,
      "txref": txref,
      "mcref": mcref,
      "credit": credit,
      "status": status,
      "accountId": accountId,
      "narration": narration,
      "paymentCode": paymentCode,
      "paymentType": paymentType,
      "regulatory": regulatory,
      "timestamp": timestamp,
    };
  }

  static double getTotalCredit(List<ECredit> ecredits) {
    var prices = ecredits.map((ecredit) {
      return ecredit.credit;
    }).toList();
    var totalCredit = 0.00;
    for (int i = 0; i < prices.length; i++) {
      totalCredit = totalCredit + prices[i];
    }

    return totalCredit;
  }
}

class EDebit {
  final String did, name, image;
  final double debit;
  final bool regulatory;
  final Timestamp timestamp;

  EDebit({
    required this.did,
    required this.name,
    required this.image,
    required this.debit,
    required this.regulatory,
    required this.timestamp,
  });

  factory EDebit.fromJson(Map<String, dynamic> json) {
    return EDebit(
      did: json['did'],
      name: json['name'],
      image: json['image'],
      debit: pick(json['debit']).asDoubleOrThrow(),
      regulatory: json['regulatory'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "did": did,
      "name": name,
      "image": image,
      "debit": debit,
      "regulatory": regulatory,
      "timestamp": timestamp,
    };
  }

  static double getTotalDebit(List<BDebit> edebits) {
    var prices = edebits.map((edebit) {
      return edebit.debit;
    }).toList();
    var totalDebit = 0.00;
    for (int i = 0; i < prices.length; i++) {
      totalDebit = totalDebit + prices[i];
    }

    return totalDebit;
  }
}
