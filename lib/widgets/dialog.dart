import 'package:flutter/material.dart';

Future<void> showMsgDialog(
    BuildContext context, String title, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showConfigDialog(
    BuildContext context, String title, String message, Function result) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              result(false);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              result(true);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
