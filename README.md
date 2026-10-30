# Khmer Bank

A Cambodian-inspired Flutter Material 3 banking UI laboratory using fictional customer data. The display name is Khmer Bank; the Dart package remains `duo_banking_lab`. No real banking APIs, credentials, payment cards, or money movements are used.

## Current implementation

The starter application has been replaced with a feature-first app containing:

- Bakong KHQR-inspired red, white and charcoal design system, light/dark/system themes, reusable banking components, responsive scrolling layouts and safe areas.
- Dashboard with swipeable USD/KHR account cards, balance privacy, quick actions, promotions, recent activity, budget preview and exchange-rate preview.
- Account search/currency filters and account details with clipboard copying.
- Sixty deterministic transactions across six categories, searchable/filterable history, paginated loading and receipts.
- Transfer form, review, demo PIN confirmation, success/failure and atomic in-memory balance/history updates.
- Splash, three-page onboarding, login validation, registration, timed OTP and password reset forms.
- QR simulator and receive-code preview, virtual card freeze/details/limits, spending overview, notifications, profile, settings and security views.
- English/Khmer locale selection. Navigation and selected labels have Khmer translations; full translation coverage and a bundled Khmer font remain unfinished.
- Widget, repository/state and integration test source, plus `/showcase` for component review.

This is an implementation milestone, **not a completed acceptance run**. Some auxiliary forms are demo previews: profile edits and PIN/password changes do not persist; QR/bill/top-up previews do not debit accounts; QR artwork is decorative; sharing/download controls provide confirmations rather than exported files. Native camera/biometrics, preference persistence, authentication session guards, all requested animations/charts, complete localization and generated immutable models are still pending. No code generation is configured yet. Android/iOS build verification and visual screenshot review remain pending.

## Run

Use a compatible Flutter stable SDK with Dart 3.12.2 or newer:

```sh
flutter pub get
flutter run
```

Login accepts any non-empty username/phone and a password of at least six characters. OTP: `123456`. Transfer PIN: `1234`; another PIN opens the failure scenario. All demo state resets when the app restarts. Dates are anchored to 28 October 2026 for reproducible previews.

## Checks

