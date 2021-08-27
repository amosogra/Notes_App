import 'package:flutter/material.dart';

class CloudRevenueInfo {
  final String? svgSrc, title, miscText;
  final int? amounts, percentage;
  final Color? color;

  CloudRevenueInfo(
      {this.svgSrc,
      this.title,
      this.miscText,
      this.amounts,
      this.percentage,
      this.color});
}

List demoMyFiels = [
  CloudRevenueInfo(
    title: "Total Balance",
    amounts: 1328,
    svgSrc: "assets/Icons/money-bill-alt.svg",
    miscText: "1.9GB",
    color: Color(0xFF2697FF),
    percentage: 35,
  ),
  CloudRevenueInfo(
    title: "Total Debit",
    amounts: 1328,
    svgSrc: "assets/Icons/money-bill-alt.svg",
    miscText: "2.9GB",
    color: Color(0xFFFFA113),
    percentage: 35,
  ),
  CloudRevenueInfo(
    title: "Total Credit",
    amounts: 1328,
    svgSrc: "assets/Icons/money-bill-alt.svg",
    miscText: "1GB",
    color: Color(0xFFA4CDFF),
    percentage: 100,
  ),
  CloudRevenueInfo(
    title: "Total Board",
    amounts: 5328,
    svgSrc: "assets/Icons/unknown.svg",
    miscText: "join_amount",
    color: Color(0xFF007EE5),
    percentage: 78,
  ),
];
