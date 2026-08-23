# Concre Innova - Project Guide

This file is the main technical briefing for Claude Code when working on Concre Innova. Read it before making changes. The system is split across three related Git repositories that must remain compatible: API, frontend, and deployment automation.

Instructions in a repository-specific `AGENTS.md` take precedence for work inside that repository. User instructions take precedence over this guide when they are explicit and safe.

## Context, Vision, and Objective

Concre Innova is an e-commerce system for selling concrete planters, plants, and related products. It supports public product discovery, customer purchases and quotations, and internal administration.

The product vision is to provide one reliable workflow from catalog discovery through order fulfillment while giving staff controlled tools for products, inventory, quotations, orders, users, permissions, audit history, and business statistics.

Primary objectives:

- Let visitors browse and filter the catalog.
- Let customers register, authenticate, save favorites, build a cart, place orders, request quotations, and review history.
- Let sellers manage the quotation workflow explicitly allowed to their role.
- Let administrators manage catalog data, inventory, users, permissions, orders, quotations, audit records, and statistics.
- Keep authorization, validation, business rules, and persistence decisions in the API.
- Preserve traceability through `Bitacora` and quotation status history.

The application has both a local development environment and a public Azure student-demo environment. The demo is not a full commercial production environment and does not include a real payment gateway.

## Local Repository Map

### Backend API (this repository)

- Repository: `C:\Users\valve\source\repos\e-commerce-api`
- Solution: `C:\Users\valve\source\repos\e-commerce-api\Concre_Innova_API.slnx`
- Main project: `C:\Users\valve\source\repos\e-commerce-api\Concre_Innova_API`
- Usual branch: `Branch-Allan`
- Project rules: `C:\Users\valve\source\repos\e-commerce-api\AGENTS.md`
- Database evolution scripts: `C:\Users\valve\source\repos\e-commerce-api\Concre_Innova_API\Database\Scripts`
- Product and quotation images: `C:\Users\valve\source\repos\e-commerce-api\Concre_Innova_API\wwwroot\images`

### Frontend web application

- Repository: `C:\Users\valve\source\repos\e-commerce`
- Application: `C:\Users\valve\source\repos\e-commerce\concre_innova_website`
- Source: `C:\Users\valve\source\repos\e-commerce\concre_innova_website\src`
- Initial database script: `C:\Users\valve\source\repos\e-commerce\ScriptDB-Concre_Innova.sql`
- Usual branch: `Allan`
- Project rules: `C:\Users\valve\source\repos\e-commerce\AGENTS.md`

### Deployment automation

- Repository: `C:\Users\valve\source\repos\concre-innova-deployment`
- GitHub repository: `valverdegit/concre-innova-deployment`
- Approved branch: `main`
- Project rules: `C:\Users\valve\source\repos\concre-innova-deployment\AGENTS.md`
- Release manifest: `config\release-manifest.yml`
- Azure infrastructure: `infra\`
- GitHub Actions: `.github\workflows\`
- Operational documentation: `docs\`

These are separate repositories. Check `git status`, remotes, and the current branch independently before editing. Never revert unrelated user changes.

## Technology Stack

### Backend

- C# and ASP.NET Core Web API targeting .NET 10 (`net10.0`).
- ADO.NET with `Microsoft.Data.SqlClient`; there is no Entity Framework ORM.
- SQL Server LocalDB for local development.
- JWT bearer authentication and role-based authorization.
- Built-in dependency injection and in-memory caching.
- MailKit for recovery and notification email.
- Swagger/OpenAPI in Development.
- Static image serving from `wwwroot`.

Important backend packages are declared in `Concre_Innova_API.csproj`.

### Frontend

- JavaScript, JSX, HTML, and CSS.
- React 19.2 with React DOM.
- Create React App / `react-scripts` 5.
- React Router DOM 7.14.
- Fetch-based API client; no Axios dependency.
- Lucide React icons, SweetAlert2, React PDF, Konva, and React Konva.
- Jest and React Testing Library.

The frontend API base URL comes from `REACT_APP_API_URL` and defaults to `http://localhost:5222` in `src/services/apiClient.js`.

### Database

- Engine: Microsoft SQL Server LocalDB.
- Local server: `(localdb)\MSSQLLocalDB`.
- Database name: `ConcreInnovaDB`.
- Connection configuration key: `ConnectionStrings:DefaultConnection`.
- Initial schema source: `C:\Users\valve\source\repos\e-commerce\ScriptDB-Concre_Innova.sql`.
- Incremental schema and stored-procedure changes: backend `Database\Scripts` directory, ordered by filename/date.
- Azure demo database: `free-sql-db-6728341` on `hogrider.database.windows.net`.
- The Azure database is an external dependency and is not created or destroyed by the deployment repository.

Never place real connection strings, passwords, SMTP credentials, JWT keys, card data, or personal customer data in this file or in commits. Use .NET User Secrets or environment variables for sensitive local values.

