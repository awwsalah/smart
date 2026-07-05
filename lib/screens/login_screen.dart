import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import 'client_home_screen.dart';
import 'driver_home_screen.dart';
import 'register_client_screen.dart';
import 'register_driver_screen.dart';

/// Phone + password login for the role chosen on the previous screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final String role;

  bool get isClient => role == 'client';

  String get roleLabel => isClient ? 'Client / Macmiil' : 'Driver / Darawal';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await context.read<AuthProvider>().login(
          phone: _phoneController.text,
          password: _passwordController.text,
          role: widget.role,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final home = widget.isClient
        ? const ClientHomeScreen()
        : const DriverHomeScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => home),
    );
  }

  void _openRegister() {
    final screen = widget.isClient
        ? const RegisterClientScreen()
        : const RegisterDriverScreen();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login — ${widget.roleLabel}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '0630000001',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value.trim())) {
                    return 'Enter 9–15 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'At least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _openRegister,
                child: Text(
                  widget.isClient
                      ? 'New client? Register here'
                      : 'New driver? Register here',
                ),
              ),
              if (!widget.isClient) ...[
                const SizedBox(height: 8),
                Text(
                  'Demo: 0630000002 / 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Demo: 0630000001 / 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
