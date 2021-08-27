import 'package:flutter/material.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:provider/provider.dart';

class MessageNotification extends StatelessWidget {
  final VoidCallback? onReplay;
  final String? title;
  final String? subtitle;

  const MessageNotification({Key? key, this.onReplay, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(size: const Size(40, 40), child: ClipOval(child: Image.asset('assets/images/logo.png'))),
          title: Text(
            title ?? '',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: config.darkThemeEnabled
              ? Text(
                  subtitle ?? '',
                  style: TextStyle(color: Colors.white),
                )
              : Text(subtitle!),
          trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                if (onReplay != null) onReplay!();
              }),
        ),
      ),
    );
  }
}
