import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  // Garantiza que los bindings estén listos antes de manipular canales nativos
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Forzar orientación horizontal (Landscape) de forma estricta
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Activar modo inmersivo de pantalla completa (oculta barras de estado/navegación)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Videojuego Web',
      home: GameContainerScreen(),
    );
  }
}

class GameContainerScreen extends StatefulWidget {
  const GameContainerScreen({super.key});

  @override
  State<GameContainerScreen> createState() => _GameContainerScreenState();
}

class _GameContainerScreenState extends State<GameContainerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 3. Inicializar el controlador del WebView apuntando al asset local
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Ocultar indicador de carga una vez renderizado el juego
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/game/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenedor principal del videojuego
          WebViewWidget(controller: _controller),

          // Pantalla de carga sutil mientras arranca el DOM/JS
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

