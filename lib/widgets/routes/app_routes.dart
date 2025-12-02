// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/view/components/notifications/badge/badge.dart'
    as badge_screen;

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static GoRouter router({required BuildContext context}) {
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      initialLocation: RoutesName.init,
      routes: <RouteBase>[
        // Init Routes
        GoRoute(
          path: RoutesName.init,
          redirect: (_, __) => RoutesName.dashboard,
        ),

        // Dashboard Routes
        GoRoute(
          path: RoutesName.dashboard,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.dashboardScaffoldKey,
              child: const Dashboard(),
            );
          },
        ),

        // Base/Card Routes
        GoRoute(
          path: RoutesName.card,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.cardScaffoldKey,
              child: const CardScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.accordion,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.accordionScaffoldKey,
              child: const AccordionScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.breadcrumb,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.breadcrumbScaffoldKey,
              child: const BreadcrumbScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.loader,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.loaderScaffoldKey,
              child: const LoaderScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.videoPlayer,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.videoPlayerScaffoldKey,
              child: const VideoPlayerScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.dragDrop,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.dragDropScaffoldKey,
              child: const DragDropScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.gallery,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.galleryScaffoldKey,
              child: const GalleryScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.listGroup,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.listGroupScaffoldKey,
              child: const ListGroupScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.popovers,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.popoversScaffoldKey,
              child: const PopoversScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.progress,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.progressScaffoldKey,
              child: const ProgressScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.tables,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.tablesScaffoldKey,
              child: const TableScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.tooltips,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.tooltipsScaffoldKey,
              child: const TooltipsScreen(),
            );
          },
        ),

        // Authentication /login & /register Routes
        GoRoute(
          path: RoutesName.login,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.loginScaffoldKey,
              child: const Login(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.register,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.registerScaffoldKey,
              child: const Register(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.notFound,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.notFoundScaffoldKey,
              child: const NotFoundPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.comingSoon,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.comingSoonScaffoldKey,
              child: const ComingSoonPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.faq,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.faqScaffoldKey,
              child: const FaqPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.maintenance,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.maintenanceScaffoldKey,
              child: const MaintenancePage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.timelinePage,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.timelineScaffoldKey,
              child: const TimelinePage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.emailVerify,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.emailVerifyScaffoldKey,
              child: const EmailVerificationWaitingScreen(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.forgotPassword,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.forgotPasswordScaffoldKey,
              child: const ForgotPasswordPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.pagoQR,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.pagoQRScaffoldKey,
              child: const PagoQRPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.codigosQR,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.codigosQRScaffoldKey,
              child: const CodigosQRPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.perfil,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.perfilScaffoldKey,
              child: const PerfilUsuarioPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.contacto,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.contactoScaffoldKey,
              child: const ContactoPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.cambioContrasena,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.cambioContrasenaScaffoldKey,
              child: const CambioContrasenaPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.metodosPago,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.metodosPagoScaffoldKey,
              child: const MetodosPagoPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.nuevaTarjeta,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.nuevaTarjetaScaffoldKey,
              child: const NuevaTarjetaPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.nuevoPerfilFiscal,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.nuevoPerfilFiscalScaffoldKey,
              child: const NuevoPerfilFiscalPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.cargarConstanciaFiscal,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.cargarConstanciaFiscalScaffoldKey,
              child: const CargarConstanciaFiscalPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.escaneoQRConstancia,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.escaneoQRConstanciaScaffoldKey,
              child: const EscaneoQRConstanciaPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.recargar,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.recargarScaffoldKey,
              child: const RecargarPage(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.seleccionarMetodoPago,
          pageBuilder: (BuildContext context, GoRouterState state) {
            String? amount;
            if (state.extra is Map) {
              amount = (state.extra as Map)['amount']?.toString();
            }
            return FadeTransitionPage(
              key: ScaffoldKey.seleccionarMetodoPagoScaffoldKey,
              child: SeleccionarMetodoPagoPage(amount: amount),
            );
          },
        ),
        GoRoute(
          path: RoutesName.resumen,
          pageBuilder: (BuildContext context, GoRouterState state) {
            String? amount;
            if (state.extra is Map) {
              amount = (state.extra as Map)['amount']?.toString();
            }
            return FadeTransitionPage(
              key: ScaffoldKey.resumenScaffoldKey,
              child: ResumenPage(amount: amount),
            );
          },
        ),
        GoRoute(
          path: RoutesName.serverError,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.internalServerScaffoldKey,
              child: const InternalServerErrorPage(),
            );
          },
        ),

        // Icons /flagIcon Routes
        GoRoute(
          path: RoutesName.flagIcon,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.flagIconScaffoldKey,
              child: const FlagIcons(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.materialIcon,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.materialScaffoldKey,
              child: const MaterialIcons(),
            );
          },
        ),

        // Notifications /alerts & /badge & /modals & /toasts Routes
        GoRoute(
          path: RoutesName.alerts,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.alertsScaffoldKey,
              child: const Alerts(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.badge,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.badgeScaffoldKey,
              child: const badge_screen.Badge(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.toasts,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.toastsScaffoldKey,
              child: const Toasts(),
            );
          },
        ),

        // Plugin /calender & /charts & /dataTables & /googleMaps Routes
        GoRoute(
          path: RoutesName.calender,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.calendarScaffoldKey,
              child: const Calendar(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.charts,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.chartsScaffoldKey,
              child: const Charts(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.dataTables,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.databasesScaffoldKey,
              child: const Databases(),
            );
          },
        ),
        GoRoute(
          path: RoutesName.googleMaps,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.googleMapsScaffoldKey,
              child: const GoogleMap(),
            );
          },
        ),

        // Widgets
        GoRoute(
          path: RoutesName.widgets,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.widgetsScaffoldKey,
              child: const Widgets(),
            );
          },
        ),

        // Form
        // Widgets
        GoRoute(
          path: RoutesName.forms,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.formScaffoldKey,
              child: FormScreen(),
            );
          },
        ),

        GoRoute(
          path: RoutesName.buttons,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return FadeTransitionPage(
              key: ScaffoldKey.internalServerScaffoldKey,
              child: const Buttons(),
            );
          },
        ),
      ],
    );
  }
}
