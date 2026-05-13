import '../models/producto_model.dart';

class SupabaseService {
  /*
    Servicio preparado para sustituir los datos demo por base de datos.

    Cuando tengáis Supabase/API/SQLite, se cambian estas funciones para consultar
    las tablas reales. La interfaz, carrito, login visual y navegación no dependen
    de datos escritos directamente en las pantallas.
  */

  Future<List<Producto>> obtenerProductos() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return productosDemo;
  }

  Future<List<Producto>> obtenerProductosProximosACaducar() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return productosDemo.where((producto) => producto.esFlash).toList();
  }

  Future<List<Receta>> obtenerRecetasSugeridas() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return recetasDemo;
  }

  Future<List<CategoriaMercadona>> obtenerCategorias() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return categoriasDemo;
  }
}

const List<CategoriaMercadona> categoriasDemo = [
  CategoriaMercadona(id: 'agua', nombre: 'Agua y refrescos', emoji: '🥤'),
  CategoriaMercadona(id: 'aperitivos', nombre: 'Aperitivos', emoji: '🍌'),
  CategoriaMercadona(id: 'arroz', nombre: 'Arroz, legumbres y pasta', emoji: '🍚'),
  CategoriaMercadona(id: 'azucar', nombre: 'Azúcar, caramelos y chocolate', emoji: '🍫'),
  CategoriaMercadona(id: 'bebe', nombre: 'Bebé', emoji: '🍼'),
  CategoriaMercadona(id: 'bodega', nombre: 'Bodega', emoji: '🍾'),
  CategoriaMercadona(id: 'cacao', nombre: 'Cacao, café e infusiones', emoji: '☕'),
  CategoriaMercadona(id: 'carne', nombre: 'Carne', emoji: '🥩'),
  CategoriaMercadona(id: 'cereales', nombre: 'Cereales y galletas', emoji: '🍪'),
  CategoriaMercadona(id: 'charcuteria', nombre: 'Charcutería y quesos', emoji: '🧀'),
  CategoriaMercadona(id: 'congelados', nombre: 'Congelados', emoji: '❄️'),
  CategoriaMercadona(id: 'conservas', nombre: 'Conservas, caldos y cremas', emoji: '🥫'),
  CategoriaMercadona(id: 'verdura', nombre: 'Fruta y verdura', emoji: '🥬'),
  CategoriaMercadona(id: 'lacteos', nombre: 'Leche, huevos y yogures', emoji: '🥛'),
  CategoriaMercadona(id: 'flash', nombre: 'Próximos a caducar', emoji: '⚡'),
];

const List<Producto> productosDemo = [
  Producto(
    id: 'p1',
    nombre: 'Papilla manzana, mango, frambuesa, plátano y papaya',
    cantidad: '1 ud. (120 g)',
    categoria: 'Bebé',
    subcategoria: 'Bebé',
    precio: 0.90,
    emoji: '🧃',
    esNovedad: true,
    descripcion: 'Producto recién añadido al catálogo.',
  ),
  Producto(
    id: 'p2',
    nombre: 'Cocktail tostado con sal Hacendado',
    cantidad: 'Paquete 300 g',
    categoria: 'Aperitivos',
    subcategoria: 'Frutos secos',
    precio: 2.80,
    emoji: '🥜',
    esNovedad: true,
  ),
  Producto(
    id: 'p3',
    nombre: 'Vino tinto roble Pata Negra DO Ribera del Duero',
    cantidad: 'Botella 750 ml',
    categoria: 'Bodega',
    precio: 3.25,
    emoji: '🍷',
  ),
  Producto(
    id: 'p4',
    nombre: 'Zanahorias',
    cantidad: 'Paquete 1 kg',
    categoria: 'Fruta y verdura',
    precio: 1.20,
    precioAnterior: 1.85,
    emoji: '🥕',
    esBajadaPrecio: true,
  ),
  Producto(
    id: 'p5',
    nombre: 'Patatas fritas clásicas Hacendado',
    cantidad: 'Paquete 7 bolsas',
    categoria: 'Aperitivos',
    precio: 1.80,
    precioAnterior: 1.90,
    emoji: '🍟',
    esBajadaPrecio: true,
  ),
  Producto(
    id: 'p6',
    nombre: 'Protector solar Sun Med FPS 50+',
    cantidad: 'Spray 250 ml',
    categoria: 'Cuidado facial y corporal',
    precio: 7.50,
    emoji: '🧴',
  ),
  Producto(
    id: 'p7',
    nombre: 'Protector solar infantil pediátrico Sun Med FPS 50+',
    cantidad: 'Spray 250 ml',
    categoria: 'Cuidado facial y corporal',
    precio: 7.50,
    emoji: '🧴',
  ),
  Producto(
    id: 'p8',
    nombre: 'Palomitas de maíz sabor mantequilla Hacendado',
    cantidad: 'Pack 3 uds.',
    categoria: 'Aperitivos',
    precio: 1.20,
    emoji: '🍿',
  ),
  Producto(
    id: 'p9',
    nombre: 'Cerveza Radler Steinburg con zumo de limón',
    cantidad: 'Pack 12 latas',
    categoria: 'Bodega',
    precio: 4.92,
    emoji: '🍋',
  ),
  Producto(
    id: 'p10',
    nombre: 'Coulant de chocolate Hacendado',
    cantidad: '2 uds.',
    categoria: 'Congelados',
    precio: 2.20,
    emoji: '🍫',
  ),
  Producto(
    id: 'f1',
    nombre: 'Yogur natural Hacendado',
    cantidad: 'Pack 4 unidades',
    categoria: 'Leche, huevos y yogures',
    subcategoria: 'Yogures',
    precio: 0.95,
    precioAnterior: 1.35,
    diasCaducidad: 0,
    emoji: '🥛',
    esFlash: true,
    descripcion: 'Producto próximo a caducar con descuento especial.',
  ),
  Producto(
    id: 'f2',
    nombre: 'Pechuga de pollo fileteada',
    cantidad: 'Bandeja 550 g',
    categoria: 'Carne',
    subcategoria: 'Pollo',
    precio: 3.75,
    precioAnterior: 4.80,
    diasCaducidad: 1,
    emoji: '🍗',
    esFlash: true,
  ),
  Producto(
    id: 'f3',
    nombre: 'Espinacas frescas',
    cantidad: 'Bolsa 200 g',
    categoria: 'Fruta y verdura',
    subcategoria: 'Verdura',
    precio: 0.89,
    precioAnterior: 1.25,
    diasCaducidad: 2,
    emoji: '🥬',
    esFlash: true,
  ),
  Producto(
    id: 'f4',
    nombre: 'Tomate maduro',
    cantidad: 'Malla 1 kg',
    categoria: 'Fruta y verdura',
    subcategoria: 'Verdura',
    precio: 1.15,
    precioAnterior: 1.65,
    diasCaducidad: 3,
    emoji: '🍅',
    esFlash: true,
  ),
  Producto(
    id: 'f5',
    nombre: 'Pan de molde integral',
    cantidad: 'Paquete 460 g',
    categoria: 'Cereales y galletas',
    subcategoria: 'Pan',
    precio: 1.05,
    precioAnterior: 1.40,
    diasCaducidad: 1,
    emoji: '🍞',
    esFlash: true,
  ),
];

