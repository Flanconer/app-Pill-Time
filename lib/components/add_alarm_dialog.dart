import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';

class AddAlarmDialog extends StatefulWidget {
  const AddAlarmDialog({super.key});

  @override
  State<AddAlarmDialog> createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<AddAlarmDialog> {
  final TextEditingController _intervalController = TextEditingController();
  String _intervalUnit = 'minutos';
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Variables para el inventario
  List<Map<String, dynamic>> _medications = [];
  String? _selectedMed;

  @override
  void initState() {
    super.initState();
    _loadInventory(); // Cargar los medicamentos al abrir el diálogo
  }

  Future<void> _loadInventory() async {
    final meds = await DatabaseHelper.getMedications();
    setState(() {
      _medications = meds;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartDate ? now : (_startDate ?? now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFDEEEF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: const Center(
        child: Text('Configurar Alarma', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Menú desplegable para seleccionar medicamento del inventario
            DropdownButtonFormField<String>(
              value: _selectedMed,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text('Selecciona el medicamento', style: TextStyle(fontSize: 14)),
              items: _medications.map((med) {
                return DropdownMenuItem<String>(
                  value: med['name'].toString(),
                  child: Text(med['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMed = value;
                });
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Cada', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _intervalUnit,
                  items: ['minutos', 'horas'].map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _intervalUnit = newValue!),
                  underline: Container(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDateButton(
              'Fecha inicio: ${_startDate != null ? _dateFormat.format(_startDate!) : "xxxx-xx-xx"}',
              () => _selectDate(context, true),
            ),
            const SizedBox(height: 10),
            _buildDateButton(
              'Fecha fin: ${_endDate != null ? _dateFormat.format(_endDate!) : "xxxx-xx-xx"}',
              () => _selectDate(context, false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 1,
          ),
          onPressed: () {
            // Empaquetamos los datos y los enviamos al HomeScreen en lugar de guardar aquí
            if (_selectedMed != null && _intervalController.text.isNotEmpty) {
              Navigator.pop(context, {
                'med_name': _selectedMed,
                'interval': '${_intervalController.text} $_intervalUnit',
                'start_date': _startDate != null ? _dateFormat.format(_startDate!) : 'N/A',
                'end_date': _endDate != null ? _dateFormat.format(_endDate!) : 'N/A',
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            }
          },
          child: const Text('Programar'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }

  Widget _buildDateButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.grey, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}