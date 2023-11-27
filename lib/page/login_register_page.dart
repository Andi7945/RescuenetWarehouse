import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../routes.dart';
import '../utils/auth_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    print('pressed Login');
    var tryAuth = await Auth().signInWithEmailAndPassword(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
    );
    setState(() {
      errorMessage = tryAuth.errorMessage;
    });
    if (tryAuth.errorCode == null) {
      Navigator.pushNamed(context, routeContainerWithContent);
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    print('pressed Register');
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      print("Error in Login: $e");
    }
  }

  Widget _logo() {
    //return the logo from the assets
    return const DrawerHeader(
      child: Image(
        image: AssetImage('assets/images/rn_logo_big.png'),
      ),
    );
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

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return FilledButton(
      onPressed: () {
        isLogin
            ? signInWithEmailAndPassword()
            : createUserWithEmailAndPassword();
      },
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

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
              _entryField('password', _controllerPassword),
              _errorMessage(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _submitButton(),
                  _loginOrRegisterButton(),
                  ElevatedButton(
                      child: Text("Forgot password"),
                      onPressed: () =>
                          Navigator.pushNamed(context, routeForgotPassword))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
