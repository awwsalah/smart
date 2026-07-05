import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../services/auth_provider.dart';
import '../widgets/address_dropdowns.dart';
import 'client_home_screen.dart';

/// Client sign-up with cascading address dropdowns.
class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _locationDao = LocationDao();

  List<City> _cities = [];
  List<District> _districts = [];
  List<Street> _streets = [];
  City? _selectedCity;
  District? _selectedDistrict;
  Street? _selectedStreet;
  bool _loadingCities = true;
  bool _loadingDistricts = false;
  bool _loadingStreets = false;
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
    _landmarkController.dispose();
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

  Future<void> _onCityChanged(City? city) async {
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
      _selectedStreet = null;
      _districts = [];
      _streets = [];
    });

    if (city == null) return;

    setState(() => _loadingDistricts = true);
    final districts = await _locationDao.getDistrictsByCity(city.id);
    if (!mounted) return;
    setState(() {
      _districts = districts;
      _loadingDistricts = false;
    });
  }

  Future<void> _onDistrictChanged(District? district) async {
    setState(() {
      _selectedDistrict = district;
      _selectedStreet = null;
      _streets = [];
    });

    if (district == null) return;

    setState(() => _loadingStreets = true);
    final streets = await _locationDao.getStreetsByDistrict(district.id);
    if (!mounted) return;
    setState(() {
      _streets = streets;
      _loadingStreets = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedDistrict == null) return;

    setState(() => _isSubmitting = true);

    final error = await context.read<AuthProvider>().registerClient(
          fullName: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          cityId: _selectedCity!.id,
          districtId: _selectedDistrict!.id,
          streetId: _selectedStreet?.id,
          landmarkNote: _landmarkController.text,
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
      MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register — Client'),
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
                    const SizedBox(height: 24),
                    AddressDropdowns(
                      cities: _cities,
                      districts: _districts,
                      streets: _streets,
                      selectedCity: _selectedCity,
                      selectedDistrict: _selectedDistrict,
                      selectedStreet: _selectedStreet,
                      isLoadingDistricts: _loadingDistricts,
                      isLoadingStreets: _loadingStreets,
                      onCityChanged: _onCityChanged,
                      onDistrictChanged: _onDistrictChanged,
                      onStreetChanged: (street) {
                        setState(() => _selectedStreet = street);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _landmarkController,
                      decoration: const InputDecoration(
                        labelText: 'Landmark note (optional)',
                        hintText: 'Near the blue mosque',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