`Jwt:Key` and `EmailSettings:Username` / `EmailSettings:Password` are deliberately empty in the versioned configuration and must be supplied per environment. The application refuses to start when `Jwt:Key` is missing, shorter than 32 characters, or equal to a known sample value:

```powershell
dotnet user-secrets set "Jwt:Key" "<clave-aleatoria-de-32-o-mas-caracteres>"
dotnet user-secrets set "EmailSettings:Username" "<usuario-smtp>"
dotnet user-secrets set "EmailSettings:Password" "<contrasena-smtp>"
```

## System Architecture

```text
Browser
  -> React pages and components
  -> frontend service modules
  -> HTTP/JSON + JWT
  -> ASP.NET Core controllers
  -> application services and validators
  -> repository interfaces
  -> ADO.NET repository implementations
  -> SQL Server tables and stored procedures
```

The Azure demo maps the same logical flow to Azure Static Web Apps, Azure App Service, and Azure SQL Database. Deployment code must not be mixed into either application repository.

The frontend is a client, not the authority. UI route guards improve navigation but API authorization is the security boundary.

### Backend layers

- `Controllers/`: HTTP routes, authorization attributes, input binding, and response shaping. Keep controllers thin.
- `Application/DTOs/`: request and response contracts shared at the API boundary.
- `Application/Interfaces/`: abstractions for services, repositories, and validators.
- `Application/Services/`: orchestration and business rules.
- `Application/Validators/`: request validation.
- `Application/Mappers/`: entity/DTO mapping.
- `Application/Models/`: internal application models.
- `Application/Security/`: request-user context model.
- `Domain/Entities/`: core data entities.
- `Domain/Constants/`: roles, permission codes, and domain rules.
- `Infrastructure/Repositories/`: SQL queries and stored-procedure calls grouped by feature.
- `Infrastructure/Data/`: SQL connection factory.
- `Infrastructure/Security/`: JWT creation and authenticated-user resolution.
- `Infrastructure/Audit/`: bitacora/audit implementation.
- `Infrastructure/Email/`: email delivery.
- `Infrastructure/Files/`: user image storage. `AlmacenamientoImagenesEnDisco` holds the shared path handling; the quotation and space-image classes delegate to it.
- `Configuration/`: dependency registration and typed settings.
- `Shared/`: cross-cutting constants and small helpers.
- `Database/Scripts/`: reproducible incremental SQL changes.
- `wwwroot/`: public static files and uploaded images.

Dependency direction should remain: Controller -> Application interface/service -> Repository interface -> Infrastructure implementation -> SQL Server.

### Frontend structure

- `src/pages/`: route-level screens for public, customer, seller, and administrator workflows. `SmartAdvisor` is embedded in the catalog, quotation creation is embedded in quotation history, and notifications appear through the navigation bell.
- `src/components/`: reusable UI such as navbar, admin layout, product modal, pagination, and protected routes.
- `src/services/`: all API requests and service-specific client logic.
- `src/routes/`: route constants and route composition.
- `src/constants/`: roles, access groups, and admin navigation.
- `src/img/` and `public/`: bundled static assets.
- `src/App.js`: router shell and startup token validation.
- `src/index.js`: React entry point.

Keep HTTP calls in services. Components may perform UX validation, but the API must repeat all security and business validation.

## Main Functional Areas

- Authentication: login, registration, token validation, password recovery, login-attempt control.
- Users and access: users, roles, permissions, role-permission assignment, inactive accounts.
- Catalog: products, categories, product types, variants, filters, related products, images, and product duplication. A duplicated product is created in `Borrador` state with its inventory and variants copied; drafts stay out of the public catalog until they are published.
- Inventory: product and variant stock, minimum quantities, and stock updates.
- Favorites: per-user saved products.
- Cart and checkout: stock validation, order registration, customer order history, and reorder preparation.
- Purchase summary: subtotal, included tax breakdown, total, stock revalidation, shipping address, and payment-method selection.
- Smart advisor (`Asesor Inteligente`): data-driven questionnaire, scored product recommendations grouped as plants and planters, per-user saved answers, and questionnaire reset.
- Space visualization: upload a photo of the customer's space, place catalog products over it at a scale proportional to their real size, save the simulation as a reusable project, and send the placed products to the cart.
- Quotations: request products, descriptions/preferences, images, staff response, customer decision, seller resolution, order conversion, tracking, history, and notifications.
- Order administration: lists, detail, status transitions, and cancellation.
- Invoicing: administrator invoice list/detail, due date and notes, payment-state updates, payment-receipt upload, and downloadable PDF documents.
- Reporting: summary metrics, frequent customers, category performance, and featured products.
- Audit: operational records in `Bitacora`.
- Chat and virtual assistant: keyword-driven bot answers, catalog-based product recommendations, persisted conversations, escalation to human support, conversation closing by the customer, and a staff console where `Administrador` and `Vendedor` list conversations with their last message, unread counter and inbox totals, reply to customers, and close resolved conversations into the finalized history.
- Notifications: per-user inbox backed by `Notificaciones`. The API creates records when an order is registered, when an order changes state or is cancelled, when staff answer or resolve a quotation, and when support replies in a chat; escalated chats still notify the assigned administrator. Users list, filter, and mark notifications as read, and the `NotificacionesActivas` preference decides whether new records are created for that account.
- Payments: `Ventas` and `Pagos` tables exist, but there is no complete external card-gateway integration in the current code. Never collect or store raw card numbers, CVV, or magnetic-stripe data; use a hosted checkout or tokenized provider and persist only gateway references and status.

