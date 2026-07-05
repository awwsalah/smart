import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../models/city.dart';
import '../services/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/loading_view.dart';
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
      AppSnackBar.showError(context, error);
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Register — Driver'),
      ),
      body: _loadingCities
          ? const LoadingView(message: 'Loading cities…')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: GlassCard(
                child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                      ),
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: AppSpacing.field),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                      ),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: AppSpacing.field),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.field),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle type',
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
                      validator: (v) =>
                          Validators.requiredSelection(v, 'a vehicle type'),
                    ),
                    const SizedBox(height: AppSpacing.field),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle plate (optional)',
                        hintText: 'HGA-1234',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.field),
                    DropdownButtonFormField<City>(
                      initialValue: _selectedServiceCity,
                      decoration: const InputDecoration(
                        labelText: 'Service city / Magaalo adeeg',
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
                      validator: (v) =>
                          v == null ? 'Please select a service city' : null,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : GradientButton(
                            onPressed: _submit,
                            label: 'Create account',
                            icon: Icons.person_add_outlined,
                          ),
                  ],
                ),
              ),
            ),
            ),
    );
  }
}
