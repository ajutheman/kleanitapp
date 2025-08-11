import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../repo/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<CalculateOrder>(_onCalculateOrder);
    on<PlaceOrder>(_placeOrder);
    on<FetchSchedules>(_fetchSchedules);
  }

  Future<void> _onCalculateOrder(CalculateOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final result = await orderRepository.calculateOrder(event.cartIds, event.coupon, subscriptionFrequency: event.subscriptionFrequency);
      emit(OrderLoaded(orderCalculation: result));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _placeOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final response = await orderRepository.placeOrder(
        cartIds: event.cartIds,
        addressId: event.addressId,
        scheduleTime: event.scheduleTime,
        subscriptionFeq: event.subscriptionFeq,
        notes: event.notes,
        paymentMethod: event.paymentMethod,
        bedrooms: event.bedrooms,
        // bathrooms: event.bathrooms,
        beds: event.beds,
        sofaBeds: event.sofaBeds,
        occupancy: event.occupancy,
        petsPresent: event.petsPresent,
        withLinen: event.withLinen,
        withSupplies: event.withSupplies,
        checkInTime: event.checkInTime,
        checkOutTime: event.checkOutTime,
        doorAccessCode: event.doorAccessCode,
        date: DateFormat('yyyy-MM-dd').format(event.date),
        coupon: event.coupon,
        typeOfCleaning: event.typeOfCleaning,
        nextGuestCheckInTime: event.nextGuestCheckInTime,
        wifiAccessCode: event.wifiAccessCode,
      );
      emit(OrderPlaced(orderResponse: response));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _fetchSchedules(FetchSchedules event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final schedules = await orderRepository.fetchSchedules(date: DateFormat("yyyy-MM-dd").format(event.date));
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }
}
