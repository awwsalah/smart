import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../theme/app_theme.dart';

/// Cascading City → District → Street pickers for client registration.
class AddressDropdowns extends StatelessWidget {
  const AddressDropdowns({
    super.key,
    required this.cities,
    required this.districts,
    required this.streets,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.selectedStreet,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onStreetChanged,
    this.isLoadingDistricts = false,
    this.isLoadingStreets = false,
  });

  final List<City> cities;
  final List<District> districts;
  final List<Street> streets;
  final City? selectedCity;
  final District? selectedDistrict;
  final Street? selectedStreet;
  final ValueChanged<City?> onCityChanged;
  final ValueChanged<District?> onDistrictChanged;
  final ValueChanged<Street?> onStreetChanged;
  final bool isLoadingDistricts;
  final bool isLoadingStreets;

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<City>(
          initialValue: selectedCity,
          decoration: const InputDecoration(
            labelText: 'City / Magaalo',
          ),
          items: cities
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Text(city.name),
                ),
              )
              .toList(),
          onChanged: onCityChanged,
          validator: (value) =>
              value == null ? 'Please select a city' : null,
        ),
        const SizedBox(height: AppSpacing.field),
        if (isLoadingDistricts)
          const LinearProgressIndicator()
        else
          DropdownButtonFormField<District>(
            initialValue: selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'District / Xaafad',
            ),
            items: districts
                .map(
                  (district) => DropdownMenuItem(
                    value: district,
                    child: Text(district.name),
                  ),
                )
                .toList(),
            onChanged: selectedCity == null ? null : onDistrictChanged,
            validator: (value) =>
                value == null ? 'Please select a district' : null,
          ),
        const SizedBox(height: AppSpacing.field),
        if (isLoadingStreets)
          const LinearProgressIndicator()
        else if (selectedDistrict != null && streets.isEmpty)
          Text(
            'No listed streets for this district — use landmark note below.',
            style: TextStyle(color: hintColor, fontSize: 13),
          )
        else
          DropdownButtonFormField<Street>(
            initialValue: selectedStreet,
            decoration: const InputDecoration(
              labelText: 'Street / Waddo (optional)',
            ),
            items: streets
                .map(
                  (street) => DropdownMenuItem(
                    value: street,
                    child: Text(street.name),
                  ),
                )
                .toList(),
            onChanged: selectedDistrict == null ? null : onStreetChanged,
          ),
      ],
    );
  }
}
