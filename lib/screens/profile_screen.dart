import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../models/user.dart';
import '../services/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/address_dropdowns.dart';
import '../widgets/app_dropdown_field.dart';
import '../widgets/app_form_fields.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/loading_view.dart';

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

  String _heroSubtitle(User user) {
    if (user.isClient) {
      final parts = <String>[
        if (_selectedCity != null) _selectedCity!.name,
        if (_selectedDistrict != null) _selectedDistrict!.name,
      ];
      return parts.isEmpty ? 'Client account' : parts.join(' · ');
    }
    final parts = <String>[
      if (_selectedVehicleType != null) _selectedVehicleType!,
      if (_selectedServiceCity != null) _selectedServiceCity!.name,
    ];
    return parts.isEmpty ? 'Driver account' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final colors = context.appColors;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Profile / Macluumaadka'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading profile…')
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user != null)
                      _ProfileHero(
                        user: user,
                        subtitle: _heroSubtitle(user),
                      )
                          .animate()
                          .fadeIn(duration: 450.ms)
                          .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileSectionHeader(
                            icon: Icons.person_outline,
                            title: 'Personal info',
                            subtitle: 'Magacaaga',
                          ),
                          AppTextField(
                            controller: _nameController,
                            labelText: 'Full name',
                            textCapitalization: TextCapitalization.words,
                            validator: Validators.fullName,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileSectionHeader(
                            icon: user?.isClient == true
                                ? Icons.location_on_outlined
                                : Icons.local_shipping_outlined,
                            title: user?.isClient == true
                                ? 'Address'
                                : 'Vehicle & service',
                            subtitle: user?.isClient == true
                                ? 'Cinwaanka'
                                : 'Gaadiidka & magaalada',
                          ),
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
                            AppForm.fieldSpacing,
                            AppTextField(
                              controller: _landmarkController,
                              labelText: 'Landmark note',
                              hintText: 'Near a known place',
                            ),
                          ] else ...[
                            AppDropdownField<String>(
                              value: _selectedVehicleType,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle type',
                              ),
                              hint: Text(
                                'Select vehicle type',
                                style: TextStyle(color: colors.textSecondary),
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
                              validator: (v) => Validators.requiredSelection(
                                v,
                                'a vehicle type',
                              ),
                            ),
                            AppForm.fieldSpacing,
                            AppTextField(
                              controller: _plateController,
                              labelText: 'Vehicle plate (optional)',
                              hintText: 'HGA-1234',
                            ),
                            AppForm.fieldSpacing,
                            AppDropdownField<City>(
                              value: _selectedServiceCity,
                              decoration: const InputDecoration(
                                labelText: 'Service city',
                              ),
                              hint: Text(
                                'Select service city',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                              items: _cities
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (c) =>
                                  setState(() => _selectedServiceCity = c),
                              validator: (v) =>
                                  v == null
                                      ? 'Please select a service city'
                                      : null,
                            ),
                          ],
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 140.ms, duration: 400.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileSectionHeader(
                            icon: Icons.lock_outline,
                            title: 'Security',
                            subtitle: 'Optional password change',
                          ),
                          AppTextField(
                            controller: _currentPasswordController,
                            labelText: 'Current password',
                            obscureText: _obscureCurrent,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent,
                              ),
                            ),
                          ),
                          AppForm.fieldSpacing,
                          AppTextField(
                            controller: _newPasswordController,
                            labelText: 'New password',
                            obscureText: _obscureNew,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                            validator: (v) => Validators.optionalNewPassword(
                              v,
                              _currentPasswordController.text,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    AppForm.sectionSpacing,
                    _saving
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colors.accent,
                            ),
                          )
                        : GradientButton(
                            onPressed: _save,
                            label: 'Save changes',
                            icon: Icons.save_outlined,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Gradient hero header — uses theme navy + subtle coral accent only.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.subtitle,
  });

  final User user;
  final String subtitle;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final roleLabel = user.isClient ? 'Client / Macmiil' : 'Driver / Darawal';
    final roleIcon =
        user.isClient ? Icons.home_outlined : Icons.local_shipping_outlined;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.gradientTop,
              colors.gradientMid,
              Color.lerp(colors.gradientBottom, colors.accent, 0.22)!,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(color: colors.glassBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.accent, colors.accentSecondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundColor: colors.gradientMid,
                  child: Text(
                    _initials(user.fullName),
                    style: GoogleFonts.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: colors.onGradient,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user.fullName,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.onGradient,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roleIcon, size: 16, color: colors.accent),
                    const SizedBox(width: 6),
                    Text(
                      roleLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onGradient.withValues(alpha: 0.82),
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: colors.iconTint,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    user.phone,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header with aligned icon + bilingual labels inside cards.
class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.iconTint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.iconTint, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 17,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
