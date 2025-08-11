import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc(this.addressRepository) : super(AddressInitial()) {
    on<FetchAddresses>(_onFetchAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  Future<void> _onFetchAddresses(FetchAddresses event, Emitter emit) async {
    emit(AddressLoading());
    try {
      final addresses = await addressRepository.fetchAddressList();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(AddAddress event, Emitter emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.saveAddress(event.payload);
      emit(AddressActionSuccess());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onUpdateAddress(UpdateAddress event, Emitter emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.updateAddress(event.encryptedId, event.payload);
      emit(AddressActionSuccess());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(DeleteAddress event, Emitter emit) async {
    emit(AddressLoading());
    try {
      final message = await addressRepository.deleteAddress(event.encryptedId);
      emit(AddressActionSuccess());
      // Optional: you can use context.read<>().add() here if needed
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
