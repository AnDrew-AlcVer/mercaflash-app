# 🛒 MercaFlash — App de Reducción del Desperdicio Alimentario

Aplicación móvil multiplataforma desarrollada en **Flutter** con backend en **Supabase** orientada a combatir el desperdicio de alimentos en supermercados. 

**MercaFlash** conecta a los consumidores con productos rebajados próximos a su fecha de caducidad y les sugiere **recetas personalizadas** basadas en esos mismos ingredientes para incentivar su compra y aprovechamiento en casa.

---

## 📱 Funcionalidades Principales

* **Catálogo de Productos Próximos a Caducar:** Visualización de artículos rebajados organizados por categorías y cercanía a su fecha de vencimiento.
* **Motor de Recomendación de Recetas:** Sugerencia de platos paso a paso que emplean como base los productos en oferta seleccionados por el usuario.
* **Diseño Centrado en el Usuario (UX/UI):** Interfaz respaldada por un estudio previo de mercado (encuestas a consumidores) y una guía de estilos propia.

---

## 🛠️ Stack Tecnológico y Metodología

* **Frontend Móvil:** Flutter & Dart (`FlutterProjects/`)
* **Backend & Base de Datos:** Supabase (Autenticación, base de datos relacional y almacenamiento de recursos)
* **Diseño UX/UI:** Guía de estilos y prototipado visual (`Guía de estilos/`)
* **Gestión Ágil del Proyecto:** Metodología **Scrum** y seguimiento de *sprints* e historias de usuario mediante **Jira** (`Guía Scrums/`, `Espacio Jira/`)

---

## 📂 Estructura del Repositorio

```text
mercaflash-app/
├── FlutterProjects/    # Código fuente de la aplicación móvil en Flutter
├── Recetas/            # Base de datos de recetas, ingredientes y recursos gráficos
├── Guía de estilos/    # Identidad visual, paleta de colores y componentes UI
├── Guía Scrums/        # Documentación de Sprints y entregables de la metodología ágil
├── Encuesta/           # Estudio de mercado y validación con usuarios reales
└── README.md           # Documentación general del proyecto