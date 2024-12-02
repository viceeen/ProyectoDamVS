import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectodam/pages/agregar_receta_page.dart';
import 'package:proyectodam/pages/detallesreceta_page.dart';
import 'package:proyectodam/services/fs_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final User user;
  final FsService fsService = FsService();

  HomePage({required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar esta receta?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _eliminarReceta(BuildContext context, String id, String recetaUserId) async {
    if (user.uid != recetaUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No tienes permiso para eliminar esta receta.')),
      );
      return;
    }

    bool confirmacion = await _showDeleteConfirmationDialog(context);
    if (confirmacion) {
      try {
        await fsService.borrarReceta(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta eliminada con éxito.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la receta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (user.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 15,
              ),
            const SizedBox(width: 10),
            Text("Bienvenido ${user.displayName ?? "Usuario"}"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fsService.recetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay recetas disponibles."));
          }

          final recetas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              final receta = recetas[index].data() as Map<String, dynamic>;
              final recetaId = recetas[index].id;
              final recetaUserId = receta['authorId'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(receta['nombre'] ?? "Sin nombre"),
                  subtitle: Text("Autor: ${receta['autor'] ?? "Desconocido"}"),
                  leading: receta['imagen'] != null
                      ? Image.asset(
                          receta['imagen'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallesrecetaPage(
                          receta: receta,
                          recetaId: recetaId,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _eliminarReceta(context, recetaId, recetaUserId),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarRecetaPage(
                autor: user.displayName ?? "Anónimo",
                agregarRecetaCallback: (nombre, instrucciones, autor, categoria, imagen) {
                  // Guardar receta en Firebase
                  FirebaseFirestore.instance.collection('recetas').add({
                    'nombre': nombre,
                    'instrucciones': instrucciones,
                    'autor': autor,
                    'categoria': categoria,
                    'imagen': imagen,
                    'authorId': user.uid,  // Asegúrate de asociar el ID del autor
                  }).then((_) {
                    // Regresar a la página anterior después de agregar la receta
                    Navigator.pop(context);
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al agregar la receta: $e')),
                    );
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
