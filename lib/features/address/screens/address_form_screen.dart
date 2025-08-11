import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kleanitapp/core/theme/color_data.dart';
import 'package:kleanitapp/core/utils/hepler.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../model/address.dart';
import 'map_picker_screen.dart';

class AddressFormScreen extends StatefulWidget {
  final CustomerAddress? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  // Define these at the top of your StatefulWidget
  // final List<String> emirates = ['Dubai', 'Abu Dhabi', 'Sharjah'];
  // final List<String> areas = ['Business Bay', 'Marina', 'Al Nahda'];
  final List<String> emirates = [
    // 'Abu Dhabi',
    'Dubai',
    // 'Sharjah',
    // 'Ajman',
    // 'Umm Al Quwain',
    // 'Ras Al Khaimah',
    // 'Fujairah',
  ];
  final List<String> areas = [
    'Palm Jebel Ali',
    'Downtown',
    'Business Bay',
    'Dubai Marina',
    'Palm Jumeirah',
    'Emaar Beachfront',
    'MBR City - Meydan',
    'Dubai Creek Harbor',
    'Dubai Hills Estate',
    'Damac Hills',
    'Damac Hills II (Akoya)',
    'Al Barari',
    'Al Barsha',
    'Al Furjan',
    'Al Ghadeer',
    'Al Jaddaf',
    'Al Safa',
    'Al Sufouh',
    'Alreemaan',
    'Arabian Ranches',
    'Arjan - Dubailand',
    'Barsha Heights',
    'Bluewaters Island',
    'City Walk',
    'DHCC - Dubai Healthcare City',
    'DMC - Dubai Maritime City',
    'Dubai Silicon Oasis',
    'Damac Lagoons',
    'Deira Creekside',
    'Dubai Harbor',
    'Dubai International City',
    'Dubai International Financial Center DIFC',
    'Dubai Investments Park | DIP',
    'Dubai Islands',
    'Dubai Production City | IMPZ',
    'Dubai South',
    'Dubai Sports City',
    'Dubai Studio City',
    'Dubailand',
    'Emaar South',
    'JBR - Jumeirah Beach Residence',
    'JLT - Jumeirah Lake Towers',
    'JVC - Jumeirah Village Circle',
    'JVT - Jumeirah Village Triangle',
    'Jebel Ali Village',
    'Jumeirah',
    'Jumeirah Bay',
    'Jumeirah Islands',
    'Jumeirah Pearl',
    'MJL - Madinat Jumeirah Living',
    'Meadows',
    'Mina Rashid',
    'Mudon',
    'Nad Al Sheba',
    'Port De La Mer',
    'Saadiyat Grove',
    'Saadiyat Island', // ⚠️ Technically in Abu Dhabi; remove if you want Dubai-only
    'Sobha Hartland',
    'Sobha Hartland 2',
    'The Heart of Europe',
    'The Valley',
    'Tilal Al Ghaf',
    'Town Square',
    'Warsan First',
    'World Islands',
    'Za’abeel',
    'Al raffa', 'Brudubai',
    // 'Zayed City', // ⚠️ Could refer to Abu Dhabi; remove if strictly Dubai
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController buildingNameController;
  late final TextEditingController flatNumberController;
  late final TextEditingController floorNumberController;
  late final TextEditingController streetNameController;
  late final TextEditingController landmarkController;
  late final TextEditingController makaniNumberController;
  late final TextEditingController additionalDirectionsController;

  String? selectedEmirate;
  String? selectedArea;
  double? latitude;
  double? longitude;

  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    buildingNameController = TextEditingController(text: widget.address?.buildingName ?? '');
    flatNumberController = TextEditingController(text: widget.address?.flatNumber ?? '');
    floorNumberController = TextEditingController(text: widget.address?.floorNumber ?? '');
    streetNameController = TextEditingController(text: widget.address?.streetName ?? '');
    landmarkController = TextEditingController(text: widget.address?.landmark ?? '');
    selectedEmirate = emirates.any((e) => e == widget.address?.emirate) ? widget.address?.emirate ?? '' : null;
    selectedArea = areas.any((e) => e == widget.address?.area) ? widget.address?.area ?? '' : null;
    makaniNumberController = TextEditingController(text: widget.address?.makaniNumber ?? '');
    additionalDirectionsController = TextEditingController(text: widget.address?.additionalDirections ?? '');
    isDefault = widget.address?.isDefault == 1;
    // latitude = widget.address?.latitude as double?;
    // longitude = widget.address?.longitude as double?;
    latitude = widget.address?.latitude != null ? double.tryParse(widget.address!.latitude!) : null;
    longitude = widget.address?.longitude != null ? double.tryParse(widget.address!.longitude!) : null;
  }

