import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import '../theme/app_theme.dart';
import 'app_dropdown_field.dart';

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
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdownField<City>(
          value: selectedCity,
          decoration: const InputDecoration(
            labelText: 'City / Magaalo',
          ),
          hint: Text(
            'Select city',
            style: TextStyle(color: colors.textSecondary),
          ),
          items: cities
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Text(
                    city.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onCityChanged,
          validator: (value) =>
              value == null ? 'Please select a city' : null,
        ),
        const SizedBox(height: AppSpacing.field),
        if (isLoadingDistricts)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: LinearProgressIndicator(),
          )
        else
          AppDropdownField<District>(
            value: selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'District / Xaafad',
            ),
            hint: Text(
              'Select district',
              style: TextStyle(color: colors.textSecondary),
            ),
            items: districts
                .map(
                  (district) => DropdownMenuItem(
                    value: district,
                    child: Text(
                      district.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                )
                .toList(),
            onChanged: selectedCity == null ? null : onDistrictChanged,
            validator: (value) =>
                value == null ? 'Please select a district' : null,
          ),
        const SizedBox(height: AppSpacing.field),
        if (isLoadingStreets)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: LinearProgressIndicator(),
          )
        else if (selectedDistrict != null && streets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              'No listed streets for this district — use landmark note below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          AppDropdownField<Street>(
            value: selectedStreet,
            decoration: const InputDecoration(
              labelText: 'Street / Waddo (optional)',
            ),
            hint: Text(
              'Select street (optional)',
              style: TextStyle(color: colors.textSecondary),
            ),
            items: streets
                .map(
                  (street) => DropdownMenuItem(
                    value: street,
                    child: Text(
                      street.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                )
                .toList(),
            onChanged: selectedDistrict == null ? null : onStreetChanged,
          ),
      ],
    );
  }
}