const List<Receta> recetasDemo = [
  Receta(
    id: 'r1',
    titulo: 'Tortilla de espinacas y pollo',
    etiqueta: 'Usa 3 productos a punto de caducar',
    descripcion: 'Aprovecha espinacas, pechuga de pollo y yogur natural.',
    tiempoMinutos: 15,
    dificultad: 'Fácil',
    raciones: 2,
    emoji: '🥘',
    ingredientes: [
      IngredienteReceta(
        nombre: 'Espinacas frescas',
        cantidad: '200 g',
        disponible: true,
        diasCaducidad: 2,
      ),
      IngredienteReceta(
        nombre: 'Pechuga de pollo',
        cantidad: '200 g',
        disponible: true,
        diasCaducidad: 1,
      ),
      IngredienteReceta(
        nombre: 'Yogur natural',
        cantidad: '2 cucharadas',
        disponible: true,
        diasCaducidad: 0,
      ),
      IngredienteReceta(nombre: 'Huevos', cantidad: '4', disponible: false),
      IngredienteReceta(
        nombre: 'Aceite de oliva virgen extra',
        cantidad: 'al gusto',
        disponible: false,
      ),
    ],
    pasos: [
      'Lava y saltea las espinacas en una sartén.',
      'Añade el pollo en tiras y cocina hasta que quede dorado.',
      'Bate los huevos con el yogur y mezcla todo.',
      'Cuaja la tortilla por ambos lados y sirve caliente.',
    ],
  ),
  Receta(
    id: 'r2',
    titulo: 'Tostadas con tomate y yogur',
    etiqueta: 'Cena rápida de aprovechamiento',
    descripcion: 'Aprovecha tomate maduro, pan y yogur natural.',
    tiempoMinutos: 10,
    dificultad: 'Muy fácil',
    raciones: 2,
    emoji: '🍞',
    ingredientes: [
      IngredienteReceta(
        nombre: 'Tomate maduro',
        cantidad: '2 unidades',
        disponible: true,
        diasCaducidad: 3,
      ),
      IngredienteReceta(
        nombre: 'Pan de molde integral',
        cantidad: '4 rebanadas',
        disponible: true,
        diasCaducidad: 1,
      ),
      IngredienteReceta(
        nombre: 'Yogur natural',
        cantidad: '1 unidad',
        disponible: true,
        diasCaducidad: 0,
      ),
      IngredienteReceta(nombre: 'Sal', cantidad: 'al gusto', disponible: false),
    ],
    pasos: [
      'Tuesta el pan hasta que quede crujiente.',
      'Ralla el tomate y repártelo sobre las tostadas.',
      'Usa el yogur como salsa fresca con sal y aceite.',
    ],
  ),
];
