# 🛒 MercaFlash — App de Reducción del Desperdicio Alimentario (Mercadona)

Aplicación móvil multiplataforma desarrollada en **Flutter** y **Supabase** diseñada como propuesta de innovación para **Mercadona**. 

**MercaFlash** conecta a los consumidores con productos rebajados próximos a su fecha de caducidad (sección *Flash*) y les sugiere **recetas paso a paso** que aprovechan esos mismos ingredientes, fomentando el ahorro doméstico y reduciendo el desperdicio alimentario en tienda.

![Prototipo Visual de MercaFlash](Guía%20de%20estilos/Imagen_prototipo.jpeg)

---

## 📱 Funcionalidades y Pantallas (`lib/screens/`)

* **Sección Flash (`flash_page.dart`):** Catálogo en tiempo real de productos con descuento por proximidad de caducidad y filtrado por alérgenos (gluten, lácteos, frutos secos, huevo, pescado, etc.).
* **Recomendador de Recetas (`detalle_receta_page.dart`):** Fichas detalladas de 20 recetas vinculadas directamente a los productos rebajados disponibles en el supermercado.
* **Experiencia Completa de Compra (`home_page.dart`, `categorias_page.dart`, `productos_categoria_page.dart`, `buscar_page.dart`):** Navegación por las 24 categorías del supermercado, buscador de artículos y validación de tienda por código postal (`postal_code_page.dart`).
* **Gestión de Carrito y Usuario (`carrito_page.dart`, `cuenta_page.dart`, `welcome_page.dart`):** Carrito de compra dinámico (`cart_widgets.dart`) y perfil de cliente conectado en la nube.

---

## 🛠️ Arquitectura y Stack Tecnológico

El código fuente dentro de `FlutterProjects/lib/` sigue una arquitectura modular limpia:

* **`app/`:** Configuración global y navegación principal (`mercadona_app.dart`, `main_screen.dart`).
* **`models/`:** Modelos de datos tipados (`producto_model.dart`).
* **`services/`:** Integración con **Supabase** (`supabase_service.dart`) para consultas de inventario, productos en oferta y recetas.
* **`theme/` & `widgets/`:** Sistema de diseño corporativo (`app_theme.dart`) y componentes reutilizables (`product_cards.dart`, `ui_components.dart`, `cart_widgets.dart`).

---

## 📂 Estructura del Repositorio

```text
mercaflash-app/
├── FlutterProjects/
│   ├── lib/
│   │   ├── app/             # Inicialización y contenedor principal de navegación
│   │   ├── models/          # Modelo de datos de productos (producto_model.dart)
│   │   ├── screens/         # 10 pantallas de la aplicación (Flash, Recetas, Carrito, Categorías...)
│   │   ├── services/        # Cliente y lógica de conexión con Supabase (supabase_service.dart)
│   │   ├── theme/           # Paleta corporativa y tipografías (app_theme.dart)
│   │   ├── widgets/         # Tarjetas de producto, carrito y componentes UI
│   │   └── main.dart        # Punto de entrada de la aplicación
│   ├── assets/              # Fuentes (Roboto/RV), iconos de 24 categorías y 7 alérgenos
│   └── pubspec.yaml         # Dependencias y declaración de recursos de Flutter
├── Guía de estilos/         # Manual de identidad visual (PDF), prototipo UI y recursos gráficos
├── Recetas/                 # Dossier con las 20 recetas e ingredientes (PDF)
├── Guía Scrums/             # Entregables de seguimiento de los Sprints (Sprint 1 a Sprint Final)
├── Encuesta/                # Dataset CSV y análisis estadístico del estudio de mercado previo
└── README.md                # Documentación general del proyecto