## Security and Roles

Canonical roles currently stored in the database:

- `Administrador`: all administrative functionality plus customer purchase flows where explicitly supported.
- `Vendedor`: staff functionality explicitly granted by the approved permission matrix — full product and category management (`productos.*`, `categorias.*`), the quotation workflow, the chat attention console, and the customer enquiry inbox (`consultas.*`). Users, roles, permissions, orders, product types, company information, statistics, reports, and the audit log stay with `Administrador`.
- `Cliente`: catalog, favorites, cart, checkout, orders, and quotations.
- `Inactivo`: no protected access.

Rules:

- Treat API `[Authorize]`, role checks, permission checks, and request-user context as the source of truth.
- Never trust `X-User-Id` or `X-User-Role` headers without validating the JWT-backed identity.
- Use parameterized SQL commands for every external value.
- Passwords must remain hashes; never log or return them.
- Do not expose stack traces, SQL text, secrets, or internal paths in API responses.
- Validate uploaded image type, size, filename, and destination.
- Record important administrative and state-changing operations in `Bitacora`.

## Critical Business Rules

- Product states are `Activo`, `Inactivo`, and `Borrador`. Only active products belong in the public catalog; duplicated products begin as drafts.
- Inventory status is derived as `disponible`, `bajo`, or `agotado` from available and minimum quantities. Inventory updates reject negative values and values above the defensive limit defined in `InventarioRules`.
- The cart is browser-local state keyed by product and variant. Its prices and quantities are advisory until the API validates stock and registers the order.
- Checkout must revalidate current stock on the server. Never trust price, subtotal, total, or availability sent by the browser.
- Order states accepted by administration are `Pendiente`, `En proceso`, `Enviado`, and `Entregado`; cancellation uses `Cancelado`.
- Registering a normal order or converting an approved quotation into an order reserves/decrements stock in SQL. Cancelling restores reserved stock exactly once. Delivered orders do not restore stock.
- Quotation progression is `Pendiente` -> `Respondida` -> customer `Aceptada` or `Rechazada` -> seller `Aprobada` or rejection -> optional formal order. Every transition must validate the current state, record history, and notify the customer without allowing an email failure to corrupt the transaction.
- Invoice payment states are `Pagada`, `Pendiente`, `En verificacion`, and `Anulada`; list filters may derive `vencida` or `revision` from persisted state and due date.
- Reorder uses historical order-line snapshots but must validate current product/variant existence, price, and stock before a new purchase is registered.
- Favorites, notifications, orders, quotations, visualizations, account data, and chat history are always scoped to the authenticated owner in the API/database query.
- Uploaded files must remain under their designated `wwwroot/images/...` area and be referenced by safe relative paths. Never accept an arbitrary client filesystem path.

## Database Design

The database is relational and uses integer primary keys for most entities. Bridge tables use composite keys. Foreign keys connect identity, catalog, commerce, quotation, communication, and authorization areas.

### Identity, customers, and authorization

- `Roles`: role catalog.
- `Usuarios`: login identity, profile, password hash, status, registration date, and `IdRol`.
- `Clientes`: commerce/customer profile; optionally links back to `Usuarios` through `IdUsuario`.
- `IntentosLogin`: failed-attempt tracking per user.
- `Permisos`: granular permission catalog by module.
- `RolPermisos`: many-to-many bridge between roles and permissions.

### Catalog and inventory

- `Categorias`: product categories and active/inactive state.
- `TiposProducto`: product classification such as Interior, Exterior, and Decorativo.
- `CategoriaTipo`: allowed many-to-many category/type combinations.
- `Productos`: product identity, description, price, stock summary, image, category, type, size, material, characteristics, and state (`Activo`, `Inactivo`, or `Borrador`).
- `ProductoVariantes`: purchasable variants with their own name, dimensions/material, price, stock, image, and state.
- `Inventario`: available/minimum stock and last update for a product.
- `Favoritos`: unique saved product per user.
- `CategoriaClasificacion`: commercial classification of each category (`Planta`, `Macetero`, `Otro`), shared by the order detail and the smart advisor.

