import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/auth_util.dart';

class AuthForgotPasswordPage extends StatefulWidget {
  @override
  State createState() => _AuthForgotPasswordPageState();
}

class _AuthForgotPasswordPageState extends State<AuthForgotPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              _logo(),
              _entryField('email', _controllerEmail),
              _errorMessage(),
              _sendBtn()
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    //return the logo from the assets
    return const DrawerHeader(
      child: Image(
        image: AssetImage('assets/images/LogoRN.png'),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _sendBtn() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: () {
            _sendMail();
          },
          child: const Text('Send mail'),
        )
      ]);

  Future<void> _sendMail() async {
    print('pressed send reset mail');
    try {
      await Auth().sendPasswordResetEmail(_controllerEmail.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      print("Error in sending mail: $e");
    }
  }
}
