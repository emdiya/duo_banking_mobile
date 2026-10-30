import '../core/widgets/app_toolbar_overlay.dart';
import 'package:foldable/foldable.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../shared/bloc/banking_cubit.dart';

class KhmerBankApp extends StatefulWidget {
  const KhmerBankApp({super.key, this.initialLocation = '/splash'});
  final String initialLocation;
  @override
  State<KhmerBankApp> createState() => _KhmerBankAppState();
}

class _KhmerBankAppState extends State<KhmerBankApp> {
  late final GoRouter router = createRouter(
    initialLocation: widget.initialLocation,
  );
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    return FoldableProvider(
      bridgeMode: DisplayFeatureBridgeMode.none,
      child: AdaptiveApp.router(
        title: 'Khmer Bank',
        materialLightTheme: AppTheme.build(Brightness.light),
        materialDarkTheme: AppTheme.build(Brightness.dark),
        cupertinoLightTheme: AppTheme.cupertino(Brightness.light),
        cupertinoDarkTheme: AppTheme.cupertino(Brightness.dark),
        themeMode: state.theme,
        locale: Locale(state.khmer ? 'km' : 'en'),
        supportedLocales: const [Locale('en'), Locale('km')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        // The fixed toolbar sits above the Navigator and needs its own
        // overlay for tooltips and popup menus, plus a Material ink ancestor.
        builder: (context, child) {
          if (!PlatformInfo.isIOS) return child ?? const SizedBox.shrink();
          final brightness = switch (state.theme) {
            ThemeMode.light => Brightness.light,
            ThemeMode.dark => Brightness.dark,
            ThemeMode.system => MediaQuery.platformBrightnessOf(context),
          };
          return Theme(
            data: AppTheme.build(
              brightness,
            ).copyWith(cupertinoOverrideTheme: AppTheme.cupertino(brightness)),
            child: AppToolbarOverlay(
              child: Material(type: MaterialType.transparency, child: child),
            ),
          );
        },
        routerConfig: router,
      ),
    );
  }
}
