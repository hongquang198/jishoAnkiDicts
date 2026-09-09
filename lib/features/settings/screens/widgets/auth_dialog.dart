import 'package:flutter/material.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';

/// Dialog for Sign In, Account Registration, Account Linking, and Google Sign-In.
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
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(
          () => _error = AppLocalizations.of(context)!.enterEmailPassword);
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

  Future<void> _submitGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.isLinking) {
        await widget.authDataSource.linkAccountWithGoogle();
      } else {
        await widget.authDataSource.signInWithGoogle();
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
    final l = AppLocalizations.of(context)!;
    final title = widget.isLinking ? l.linkAccountSync : l.signIn;

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // Google Sign-In Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _submitGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
              label: Text(
                  widget.isLinking ? l.linkWithGoogle : l.continueWithGoogle),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l.emailAddress,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l.password,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            if (widget.isLinking) ...[
              const SizedBox(height: 8),
              Text(
                l.linkingEmailHint,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      widget.isLinking ? l.linkWithEmail : l.signinWithEmail,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
