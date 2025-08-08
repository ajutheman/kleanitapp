import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/color_data.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../model/address.dart';
import 'address_form_screen.dart';

class AddressListScreen extends StatelessWidget {
  final bool isSelectionMode;

  const AddressListScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
          ), // or your custom `icon`
        ),
        title: Text(isSelectionMode ? 'Select Address' : 'My Address'),
        actions: [
          // if (!isSelectionMode)
          //   IconButton(
          //     icon: const Icon(Icons.add_location_alt),
          //     tooltip: 'Add New Address',
          //     onPressed: () => _navigateToAddressForm(context),
          //   )
        ],
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressInitial || state is AddressActionSuccess) {
            Future.microtask(
                () => context.read<AddressBloc>().add(FetchAddresses()));
            return const SizedBox.shrink();
          } else if (state is AddressLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          } else if (state is AddressLoaded) {
            // final addresses = state.addresses;
            final addresses =
                state.addresses.where((a) => a.isDeleted == 0).toList();

            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text("No addresses found",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddressForm(context),
                      icon: const Icon(Icons.add_location_alt,
                          color: Colors.white),
                      label: const Text('Add New Address'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                      ),
                    )
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(context, address);
              },
            );
          } else if (state is AddressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text("Error Loading Addresses",
                      style: TextStyle(color: Colors.red[600], fontSize: 18)),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AddressBloc>().add(FetchAddresses());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(3)), // 👈 square shape
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  )
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddressForm(context),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Address'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, CustomerAddress address) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          // Return the selected address ID when in selection mode
          Navigator.pop(context, address);
        } else {
          _navigateToAddressForm(context, address: address);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: address.isDefault == 1
              ? BorderSide(color: primaryColor.withOpacity(.3), width: 2)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.buildingName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${address.flatNumber}, ${address.streetName}',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    Text(
                      '${address.isDeleted}, ${address.streetName}',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    Text(
                      address.area,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${address.emirate}, ${address.area}',
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (address.isDefault == 1)
                    Chip(
                      label: const Text(
                        "Default",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor.withOpacity(.8),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Address',
                    onPressed: () =>
                        _navigateToAddressForm(context, address: address),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    tooltip: 'Delete Address',
                    onPressed: () => _confirmDelete(context, address),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddressForm(BuildContext context,
      {CustomerAddress? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(address: address),
      ),
    );
    if (result == true) {
      context.read<AddressBloc>().add(FetchAddresses());
    }
  }

  void _confirmDelete(BuildContext context, CustomerAddress address) async {
    final bloc = context.read<AddressBloc>();

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure want to delete your address permanently?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        bloc.add(DeleteAddress(address.encryptedId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Deleting address..."),
              backgroundColor: Colors.orange),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