### Smart advisor

- `AsesorPreguntas`: questionnaire questions with display order and state.
- `AsesorOpciones`: selectable answers per question.
- `AsesorCriterios`: scoring rules that link an answer option to a category, a product type, or a keyword with a weight.
- `AsesorRespuestas`: latest answer per question for an authenticated user (unique per user and question).

### Quotations

- `Cotizaciones`: quotation header linked to a customer; contains status, total, request text, response, preferences, dates, and tracking number.
- `DetalleCotizacion`: priced product lines for a quotation.
- `SolicitudCotizacionProductos`: products and quantities originally requested before/alongside pricing.
- `CotizacionImagenes`: metadata and server path for uploaded reference images; binaries live under backend `wwwroot/images/cotizaciones`.
- `CotizacionEstadoHistorial`: every quotation status transition.
- `CotizacionNotificaciones`: email notification queue/retry state for status transitions.

### Orders, sales, and payments

- `Pedidos`: order header linked to a customer and optionally to its source quotation.
- `DetallePedido`: immutable order lines, including product/variant snapshot fields, quantity, unit price, and subtotal.
- `Ventas`: sale/payment summary for an order, including payment method, payment state, total, due date, and administrative observations.
- `Pagos`: payment records linked to a sale, with amount, date, method, external/reference value, optional uploaded receipt path, and registering user. It must never contain raw card credentials.

Typical flow: validate stock -> create `Pedido` and `DetallePedido` -> reserve/decrement stock -> create/update `Venta` -> record payment reference/status. Quotation conversion uses the same commerce entities and links `Pedidos.IdCotizacion`.

### Audit, notifications, and chat

- `Bitacora`: user, affected table, operation, description, timestamp, and IP address.
- `Notificaciones`: per-user notifications with `Tipo` (`Pedido`, `Cotizacion`, `Chat`, `General`), `Titulo`, `Mensaje`, optional `Enlace` and `Referencia` to the originating record, read state, and `FechaLectura`.
- `PreferenciasUsuario`: per-user preferences for in-app notifications, email notifications, and theme.
- `Chats`: conversation header for a customer. `IdUsuario` is the assigned support agent and stays NULL until the conversation is escalated. `Estado` is `Abierto`, `Escalado`, or `Finalizado`.
- `MensajesChat`: messages belonging to a chat. `Remitente` is `Cliente`, `Bot`, or `Soporte`, and `Mensaje` is NVARCHAR because bot answers contain emojis.
- `BotIntenciones`: configured assistant answers, whether they suggest products and whether they warrant escalation.
- `BotIntencionPalabras`: keywords that activate each bot intent.

### Space visualization

- `Visualizaciones`: saved simulation per user, with the space image path and the canvas size it was designed for.
- `VisualizacionProductos`: products placed on a saved visualization, including quantity, colour, planter, position, size and rotation.

### Important relationships

- `Roles 1 -> many Usuarios`; `Roles many <-> many Permisos` through `RolPermisos`.
- `Usuarios 1 -> 0..1 Clientes`; users also own favorites, notifications, login attempts, and audit records.
- `Categorias 1 -> many Productos`; categories and product types are also linked through `CategoriaTipo`.
- `Productos 1 -> many ProductoVariantes` and `Productos 1 -> many Inventario/Favoritos/detail rows`.
- `Clientes 1 -> many Cotizaciones/Pedidos/Chats`.
- `Cotizaciones 1 -> many DetalleCotizacion/SolicitudCotizacionProductos/images/history/notifications` and `Cotizaciones 1 -> 0..many Pedidos`.
- `Pedidos 1 -> many DetallePedido` and `Pedidos 1 -> many Ventas` according to the physical schema.
- `Ventas 1 -> many Pagos` according to the physical schema.
- `Chats 1 -> many MensajesChat`.

### Stored procedures

The installed local database currently contains procedures for:

