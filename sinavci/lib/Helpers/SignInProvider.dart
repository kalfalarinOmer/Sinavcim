import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class SignInProvider extends StatefulWidget {
  final String infoText;
  final Buttons buttonType;
  final Function signInMethod;
  final Color color;

  const SignInProvider({
    Key key,
    @required this.infoText,
    @required this.buttonType,
    @required this.signInMethod,
    @required this.color,

  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignInProviderState();
  }

}

class SignInProviderState extends State<SignInProvider> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility( visible: false,
            child: Container(
              child: Text(
                widget.infoText,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            ),
          ),
          Center(
            child: SignInButton(
              widget.buttonType,
              text: widget.infoText,
              onPressed: () async => widget.signInMethod(),
            ),
          ),
        ],
      ),
    );
  }
}