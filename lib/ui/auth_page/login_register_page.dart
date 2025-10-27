import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes.dart';
import '../../repositories/auth_providers.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/org_logo.dart';
import '../../utils/email_validator.dart';
import '../../config/org_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = "/login";

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    print('pressed Login');
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final tryAuth = await authNotifier.signInWithEmailAndPassword(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
    );
    setState(() {
      errorMessage = "${tryAuth.errorCode} : ${tryAuth.errorMessage}";
    });
    if (tryAuth.errorCode == null) {
      Navigator.pushNamed(context, routeContainerWithContent);
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    print('pressed Register');
    try {
      // Get current organization configuration
      final orgConfig = ref.read(currentOrgProvider);

      // Validate email domain using organization's configuration
      final domainError = EmailDomainValidator.validate(
        _controllerEmail.text,
        allowedDomains: orgConfig.allowedEmailDomains,
        whitelistedEmails: orgConfig.whitelistedEmails,
      );

      if (domainError != null) {
        setState(() {
          errorMessage = domainError;
        });
        return;
      }

      // Proceed with registration
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
        name: _controllerEmail.text
            .split('@')
            .first, // Use email prefix as name
      );

      // Registration successful, navigate to main app
      Navigator.pushNamed(context, routeContainerWithContent);
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
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
    return const DrawerHeader(child: OrgLogo.large());
  }

  Widget _entryField(String title, TextEditingController controller) {
    return Semantics(
      label: title,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: title, hint: Text(title)),
      ),
    );
  }

  Widget _secureEntryField(String title, TextEditingController controller) {
    return Semantics(
      label: title,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(labelText: title),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Error : $errorMessage');
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
              _secureEntryField('password', _controllerPassword),
              _errorMessage(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _submitButton(),
                  _loginOrRegisterButton(),
                  ElevatedButton(
                    child: Text("Forgot password"),
                    onPressed: () =>
                        Navigator.pushNamed(context, routeForgotPassword),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