- Authentication/users: `SP_Login`, `SP_InsertarUsuario`, `SP_ActualizarUsuario`, `SP_DesactivarUsuario`, `SP_ObtenerUsuarios`, `SP_ObtenerRoles`, `SP_ValidarCorreoRecuperacion`, `SP_RestablecerContrasena`.
- Catalog: `SP_ObtenerCatalogoProductos`, `SP_ObtenerCategorias`, `SP_InsertarProducto`, `SP_ActualizarProducto`, `SP_EliminarProducto`, `SP_DuplicarProducto`.
- Cart/orders: `SP_ValidarStockCarrito`, `SP_RegistrarPedido`, `SP_ObtenerMisPedidos`, `SP_PrepararRecompraPedido`, `SP_ObtenerPedidosAdmin`, `SP_ObtenerPedidoAdminDetalle`, `SP_ActualizarEstadoPedido`, `SP_CancelarPedido`.
- Quotations: `SP_CrearCotizacionConImagenes`, `SP_ObtenerMisCotizaciones`, `SP_ObtenerCotizacionesAdmin`, `SP_ResponderCotizacion`, `SP_DecidirCotizacion`, `SP_ResolverCotizacionVendedor`, `SP_ConvertirCotizacionEnPedido`.
- Smart advisor: `SP_ObtenerCuestionarioAsesor`, `SP_GenerarRecomendacionesAsesor`, `SP_GuardarRespuestasAsesor`, `SP_LimpiarRespuestasAsesor`.
- Chat and assistant: `SP_ObtenerIntencionesBot`, `SP_ObtenerOCrearChatCliente`, `SP_RegistrarMensajeChat`, `SP_ObtenerConversacionCliente`, `SP_EscalarChatASoporte`, `SP_FinalizarChat`, `SP_ObtenerChatsAdmin`, `SP_ObtenerMensajesChat`, `SP_ObtenerResumenChatsAdmin`.
- Notifications: `SP_RegistrarNotificacion`, `SP_ObtenerNotificacionesUsuario`, `SP_ObtenerResumenNotificaciones`, `SP_MarcarNotificacionLeida`, `SP_MarcarNotificacionesLeidas`.
- Space visualization: `SP_GuardarVisualizacion`, `SP_ObtenerVisualizacionesUsuario`, `SP_EliminarVisualizacion`.
- Reporting/audit: `SP_InsertarBitacora`, `SP_ObtenerBitacora`, `SP_EstadisticasResumenNegocio`, `SP_EstadisticasClientesFrecuentes`, `SP_EstadisticasPorCategoria`, `SP_EstadisticasProductosDestacados`.
- Inventory: `SP_ObtenerInventario`, `SP_ObtenerInventarioDetalle`, `SP_ActualizarInventario`.
- Invoices/payments: `SP_ObtenerFacturasAdmin`, `SP_ObtenerFacturaDetalle`, `SP_ActualizarEstadoFactura`, `SP_RegistrarComprobantePago`.
- Reports/company/preferences: `SP_ReporteVentasPorPeriodo`, `SP_ReporteComparativoPeriodos`, `SP_ReporteProductosMasVendidos`, `SP_EstadisticasDashboard`, `SP_ObtenerInformacionEmpresa`, `SP_ActualizarInformacionEmpresa`, `SP_ObtenerPreferenciasUsuario`, `SP_ActualizarPreferenciasUsuario`.

Repositories also contain parameterized inline SQL for features such as category/type management, permissions, favorites, catalog projections, and quotation notifications.

### Data policy

The versioned scripts include catalog seed and normalization data, but database rows are mutable runtime state. Never treat previously observed counts, users, stock, orders, or quotation totals as permanent truth; query the target database when exact values matter.

Product photography lives in `wwwroot/images/productos` and is versioned with the API. `Productos.Imagen` and `ProductoVariantes.Imagen` store the relative path (`images/productos/<archivo>.jpg`), which the web client resolves against `REACT_APP_API_URL` without extra configuration. Each product design has one photograph; a variant only carries its own file when the photo really shows that same design in another size.

Do not document names, emails, password hashes, tokens, image contents, or other personal/sensitive row values.

## Database Change Workflow

1. Inspect the initial script and every later script that touches the same objects.
2. Inspect the live schema with SQL Server metadata before assuming it matches the initial script.
3. Add a new dated, idempotent SQL script under backend `Database\Scripts`; do not silently edit database state only.
4. Include constraints, foreign keys, indexes, data backfills, and stored-procedure updates needed by the change.
5. Keep API DTOs, repositories, services, and frontend service contracts synchronized.
6. Test both fresh application of the relevant scripts and behavior against the current local database when practical.
7. Never edit an already-shared migration to represent a new change; add a later dated script.
8. Do not include `20260813_ZZ_LimpiezaDatosDePrueba.sql` in automatic installation or deployment. It is intentionally destructive and requires manual review.
9. Apply Azure SQL changes only through the reviewed migration workflow or an explicitly authorized manual operation.
10. Record the exact script, target database, execution result, and required rollback/forward-fix behavior.

Avoid unbounded list queries and N+1 access. Use pagination and projections, and add indexes for new frequently used filters or joins.

The initial schema and incremental scripts serve different purposes:

- `ScriptDB-Concre_Innova.sql` creates the historical base schema for a new local database.
- API `Database/Scripts` upgrades an existing schema in chronological dependency order.
- A full-from-zero handoff script must include base schema, all required migrations, seed data, procedures, constraints, and indexes; an upgrade script must not recreate or drop the database.

## API and Frontend Contract

