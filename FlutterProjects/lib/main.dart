import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Modelos, Servicios y Tema ---
import 'models/producto_model.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

// --- Pantallas (Screens) ---
import 'screens/home_page.dart';
import 'screens/categorias_page.dart';
import 'screens/buscar_page.dart';
import 'screens/carrito_page.dart';
import 'screens/cuenta_page.dart';
import 'screens/flash_page.dart';
import 'screens/productos_categoria_page.dart';
import 'screens/detalle_receta_page.dart';

// --- Widgets (Componentes) ---
import 'widgets/cart_widgets.dart'; // Para el CartNavIcon del menú inferior

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://dpawbhtkvspqukvmewuk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXdiaHRrdnNwcXVrdm1ld3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDMzMTAsImV4cCI6MjA5MzA3OTMxMH0.iVeTff57W8OHPo9p8VwDwH9rRtlKeASpaUZu4Fj4yj4',
  );

  runApp(const MercadonaApp());
}

class MercadonaApp extends StatelessWidget {
  const MercadonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

enum SpecialPage { flash, category, recipe }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SupabaseService _service = SupabaseService();

  int _selectedIndex = 0;
  bool _cargando = true;
  bool _sesionIniciada = false;
  String _nombreUsuario = 'Jordi';

  SpecialPage? _specialPage;
  String? _categoriaSeleccionada;
  Receta? _recetaSeleccionada;

  List<Producto> _productos = [];
  List<Producto> _productosFlash = [];
  List<Receta> _recetas = [];
  List<CategoriaMercadona> _categorias = [];

  final Map<String, int> _carrito = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      print('⏳ Iniciando carga desde Supabase...');
      final productos = await _service.obtenerProductos();
      print('✅ Productos cargados: ${productos.length}');
      
      final productosFlash = await _service.obtenerProductosProximosACaducar();
      final recetas = await _service.obtenerRecetasSugeridas();
      final categorias = await _service.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _productosFlash = productosFlash;
        _recetas = recetas;
        _categorias = categorias;
        _cargando = false;
      });
    } catch (e, stacktrace) {
      print('❌ ERROR FATAL CARGANDO DATOS: $e');
      print(stacktrace);
      setState(() => _cargando = false); 
    }
  }

  int get _totalUnidadesCarrito {
    return _carrito.values.fold(0, (total, cantidad) => total + cantidad);
  }

  double get _totalCarrito {
    double total = 0;
    for (final entry in _carrito.entries) {
      final producto = _productoPorId(entry.key);
      if (producto != null) total += producto.precio * entry.value;
    }
    return total;
  }

  Producto? _productoPorId(String id) {
    for (final producto in _productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }

  void _cambiarPantalla(int index) {
    setState(() {
      _selectedIndex = index;
      _specialPage = null;
      _categoriaSeleccionada = null;
      _recetaSeleccionada = null;
    });
  }

  void _abrirFlash() {
    setState(() {
      _specialPage = SpecialPage.flash;
      _categoriaSeleccionada = null;
      _recetaSeleccionada = null;
    });
  }

  void _abrirCategoria(String categoria) {
    if (categoria == 'Próximos a caducar') {
      _abrirFlash();
      return;
    }

    setState(() {
      _specialPage = SpecialPage.category;
      _categoriaSeleccionada = categoria;
      _recetaSeleccionada = null;
    });
  }

  void _abrirReceta(Receta receta) {
    setState(() {
      _specialPage = SpecialPage.recipe;
      _recetaSeleccionada = receta;
    });
  }

  void _volver() {
    setState(() {
      if (_specialPage == SpecialPage.recipe) {
        _specialPage = SpecialPage.flash;
        _recetaSeleccionada = null;
      } else {
        _specialPage = null;
        _categoriaSeleccionada = null;
        _recetaSeleccionada = null;
      }
    });
  }

  void _sumarProducto(Producto producto) {
    setState(() {
      _carrito.update(producto.id, (cantidad) => cantidad + 1, ifAbsent: () => 1);
    });
    _mostrarSnack('${producto.nombre} añadido al carrito');
  }

  void _restarProducto(Producto producto) {
    setState(() {
      final cantidadActual = _carrito[producto.id] ?? 0;
      if (cantidadActual <= 1) {
        _carrito.remove(producto.id);
      } else {
        _carrito[producto.id] = cantidadActual - 1;
      }
    });
  }

  void _vaciarCarrito() {
    setState(_carrito.clear);
    _mostrarSnack('Carrito vaciado');
  }

  void _iniciarSesion(String nombre) {
    setState(() {
      _sesionIniciada = true;
      _nombreUsuario = nombre.trim().isEmpty ? 'Jordi' : nombre.trim();
    });
    _mostrarSnack('Sesión iniciada correctamente');
  }

  void _cerrarSesion() {
    setState(() {
      _sesionIniciada = false;
      _nombreUsuario = 'Jordi';
    });
  }

  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.green,
          duration: const Duration(milliseconds: 1100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    Widget body;
    if (_specialPage == SpecialPage.recipe && _recetaSeleccionada != null) {
      body = DetalleRecetaPage(receta: _recetaSeleccionada!, onBack: _volver);
    } else if (_specialPage == SpecialPage.flash) {
      body = FlashPage(
        productos: _productosFlash,
        recetas: _recetas,
        carrito: _carrito,
        onAdd: _sumarProducto,
        onRemove: _restarProducto,
        onBack: _volver,
        onOpenRecipe: _abrirReceta,
      );
    } else if (_specialPage == SpecialPage.category && _categoriaSeleccionada != null) {
      body = ProductosCategoriaPage(
        categoria: _categoriaSeleccionada!,
        productos: _productos
            .where((producto) => producto.categoria == _categoriaSeleccionada)
            .toList(),
        carrito: _carrito,
        onAdd: _sumarProducto,
        onRemove: _restarProducto,
        onBack: _volver,
      );
    } else {
      body = IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            productos: _productos,
            carrito: _carrito,
            totalUnidades: _totalUnidadesCarrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
            onOpenFlash: _abrirFlash,
          ),
          CategoriasPage(
            categorias: _categorias,
            onOpenCategory: (categoria) => _abrirCategoria(categoria.nombre),
          ),
          BuscarPage(
            productos: _productos,
            carrito: _carrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
          ),
          CarritoPage(
            productos: _productos,
            carrito: _carrito,
            total: _totalCarrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
            onClear: _vaciarCarrito,
          ),
          CuentaPage(
            sesionIniciada: _sesionIniciada,
            nombreUsuario: _nombreUsuario,
            onLogin: _iniciarSesion,
            onLogout: _cerrarSesion,
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _cambiarPantalla,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categorías',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: CartNavIcon(count: _totalUnidadesCarrito, selected: false),
            selectedIcon: CartNavIcon(count: _totalUnidadesCarrito, selected: true),
            label: 'Lista',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}