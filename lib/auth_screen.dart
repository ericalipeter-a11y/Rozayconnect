import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_createAccount) {
        final response = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        if (response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created. Check your email to confirm it, then sign in.')),
          );
          setState(() => _createAccount = false);
        } else {
          Navigator.of(context).pop(true);
        }
      } else {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (mounted) Navigator.of(context).pop(true);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach the account service. Check your connection and try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Rozay account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.storefront, size: 58, color: Color(0xFF16834A)),
                const SizedBox(height: 16),
                Text(
                  _createAccount ? 'Create your account' : 'Welcome back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Sign in to manage your seller profile and listings.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email address', border: OutlineInputBorder()),
                  validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email address' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  autofillHints: _createAccount ? const [AutofillHints.newPassword] : const [AutofillHints.password],
                  decoration: const InputDecoration(labelText: 'Password (at least 8 characters)', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.length < 8 ? 'Use at least 8 characters' : null,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? 'Please wait…' : _createAccount ? 'Create account' : 'Sign in'),
                ),
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _createAccount = !_createAccount),
                  child: Text(_createAccount ? 'Already have an account? Sign in' : 'New to Rozay Connect? Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