Controller route groups currently include `api/Auth`, `api/Users`, `api/Roles`, `api/Permisos`, `api/Productos`, `api/Categorias`, `api/TiposProducto`, `api/Favoritos`, `api/Carrito`, `api/Cotizaciones`, `api/Pedidos`, `api/Inventario`, `api/Facturas`, `api/Pagos`, `api/Estadisticas`, `api/Reportes`, `api/Empresa`, `api/Consultas`, `api/Bitacora`, `api/Asesor`, `api/Chat`, `api/Preferencias`, `api/Notificaciones`, and `api/Visualizaciones`.

Frontend route groups:

- Public: `/`, `/catalog`, `/product/:idProducto`, `/favorites`, `/contacto`, `/login`, `/register`, and `/forgot-password`.
- Purchase/customer: `/cart`, `/checkout`, `/mis-pedidos`, `/mis-cotizaciones`, and `/mi-cuenta`.
- Administrator: `/admin`, inventory, orders, invoices, reports, users, permissions, company information, and bitacora.
- Administrator and seller: products, categories, quotations, administrative chat, and customer enquiries.

`ProtectedRoute` and menu visibility improve user experience, but they do not replace API authorization. Direct URL and direct API access must both be tested for restricted functionality.

`api/Consultas` is the enquiry inbox built on `MensajesContacto`: `GET api/Consultas` requires `consultas.ver` and `POST api/Consultas/{id}/respuesta` requires `consultas.responder`, both granted to `Administrador` and `Vendedor`. Answering stores the reply, its date and its author, marks the enquiry as `Respondido`, records the change in `Bitacora`, and emails the customer as a best-effort step that never fails the operation. `api/Empresa/mensajes` remains available to `empresa.gestionar` for the company-information screen.

`POST api/Bitacora/acceso-denegado` lets the web application record a route rejected by its guards; it only accepts the authenticated caller's own attempt.

Unhandled exceptions are converted by `ManejoErroresMiddleware` into a generic message. Controllers must never return `ex.Message`, SQL text, or internal paths in a response.

`api/Notificaciones` requires any authenticated role and every stored procedure filters by user, so a notification can only be read or marked by its owner. It exposes the paginated inbox, a lightweight `resumen` endpoint used by the navigation bar indicator, and the read-state endpoints. Notifications are never created through HTTP: `INotificacionEventoService` emits them from the order, quotation, and chat services, and failures there are logged without interrupting the originating operation.

`api/Asesor` is public for reading the questionnaire and generating recommendations; answers are only persisted when the caller presents a valid token, and `DELETE api/Asesor/respuestas` requires an authenticated purchase role.

`api/Visualizaciones` requires an authenticated purchase role for every operation, and each stored procedure filters by user so a visualization can only be read or deleted by its owner. Uploaded space images live under `wwwroot/images/visualizaciones/{idUsuario}`.

`api/Chat` accepts messages from anonymous visitors (bot answer only, nothing persisted). Conversation history, escalation, and closing require an authenticated purchase role, and the `api/Chat/admin` endpoints require `Administrador` or `Vendedor` (`AppRoles.RolesAtencionChat`). Whether escalation to a human is offered comes from the `SoporteHumano` configuration section.

Product duplication lives at `POST api/Productos/{id}/duplicado` and requires the `productos.duplicar` permission, granted to `Administrador` and `Vendedor`. `GET api/Productos` accepts `incluirBorradores=true`, which only takes effect for callers holding that permission, so the public catalog never exposes drafts. Updating a product requires `productos.actualizar`; holders of only `productos.duplicar` may update a product while both the stored product and the request keep the `Borrador` state, which lets a seller adjust a copy without publishing it.

Before changing a route, DTO, status code, role requirement, field name, or enum-like state string:

- Search the corresponding frontend service and page usage.
- Search stored procedures and repository mapping by column/parameter name.
- Preserve backward compatibility unless the task explicitly requires a contract change.
- Update tests in both repositories where the behavior crosses the boundary.

## Common Commands

Run backend commands from `C:\Users\valve\source\repos\e-commerce-api`:

```powershell
dotnet restore .\Concre_Innova_API.slnx
dotnet build .\Concre_Innova_API.slnx
dotnet test .\Concre_Innova_API.slnx
dotnet run --project .\Concre_Innova_API\Concre_Innova_API.csproj
```

`Concre_Innova_API.Tests` (xUnit) covers the role/permission policy and the request validators. Add a case there whenever the permission matrix or a validation rule changes.

Run frontend commands from `C:\Users\valve\source\repos\e-commerce\concre_innova_website`:

```powershell
npm.cmd ci
npm.cmd start
npm.cmd test -- --runInBand --watchAll=false
npm.cmd run build
```

Inspect the local database without embedding credentials:

```powershell
sqlcmd -S '(localdb)\MSSQLLocalDB' -d ConcreInnovaDB -E
```

The backend development launch profile determines the effective API port. Keep `REACT_APP_API_URL` aligned with it.

Validate the deployment repository from `C:\Users\valve\source\repos\concre-innova-deployment`:

