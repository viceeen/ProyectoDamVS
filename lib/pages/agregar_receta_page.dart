import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarRecetaPage extends StatefulWidget {
  final String autor; // Nombre del usuario que crea la receta
  final Function agregarRecetaCallback; // Callback para agregar receta

  AgregarRecetaPage({required this.autor, required this.agregarRecetaCallback});

  @override
  _AgregarRecetaPageState createState() => _AgregarRecetaPageState();
}

class _AgregarRecetaPageState extends State<AgregarRecetaPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  String? _categoriaSeleccionada;
  String? _imagenSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Receta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre de la receta"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(labelText: "Instrucciones"),
            ),
            const SizedBox(height: 10),
           StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categoria').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                // Mapeamos las categorías a los elementos del Dropdown
                List<DropdownMenuItem<String>> items = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc['nombre'], // Usamos el campo 'nombre' para la selección
                    child: Text(doc['nombre']),
                    onTap: () {
                      setState(() {
                        // Guardamos la imagen de la categoría seleccionada
                        _imagenSeleccionada = doc['imagen'];
                      });
                    },
                  );
                }).toList();

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Categoría"),
                  value: _categoriaSeleccionada,
                  items: items, // Los items del Dropdown con las categorías
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value!;
                    });
                  },
                );
              }

              return const Text('No hay datos disponibles');
            },
          ),


            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    instructionsController.text.isNotEmpty &&
                    _categoriaSeleccionada != null &&
                    _imagenSeleccionada != null) {
                  // Si todos los campos están completos, llamamos al callback
                  widget.agregarRecetaCallback(
                    nameController.text,
                    instructionsController.text,
                    widget.autor,
                    _categoriaSeleccionada!,
                    _imagenSeleccionada!,
                  );
                  Navigator.pop(context);
                } else {
                  // Si algún campo está vacío, mostramos un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todos los campos son obligatorios.")),
                  );
                }
              },
              child: const Text("Agregar"),
            ),
          ],
        ),
      ),
    );
  }
}
