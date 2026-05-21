import 'package:flutter/material.dart';
import '../components/add_medication_dialog.dart';
import '../services/db_helper.dart'; // Importamos la base de datos local

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Ahora usamos 'dynamic' porque SQLite devuelve tipos variados (como el ID que es un número)
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadMedications(); // Cargamos los datos guardados al abrir la pantalla
  }

  // Función para leer la base de datos local
  Future<void> _loadMedications() async {
    final data = await DatabaseHelper.getMedications();
    setState(() {
      _inventory = data;
    });
  }

  // Función para abrir la ventana flotante y guardar en SQLite
  void _openAddMedicationDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddMedicationDialog(),
    );

    // Si el usuario guardó un medicamento
    if (result != null) {
      // 1. Guardamos en la base de datos local
      await DatabaseHelper.insertMedication({
        'name': result['name'],
        'presentation': result['presentation'],
        'quantity': result['quantity'],
        'unit': result['unit'],
      });

      // 2. Recargamos la lista para mostrar el nuevo elemento
      _loadMedications();
    }
  }

  // Función para eliminar un medicamento
  void _deleteMedication(int id) async {
    // 1. Borramos de SQLite usando su ID único
    await DatabaseHelper.deleteMedication(id);
    // 2. Recargamos la lista
    _loadMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inventario de Medicamentos',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      
      // Lista de medicamentos
      body: _inventory.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay medicamentos en el inventario.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final med = _inventory[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEEEF), // Fondo rosa claro de tu diseño
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: const Color(0xFFE8D5D5), width: 1), // Borde sutil
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    title: Text(
                      med['name'], // SQLite devuelve dynamic, ya no necesitamos el "!"
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${med['presentation']} - ${med['quantity']} ${med['unit']}',
                      style: const TextStyle(color: Color(0xFF5A4A42)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF5A4A42)),
                      // Pasamos el ID del medicamento a la función de borrar
                      onPressed: () => _deleteMedication(med['id']), 
                    ),
                  ),
                );
              },
            ),

      // Botón Flotante para agregar (+) con el diseño redondeado
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMedicationDialog,
        backgroundColor: const Color(0xFFFDEEEF), // Rosa claro
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Hace que sea un cuadrado redondeado
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}