```sh
flutter analyze
flutter test
flutter test integration_test/banking_flow_test.dart -d <device-id>
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

The widget suite covers login validation, dashboard rendering, balance visibility, retained tabs, transaction search/empty state, transfer validation, theme/language selection and dashboard sizes 320×568, 390×844, 430×932, 800×1280 and 844×390. The integration scenario covers login → dashboard → transfer → review → demo PIN → success → history. These tests have **not passed in this environment**.

### Validation observed during implementation

- Standalone Dart model smoke check: passed (60 deterministic entries, six categories, unique references, initial balance and USD formatting).
- Dart formatter processed the sources; its process then reported a sandbox denial writing global telemetry.
- `flutter pub get --offline`: passed after switching to `flutter_bloc` 9.1.1 and resolving cached dependencies.
- Dart analysis server: completed with no diagnostics after the migration. The standard Flutter analyzer launcher encounters sandbox restrictions writing global telemetry, so analysis used the SDK analysis-server protocol directly.
- `flutter test --no-pub`: test sources compiled, but execution failed because the Flutter test harness could not bind its localhost server socket (`Operation not permitted`). No widget/state test pass is claimed.
- A writable temporary SDK copy was used; the system SDK was not modified.
- No device build or screenshot claims are made.

## Structure

`lib/app` holds routing, themes and localization; `lib/core` holds reusable controls and the future Dio transport; `lib/shared` holds deterministic models and BLoC/Cubit state; `lib/features` holds feature screens. `BankingCubit.transfer` validates the amount and updates the source account and transaction list together.

## Screenshot review

Run on an iOS simulator or Android emulator. Complete onboarding/login, then capture Home, Accounts, Cards, Transfer review and Settings in both themes. Switch language in Profile → Settings. Repeat at small phone, standard phone, large phone, tablet and landscape sizes, and with accessibility text scaling enabled. Confirm every page scrolls, the keyboard leaves form actions reachable, balances hide, and no overflow warning appears. Use the platform screenshot shortcut or `flutter screenshot -o screenshots/home.png` after creating a `screenshots` directory.

## Visual reference

The red-and-white payment styling takes inspiration from the [official Bakong KHQR references](https://bakong.nbc.gov.kh/en/). Khmer Bank remains a fictional demo. The receive card is a decorative UI preview, not a generated KHQR payload or a real payment destination.

## Adaptive iOS interface

`adaptive_platform_ui` ^1.0.2 is integrated through `AdaptiveApp.router`. iOS receives separate Cupertino light/dark themes, native toolbar and five-tab bar on iOS 26+, and the package's Cupertino fallback on earlier versions. Android retains Material 3. All three Flutter localization delegates are registered for English/Khmer. BLoC owns the shared theme/language/banking state; tab navigators retain their state.

Main iOS tabs expose notification/settings actions and a balance visibility menu. Detail/auth pages publish native toolbars with automatic back navigation. The native tab bar requests minimization on scroll and hides when the keyboard is visible. Shared primary buttons, switches, sliders and segmented controls adapt on iOS; `/showcase` includes interactive previews. The experimental native search tab bar is not enabled.

Install the new plugin and rebuild (hot reload cannot register iOS plugins):

```sh
flutter pub get
cd ios
pod install
cd ..
flutter run
```

The existing Runner and Podfile minimum remains iOS 15.0. Verify on an iOS 26+ simulator/device and an earlier iOS simulator, including back swipe cancellation, tab state, menu updates, keyboard visibility, portrait/landscape, large text, and light/dark/system themes in English/Khmer.

**Current adaptive integration validation:** dependency installation was attempted but `pub.dev` DNS resolution is unavailable and this package is not cached. The dependency lockfile and generated iOS plugin registration therefore have not been refreshed for this addition. Formatting completed, but compilation, updated static analysis, tests and native rendering cannot be verified until package installation succeeds. Previous clean analysis results apply to the earlier code, not this integration.

Reference: [Adaptive Platform UI package documentation](https://pub.dev/packages/adaptive_platform_ui).

## Fold-aware windows

`foldable` ^1.0.5 (compatible with the requested 1.0 API) wraps the app in `FoldableProvider` with `DisplayFeatureBridgeMode.none`. The version includes fixes for initial unknown hinge support and stale fold regions.

Banking screens use `FoldAwareBuilder` with local division/camera rectangles. Active vertical and horizontal folds place the main content and a scrolling account/activity companion on opposite sides of the actual region. Narrow unusable sides fall back to the larger clear pane. Regular iOS width classes enable the companion without requiring a hinge; compact classes retain one pane. Off iOS, unspecified classes permit a width-based fallback. Authentication stays a single form, clear of the fold. Geometry changes reposition the same keyed primary subtree to retain navigator and form state. Active camera rectangles are excluded locally, without publishing display features that would split framework dialogs.

The UI showcase has isolated live angle/posture/size-class diagnostics. The raw angle stream only rebuilds its readout; layout is driven by fold/region/size-class changes. The readout handles empty/completed streams and errors, with subscription disposal managed by `StreamBuilder`.

The installed Xcode reports iOS and Simulator SDK 27.1. Runner/Pods remain at deployment target 15.0. Debug simulator builds use `$(ARCHS_STANDARD)` with `ONLY_ACTIVE_ARCH = YES` to select the destination architecture; device, Release and Profile settings are unchanged. Native SDK behavior, rotation, Split View and fold transitions have not been verified on a simulator or physical hardware.

Geometry test source covers compact/regular/unspecified widths, off-center vertical and horizontal folds, narrow-pane fallback and active camera avoidance. `flutter pub get` remains blocked by unavailable `pub.dev` DNS and uncached plugins; neither new plugin has been installed or registered yet. Build/test success is not claimed. Run package installation and `pod install`, then fully rebuild before reviewing on the iPhone Duo simulator.

Reference: [foldable package documentation](https://pub.dev/packages/foldable).
