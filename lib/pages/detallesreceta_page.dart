import 'package:flutter/material.dart';
import 'package:proyectodam/services/fs_service.dart';

class DetallesrecetaPage extends StatelessWidget {
  final Map<String, dynamic> receta;
  final String recetaId;  // Recibir el ID del documento de Firebase
  final FsService fsService = FsService();  // Instancia de Firestore

  DetallesrecetaPage({required this.receta, required this.recetaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receta['nombre'] ?? "Detalles de la receta"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarEliminacion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${receta['nombre'] ?? 'Sin nombre'}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Autor: ${receta['autor'] ?? 'Desconocido'}"),
            SizedBox(height: 10),
            Text("Categoría: ${receta['categoria'] ?? 'Sin categoría'}"),
            SizedBox(height: 10),
            Text("Instrucciones:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(receta['instrucciones'] ?? "Sin instrucciones"),
          ],
        ),
      ),
    );
  }

  // Confirmar eliminación de la receta
  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta receta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                
                  // Llamar al método para eliminar la receta con su ID
                  await fsService.borrarReceta(recetaId);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receta eliminada con éxito")));
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
              
                
              },
            ),
          ],
        );
      },
    );
  }
}
