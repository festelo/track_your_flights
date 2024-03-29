import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trackyourflights/domain/exceptions/wrong_credentials_exception.dart';
import 'package:trackyourflights/presentation/pages/home/home_page.dart';
import 'package:trackyourflights/presentation/widgets/loading_overlay.dart';
import 'package:trackyourflights/presentation/widgets/primary_button.dart';
import 'package:trackyourflights/repositories.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PrimaryButtonState> buttonKey = GlobalKey();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  Future<void> onLogin() async {
    _loading = true;
    try {
      if (!formKey.currentState!.validate()) return;
      await sessionRepository.authenticate(
        usernameController.text,
        passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (ctx) => const HomePage()),
        );
      }
    } on WrongCredentialsException {
      buttonKey.currentState?.addError('Invalid credentials');
    } catch (e) {
      showSnackbarError(e.toString());
    } finally {
      _loading = false;
    }
  }

  void showSnackbarError(String text) {
    ScaffoldMessenger.of(formKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
              ],
            ),
            Center(
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: LoadingOverlay(
                  loading: _loading,
                  showText: false,
                  iconSize: const Size(250, 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Track your flights',
                          maxLines: 1,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          validator: (v) =>
                              v == null || v.isEmpty ? 'I realy want' : null,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'I want to know your username',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          controller: usernameController,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          validator: (v) =>
                              v == null || v.isEmpty ? '• ••••• ••••' : null,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: '• •••• •• •••• •••• ••••••••',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          controller: passwordController,
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: PrimaryButton(
                          key: buttonKey,
                          onTap: onLogin,
                          text: 'Login',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
