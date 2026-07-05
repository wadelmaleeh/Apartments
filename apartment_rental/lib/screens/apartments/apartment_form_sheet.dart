import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../models/apartment.dart';
import '../../providers/apartment_provider.dart';
import '../../main.dart';

class ApartmentFormSheet extends StatefulWidget {
  final Apartment? apartment;
  final GlobalKey<FormState>? formKey;

  const ApartmentFormSheet({super.key, this.apartment, this.formKey});

  @override
  State<ApartmentFormSheet> createState() => ApartmentFormSheetState();
}

class ApartmentFormSheetState extends State<ApartmentFormSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get isEditing => widget.apartment != null;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _nameController =
        TextEditingController(text: widget.apartment?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.apartment?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.apartmentName,
              hintText: loc.enterName,
              prefixIcon: const Icon(Icons.apartment_rounded,
                  color: AppColors.accent),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? loc.nameRequired : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: loc.apartmentDescription,
              hintText: loc.enterDescription,
              prefixIcon: const Icon(Icons.description_rounded,
                  color: AppColors.accent),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
    final provider = context.read<ApartmentProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateApartment(
        widget.apartment!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );
    } else {
      success = await provider.addApartment(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