```powershell
.\scripts\validate-release.ps1
az bicep build --file .\infra\main.bicep
```

## Configuration Reference

Local and deployed configuration must be supplied through environment-specific mechanisms. Use .NET User Secrets locally and GitHub environment secrets/variables plus Azure App Service settings for the demo.

Important keys:

- `ConnectionStrings:DefaultConnection`: SQL Server connection string.
- `Jwt:Key`, `Jwt:Issuer`, `Jwt:Audience`, `Jwt:ExpireMinutes`: token signing and validation.
- `AllowedOrigins`: exact frontend origins accepted by CORS.
- `EmailSettings:Host`, `Port`, `Username`, `Password`, `SenderEmail`, `SenderName`, `UseSsl`: SMTP delivery.
- `SoporteHumano:Habilitado`, `SoporteHumano:ContactoAlternativo`: chat escalation behavior.
- `REACT_APP_API_URL`: frontend API base URL fixed at build time.

Never put secret values in `CLAUDE.md`, source files, screenshots, logs, workflow output, pull-request text, or commits.

## Deployment Workflow

The deployment repository owns Azure automation. Application source stays in the API and frontend repositories.

```text
GitHub application main branches
  -> immutable commit SHAs in config/release-manifest.yml
  -> reviewed deployment pull request
  -> GitHub Actions with Azure OIDC
  -> Azure App Service + Azure Static Web Apps
  -> Azure SQL Database
```

Deployment workflows:

- `validate.yml`: validates Bicep and release metadata on pull requests.
- `verify-azure-oidc.yml`: verifies passwordless GitHub-to-Azure authentication.
- `provision-demo.yml`: creates or updates demo infrastructure from Bicep.
- `migrate-demo-database.yml`: applies an explicitly selected, reviewed SQL migration.
- `deploy-demo.yml`: checks out immutable API/frontend SHAs, builds, tests, deploys, and smoke-tests both applications.
- `destroy-demo.yml`: removes owned demo resources only after explicit confirmation; it must not delete the external Azure SQL database.

The GitHub `demo` environment stores secret values under `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_SQL_CONNECTION_STRING`, `JWT_KEY`, `EMAIL_USERNAME`, and `EMAIL_PASSWORD`. Repository variables identify `AZURE_RESOURCE_GROUP`, `AZURE_API_APP_NAME`, `AZURE_STATIC_WEB_APP_NAME`, and `API_BASE_URL`. Document names only, never values.

Azure authentication uses OIDC federation. GitHub requests a short-lived Azure token for the approved repository/environment identity, so no long-lived Azure client secret is stored in GitHub.

Release rules:

1. Merge and validate application changes in their own repositories first.
2. Use the resulting 40-character commit SHAs in the release manifest and deployment workflow defaults.
3. Apply deployment changes through a short-lived `codex/*` branch and pull request.
4. If the API requires a database migration, run the reviewed migration before deploying the dependent API, and keep it backward compatible during rollout.
5. Run `Deploy demo applications` only from approved `main` metadata.
6. Confirm the workflow result and independently smoke-test the API and frontend URLs.
7. Roll back by redeploying the last known-good immutable SHAs; never guess a branch tip.

Current demo endpoints may change after reprovisioning:

- Frontend: `https://happy-flower-02cc53310.7.azurestaticapps.net`
- API: `https://concreinnova-demo-api-wppfkoecd5366.azurewebsites.net`

## Required Work Routine

1. Read the `AGENTS.md` in every repository involved in the task.
2. Check branch, remotes, `git status`, and divergence before changing files.
3. Inspect the current implementation, DTOs, services, repositories, SQL objects, frontend consumers, and tests before deciding on a fix.
4. Preserve architecture and public behavior; make the smallest coherent change.
5. Put business rules in API services and persistence in repositories or stored procedures, never only in React components.
6. Add a dated, reproducible SQL script whenever schema, data contracts, indexes, permissions, or stored procedures change.
7. Test success, validation, authentication, authorization, not-found, conflict, persistence, and relevant UI states.
8. Build both applications when a contract or shared workflow changes.
9. Do not commit, push, merge, migrate Azure SQL, or deploy unless the user requests it.
10. Before finalizing, confirm all affected worktrees are clean or clearly report remaining user changes.

## Assistant Behavior

- Respond in the user's language; project UI and user-facing messages are Spanish.
- When the user requests analysis only, do not modify files, database state, branches, or deployments.
- When implementation is requested, continue through code, tests, runtime validation, and a concise result summary unless blocked.
- Acceptance criteria help validation but are not mandatory to implement a clear user story or bug report.
- Do not invent requirements, credentials, users, database rows, test results, or deployment status.
- For reviews, report defects and risks first with exact files/methods, then assumptions and suggested fixes.
- Explain any necessary public API, DTO, route, database, or behavior change before or alongside implementation.
- Distinguish build success, automated test success, endpoint success, browser success, and persistence verification; none substitutes for the others.
- Keep progress communication concise and technical. Final reports must state what changed, SOLID/architecture impact when relevant, files moved or renamed, tests/build/runtime results, database scripts, and unverified items.

