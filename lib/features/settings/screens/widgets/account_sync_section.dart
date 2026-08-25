import 'package:flutter/material.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/injection.dart';
import 'auth_dialog.dart';

/// Settings section for Account management & Cloud Firestore synchronization.
class AccountSyncSection extends StatefulWidget {
  const AccountSyncSection({super.key});

  @override
  State<AccountSyncSection> createState() => _AccountSyncSectionState();
}

class _AccountSyncSectionState extends State<AccountSyncSection> {
  late final AuthRemoteDataSource _authDataSource;
  late final UserDataRepository _userDataRepo;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _authDataSource = getIt<AuthRemoteDataSource>();
    _userDataRepo = getIt<UserDataRepository>();
  }

  void _refresh() => setState(() {});

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);
    try {
      await _userDataRepo.syncWithRemote();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cloud sync completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _openAuthDialog({required bool isLinking}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AuthDialog(
        authDataSource: _authDataSource,
        isLinking: isLinking,
      ),
    );
    if (result == true) {
      _refresh();
      _syncNow();
    }
  }

  Future<void> _signOut() async {
    await _authDataSource.signOut();
    // Re-sign in anonymously as per requirements
    await _authDataSource.signInAnonymously();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authDataSource.currentUserId ?? 'Unknown';
    final shortUid = uid.length > 10 ? '${uid.substring(0, 10)}...' : uid;
    final isAnon = _authDataSource.isAnonymous;
    final email = _authDataSource.userEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Text(
            'Account & Cloud Sync',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAnon ? 'Guest User (Anonymous)' : 'Signed In',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(shortUid, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                if (email != null) ...[
                  const SizedBox(height: 4),
                  Text('Email: $email', style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    if (isAnon) ...[
                      ElevatedButton.icon(
                        onPressed: () => _openAuthDialog(isLinking: true),
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('Link Account / Register'),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('Sign Out'),
                      ),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _openAuthDialog(isLinking: false),
                      icon: const Icon(Icons.login, size: 16),
                      label: Text(isAnon ? 'Sign In / Switch' : 'Sign In'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncNow,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync, size: 16),
                      label: const Text('Sync Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
