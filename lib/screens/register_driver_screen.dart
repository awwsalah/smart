import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../models/city.dart';
import '../services/auth_provider.dart';
import '../services/auth_service.dart';
import 'driver_home_screen.dart';

/// Driver sign-up with vehicle info and service city.
class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _plateController = TextEditingController();
  final _locationDao = LocationDao();

  List<City> _cities = [];
  City? _selectedServiceCity;
  String? _selectedVehicleType;
  bool _loadingCities = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    final cities = await _locationDao.getCities();
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _loadingCities = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceCity == null || _selectedVehicleType == null) return;

    setState(() => _isSubmitting = true);

    final error = await context.read<AuthProvider>().registerDriver(
          fullName: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          vehicleType: _selectedVehicleType!,
          serviceCityId: _selectedServiceCity!.id,
          vehiclePlate: _plateController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register — Driver'),
      ),
      body: _loadingCities
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!RegExp(r'^[0-9]{9,15}$').hasMatch(v.trim())) {
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle type',
                        border: OutlineInputBorder(),
                      ),
                      items: AuthService.vehicleTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedVehicleType = value);
                      },
                      validator: (v) => v == null ? 'Select vehicle type' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle plate (optional)',
                        hintText: 'HGA-1234',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<City>(
                      initialValue: _selectedServiceCity,
                      decoration: const InputDecoration(
                        labelText: 'Service city / Magaalo adeeg',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city.name),
                            ),
                          )
                          .toList(),
                      onChanged: (city) {
                        setState(() => _selectedServiceCity = city);
                      },
                      validator: (v) => v == null ? 'Select service city' : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
