import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../spacing/gap.dart';
import '../spacing/spacing_tokens.dart';
import '../text/app_text.dart';

enum _HeaderVariant { greeting, search, backTitle }

/// Header reusable para [AppScaffold] con 3 variantes:
/// `greeting`, `search` y `backTitle`.
class AppScaffoldHeader extends StatelessWidget {
  const AppScaffoldHeader.greeting({
    super.key,
    required String this.greetingText,
    this.onNotificationTap,
  }) : _variant = _HeaderVariant.greeting,
       searchHintText = null,
       onSearchTap = null,
       title = null,
       onBackTap = null;

  const AppScaffoldHeader.search({
    super.key,
    this.searchHintText = 'Buscar...',
    this.onSearchTap,
    this.onNotificationTap,
  }) : _variant = _HeaderVariant.search,
       greetingText = null,
       title = null,
       onBackTap = null;

  const AppScaffoldHeader.backTitle({
    super.key,
    required String this.title,
    this.onBackTap,
  }) : _variant = _HeaderVariant.backTitle,
       greetingText = null,
       searchHintText = null,
       onSearchTap = null,
       onNotificationTap = null;

  final String? greetingText;
  final String? searchHintText;
  final String? title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final _HeaderVariant _variant;

  Widget _notificationButton() => IconButton(
    onPressed: onNotificationTap,
    icon: const Icon(Icons.notifications_none_rounded),
    color: AppColors.text300,
  );

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _HeaderVariant.greeting => Row(
        children: [
          Expanded(child: AppText.headline(greetingText!)),
          _notificationButton(),
        ],
      ),
      _HeaderVariant.search => Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bg900,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.bg800),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.text500,
                    ),
                    Gap.hXs(),
                    AppText.body(searchHintText!, color: AppColors.text500),
                  ],
                ),
              ),
            ),
          ),
          Gap.hXs(),
          _notificationButton(),
        ],
      ),
      _HeaderVariant.backTitle => Row(
        children: [
          IconButton(
            onPressed: onBackTap ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.text100,
          ),
          Expanded(child: AppText.title(title!, textAlign: TextAlign.center)),
          // Balancea visualmente el botón de regreso.
          const SizedBox(width: 48),
        ],
      ),
    };
  }
}

/// Estructura estándar de pantalla:
///
/// - `SafeArea` configurable.
/// - Padding base (`EdgeInsets.all(16)`).
/// - Cierre de teclado al tocar fuera.
/// - AppBar simple por `title/titleWidget` o custom por `appBar`.
/// - Header reusable por `header` ([AppScaffoldHeader]).
/// - Scroll opcional con `SingleChildScrollView`.
///
/// Reglas:
/// - Si el `body` ya es scrollable, usa `scrollable: false`.
/// - Si envías `appBar`, se ignoran `title/titleWidget/leading/actions`.
/// - Si envías `header`, no uses `appBar/title/titleWidget` al mismo tiempo.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.appBar,
    this.header,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.scrollable = false,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.safeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.dismissKeyboardOnTap = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomBar,
  }) : assert(
         header == null ||
             (appBar == null && title == null && titleWidget == null),
         'Si envías header, no uses appBar/title/titleWidget al mismo tiempo.',
       );

  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final PreferredSizeWidget? appBar;
  final Widget? header;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool dismissKeyboardOnTap;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomBar;

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (appBar != null) return appBar;
    if (title == null && titleWidget == null) return null;
    return AppBar(
      title: titleWidget ?? AppText.title(title!),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: header == null
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header!,
                Gap.vMd(),
                Expanded(child: body),
              ],
            ),
    );

    if (scrollable) {
      // Con scroll, el header acompaña al contenido.
      content = SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: header == null
              ? body
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header!, Gap.vMd(), body],
                ),
        ),
      );
    }

    if (safeArea) {
      content = SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: content,
      );
    }

    Widget scaffold = Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: content,
    );

    if (dismissKeyboardOnTap) {
      scaffold = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: scaffold,
      );
    }

    return scaffold;
  }
}
