import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/prescription_repository.dart';

class DoctorScanPrescriptionScreen extends StatefulWidget {
  const DoctorScanPrescriptionScreen({super.key});

  @override
  State<DoctorScanPrescriptionScreen> createState() => _DoctorScanPrescriptionScreenState();
}

class _DoctorScanPrescriptionScreenState extends State<DoctorScanPrescriptionScreen> {
  bool _isScanning = false;
  bool _scanCompleted = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final prescriptionRepository = context.read<PrescriptionRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner une Ordonnance"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isScanning)
              const CircularProgressIndicator()
            else if (_scanCompleted && _message != null)
              Text(_message!)
            else
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isScanning = true;
                    _scanCompleted = false;
                    _message = null;
                  });

                  // Simulez un "scan" sans OCR, juste un Future.delayed
                  await Future.delayed(const Duration(seconds: 2));

                  // Données factices de prescription après "scan"
                  final prescriptionData = {
                    'patientId': 'patient123',
                    'medications': [
                      {'name': 'Paracetamol', 'dosage': '500mg', 'duration': '5 days'},
                    ],
                    'scannedAt': DateTime.now().toIso8601String(),
                  };

                  // Ajout de la prescription via le repository
                  final success = await prescriptionRepository.addPrescription('patient123', prescriptionData);

                  setState(() {
                    _isScanning = false;
                    _scanCompleted = true;
                    _message = success 
                      ? "Scan effectué et prescription ajoutée avec succès !" 
                      : "Échec de l'ajout de la prescription.";
                  });
                },
                child: const Text("Scanner une ordonnance"),
              ),
          ],
        ),
      ),
    );
  }
}