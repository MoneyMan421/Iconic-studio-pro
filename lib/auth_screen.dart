import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'app_colors.dart';

// ─── AuthState ────────────────────────────────────────────────────────────────

class AuthState extends ChangeNotifier {
  static const _kLoggedIn      = 'auth_isLoggedIn';
  static const _kDisplayName   = 'auth_displayName';
  static const _kEmail         = 'auth_userEmail';
  static const _kPasswordHash  = 'auth_passwordHash';

  bool   isLoggedIn    = false;
  String displayName   = '';
  String userEmail     = '';
  String _passwordHash = '';

  // ── Load from SharedPreferences ─────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn    = prefs.getBool(_kLoggedIn)      ?? false;
    displayName   = prefs.getString(_kDisplayName) ?? '';
    userEmail     = prefs.getString(_kEmail)        ?? '';
    _passwordHash = prefs.getString(_kPasswordHash) ?? '';
    notifyListeners();
  }

  // ── Sign up ─────────────────────────────────────────────────────────────

  /// Returns null on success, or an error string on failure.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty)  return 'Name cannot be empty.';
    if (!email.contains('@')) return 'Enter a valid email address.';
    if (password.length < 6)  return 'Password must be at least 6 characters.';

    final hash  = _hash(password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(  _kLoggedIn,     true);
    await prefs.setString(_kDisplayName,  name.trim());
    await prefs.setString(_kEmail,        email.trim().toLowerCase());
    await prefs.setString(_kPasswordHash, hash);

    isLoggedIn    = true;
    displayName   = name.trim();
    userEmail     = email.trim().toLowerCase();
    _passwordHash = hash;
    notifyListeners();
    return null;
  }

  // ── Login ───────────────────────────────────────────────────────────────

  /// Returns null on success, or an error string on failure.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@')) return 'Enter a valid email address.';

    final prefs       = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_kEmail)        ?? '';
    final storedHash  = prefs.getString(_kPasswordHash) ?? '';

    if (email.trim().toLowerCase() != storedEmail) {
      return 'No account found for that email.';
    }
    if (_hash(password) != storedHash) {
      return 'Incorrect password.';
    }

    await prefs.setBool(_kLoggedIn, true);
    isLoggedIn    = true;
    displayName   = prefs.getString(_kDisplayName) ?? '';
    userEmail     = storedEmail;
    _passwordHash = storedHash;
    notifyListeners();
    return null;
  }

  // ── Logout ──────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    isLoggedIn = false;
    notifyListeners();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();
}

// ─── AuthGate ─────────────────────────────────────────────────────────────────

/// Loads auth state asynchronously; shows the [child] when logged in,
/// or [AuthScreen] when not. [onAuthenticated] is called when the user
/// successfully signs up / logs in so the gate can rebuild.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  /// The screen to show when the user is authenticated.
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthState _auth    = AuthState();
  bool            _loading = true;

  @override
  void initState() {
    super.initState();
    _auth.load().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _onAuthenticated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SplashScreen();
    if (_auth.isLoggedIn) return widget.child;
    return AuthScreen(auth: _auth, onAuthenticated: _onAuthenticated);
  }
}

// ─── SplashScreen ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, color: AppColors.gold, size: 64),
            SizedBox(height: 16),
            Text(
              'Iconic Studio Pro',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.6,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

// ─── AuthScreen ───────────────────────────────────────────────────────────────

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.auth,
    required this.onAuthenticated,
  });

  final AuthState   auth;
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Icon(Icons.diamond, color: AppColors.gold, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'Iconic Studio Pro',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Diamond refraction icon editor',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.panelBorder),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabs,
                          indicatorColor: AppColors.gold,
                          labelColor: AppColors.gold,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: const [
                            Tab(text: 'Sign Up'),
                            Tab(text: 'Log In'),
                          ],
                        ),
                        SizedBox(
                          height: 340,
                          child: TabBarView(
                            controller: _tabs,
                            children: [
                              _SignUpForm(
                                auth:            widget.auth,
                                onAuthenticated: widget.onAuthenticated,
                              ),
                              _LoginForm(
                                auth:            widget.auth,
                                onAuthenticated: widget.onAuthenticated,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sign-up form ─────────────────────────────────────────────────────────────

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({required this.auth, required this.onAuthenticated});
  final AuthState    auth;
  final VoidCallback onAuthenticated;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final err = await widget.auth.signUp(
      name:     _nameCtrl.text,
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AuthField(
            controller: _nameCtrl,
            label: 'Display Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller:   _emailCtrl,
            label:        'Email',
            icon:         Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: _passCtrl,
            label:      'Password',
            icon:       Icons.lock_outline,
            obscure:    true,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          _GoldButton(
            label:     _loading ? 'Creating account…' : 'Create Account',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

// ─── Login form ───────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.auth, required this.onAuthenticated});
  final AuthState    auth;
  final VoidCallback onAuthenticated;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final err = await widget.auth.login(
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AuthField(
            controller:   _emailCtrl,
            label:        'Email',
            icon:         Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: _passCtrl,
            label:      'Password',
            icon:       Icons.lock_outline,
            obscure:    true,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          _GoldButton(
            label:     _loading ? 'Signing in…' : 'Sign In',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure      = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String                label;
  final IconData              icon;
  final bool                  obscure;
  final TextInputType?        keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled:     true,
        fillColor:  AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: AppColors.panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: AppColors.panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onPressed});
  final String        label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
