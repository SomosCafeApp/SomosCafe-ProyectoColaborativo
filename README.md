## <h1 align="center"> SOMOS CAFE APP ☕ </h1>

Aplicación móvil y sistema de gestión para la cafetería SOMOS, orientado a digitalizar y optimizar los procesos de atención al cliente y administración del negocio.

**SOMOS CAFE APP** es una solución tecnológica desarrollada para modernizar la gestión de la cafetería SOMOS y mejorar la experiencia de sus clientes.

La aplicación permite a los usuarios consultar el menú, personalizar productos, realizar pedidos, consultar su historial, acumular puntos de fidelización, recibir notificaciones, participar en eventos y valorar productos o servicios.

Por otra parte, el sistema proporciona funcionalidades administrativas para gestionar productos, pedidos, promociones, eventos, usuarios, inventario y reportes.

## Stack tecnológico 💻

### Frontend

* **Flutter** — Desarrollo de la aplicación multiplataforma.
* **Dart** — Lenguaje de programación utilizado por Flutter.
* **HTTP/REST** — Comunicación entre la aplicación y el backend.
* **JSON** — Formato utilizado para el intercambio de información.

### Backend

* **Node.js** — Entorno de ejecución de JavaScript.
* **Express.js** — Framework utilizado para desarrollar la API REST.
* **Mongoose** — ODM para la comunicación y gestión de datos en MongoDB.
* **JWT (JSON Web Token)** — Autenticación y autorización de usuarios.
* **CORS** — Configuración de comunicación entre frontend y backend.

### Base de datos

* **MongoDB** — Sistema de gestión de base de datos NoSQL.
* **MongoDB Atlas** — Servicio utilizado para alojar la base de datos en la nube durante el desarrollo.

### Herramientas de desarrollo

* **Git** — Control de versiones.
* **GitHub** — Repositorio remoto y trabajo colaborativo.
* **Visual Studio Code** — Editor de código.
* **Android Studio** — Desarrollo, emulación y herramientas para Android.
* **Postman** — Pruebas y validación de la API REST.

---

## Características del proyecto 

### Gestión de usuarios

* Registro de nuevos usuarios.
* Inicio de sesión.
* Autenticación y autorización.
* Gestión del perfil.
* Gestión de preferencias.
* Historial de pedidos.

### Menú y productos

* Visualización del menú.
* Organización por categorías.
* Gestión de productos.
* Gestión de precios.
* Descripciones e imágenes de productos.
* Gestión de ingredientes.
* Personalización de productos.

### Pedidos

* Selección de productos.
* Carrito de compras.
* Personalización del pedido.
* Selección de método de entrega.
* Confirmación de pedidos.
* Consulta del historial de pedidos.

### Administración

* Gestión de productos.
* Gestión de usuarios.
* Gestión de promociones.
* Gestión de eventos.
* Gestión de pedidos.
* Gestión de inventario.
* Reportes de ventas.
* Reportes de inventario.
* Consulta de estadísticas.

### Fidelización

* Acumulación de puntos por compras.
* Consulta del saldo de puntos.
* Canje de puntos por beneficios.

### Promociones y eventos

* Creación y gestión de promociones.
* Publicación de ofertas.
* Gestión de eventos de la cafetería.
* Inscripción de usuarios a eventos.

### Notificaciones

* Notificaciones sobre promociones.
* Notificaciones sobre eventos.
* Actualizaciones del estado de los pedidos.
* Comunicación de novedades del sistema.

### Calificaciones y comentarios

* Calificación de productos.
* Calificación de servicios.
* Comentarios de los usuarios.
* Registro de retroalimentación.

### ChatBot

* Atención mediante chatbot.
* Respuestas a preguntas frecuentes.
* Recomendaciones de productos.
* Asistencia contextual al usuario.

# Instalación y configuración

## Requisitos previos

Antes de instalar el proyecto, cada integrante del equipo debe contar con las siguientes herramientas:

* Git
* Node.js
* npm
* Flutter SDK
* Dart SDK
* MongoDB / acceso a MongoDB Atlas
* Visual Studio Code
* Android Studio
* Un dispositivo Android o un emulador Android

Se recomienda verificar que las herramientas estén disponibles desde la terminal:

```
git --version
node --version
npm --version
flutter --version
dart --version
```

---

## 1. Clonar el repositorio

Clonar el repositorio desde GitHub:

```
git clone https://github.com/SomosCafeApp/SomosCafe-ProyectoColaborativo
```

Ingresar al directorio:

```
cd Somos-Cafe-App
```

---

# Configuración del Backend

Ingresar a la carpeta del backend:

```
cd backend
```

Instalar las dependencias:

```
npm install
```

El backend utiliza Node.js y Express para proporcionar la API que comunica la aplicación con la base de datos. La arquitectura contempla una separación entre la interfaz de usuario y el componente encargado de procesar la lógica y gestionar la base de datos.


## Ejecutar el backend

Desde la carpeta `backend`:

```
npm start
```

Si el proyecto utiliza un script de desarrollo con Nodemon:

```
npm run dev
```

Una vez iniciado, la API estará disponible en:

```
http://localhost:3000
```

---

# Configuración del Frontend

Desde la raíz del proyecto ingresar a la carpeta de Flutter:

```
cd frontend
```

O a la carpeta correspondiente donde se encuentre el proyecto Flutter.

Instalar las dependencias:

```
flutter pub get
```

Verificar los dispositivos disponibles:

```
flutter devices
```

Ejecutar la aplicación:

```
flutter run
```

Para ejecutar específicamente en Android:

```
flutter run -d android
```

# Arquitectura del proyecto

SOMOS CAFE APP utiliza una arquitectura dividida principalmente en **Frontend, Backend y Base de Datos**.

```
                    SOMOS CAFE APP
                          │
            ┌─────────────┴─────────────┐
            │                           │
        FRONTEND                    BACKEND
        Flutter                   Node.js
        Dart                      Express
            │                           │
            │        HTTP / REST        │
            └──────────────┬────────────┘
                           │
                           ▼
                       MongoDB
                    MongoDB Atlas
```

## Frontend

El frontend es responsable de la interfaz visual y de la interacción con los usuarios.

Estructura recomendada:

```
frontend/
│
├── lib/
│   ├── models/
│   │
│   ├── pages/
│   │
│   ├── services/
│   │
│   ├── widgets/
│   │
│   ├── config/
│   │
│   └── main.dart
│
├── assets/
|   |
│   ├── img/
|   |
│   └── ...
│
└── pubspec.yaml
```

# Backend

El backend contiene la lógica de negocio y funciona como intermediario entre Flutter y MongoDB.

Estructura recomendada:

```
backend/
│
├── controllers/
│
├── models/
│
├── routes/
│
├── middleware/
│
├── config/
│
├── .env
|
├── server.js
|
├── package.json
|
└── .gitignore
```

# Autores

Proyecto desarrollado por:

| Integrante                        | Rol                               |
| --------------------------------- | --------------------------------- |
| **Jhon Edison Rojas Henao**       | Lider, Backend y Pruebas          |
| **Jesus Manuel Serrano Collazos** | Frontend                          |
| **Faiber Julian Torres Gaviria**  | Base de datos y Documentación     |

---