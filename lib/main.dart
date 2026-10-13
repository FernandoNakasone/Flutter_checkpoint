import 'package:flutter/material.dart';
import 'services/holiday_service.dart';
import 'services/reservation_manager.dart';
import 'ui/screens/reservation_screen.dart';

void main() {
  final holidayService = FakeHolidayService();

  final reservationManager = ReservationManager(
    holidayService: holidayService,
    baseHourlyRate: 10.0,
  );

  runApp(SpotReserveApp(manager: reservationManager));
}

class SpotReserveApp extends StatelessWidget {
  final ReservationManager manager;

  const SpotReserveApp({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotReserve - Estacionamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: ReservationScreen(manager: manager),
    );
  }
}