  @override
  void dispose() {
    buildingNameController.dispose();
    flatNumberController.dispose();
    floorNumberController.dispose();
    streetNameController.dispose();
    landmarkController.dispose();
    makaniNumberController.dispose();
    additionalDirectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // or your custom `icon`
        ),
        title: Text(widget.address == null ? "Add New Address" : "Edit Address", style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (ctx, state) {
          if (state is AddressActionSuccess) {
            context.read<AddressBloc>().add(FetchAddresses());
            Navigator.pop(context);
          } else if (state is AddressError) {
            showSnackBar(context, msg: state.message);
            context.read<AddressBloc>().add(FetchAddresses());
          }
        },
        builder: (ctx, state) {
          if (state is AddressLoading) return Center(child: CircularProgressIndicator());
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: Colors.white,
              child: Form(
                key: _formKey,
                child: ListView(padding: const EdgeInsets.all(16), children: [..._buildFormFields(), _buildDefaultAddressToggle(), const SizedBox(height: 20), _buildSaveButton()]),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField(buildingNameController, 'building_name', isRequired: true),
      _buildTextField(flatNumberController, 'flat_number', isRequired: true),
      _buildTextField(floorNumberController, 'floor_number', isRequired: true),
      _buildTextField(streetNameController, 'street_name', isRequired: true),

      // SizedBox(height: 20),
      _buildDropdownField('emirate', emirates, selectedEmirate, (value) => setState(() => selectedEmirate = value)),
      _buildDropdownField('area', areas, selectedArea, (value) => setState(() => selectedArea = value)),
      _buildTextField(landmarkController, 'landmark', isRequired: false),
      _buildTextField(makaniNumberController, 'makani_number', isRequired: false),
      _buildTextField(additionalDirectionsController, 'additional_directions', isRequired: false),
      _buildLocationPicker(),
      SizedBox(height: 20),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String key, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: _formatFieldName(key),
          prefixIcon: Icon(_getIconForField(key)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(.4), width: 2)),
        ),
        validator: (value) {
          if (!isRequired) return null;
          if (value == null || value.isEmpty) {
            return 'Please enter ${_formatFieldName(key).toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String key, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: _formatFieldName(key),
          prefixIcon: Icon(_getIconForField(key)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(.4), width: 2)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select ${_formatFieldName(key).toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickLocationFromMap,
          icon: Icon(Icons.map_outlined),
          label: Text('Pick Location on Map'),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
        // if (latitude != null && longitude != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 8),
        //     child: Text(
        //       'Picked Location: ($latitude, $longitude)',
        //       style: TextStyle(color: Colors.black54),
        //     ),
        //   ),
        if (latitude == null || longitude == null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('⚠ Location is required', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _pickLocationFromMap() async {
    final result = await Navigator.push<LatLng>(context, MaterialPageRoute(builder: (_) => const OsmPickerScreen()));

    if (result != null) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
      showSnackBar(context, msg: "Location Selected: ($latitude, $longitude)");
    }
  }

  Widget _buildDefaultAddressToggle() {
    return Row(
      children: [
        Switch(value: isDefault, activeColor: primaryColor, onChanged: (val) => setState(() => isDefault = val)),
        const SizedBox(width: 10),
        const Text("Set as default address", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _onSave,
      icon: const Icon(Icons.save_outlined, color: Colors.white),
      label: Text(widget.address == null ? 'Save Address' : 'Update Address'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatFieldName(String key) {
    return key.replaceAll("_", " ").toUpperCase();
  }

  IconData _getIconForField(String key) {
    switch (key) {
      case 'building_name':
        return Icons.apartment_outlined;
      case 'flat_number':
        return Icons.numbers_outlined;
      case 'floor_number':
        return Icons.stairs_outlined;
      case 'street_name':
        return Icons.streetview_outlined;
      case 'area':
        return Icons.location_city_outlined;
      case 'landmark':
        return Icons.location_on_outlined;
      case 'emirate':
        return Icons.map_outlined;
      case 'makani_number':
        return Icons.location_searching_outlined;
      case 'po_box':
        return Icons.markunread_mailbox_outlined;
      case 'additional_directions':
        return Icons.directions_outlined;
      default:
        return Icons.text_fields_outlined;
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (latitude == null || longitude == null) {
        showSnackBar(context, msg: "Please pick a location on the map.");
        return;
      }

      final payload = {
        'building_name': buildingNameController.text,
        'flat_number': flatNumberController.text,
        'floor_number': floorNumberController.text,
        'street_name': streetNameController.text,
        'area': selectedArea,
        'landmark': landmarkController.text,
        'emirate': selectedEmirate,
        'makani_number': makaniNumberController.text,
        'additional_directions': additionalDirectionsController.text,
        'is_default': isDefault,
        'latitude': latitude?.toStringAsFixed(6),
        'longitude': longitude?.toStringAsFixed(6),

        // 'po_box': '',

        // 'building_name',
        // 'flat_number',
        // 'floor_number',
        // 'street_name',
        // 'area',
        // 'landmark',
        // 'emirate',
        // 'makani_number',
        // 'po_box',
        // 'additional_directions'
      };

      if (widget.address == null) {
        context.read<AddressBloc>().add(AddAddress(payload));
      } else {
        context.read<AddressBloc>().add(UpdateAddress(encryptedId: widget.address!.encryptedId, payload: payload));
      }
    }
  }
}
