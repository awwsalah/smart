import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/location_dao.dart';
import '../db/waste_type_dao.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../models/waste_type.dart';
import '../services/auth_provider.dart';
import '../services/reference_data_service.dart';
import '../services/request_service.dart';
import '../widgets/address_dropdowns.dart';
import 'request_detail_screen.dart';

/// Form to create a new waste pickup request.
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _requestService = RequestService();
  final _locationDao = LocationDao();
  final _wasteTypeDao = WasteTypeDao();
  final _referenceData = ReferenceDataService.instance;

  List<WasteType> _wasteTypes = [];
  List<String> _sizes = [];
  List<String> _timeSlots = [];
  List<String> _paymentMethods = [];
  List<City> _cities = [];
  List<District> _districts = [];
  List<Street> _streets = [];

  WasteType? _selectedWasteType;
  String? _selectedSize;
  String? _selectedSlot;
  String? _selectedPayment;
  DateTime? _selectedDate;
  City? _selectedCity;
  District? _selectedDistrict;
  Street? _selectedStreet;

  bool _loading = true;
  bool _loadingDistricts = false;
  bool _loadingStreets = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final user = context.read<AuthProvider>().currentUser;
    final wasteTypes = await _wasteTypeDao.getAll();
    final sizes = await _referenceData.getSizes();
    final slots = await _referenceData.getTimeSlots();
    final payments = await _referenceData.getPaymentMethods();
    final cities = await _locationDao.getCities();

    City? city;
    District? district;
    Street? street;
    var districts = <District>[];
    var streets = <Street>[];

    if (user?.cityId != null) {
      for (final c in cities) {
        if (c.id == user!.cityId) {
          city = c;
          break;
        }
      }
      if (city != null) {
        districts = await _locationDao.getDistrictsByCity(city.id);
        if (user?.districtId != null) {
          for (final d in districts) {
            if (d.id == user!.districtId) {
              district = d;
              break;
            }
          }
          if (district != null) {
            streets = await _locationDao.getStreetsByDistrict(district.id);
            if (user?.streetId != null) {
              for (final s in streets) {
                if (s.id == user!.streetId) {
                  street = s;
                  break;
                }
              }
            }
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _wasteTypes = wasteTypes;
      _sizes = sizes;
      _timeSlots = slots;
      _paymentMethods = payments;
      _cities = cities;
      _districts = districts;
      _streets = streets;
      _selectedCity = city;
      _selectedDistrict = district;
      _selectedStreet = street;
      _landmarkController.text = user?.landmarkNote ?? '';
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a preferred date')),
      );
      return;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      return;
    }

    setState(() => _submitting = true);
    final client = context.read<AuthProvider>().currentUser!;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final result = await _requestService.createRequest(
      client: client,
      wasteTypeId: _selectedWasteType!.id,
      size: _selectedSize!,
      preferredDate: dateStr,
      preferredSlot: _selectedSlot!,
      paymentMethod: _selectedPayment!,
      cityId: _selectedCity!.id,
      districtId: _selectedDistrict!.id,
      streetId: _selectedStreet?.id,
      landmarkNote: _landmarkController.text,
      note: _noteController.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(requestId: result.request!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request / Codsi Cusub'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<WasteType>(
                      initialValue: _selectedWasteType,
                      decoration: const InputDecoration(
                        labelText: 'Waste type / Nooca qashinka',
                        border: OutlineInputBorder(),
                      ),
                      items: _wasteTypes
                          .map(
                            (wt) => DropdownMenuItem(
                              value: wt,
                              child: Text(
                                '${wt.name} (\$${wt.estFee.toStringAsFixed(1)})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedWasteType = v),
                      validator: (v) => v == null ? 'Select waste type' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSize,
                      decoration: const InputDecoration(
                        labelText: 'Size / Cabir',
                        border: OutlineInputBorder(),
                      ),
                      items: _sizes
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSize = v),
                      validator: (v) => v == null ? 'Select size' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Preferred date / Taariikhda',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Tap to choose date'
                              : DateFormat.yMMMd().format(_selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSlot,
                      decoration: const InputDecoration(
                        labelText: 'Time slot / Waqtiga',
                        border: OutlineInputBorder(),
                      ),
                      items: _timeSlots
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSlot = v),
                      validator: (v) => v == null ? 'Select time slot' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPayment,
                      decoration: const InputDecoration(
                        labelText: 'Payment method / Lacag bixin',
                        border: OutlineInputBorder(),
                      ),
                      items: _paymentMethods
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPayment = v),
                      validator: (v) =>
                          v == null ? 'Select payment method' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pickup address (from profile, editable)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
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
                      onStreetChanged: (s) => setState(() => _selectedStreet = s),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _landmarkController,
                      decoration: const InputDecoration(
                        labelText: 'Landmark note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit request'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
