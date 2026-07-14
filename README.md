# kilometer-check · iTire

App Flutter que resuelve la historia de usuario:

> *“Como encargado de flotilla, quiero ver el kilometraje actualizado a la fecha de un vehículo en particular.”*

La app consulta el kilometraje de la unidad **Buick Skylark Convertible** (ID `734455`) a través de la **API remota de Wialon**, lo presenta con una interfaz alineada a la identidad de iTire e informa si el kilometraje **aumentó** o **se mantuvo constante** entre consultas.

---

## 🚀 Instrucciones rápidas

**Requisito:** Flutter **3.41.2** (versión pedida en el ejercicio).

```bash
flutter pub get
flutter run
```

Eso es todo — la app arranca en el splash y pasa a la pantalla de consulta de kilometraje. No requiere configuración adicional (el token de prueba de Wialon ya viene incluido, ver nota abajo).

### Si no tienes Flutter 3.41.2 instalado

Usa [fvm](https://fvm.app) para no afectar tu instalación global de Flutter (el repo ya incluye `.fvmrc` apuntando a `3.41.2`):

```bash
fvm install         # descarga la 3.41.2 (solo la primera vez)
fvm flutter pub get
fvm flutter run
```

> **Token de Wialon:** por tratarse de un ejercicio, el token de prueba del PDF
> está como *default* en `lib/core/constants/wialon_constants.dart`. Puede
> sobreescribirse sin tocar código con:
> `flutter run --dart-define=WIALON_TOKEN=<tu_token>`

### Correr los tests

```bash
flutter test
# o, con fvm:
fvm flutter test
```

---

## 🔌 Integración con Wialon (2 llamadas)

| # | Servicio | Propósito |
|---|----------|-----------|
| 1 | `token/login` | Intercambia el token por una sesión (`eid`) |
| 2 | `core/search_item` con `flags = 0x1 + 0x2000` (8193) | Devuelve la unidad con su contador de kilometraje `cnm` (km) |

- La **sesión se cachea** entre consultas; si Wialon reporta sesión inválida (`{"error": 1}`), el datasource se re-autentica una única vez y reintenta automáticamente.
- Todos los códigos de error de la API se traducen a mensajes amigables (`WialonApiException`), y los fallos de red/parseo tienen sus propias excepciones (`NetworkException`, `ParsingException`).

---

## 🏗️ Arquitectura

Clean Architecture por feature + gestión de estado con **Provider** (`ChangeNotifier`): los widgets leen y reaccionan al estado exclusivamente a través de `MileageProvider`.

```
lib/
├── main.dart                  # Composición de dependencias (DI) con provider
├── app/                       # Raíz de la app (KilometerCheckApp) + Go Router (splash → home)
├── core/
│   ├── constants/             # Constantes de Wialon
│   ├── errors/                # Jerarquía sellada de AppException
│   ├── theme/                 # Paleta iTire, tema Material 3, curvas de animación
│   ├── utils/                 # Assets centralizados, tipografía, formatters
│   └── widgets/               # AppScaffold, AppText, AppImage, AppTextField, AppButton,
│                              # AnimatedBackgroundButton, Gap, Spacing, Entrance,
│                              # CirclesAnimationBackground (barrel: widgets.dart)
└── features/
    ├── splash/                # Splash animado (CustomPainter)
    └── mileage/
        ├── data/              # WialonRemoteDatasource, MileageModel, repo impl
        ├── domain/            # Entidad, contrato de repositorio, caso de uso
        └── presentation/      # MileageProvider + pantalla y widgets animados

tool/
└── gen_app_icon.dart          # Genera ícono de app y splash nativo desde assets/icons/icon.png
```

**Flujo de dependencias:** `http.Client → WialonRemoteDatasource → MileageRepository → GetCurrentMileage → MileageProvider → UI`. Cada capa solo conoce el contrato de la anterior, lo que permite sustituirlas en pruebas (ver `test/`).

---

## ✨ UX / UI

- Tema oscuro con la paleta de iTire (azul `#005CA8`, amarillo `#ECB806`) y tipografías Red Hat Display / Inter / JetBrains Mono.
- **Splash personalizado** con llanta dibujada por fases (`CustomPainter`) y transición fade+scale hacia la pantalla principal (Go Router `CustomTransitionPage`).
- **Odómetro animado**: el valor "rueda" desde la lectura anterior hasta la nueva; un halo de círculos azul/amarillo orbita detrás de la tarjeta sólida, asomando por sus orillas.
- **Leyenda de tendencia** (petición EXTRA): informa si el kilometraje aumentó (+Δ km) o se mantuvo constante.
- Indicador de carga en el botón (bloquea doble tap), feedback del estado de la llamada (hora de última actualización) y manejo de errores con mensajes accionables.
- Entradas escalonadas de contenido y micro-animaciones en botones e indicador "En vivo".

### 🎨 Ícono, splash nativo y nombre de la app

La app tiene su propio ícono de launcher (Android/iOS/Web), reemplaza el splash nativo de Flutter (el logo que aparece antes del splash personalizado) por el logo de iTire sobre fondo oscuro de marca, y se muestra como **"iTire Kilometraje"** en el dispositivo.

Todo se genera con `flutter_launcher_icons` + `flutter_native_splash` a partir de un único archivo fuente: `assets/icons/icon.png`. Si ese archivo cambia, regenera los assets con:

```bash
fvm dart run tool/gen_app_icon.dart   # convierte el origen a los PNG necesarios
fvm dart run flutter_launcher_icons   # ícono de la app
fvm dart run flutter_native_splash:create   # splash nativo
```

> Este cambio solo se ve al **reinstalar la app** (no aplica con hot reload).

---

## ✅ Calidad

- `flutter analyze`: sin issues.
- `flutter test`: 20 pruebas (formatters, modelo, datasource con `MockClient` —incluye re-login por sesión expirada—, provider y widget test del botón).
