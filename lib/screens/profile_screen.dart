import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../services/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/address_dropdowns.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_title.dart';

/// Edit name, address or vehicle info, and optional password change.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _locationDao = LocationDao();

  List<City> _cities = [];
  List<District> _districts = [];
  List<Street> _streets = [];
  City? _selectedCity;
  District? _selectedDistrict;
  Street? _selectedStreet;
  String? _selectedVehicleType;
  City? _selectedServiceCity;

  bool _loading = true;
  bool _loadingDistricts = false;
  bool _loadingStreets = false;
  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _landmarkController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _nameController.text = user.fullName;
    _landmarkController.text = user.landmarkNote ?? '';
    _plateController.text = user.vehiclePlate ?? '';
    _selectedVehicleType = user.vehicleType;

    final cities = await _locationDao.getCities();
    City? city;
    District? district;
    Street? street;
    City? serviceCity;
    var districts = <District>[];
    var streets = <Street>[];

    for (final c in cities) {
      if (c.id == user.cityId) city = c;
      if (c.id == user.serviceCityId) serviceCity = c;
    }

    if (city != null) {
      districts = await _locationDao.getDistrictsByCity(city.id);
      for (final d in districts) {
        if (d.id == user.districtId) district = d;
      }
      if (district != null) {
        streets = await _locationDao.getStreetsByDistrict(district.id);
        for (final s in streets) {
          if (s.id == user.streetId) street = s;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _cities = cities;
      _districts = districts;
      _streets = streets;
      _selectedCity = city;
      _selectedDistrict = district;
      _selectedStreet = street;
      _selectedServiceCity = serviceCity;
      _loading = false;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    String? error;

    if (user.isClient) {
      if (_selectedCity == null || _selectedDistrict == null) {
        error = 'Select city and district';
      } else {
        error = await context.read<AuthProvider>().updateClientProfile(
              fullName: _nameController.text,
              cityId: _selectedCity!.id,
              districtId: _selectedDistrict!.id,
              streetId: _selectedStreet?.id,
              landmarkNote: _landmarkController.text,
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );
      }
    } else {
      if (_selectedServiceCity == null || _selectedVehicleType == null) {
        error = 'Select service city and vehicle type';
      } else {
        error = await context.read<AuthProvider>().updateDriverProfile(
              fullName: _nameController.text,
              vehicleType: _selectedVehicleType!,
              serviceCityId: _selectedServiceCity!.id,
              vehiclePlate: _plateController.text,
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      AppSnackBar.showError(context, error);
      return;
    }

    _currentPasswordController.clear();
    _newPasswordController.clear();
    AppSnackBar.showSuccess(context, 'Profile updated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile / Macluumaadka'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading profile…')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Phone: ${user?.phone ?? ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.field),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                      ),
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    if (user?.isClient == true) ...[
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
                        onStreetChanged: (s) =>
                            setState(() => _selectedStreet = s),
                      ),
                      const SizedBox(height: AppSpacing.field),
                      TextFormField(
                        controller: _landmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Landmark note',
                        ),
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedVehicleType,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle type',
                        ),
                        items: AuthService.vehicleTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedVehicleType = v),
                        validator: (v) =>
                            Validators.requiredSelection(v, 'a vehicle type'),
                      ),
                      const SizedBox(height: AppSpacing.field),
                      TextFormField(
                        controller: _plateController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle plate (optional)',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.field),
                      DropdownButtonFormField<City>(
                        initialValue: _selectedServiceCity,
                        decoration: const InputDecoration(
                          labelText: 'Service city',
                        ),
                        items: _cities
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (c) =>
                            setState(() => _selectedServiceCity = c),
                        validator: (v) =>
                            v == null ? 'Please select a service city' : null,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    const SectionTitle('Change password (optional)'),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.field),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (v) => Validators.optionalNewPassword(
                        v,
                        _currentPasswordController.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
