import 'package:flutter/material.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';

/// Dialog for Sign In, Account Registration, and Account Linking.
class AuthDialog extends StatefulWidget {
  final AuthRemoteDataSource authDataSource;
  final bool isLinking;

  const AuthDialog({
    super.key,
    required this.authDataSource,
    this.isLinking = false,
  });

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.isLinking) {
        await widget.authDataSource.linkAccountWithEmail(
          email: email,
          password: password,
        );
      } else if (_isRegistering) {
        await widget.authDataSource.signUpWithEmail(
          email: email,
          password: password,
        );
      } else {
        await widget.authDataSource.signInWithEmail(
          email: email,
          password: password,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isLinking
        ? 'Link Account & Save Progress'
        : (_isRegistering ? 'Register Account' : 'Sign In');

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (!widget.isLinking) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    setState(() => _isRegistering = !_isRegistering),
                child: Text(_isRegistering
                    ? 'Already have an account? Sign In'
                    : 'Need an account? Register'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isLinking
                  ? 'Link'
                  : (_isRegistering ? 'Register' : 'Sign In')),
        ),
      ],
    );
  }
}