## Git and Release Discipline

- API work normally starts on `Branch-Allan`; the repository's default integration branch is `master`.
- Frontend work normally starts on `Allan`; the default integration branch is `main`.
- Deployment changes use a short-lived `codex/*` branch and a pull request into `main`.
- Fetch before comparing or merging. Integrate the newest default branch into the working branch before publishing when requested.
- Resolve conflicts by understanding and preserving compatible behavior from both sides; never choose one whole side blindly.
- Never use force push, hard reset, destructive checkout, or history rewriting unless explicitly authorized and technically justified.
- Do not commit unrelated local changes. Review staged diffs and `git status` before every commit.
- Push/merge all repositories explicitly requested by the user, then verify remote branch divergence is zero.
- Deployment is a separate authorized operation after application merges; a successful application push does not automatically mean Azure is updated.

## Engineering Rules

- Read every relevant repository's `AGENTS.md` before cross-repository work.
- Preserve the current layered architecture and folder organization.
- Keep controllers and React pages focused; place rules in application services and persistence in repositories.
- Prefer existing interfaces, validators, service patterns, response shapes, and UI conventions.
- Do not rewrite broad areas for a narrow task.
- Use async database and I/O APIs.
- Use clear names and small methods; avoid duplicated mapping and validation.
- Keep public API responses in DTOs, never raw database entities containing sensitive fields.
- Do not rely on frontend route visibility for authorization.
- Do not modify generated/build directories (`bin`, `obj`, `node_modules`, `build`) manually.
- Do not commit uploaded test images, local logs, `.vs`, secrets, or machine-specific configuration unless explicitly required.
- Keep user-facing text in clear Spanish with correct accents; keep code identifiers consistent with the language already used by the surrounding module.
- Use dependency injection and existing interfaces in C#; do not instantiate repositories, email clients, or SQL connections inside controllers.
- Use `async` database and file APIs, dispose SQL resources, and pass cancellation tokens where the existing contract supports them.
- Parameterize all SQL values. Do not build SQL clauses from raw user input; whitelist sort columns and state values.
- Keep React effects controlled with correct dependency arrays, cleanup, request cancellation, and debounce for live input where appropriate.
- Use shared `apiClient`, service modules, pagination helpers, pricing helpers, role constants, and route constants instead of duplicating behavior.
- Preserve loading, empty, error, disabled/submitting, and confirmation states. A visible button is not evidence that its workflow works.
- Keep the current visual language and responsive behavior. Make focused improvements rather than redesigning unrelated screens.
- Prefer `documentService` for branded downloadable PDF documents instead of constructing ad hoc HTML downloads.

## Testing Strategy

- Backend unit tests use xUnit in `Concre_Innova_API.Tests`.
- Frontend tests use Jest and React Testing Library beside pages/services or under `src`.
- Builds are mandatory but insufficient: run the applications and exercise affected API endpoints and browser workflows when practical.
- Test every affected role, including direct API attempts and direct protected-route navigation.
- Test valid, empty, whitespace-only, boundary, malformed, unauthorized, forbidden, not-found, duplicate, and conflict cases relevant to the change.
- After a write operation, query the API again and reload the UI to prove persistence; inspect SQL state when database access is available.
- For stock, quotation, order, invoice, and payment changes, verify transaction behavior and repeated requests so quantities or states cannot be applied twice.
- For uploads, test allowed/blocked types, size limits, generated names, ownership, persisted path, and retrieval.
- For frontend request changes, verify endpoint, method, headers, query/path parameters, body, status handling, and cancellation behavior.
- Never mark an unexecuted scenario as passed. Report it as unverified or blocked with the reason.

## Definition of Done

For backend changes:

- Build `Concre_Innova_API.slnx` successfully.
- Run relevant tests or exercise affected endpoints when no tests exist.
- Include a complete dated SQL script for every database change.
- Verify authorization and negative/error paths.

For frontend changes:

- Run focused tests and `npm.cmd run build` on Windows.
- Verify loading, empty, success, unauthorized, forbidden, and error states where relevant.
- Check both desktop and mobile layouts for changed screens.

For cross-repository changes:

- Verify the API contract end to end with both applications running.
- Report files changed, commands run, and any verification that could not be completed.
- Check `git status` separately in every affected repository before finalizing.

## Maintaining This File

Treat `CLAUDE.md` as versioned architecture documentation. Update it when repository paths, startup commands, architectural boundaries, roles, core workflows, database objects, or verification requirements change. Keep transient task details and secrets out of it. When this file becomes too large or specialized, move scoped rules into `.claude/rules/` files rather than letting contradictory guidance accumulate.
