import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/repositories/auth_providers.dart';
import 'package:rescuenet_warehouse/repositories/auth_repository.dart';
import 'package:rescuenet_warehouse/widgets/org_logo.dart';

class AuthForgotPasswordPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _AuthForgotPasswordPageState();
}

class _AuthForgotPasswordPageState
    extends ConsumerState<AuthForgotPasswordPage> {
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
              _sendBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    //return the logo from the assets
    return const DrawerHeader(child: OrgLogo.small());
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Error : $errorMessage');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
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
      ),
    ],
  );

  Future<void> _sendMail() async {
    print('pressed send reset mail');
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.sendPasswordResetEmail(_controllerEmail.text);
      setState(() {
        errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      print("Error in sending mail: $e");
    }
  }
}
