import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Inicia sesión con Google
  Future<UserCredential> signInWithGoogle() async {
    // Desconectar usuario previo (si existe) para forzar selección de cuenta
    await _googleSignIn.signOut();

    // Desplegar la lista de cuentas para seleccionar una nueva
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Verificar que el usuario haya seleccionado una cuenta
    if (googleUser == null) {
      throw Exception("El inicio de sesión fue cancelado por el usuario.");
    }

    // Obtener las credenciales de autenticación de Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Crear las credenciales de Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Autenticar con Firebase
    return await _auth.signInWithCredential(credential);
  }

  /// Maneja la acción de iniciar sesión
  Future<void> _signIn(BuildContext context) async {
    try {
      UserCredential userCredential = await signInWithGoogle();

      // Si la autenticación es exitosa, redirige al HomePage
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: userCredential.user!)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título "NaturalEats"
              Text(
                "NaturalEats",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Ícono de manzana
              Icon(
                MdiIcons.foodApple,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 50),
              // Botón de inicio de sesión con Google
              ElevatedButton.icon(
                onPressed: () => _signIn(context),
                icon: Icon(
                  Icons.login,
                  color: Colors.green,
                ),
                label: Text(
                  "Iniciar sesión con Google",
                  style: TextStyle(color: Colors.green),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
