import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qrgenerator/Utils/alertDialog.dart';
import 'package:qrgenerator/Utils/constants.dart';
import 'package:qrgenerator/Utils/responsive_widget.dart';
import 'package:qrgenerator/Utils/rounded_button.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  MetaSEO().config();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
        apiKey: "AIzaSyBfmvwE_om32sQLB8EgBpfBwfBRTRSBNko",
        authDomain: "softwarelab-by-encorange.firebaseapp.com",
        projectId: "softwarelab-by-encorange",
        storageBucket: "softwarelab-by-encorange.appspot.com",
        messagingSenderId: "182804209799",
        appId: "1:182804209799:web:384dd4de2413aa8e951822",
        measurementId: "G-WG6K1686BX"),
  );

  runApp(MyApp(initialQrData: _initialQrDataFromCurrentUrl()));
}

const Color backgroundBlue = Color(0xFF90B7D1); //purple
const Color darkBlue = Color(0xFF032137);
const Color lightBlue = Color(0xFF0282C7);
const Color flashGreen = Color(0xFF1FD1B9);
const String seoTitle = 'Free QR';
const String seoUrl = 'https://freeqr.softwarelabx.com/';
const String seoDescription = 'Free QR Code Generator';
const String analyticsPlatformId = 'free_qr';
const String analyticsPlatformName = 'Free QR';
const String analyticsToolId = 'free_qr_generator';
const String analyticsToolName = 'Free QR Generator';
const String analyticsSchemaVersion = 'free_qr_v1';
const List<String> _initialQrQueryParameters = ['value', 'data', 'text', 'qr'];

enum QuickQrLayout { large, small }

enum QuickQrStep { input, customize, download }

String _languageCode(bool useSpanish) => useSpanish ? 'es' : 'en';

String _colorToHex(Color color) =>
    color.value.toRadixString(16).padLeft(8, '0').toUpperCase();

String _devicePlatform() => kIsWeb ? 'web' : defaultTargetPlatform.name;

String _viewportBucket() {
  if (!kIsWeb) {
    return 'native';
  }

  final width = html.window.innerWidth ?? 0;
  if (width < 600) {
    return 'mobile';
  }
  if (width < 1024) {
    return 'tablet';
  }
  if (width < 1440) {
    return 'desktop';
  }
  return 'wide_desktop';
}

String _viewportOrientation() {
  if (!kIsWeb) {
    return 'native';
  }

  final width = html.window.innerWidth ?? 0;
  final height = html.window.innerHeight ?? 0;

  return width >= height ? 'landscape' : 'portrait';
}

String? _initialQrDataFromCurrentUrl() {
  if (!kIsWeb) {
    return null;
  }

  return _initialQrDataFromUri(Uri.parse(html.window.location.href));
}

String? _initialQrDataFromUri(Uri uri) {
  return _extractInitialQrData(uri) ?? _extractInitialQrDataFromFragment(uri);
}

String? _extractInitialQrData(Uri uri) {
  for (final parameterName in _initialQrQueryParameters) {
    final value = uri.queryParameters[parameterName];
    if (_hasInitialQrData(value)) {
      return value;
    }
  }

  final bareQueryValue = _bareValueQueryData(uri);
  if (_hasInitialQrData(bareQueryValue)) {
    return bareQueryValue;
  }

  final valuePathData = _valuePathData(uri);
  if (_hasInitialQrData(valuePathData)) {
    return valuePathData;
  }

  return null;
}

String? _extractInitialQrDataFromFragment(Uri uri) {
  final fragment = uri.fragment;
  if (fragment.isEmpty) {
    return null;
  }

  final normalizedFragment = fragment.startsWith('/') ? fragment : '/$fragment';
  return _extractInitialQrData(
      Uri.parse('https://free-qrcode.com$normalizedFragment'));
}

String? _bareValueQueryData(Uri uri) {
  if (uri.query.isEmpty) {
    return null;
  }

  final lastPathSegment =
      uri.pathSegments.isEmpty ? '' : uri.pathSegments.last.toLowerCase();
  if (lastPathSegment != 'value' && lastPathSegment != 'value=') {
    return null;
  }

  return Uri.decodeQueryComponent(uri.query);
}

String? _valuePathData(Uri uri) {
  final pathSegments = uri.pathSegments;

  for (final segment in pathSegments.reversed) {
    if (segment.toLowerCase().startsWith('value=')) {
      return segment.substring('value='.length);
    }
  }

  for (var index = 0; index < pathSegments.length - 1; index++) {
    if (pathSegments[index].toLowerCase() == 'value') {
      return pathSegments[index + 1];
    }
  }

  return null;
}

bool _hasInitialQrData(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _classifyQrData(String value) {
  final trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return 'empty';
  }

  final lowerValue = trimmedValue.toLowerCase();
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final phonePattern = RegExp(r'^\+?[0-9()\-\s]{7,}$');

  if (lowerValue.startsWith('http://') || lowerValue.startsWith('https://')) {
    return 'url';
  }
  if (lowerValue.startsWith('mailto:') || emailPattern.hasMatch(trimmedValue)) {
    return 'email';
  }
  if (lowerValue.startsWith('tel:') || phonePattern.hasMatch(trimmedValue)) {
    return 'phone';
  }
  if (lowerValue.startsWith('wifi:')) {
    return 'wifi';
  }
  if (lowerValue.startsWith('sms:')) {
    return 'sms';
  }
  if (lowerValue.startsWith('geo:')) {
    return 'geo';
  }
  if (lowerValue.startsWith('upi:')) {
    return 'payment';
  }
  if (lowerValue.startsWith('whatsapp://')) {
    return 'whatsapp';
  }

  return 'text';
}

class StripeSupportSection extends StatelessWidget {
  const StripeSupportSection({
    super.key,
    required this.useSpanish,
    required this.compact,
    this.onSupportPressed,
    this.onSupportReady,
  });

  final bool useSpanish;
  final bool compact;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onSupportReady;

  @override
  Widget build(BuildContext context) {
    final maxWidth = compact ? 320.0 : 460.0;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            useSpanish ? 'Te gusta esta herramienta?' : 'Like this tool?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 280 : 320),
            child: _StripeBuyButton(
              compact: compact,
              onPressed: onSupportPressed,
              onReady: onSupportReady,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              useSpanish
                  ? 'Estas herramientas son gratuitas. Si quieres ayudar a que los desarrolladores sigan creando herramientas gratis, puedes invitarnos un cafe.'
                  : 'These tools are free. If you would like to help the developers keep making free tools, you can sponsor the coffee.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StripeBuyButton extends StatefulWidget {
  const _StripeBuyButton({
    required this.compact,
    this.onPressed,
    this.onReady,
  });

  final bool compact;
  final VoidCallback? onPressed;
  final VoidCallback? onReady;

  @override
  State<_StripeBuyButton> createState() => _StripeBuyButtonState();
}

class _StripeBuyButtonState extends State<_StripeBuyButton> {
  static const String _stripeScriptUrl =
      'https://js.stripe.com/v3/buy-button.js';
  static const String _buyButtonId = 'buy_btn_1StauSErS4BEreV5TBeUB31X';
  static const String _publishableKey =
      'pk_live_51OmJtBErS4BEreV5UhzYaKOFcnSh7rBR8JhZVHxdoMOdASgGpvv5K7DR5iJObdGIJiMS6eHWhuI1DaiaaCQTi7nB006QQHO4DH';
  static const double _initialButtonHeight = 360;
  static const double _maxButtonHeight = 440;
  static const double _heightPadding = 8;
  static const double _minimumMeasuredHeight = 120;

  static int _viewTypeCounter = 0;
  static bool _stripeScriptInjected = false;

  late final String _viewType;
  html.DivElement? _container;
  html.Element? _stripeButton;
  Timer? _heightProbe;
  double _buttonHeight = _initialButtonHeight;
  int _stableHeightTicks = 0;
  bool _hasReportedReady = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'stripe-buy-button-view-${_viewTypeCounter++}';

    if (!kIsWeb) {
      return;
    }

    _ensureStripeScript();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final container = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'flex-start';

        container.onClick.listen((_) {
          widget.onPressed?.call();
        });

        final stripeButton = html.document.createElement('stripe-buy-button')
          ..setAttribute('buy-button-id', _buyButtonId)
          ..setAttribute('publishable-key', _publishableKey)
          ..style.display = 'block'
          ..style.width = '100%';

        _container = container;
        _stripeButton = stripeButton;
        container.children.add(stripeButton);
        return container;
      },
    );
    _startHeightProbe();
  }

  void _ensureStripeScript() {
    if (_stripeScriptInjected) {
      return;
    }

    final existingScript =
        html.document.querySelector('script[src="$_stripeScriptUrl"]');
    if (existingScript != null) {
      _stripeScriptInjected = true;
      return;
    }

    final script = html.ScriptElement()
      ..async = true
      ..src = _stripeScriptUrl;
    html.document.head?.append(script);
    _stripeScriptInjected = true;
  }

  void _startHeightProbe() {
    _heightProbe?.cancel();
    _heightProbe = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) {
        return;
      }

      final measuredHeight = _measureRenderedHeight();
      if (measuredHeight == null) {
        return;
      }

      if (!_hasReportedReady) {
        _hasReportedReady = true;
        widget.onReady?.call();
      }

      final nextHeight = (measuredHeight + _heightPadding)
          .clamp(0, _maxButtonHeight)
          .toDouble();
      if ((nextHeight - _buttonHeight).abs() > 1) {
        _stableHeightTicks = 0;
        setState(() {
          _buttonHeight = nextHeight;
        });
        return;
      }

      _stableHeightTicks++;
      if (_stableHeightTicks >= 6) {
        _heightProbe?.cancel();
      }
    });
  }

  double? _measureRenderedHeight() {
    final container = _container;
    final stripeButton = _stripeButton;
    if (container == null || stripeButton == null) {
      return null;
    }

    final iframe = stripeButton.shadowRoot?.querySelector('iframe') ??
        stripeButton.querySelector('iframe');
    var measuredHeight = iframe?.getBoundingClientRect().height ?? 0;
    final stripeScrollHeight = stripeButton.scrollHeight.toDouble();
    if (stripeScrollHeight > measuredHeight) {
      measuredHeight = stripeScrollHeight;
    }

    final stripeRectHeight = stripeButton.getBoundingClientRect().height;
    final isMeasuringAssignedHeight =
        (stripeRectHeight - _buttonHeight).abs() <= 1;
    if (!isMeasuringAssignedHeight && stripeRectHeight > measuredHeight) {
      measuredHeight = stripeRectHeight;
    }

    if (measuredHeight < _minimumMeasuredHeight) {
      return null;
    }

    return measuredHeight.toDouble();
  }

  @override
  void dispose() {
    _heightProbe?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _buttonHeight,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}

class QuickQrAnalyticsTracker {
  QuickQrAnalyticsTracker({
    required this.analytics,
    required this.layout,
  });

  final FirebaseAnalytics analytics;
  final QuickQrLayout layout;

  static final RegExp _invalidKeyChars = RegExp(r'[^a-zA-Z0-9_]');

  Future<void>? _configureFuture;
  String? _lastStep;
  String? _lastScreenName;

  String get _layoutName => layout.name;

  Future<void> initialize({required String language}) {
    return _configureFuture ??= _configure(language: language);
  }

  Future<void> _configure({required String language}) async {
    try {
      await analytics.setAnalyticsCollectionEnabled(true);
      await analytics.setDefaultEventParameters({
        'platform_id': analyticsPlatformId,
        'platform_name': analyticsPlatformName,
        'tool_id': analyticsToolId,
        'analytics_schema': analyticsSchemaVersion,
      });
      await _setUserProperty(name: 'platform_id', value: analyticsPlatformId);
      await _setUserProperty(name: 'tool_id', value: analyticsToolId);
      await _setUserProperty(name: 'layout_type', value: _layoutName);
      await _setUserProperty(name: 'lang_code', value: language);
      await _setUserProperty(
          name: 'editor_step', value: QuickQrStep.input.name);
      await _setUserProperty(name: 'qr_ready', value: 'no');
      await _setUserProperty(name: 'qr_input_type', value: 'empty');
      await _setUserProperty(name: 'support_seen', value: 'no');

      await _logStepScreenView(
        step: QuickQrStep.input,
        language: language,
        snapshot: const {
          'data_type': 'empty',
          'data_length': 0,
          'qr_ready': false,
        },
      );
      await _logEvent(
        'free_qr_session_start',
        params: {
          'layout': _layoutName,
          'language': language,
          'tool_name': analyticsToolName,
          'site_domain': Uri.parse(seoUrl).host,
          'device_platform': _devicePlatform(),
          'runtime': kReleaseMode ? 'release' : 'debug',
          'viewport_bucket': _viewportBucket(),
          'viewport_orientation': _viewportOrientation(),
        },
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics initialization failed: $error');
      }
    }
  }

  Future<void> trackLifecycle({
    required AppLifecycleState state,
    required String language,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _logEditorEvent(
      'free_qr_lifecycle',
      snapshot: snapshot,
      extra: {
        'language': language,
        'lifecycle_state': state.name,
      },
    );
  }

  Future<void> trackStepView({
    required QuickQrStep step,
    required String language,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    final stepName = step.name;
    if (_lastStep == stepName) {
      return;
    }

    _lastStep = stepName;
    await _setUserProperty(name: 'editor_step', value: stepName);
    await _setSnapshotUserProperties(snapshot);

    await _logStepScreenView(
      step: step,
      language: language,
      snapshot: snapshot,
    );
    await _logEditorEvent(
      'free_qr_step_view',
      snapshot: snapshot,
      extra: {
        'language': language,
        'step': stepName,
      },
    );
  }

  Future<void> trackLanguageToggle({
    required String language,
    required String previousLanguage,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _setUserProperty(name: 'lang_code', value: language);
    await _logEditorEvent(
      'free_qr_language_change',
      snapshot: snapshot,
      extra: {
        'language': language,
        'previous_language': previousLanguage,
      },
    );
  }

  Future<void> trackInputStarted({
    required String language,
    required String inputType,
    required int draftLength,
  }) async {
    await initialize(language: language);
    await _setUserProperty(name: 'qr_input_type', value: inputType);
    await _logEvent(
      'free_qr_input_start',
      params: {
        'layout': _layoutName,
        'language': language,
        'draft_type': inputType,
        'draft_length': draftLength,
      },
    );
  }

  Future<void> trackInputCleared({
    required String language,
  }) async {
    await initialize(language: language);
    await _setUserProperty(name: 'qr_input_type', value: 'empty');
    await _logEvent(
      'free_qr_input_clear',
      params: {
        'layout': _layoutName,
        'language': language,
      },
    );
  }

  Future<void> trackInputSubmitted({
    required String language,
    required String inputSource,
    required String status,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _logEditorEvent(
      'free_qr_input_submit',
      snapshot: snapshot,
      extra: {
        'language': language,
        'input_source': inputSource,
        'status': status,
      },
    );
  }

  Future<void> trackQrGenerated({
    required String language,
    required String inputSource,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _setSnapshotUserProperties(snapshot);
    await _logEditorEvent(
      'free_qr_generate',
      snapshot: snapshot,
      extra: {
        'language': language,
        'input_source': inputSource,
      },
    );
  }

  Future<void> trackCustomization({
    required String language,
    required String control,
    required String action,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _setSnapshotUserProperties(snapshot);
    await _logEditorEvent(
      'free_qr_customize',
      snapshot: snapshot,
      extra: {
        'language': language,
        'control': control,
        'action': action,
      },
    );
  }

  Future<void> trackReset({
    required String language,
    required String phase,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    if (phase == 'confirmed') {
      await _setUserProperty(name: 'qr_ready', value: 'no');
      await _setUserProperty(
          name: 'editor_step', value: QuickQrStep.input.name);
      await _setUserProperty(name: 'qr_input_type', value: 'empty');
      await _setUserProperty(name: 'has_image', value: 'no');
      await _setUserProperty(name: 'has_caption', value: 'no');
    }
    await _logEditorEvent(
      'free_qr_reset',
      snapshot: snapshot,
      extra: {
        'language': language,
        'phase': phase,
      },
    );
  }

  Future<void> trackDownload({
    required String language,
    required String status,
    required Map<String, Object?> snapshot,
    String? errorText,
  }) async {
    await initialize(language: language);
    await _setSnapshotUserProperties(snapshot);
    await _logEditorEvent(
      'free_qr_download',
      snapshot: snapshot,
      extra: {
        'language': language,
        'status': status,
        'file_type': 'png',
        'file_name': 'screenshot.png',
        if (errorText != null && errorText.isNotEmpty) 'error_text': errorText,
      },
    );
  }

  Future<void> trackSupportAction({
    required String language,
    required String action,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    if (action == 'shown' || action == 'stripe_loaded') {
      await _setUserProperty(name: 'support_seen', value: 'yes');
    }
    await _logEditorEvent(
      'free_qr_support',
      snapshot: snapshot,
      extra: {
        'language': language,
        'action': action,
      },
    );
  }

  Future<void> trackOutboundClick({
    required String language,
    required String destination,
    required Uri uri,
    required bool success,
    required Map<String, Object?> snapshot,
  }) async {
    await initialize(language: language);
    await _logEditorEvent(
      'free_qr_outbound',
      snapshot: snapshot,
      extra: {
        'language': language,
        'destination': destination,
        'launch_ok': success,
        'link_scheme': uri.scheme,
        'link_host': uri.host.isNotEmpty ? uri.host : uri.path,
      },
    );
  }

  Future<void> _setSnapshotUserProperties(Map<String, Object?> snapshot) async {
    await _setUserProperty(
      name: 'qr_ready',
      value: snapshot['qr_ready'] == true ? 'yes' : 'no',
    );
    await _setUserProperty(
      name: 'qr_input_type',
      value: snapshot['data_type']?.toString(),
    );
    await _setUserProperty(
      name: 'has_image',
      value: snapshot['has_center_image'] == true ? 'yes' : 'no',
    );
    await _setUserProperty(
      name: 'has_caption',
      value: snapshot['has_caption'] == true ? 'yes' : 'no',
    );
  }

  Future<void> _logStepScreenView({
    required QuickQrStep step,
    required String language,
    required Map<String, Object?> snapshot,
  }) async {
    final screenName = '${analyticsPlatformId}_${_layoutName}_${step.name}';
    if (_lastScreenName == screenName) {
      return;
    }

    _lastScreenName = screenName;
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: analyticsToolId,
        parameters: _sanitizeParameters({
          'layout': _layoutName,
          'language': language,
          'step': step.name,
          'data_type': snapshot['data_type'],
          'qr_ready': snapshot['qr_ready'],
          'viewport_bucket': _viewportBucket(),
          'viewport_orientation': _viewportOrientation(),
        }),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics screen "$screenName" failed: $error');
      }
    }
  }

  Future<void> _logEditorEvent(
    String name, {
    required Map<String, Object?> snapshot,
    Map<String, Object?> extra = const {},
  }) {
    return _logEvent(
      name,
      params: {
        'layout': _layoutName,
        'viewport_bucket': _viewportBucket(),
        'viewport_orientation': _viewportOrientation(),
        ...snapshot,
        ...extra,
      },
    );
  }

  Future<void> _logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: _sanitizeParameters(params),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics event "$name" failed: $error');
      }
    }
  }

  Future<void> _setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await analytics.setUserProperty(
        name: name,
        value: value == null ? null : _truncate(value, 36),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics user property "$name" failed: $error');
      }
    }
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> params) {
    final sanitized = <String, Object>{};

    params.forEach((key, value) {
      final normalizedValue = _normalizeValue(value);
      if (normalizedValue == null) {
        return;
      }

      var sanitizedKey = key.replaceAll(_invalidKeyChars, '_');
      if (sanitizedKey.isEmpty ||
          !RegExp(r'^[A-Za-z]').hasMatch(sanitizedKey)) {
        sanitizedKey = 'p_$sanitizedKey';
      }
      sanitizedKey = _truncate(sanitizedKey, 40);

      sanitized[sanitizedKey] = normalizedValue;
    });

    return sanitized;
  }

  Object? _normalizeValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num) {
      return value;
    }
    if (value is Enum) {
      return _truncate(value.name, 100);
    }
    if (value is String) {
      return _truncate(value, 100);
    }

    return _truncate(value.toString(), 100);
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return value.substring(0, maxLength);
  }
}

abstract class QuickQrEditorState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController textController = TextEditingController();

  static const double _defaultOutlineWidth = 1;
  static const double _defaultCodeTextSize = 20;

  QuickQrLayout get layout;
  String? get initialQrData;

  late final QuickQrAnalyticsTracker _tracker = QuickQrAnalyticsTracker(
    analytics: analytics,
    layout: layout,
  );

  String data = '';
  bool toggleLanguage = false;
  Color currentColor = darkBlue;
  Color codeBackground = Colors.white;
  bool roundedCorners = false;
  bool outline = false;
  double outlineWidth = _defaultOutlineWidth;
  String codeText = '';
  double codeTextSize = _defaultCodeTextSize;
  Uint8List? imageFile;
  int _previewVersion = 0;
  bool _hasLoggedInputStart = false;
  bool _hasLoggedSupportPromptShown = false;

  bool get imageAvailable => imageFile != null;

  String get _language => _languageCode(toggleLanguage);

  Map<String, Object?> _analyticsSnapshot() {
    return {
      'data_type': _classifyQrData(data),
      'data_length': data.length,
      'qr_ready': data.isNotEmpty,
      'rounded_corners': roundedCorners,
      'outline_enabled': outline,
      'outline_width': outlineWidth.round(),
      'has_center_image': imageAvailable,
      'has_caption': codeText.trim().isNotEmpty,
      'caption_length': codeText.trim().length,
      'caption_size': codeTextSize.round(),
      'code_color': _colorToHex(currentColor),
      'bg_color': _colorToHex(codeBackground),
      'preview_version': _previewVersion,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_tracker.initialize(language: _language));
    unawaited(
      _tracker.trackStepView(
        step: QuickQrStep.input,
        language: _language,
        snapshot: _analyticsSnapshot(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialQrData();
    });
  }

  void _applyInitialQrData() {
    if (!mounted || data.isNotEmpty) {
      return;
    }

    final initialData = initialQrData;
    if (!_hasInitialQrData(initialData)) {
      return;
    }

    textController.text = initialData!;
    _hasLoggedInputStart = true;
    handleSubmit(initialData, source: 'url');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      _tracker.trackLifecycle(
        state: state,
        language: _language,
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _setState(VoidCallback updates) {
    if (!mounted) return;
    setState(updates);
  }

  void _updatePreview(VoidCallback updates) {
    _setState(() {
      updates();
      _previewVersion++;
    });
  }

  void _toggleLanguage() {
    final previousLanguage = _language;
    _setState(() {
      toggleLanguage = !toggleLanguage;
    });
    unawaited(
      _tracker.trackLanguageToggle(
        language: _language,
        previousLanguage: previousLanguage,
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _showResetDialog() {
    unawaited(
      _tracker.trackReset(
        language: _language,
        phase: 'requested',
        snapshot: _analyticsSnapshot(),
      ),
    );

    showAlertPopup(
      context,
      toggleLanguage ? 'Volver al paso 1' : 'Go back step 1',
      toggleLanguage
          ? 'Se tendrá que volver a generar un nuevo código QR'
          : 'A new QR Code will have to be generated',
      'OK',
      toggleLanguage ? 'Cancelar' : 'Cancel',
      () {
        unawaited(
          _tracker.trackReset(
            language: _language,
            phase: 'confirmed',
            snapshot: _analyticsSnapshot(),
          ),
        );
        _resetEditor();
        Navigator.pop(context);
      },
    );
  }

  void _resetEditor() {
    _setState(() {
      textController.clear();
      data = '';
      currentColor = darkBlue;
      codeBackground = Colors.white;
      roundedCorners = false;
      outline = false;
      outlineWidth = _defaultOutlineWidth;
      codeText = '';
      codeTextSize = _defaultCodeTextSize;
      imageFile = null;
      _previewVersion = 0;
      _hasLoggedInputStart = false;
      _hasLoggedSupportPromptShown = false;
    });

    unawaited(
      _tracker.trackStepView(
        step: QuickQrStep.input,
        language: _language,
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _handleDataInputChanged(String value) {
    final hasValue = value.trim().isNotEmpty;
    if (!_hasLoggedInputStart && hasValue) {
      _hasLoggedInputStart = true;
      unawaited(
        _tracker.trackInputStarted(
          language: _language,
          inputType: _classifyQrData(value),
          draftLength: value.length,
        ),
      );
      return;
    }

    if (_hasLoggedInputStart && !hasValue) {
      _hasLoggedInputStart = false;
      unawaited(
        _tracker.trackInputCleared(language: _language),
      );
    }
  }

  void handleSubmit(String value, {required String source}) {
    _updatePreview(() {
      data = value;
    });

    final snapshot = _analyticsSnapshot();
    unawaited(
      _tracker.trackInputSubmitted(
        language: _language,
        inputSource: source,
        status: data.isEmpty ? 'empty' : 'accepted',
        snapshot: snapshot,
      ),
    );

    if (data.isEmpty) {
      return;
    }

    unawaited(
      _tracker.trackQrGenerated(
        language: _language,
        inputSource: source,
        snapshot: snapshot,
      ),
    );

    unawaited(
      _tracker.trackStepView(
        step: QuickQrStep.customize,
        language: _language,
        snapshot: snapshot,
      ),
    );
    unawaited(
      _tracker.trackStepView(
        step: QuickQrStep.download,
        language: _language,
        snapshot: snapshot,
      ),
    );

    if (!_hasLoggedSupportPromptShown) {
      _hasLoggedSupportPromptShown = true;
      unawaited(
        _tracker.trackSupportAction(
          language: _language,
          action: 'shown',
          snapshot: snapshot,
        ),
      );
    }
  }

  void _handleSupportPressed() {
    unawaited(
      _tracker.trackSupportAction(
        language: _language,
        action: 'clicked',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _handleSupportReady() {
    unawaited(
      _tracker.trackSupportAction(
        language: _language,
        action: 'stripe_loaded',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  Future<void> _pickQrColor() async {
    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'qr_color',
        action: 'picker_opened',
        snapshot: _analyticsSnapshot(),
      ),
    );

    final selectedColor = await _showColorPickerDialog(
      context: context,
      useSpanish: toggleLanguage,
      initialColor: currentColor,
    );
    if (selectedColor == null) {
      unawaited(
        _tracker.trackCustomization(
          language: _language,
          control: 'qr_color',
          action: 'picker_cancelled',
          snapshot: _analyticsSnapshot(),
        ),
      );
      return;
    }

    _updatePreview(() {
      currentColor = selectedColor;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'qr_color',
        action: 'changed',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  Future<void> _pickBackgroundColor() async {
    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'background',
        action: 'picker_opened',
        snapshot: _analyticsSnapshot(),
      ),
    );

    final selectedColor = await _showColorPickerDialog(
      context: context,
      useSpanish: toggleLanguage,
      initialColor:
          codeBackground == Colors.transparent ? Colors.white : codeBackground,
    );
    if (selectedColor == null) {
      unawaited(
        _tracker.trackCustomization(
          language: _language,
          control: 'background',
          action: 'picker_cancelled',
          snapshot: _analyticsSnapshot(),
        ),
      );
      return;
    }

    _updatePreview(() {
      codeBackground = selectedColor;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'background',
        action: 'changed',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _clearBackground() {
    if (codeBackground == Colors.transparent) return;

    _updatePreview(() {
      codeBackground = Colors.transparent;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'background',
        action: 'cleared',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _setRoundedCorners(bool value) {
    if (roundedCorners == value) return;

    _updatePreview(() {
      roundedCorners = value;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'rounded_corners',
        action: value ? 'enabled' : 'disabled',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _setOutline(bool value) {
    if (outline == value) return;

    _updatePreview(() {
      outline = value;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'outline',
        action: value ? 'enabled' : 'disabled',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _setOutlineWidth(double value) {
    _updatePreview(() {
      outlineWidth = value;
    });
  }

  void _commitOutlineWidth(double value) {
    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'outline_width',
        action: 'changed',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _setCodeText(String value) {
    final hadCaption = codeText.trim().isNotEmpty;

    _updatePreview(() {
      codeText = value;
    });

    final hasCaption = codeText.trim().isNotEmpty;
    if (!hadCaption && hasCaption) {
      unawaited(
        _tracker.trackCustomization(
          language: _language,
          control: 'caption',
          action: 'added',
          snapshot: _analyticsSnapshot(),
        ),
      );
    } else if (hadCaption && !hasCaption) {
      unawaited(
        _tracker.trackCustomization(
          language: _language,
          control: 'caption',
          action: 'cleared',
          snapshot: _analyticsSnapshot(),
        ),
      );
    }
  }

  void _setCodeTextSize(double value) {
    _updatePreview(() {
      codeTextSize = value;
    });
  }

  void _commitCodeTextSize(double value) {
    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'caption_size',
        action: 'changed',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  void _removeCenterImage() {
    if (!imageAvailable) return;

    _updatePreview(() {
      imageFile = null;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'center_image',
        action: 'removed',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  Future<void> _pickCenterImage() async {
    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'center_image',
        action: 'picker_opened',
        snapshot: _analyticsSnapshot(),
      ),
    );

    final image = await ImagePickerWeb.getImageAsBytes();
    if (image == null) {
      unawaited(
        _tracker.trackCustomization(
          language: _language,
          control: 'center_image',
          action: 'picker_cancelled',
          snapshot: _analyticsSnapshot(),
        ),
      );
      return;
    }

    _updatePreview(() {
      imageFile = image;
    });

    unawaited(
      _tracker.trackCustomization(
        language: _language,
        control: 'center_image',
        action: 'added',
        snapshot: _analyticsSnapshot(),
      ),
    );
  }

  Future<void> _capturePng() async {
    final snapshotBeforeDownload = _analyticsSnapshot();
    unawaited(
      _tracker.trackDownload(
        language: _language,
        status: 'attempt',
        snapshot: snapshotBeforeDownload,
      ),
    );

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "screenshot.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      }

      await _tracker.trackDownload(
        language: _language,
        status: 'success',
        snapshot: _analyticsSnapshot(),
      );
    } catch (error) {
      await _tracker.trackDownload(
        language: _language,
        status: 'failure',
        snapshot: _analyticsSnapshot(),
        errorText: error.toString(),
      );
      if (kDebugMode) {
        debugPrint('Image download failed: $error');
      }
    }
  }

  Future<void> _openTrackedUri({
    required Uri uri,
    required String destination,
  }) async {
    final launched = await launchUrl(uri);
    await _tracker.trackOutboundClick(
      language: _language,
      destination: destination,
      uri: uri,
      success: launched,
      snapshot: _analyticsSnapshot(),
    );

    if (!launched && kDebugMode) {
      debugPrint('Could not launch $uri');
    }
  }
}

Future<Color?> _showColorPickerDialog({
  required BuildContext context,
  required bool useSpanish,
  required Color initialColor,
}) {
  Color selectedColor = initialColor;

  return showDialog<Color>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              useSpanish ? 'Elegir color' : 'Choose a color',
              style:
                  const TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setDialogState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(selectedColor);
                },
                child: Text(useSpanish ? 'Seleccionar' : 'Select'),
              ),
            ],
          );
        },
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.initialQrData}) : super(key: key);

  final String? initialQrData;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // here you can add any tags does not exist in the package as this
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Futura'),
      title: seoTitle,
      home: MyHomePage(initialQrData: initialQrData),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.initialQrData}) : super(key: key);

  final String? initialQrData;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(initialQrData: widget.initialQrData),
      smallScreen: SmallScreen(initialQrData: widget.initialQrData),
    );
  }
}

///LARGE SCREEN
class LargeScreen extends StatefulWidget {
  const LargeScreen({super.key, this.initialQrData});

  final String? initialQrData;

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends QuickQrEditorState<LargeScreen> {
  @override
  QuickQrLayout get layout => QuickQrLayout.large;

  @override
  String? get initialQrData => widget.initialQrData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      extendBodyBehindAppBar: true,
      appBar: data.isNotEmpty
          ? AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 100,
              leading: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: data.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                tooltip: toggleLanguage
                                    ? 'Volver a emepezar'
                                    : 'Start over',
                                onPressed: _showResetDialog,
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: darkBlue,
                                  size: 30,
                                )),
                            Image.asset(
                              'images/Logo_generator.png',
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QuickQR',
                                    style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700)),
                                Text('Generator',
                                    style: TextStyle(
                                        color: lightBlue,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        )
                      : Container()),
              leadingWidth: 300,
              elevation: 0.0,
              bottomOpacity: 0.0,
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: _toggleLanguage,
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: _toggleLanguage,
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Generator container:
            ///Textfield:
            data.isNotEmpty
                ? Container()
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/Logo_generator.png',
                          height: 150,
                          width: 150,
                        ),
                        const Text('QuickQR',
                            style: TextStyle(
                                color: darkBlue,
                                fontSize: 35,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 50),

                        //instructions:  step 1.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 1' : 'Step 1',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Insertar texto para convertirlo en código QR'
                                    : 'Insert text to convert it to QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Data Textfield:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 300,
                              child: TextField(
                                controller: textController,
                                obscureText: false,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (value) =>
                                    handleSubmit(value, source: 'keyboard'),
                                onChanged: _handleDataInputChanged,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: toggleLanguage
                                      ? 'Vinculo, texto, etc...'
                                      : 'Link, text, etc...', //as a placeholder text.
                                  hintStyle: const TextStyle(color: darkBlue),
                                  //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                  // counterText:
                                  //     'Correo electronico', //below to the right.
                                  //helperText: 'helper text', //below to the left
                                  labelText: toggleLanguage
                                      ? 'Insertar texto aqui...'
                                      : 'Insert data here...', //normal text inside
                                  errorStyle:
                                      const TextStyle(color: flashGreen),
                                  labelStyle: const TextStyle(
                                      color: Colors.grey, fontFamily: 'Futura'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: darkBlue, width: 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: lightBlue, width: 2.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            RoundedButton(
                                color: darkBlue,
                                textColor: Colors.white,
                                title: toggleLanguage
                                    ? 'Generar código'
                                    : 'Generate code',
                                width: 200,
                                pressed: () {
                                  handleSubmit(
                                    textController.text,
                                    source: 'button',
                                  );
                                }),
                          ],
                        ),
                        const SizedBox(height: 50),
                        //Tagline:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Powered by',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10)),
                            //button logo
                            IconButton(
                              onPressed: () {
                                final Uri link = Uri.parse(Website);
                                unawaited(
                                  _openTrackedUri(
                                    uri: link,
                                    destination: 'powered_by_tagline',
                                  ),
                                );
                              },
                              icon: Image.asset(
                                'images/Tagline.png',
                                width: 150,
                                color: lightBlue,
                              ),
                              iconSize: 75,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

            ///QR Code:
            data.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 150, bottom: 50, right: 100, left: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Instructions:  step 2.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 2' : 'Step 2',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Personaliza tu código QR'
                                    : 'Personalize your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Editor end view
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///QR Code
                              Column(
                                children: [
                                  RepaintBoundary(
                                    key: _globalKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Set the border radius
                                        color: codeBackground,
                                        border: Border.all(
                                          color: outline
                                              ? currentColor
                                              : Colors
                                                  .transparent, // Set the border color
                                          width:
                                              outlineWidth, // Set the border width
                                        ),
                                        // Set the background color
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: Column(
                                          children: [
                                            PrettyQr(
                                              key: ValueKey(
                                                  'large-qr-$_previewVersion'),
                                              image: imageAvailable
                                                  ? MemoryImage(imageFile!)
                                                  : null, //const AssetImage('images/Logo_iago.png'),
                                              typeNumber: null,
                                              size: 400,
                                              data: data,
                                              errorCorrectLevel:
                                                  QrErrorCorrectLevel.H,
                                              roundEdges: roundedCorners,
                                              elementColor: currentColor,
                                            ),
                                            codeText.isEmpty
                                                ? Container()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15),
                                                    child: Text(codeText,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: currentColor,
                                                            fontSize:
                                                                codeTextSize,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                      toggleLanguage
                                          ? 'Vista previa'
                                          : 'Preview',
                                      style: TextStyle(
                                          color: currentColor.withOpacity(0.5),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),

                              ///tools
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Set the border radius
                                  color:
                                      codeBackground, // Set the background color
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ///buttons :
                                      RoundedButton(
                                          color: currentColor,
                                          textColor: Colors.white,
                                          title: toggleLanguage
                                              ? 'Color del código'
                                              : 'QR Code\'s color',
                                          width: 250,
                                          pressed: _pickQrColor),
                                      Row(
                                        children: [
                                          RoundedButton(
                                              color: codeBackground,
                                              textColor: currentColor,
                                              title: toggleLanguage
                                                  ? 'Color del fondo'
                                                  : 'Background color',
                                              width: 200,
                                              pressed: _pickBackgroundColor),
                                          IconButton(
                                              tooltip: toggleLanguage
                                                  ? 'Eliminar fondo'
                                                  : 'Delete background',
                                              icon: const Icon(
                                                  Icons.highlight_remove,
                                                  color: Colors.red),
                                              onPressed: _clearBackground),
                                        ],
                                      ),

                                      ///rounded switch
                                      const Divider(),
                                      Row(
                                        children: [
                                          Text(
                                            toggleLanguage
                                                ? 'Redondear'
                                                : 'Rounded corners',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: currentColor),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Switch(
                                            activeColor: currentColor,
                                            inactiveTrackColor: Colors.grey,
                                            value: roundedCorners,
                                            onChanged: _setRoundedCorners,
                                          ),
                                        ],
                                      ),

                                      ///outline switch
                                      const Divider(),
                                      Row(
                                        children: [
                                          Text(
                                            toggleLanguage
                                                ? 'Contorno'
                                                : 'Outline',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: currentColor),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Switch(
                                            activeColor: currentColor,
                                            inactiveTrackColor: Colors.grey,
                                            value: outline,
                                            onChanged: _setOutline,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        toggleLanguage
                                            ? 'Tamaño del contorno'
                                            : 'Outline size',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Slider(
                                        activeColor: currentColor,
                                        inactiveColor: Colors.grey,
                                        value: outlineWidth,
                                        min: 1.0,
                                        max: 20.0,
                                        onChanged: _setOutlineWidth,
                                        onChangeEnd: _commitOutlineWidth,
                                      ),

                                      const Divider(),

                                      ///ImagePicker
                                      GestureDetector(
                                        child: imageAvailable
                                            ? Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    20.0)),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              offset:
                                                                  const Offset(
                                                                      2.0, 2.0),
                                                              blurRadius: 5.0,
                                                              spreadRadius:
                                                                  0.5),
                                                        ],
                                                      ),
                                                      child: Image.memory(
                                                          imageFile!,
                                                          height: 250,
                                                          width: 250,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -0,
                                                    right: -0,
                                                    child: GestureDetector(
                                                      onTap: _removeCenterImage,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.red,
                                                        ),
                                                        child: const Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: 15),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                height: 250.0,
                                                width: 250.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              20.0)),
                                                  color: currentColor
                                                      .withOpacity(0.5),
                                                  shape: BoxShape.rectangle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade200,
                                                        offset: const Offset(
                                                            2.0, 2.0),
                                                        blurRadius: 5.0,
                                                        spreadRadius: 0.5),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .add_photo_alternate_outlined,
                                                        size: 30,
                                                        color: Colors.white),
                                                    Text(
                                                        toggleLanguage
                                                            ? 'Agregar imagen al centro del QR'
                                                            : 'Add image to the center of the code',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                        onTap: _pickCenterImage,
                                      ),
                                      const Divider(),

                                      ///Code text
                                      SizedBox(
                                        height: 50,
                                        width: 250,
                                        child: TextField(
                                          //controller: textController,
                                          obscureText: false,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.name,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          onChanged: _setCodeText,
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: toggleLanguage
                                                ? 'Escaneame!...'
                                                : 'Scan me!...', //as a placeholder text.
                                            hintStyle: const TextStyle(
                                                color: darkBlue),
                                            //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                            // counterText:
                                            //     'Correo electronico', //below to the right.
                                            //helperText: 'helper text', //below to the left
                                            labelText: toggleLanguage
                                                ? 'Agregar texto...'
                                                : 'Add text here...', //normal text inside
                                            errorStyle: const TextStyle(
                                                color: flashGreen),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontFamily: 'Futura'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20.0),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: darkBlue, width: 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: lightBlue, width: 2.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        toggleLanguage
                                            ? 'Tamaño del texto'
                                            : 'Text size',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Slider(
                                        activeColor: currentColor,
                                        inactiveColor: Colors.grey,
                                        value: codeTextSize,
                                        min: 10.0,
                                        max: 50.0,
                                        onChanged: _setCodeTextSize,
                                        onChangeEnd: _commitCodeTextSize,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),

                        ///Instructions:  step 3.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 3' : 'Step 3',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Descarga tu código QR'
                                    : 'Download your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Download button
                        RoundedButton(
                            color: darkBlue,
                            textColor: Colors.white,
                            title: toggleLanguage ? 'Descargar' : 'Download',
                            width: 200,
                            pressed: _capturePng),
                        Container(
                          child: StripeSupportSection(
                            useSpanish: toggleLanguage,
                            compact: false,
                            onSupportPressed: _handleSupportPressed,
                            onSupportReady: _handleSupportReady,
                          ),
                        ),

                        ///Tagline:
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              toggleLanguage
                                  ? const Text('Web app desarrollada por',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10))
                                  : const Text('Powered by',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10)),
                              //tagline
                              IconButton(
                                onPressed: () {
                                  final Uri link = Uri.parse(Website);
                                  unawaited(
                                    _openTrackedUri(
                                      uri: link,
                                      destination: 'powered_by_footer',
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  'images/Tagline.png',
                                  width: 150,
                                  color: lightBlue,
                                ),
                                iconSize: 75,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

            ///Bottom container
            Container(
              height: 200.0,
              width: double.infinity,
              color: darkBlue,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 20.0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Social Media, profile and legal Links:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.pushNamed(context, ProfileScreen.id);
                        //   },
                        //   child: const Text(
                        //     'My Account Information',
                        //     textAlign: TextAlign.start,
                        //     style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        //Email contact
                        Row(children: [
                          const Icon(
                            Icons.local_post_office,
                            color: Colors.white,
                            size: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                String? encodeQueryParameters(
                                    Map<String, String> params) {
                                  return params.entries
                                      .map((MapEntry<String, String> e) =>
                                          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                      .join('&');
                                }

                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: contactEmail,
                                  query: encodeQueryParameters(<String, String>{
                                    'subject': 'Hello SoftwareLab!',
                                    'body':
                                        'I\'d Just checked out the QR generator...',
                                  }),
                                );
                                unawaited(
                                  _openTrackedUri(
                                    uri: emailLaunchUri,
                                    destination: 'contact_email',
                                  ),
                                );
                              },
                              child: const Text(
                                contactEmail,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              )),
                        ]),
                        //location info
                        Row(children: [
                          const Icon(
                            Icons.edit_location,
                            color: Colors.white,
                            size: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                final Uri link = Uri.parse(
                                    'https://goo.gl/maps/wpm2LhGHeiw9LqXB7');
                                unawaited(
                                  _openTrackedUri(
                                    uri: link,
                                    destination: 'location_map',
                                  ),
                                );
                              },
                              child: const Text(
                                '900 Biscayne Blvd, Miami, FL 33132',
                                style: TextStyle(color: Colors.white),
                              )),
                        ]),
                        const SizedBox(height: 15),
                        toggleLanguage
                            ? const Text('Siguenos en',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                            : const Text('Follow us on',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                        //Social media outlets
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //   icon: Image.asset('images/youtube.png',
                            //       height: 25,
                            //       color: Colors
                            //           .white), // Replace 'assets/icon.png' with your image asset
                            //   onPressed: () {
                            //     analytics.logEvent(
                            //       name: 'QuickQR - Youtube SoftwareLab',
                            //       parameters: <String, dynamic>{
                            //         'YouTube Redirect': data,
                            //       },
                            //     );
                            //     final Uri link = Uri.parse(YouTube);
                            //     launchURL(link);
                            //   },
                            // ),
                            // const SizedBox(width: 5),
                            IconButton(
                              onPressed: () {
                                final Uri link = Uri.parse(Instagram);
                                unawaited(
                                  _openTrackedUri(
                                    uri: link,
                                    destination: 'instagram',
                                  ),
                                );
                              },
                              icon: Image.asset('images/instagram.png',
                                  height: 25, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //Logo
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'images/logo.png',
                            width: 100,
                          ),
                          onPressed: () {
                            final Uri link =
                                Uri.parse('https://softwarelabx.com/');
                            unawaited(
                              _openTrackedUri(
                                uri: link,
                                destination: 'company_website',
                              ),
                            );
                          },
                        ),
                        toggleLanguage
                            ? const Text(
                                'Todos los derechos reservados © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            : const Text(
                                'All rights reserved © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///SMALL SCREEN
class SmallScreen extends StatefulWidget {
  const SmallScreen({super.key, this.initialQrData});

  final String? initialQrData;

  @override
  State<SmallScreen> createState() => _SmallScreenState();
}

class _SmallScreenState extends QuickQrEditorState<SmallScreen> {
  @override
  QuickQrLayout get layout => QuickQrLayout.small;

  @override
  String? get initialQrData => widget.initialQrData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      extendBodyBehindAppBar: true,
      appBar: data.isNotEmpty
          ? AppBar(
              backgroundColor: backgroundGrey,
              toolbarHeight: 100,
              leading: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: data.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                tooltip: toggleLanguage
                                    ? 'Volver a emepezar'
                                    : 'Start over',
                                onPressed: _showResetDialog,
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: darkBlue,
                                  size: 30,
                                )),
                            Image.asset(
                              'images/Logo_generator.png',
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QuickQR',
                                    style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text('Generator',
                                    style: TextStyle(
                                        color: lightBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        )
                      : Container()),
              leadingWidth: 300,
              elevation: 0.1,
              bottomOpacity: 0.1,
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: _toggleLanguage,
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: _toggleLanguage,
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Generator container:
            ///Textfield:
            data.isNotEmpty
                ? Container()
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/Logo_generator.png',
                          height: 100,
                          width: 100,
                        ),
                        const Text('QuickQR',
                            style: TextStyle(
                                color: darkBlue,
                                fontSize: 25,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 60),

                        //instructions:  step 1.
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 1' : 'Step 1',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 3,
                                width: 100,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Insertar texto para convertirlo en código QR'
                                    : 'Insert text to convert it to QR code',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ///Data Textfield:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 300,
                              child: TextField(
                                controller: textController,
                                obscureText: false,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (value) =>
                                    handleSubmit(value, source: 'keyboard'),
                                onChanged: _handleDataInputChanged,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: toggleLanguage
                                      ? 'Vinculo, texto, etc...'
                                      : 'Link, text, etc...', //as a placeholder text.
                                  hintStyle: const TextStyle(color: darkBlue),
                                  //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                  // counterText:
                                  //     'Correo electronico', //below to the right.
                                  //helperText: 'helper text', //below to the left
                                  labelText: toggleLanguage
                                      ? 'Insertar texto aqui...'
                                      : 'Insert data here...', //normal text inside
                                  errorStyle:
                                      const TextStyle(color: flashGreen),
                                  labelStyle: const TextStyle(
                                      color: Colors.grey, fontFamily: 'Futura'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: darkBlue, width: 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: lightBlue, width: 2.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            RoundedButton(
                                color: darkBlue,
                                textColor: Colors.white,
                                title: toggleLanguage
                                    ? 'Generar código'
                                    : 'Generate code',
                                width: 200,
                                pressed: () {
                                  handleSubmit(
                                    textController.text,
                                    source: 'button',
                                  );
                                }),
                          ],
                        ),
                        const SizedBox(height: 60),
                        //Tagline:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Powered by',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10)),
                            //button logo
                            IconButton(
                              onPressed: () {
                                final Uri link = Uri.parse(Website);
                                unawaited(
                                  _openTrackedUri(
                                    uri: link,
                                    destination: 'powered_by_tagline',
                                  ),
                                );
                              },
                              icon: Image.asset(
                                'images/Tagline.png',
                                width: 150,
                                color: lightBlue,
                              ),
                              iconSize: 75,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

            ///QR Code:
            data.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 100, bottom: 30, right: 20, left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Instructions:  step 2.
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 2' : 'Step 2',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 3,
                                width: 100,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Personaliza tu código QR'
                                    : 'Personalize your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Editor end view
                        //QR Code
                        Column(
                          children: [
                            RepaintBoundary(
                              key: _globalKey,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Set the border radius
                                  color: codeBackground,
                                  border: Border.all(
                                    color: outline
                                        ? currentColor
                                        : Colors
                                            .transparent, // Set the border color
                                    width: outlineWidth, // Set the border width
                                  ),
                                  // Set the background color
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      PrettyQr(
                                        key: ValueKey(
                                            'small-qr-$_previewVersion'),
                                        image: imageAvailable
                                            ? MemoryImage(imageFile!)
                                            : null, //const AssetImage('images/Logo_iago.png'),
                                        typeNumber: null,
                                        size: 300,
                                        data: data,
                                        errorCorrectLevel:
                                            QrErrorCorrectLevel.H,
                                        roundEdges: roundedCorners,
                                        elementColor: currentColor,
                                      ),
                                      codeText.isEmpty
                                          ? Container()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: Text(codeText,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: currentColor,
                                                      fontSize: codeTextSize,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(toggleLanguage ? 'Vista previa' : 'Preview',
                                style: TextStyle(
                                    color: currentColor.withOpacity(0.5),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 30),
                          ],
                        ),

                        ///tools
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                20.0), // Set the border radius
                            color: codeBackground, // Set the background color
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///buttons :
                                RoundedButton(
                                    color: currentColor,
                                    textColor: Colors.white,
                                    title: toggleLanguage
                                        ? 'Color del código'
                                        : 'QR Code\'s color',
                                    width: 250,
                                    pressed: _pickQrColor),
                                Row(
                                  children: [
                                    RoundedButton(
                                        color: codeBackground,
                                        textColor: currentColor,
                                        title: toggleLanguage
                                            ? 'Color del fondo'
                                            : 'Background color',
                                        width: 200,
                                        pressed: _pickBackgroundColor),
                                    IconButton(
                                        tooltip: toggleLanguage
                                            ? 'Eliminar fondo'
                                            : 'Delete background',
                                        icon: const Icon(Icons.highlight_remove,
                                            color: Colors.red),
                                        onPressed: _clearBackground),
                                  ],
                                ),

                                ///rounded switch
                                const Divider(),
                                Row(
                                  children: [
                                    Text(
                                      toggleLanguage
                                          ? 'Redondear'
                                          : 'Rounded corners',
                                      style: TextStyle(
                                          fontSize: 20.0, color: currentColor),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Switch(
                                      activeColor: currentColor,
                                      inactiveTrackColor: Colors.grey,
                                      value: roundedCorners,
                                      onChanged: _setRoundedCorners,
                                    ),
                                  ],
                                ),

                                ///outline switch
                                const Divider(),
                                Row(
                                  children: [
                                    Text(
                                      toggleLanguage ? 'Contorno' : 'Outline',
                                      style: TextStyle(
                                          fontSize: 20.0, color: currentColor),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Switch(
                                      activeColor: currentColor,
                                      inactiveTrackColor: Colors.grey,
                                      value: outline,
                                      onChanged: _setOutline,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  toggleLanguage
                                      ? 'Tamaño del contorno'
                                      : 'Outline size',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Slider(
                                  activeColor: currentColor,
                                  inactiveColor: Colors.grey,
                                  value: outlineWidth,
                                  min: 1.0,
                                  max: 20.0,
                                  onChanged: _setOutlineWidth,
                                  onChangeEnd: _commitOutlineWidth,
                                ),

                                const Divider(),

                                ///ImagePicker
                                GestureDetector(
                                  child: imageAvailable
                                      ? Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Container(
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              20.0)),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade200,
                                                        offset: const Offset(
                                                            2.0, 2.0),
                                                        blurRadius: 5.0,
                                                        spreadRadius: 0.5),
                                                  ],
                                                ),
                                                child: Image.memory(imageFile!,
                                                    height: 250,
                                                    width: 250,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            Positioned(
                                              top: -0,
                                              right: -0,
                                              child: GestureDetector(
                                                onTap: _removeCenterImage,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: const Icon(Icons.close,
                                                      color: Colors.white,
                                                      size: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(10.0),
                                          height: 250.0,
                                          width: 250.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20.0)),
                                            color:
                                                currentColor.withOpacity(0.5),
                                            shape: BoxShape.rectangle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey.shade200,
                                                  offset:
                                                      const Offset(2.0, 2.0),
                                                  blurRadius: 5.0,
                                                  spreadRadius: 0.5),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 30,
                                                  color: Colors.white),
                                              Text(
                                                  toggleLanguage
                                                      ? 'Agregar imagen al centro del QR'
                                                      : 'Add image to the center of the code',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                  onTap: _pickCenterImage,
                                ),
                                const Divider(),

                                ///Code text
                                SizedBox(
                                  height: 50,
                                  width: 250,
                                  child: TextField(
                                    //controller: textController,
                                    obscureText: false,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: _setCodeText,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: toggleLanguage
                                          ? 'Escaneame!...'
                                          : 'Scan me!...', //as a placeholder text.
                                      hintStyle:
                                          const TextStyle(color: darkBlue),
                                      //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                      // counterText:
                                      //     'Correo electronico', //below to the right.
                                      //helperText: 'helper text', //below to the left
                                      labelText: toggleLanguage
                                          ? 'Agregar texto...'
                                          : 'Add text here...', //normal text inside
                                      errorStyle:
                                          const TextStyle(color: flashGreen),
                                      labelStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'Futura'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32.0)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: darkBlue, width: 1.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: lightBlue, width: 2.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  toggleLanguage
                                      ? 'Tamaño del texto'
                                      : 'Text size',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Slider(
                                  activeColor: currentColor,
                                  inactiveColor: Colors.grey,
                                  value: codeTextSize,
                                  min: 10.0,
                                  max: 50.0,
                                  onChanged: _setCodeTextSize,
                                  onChangeEnd: _commitCodeTextSize,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        ///Instructions:  step 3.
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 3' : 'Step 3',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 3,
                                width: 100,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Descarga tu código QR'
                                    : 'Download your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Download button
                        RoundedButton(
                            color: darkBlue,
                            textColor: Colors.white,
                            title: toggleLanguage ? 'Descargar' : 'Download',
                            width: 200,
                            pressed: _capturePng),
                        StripeSupportSection(
                          useSpanish: toggleLanguage,
                          compact: true,
                          onSupportPressed: _handleSupportPressed,
                          onSupportReady: _handleSupportReady,
                        ),

                        ///Tagline:
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Powered by',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 10)),
                              //tagline
                              IconButton(
                                onPressed: () {
                                  final Uri link = Uri.parse(Website);
                                  unawaited(
                                    _openTrackedUri(
                                      uri: link,
                                      destination: 'powered_by_footer',
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  'images/Tagline.png',
                                  width: 150,
                                  color: lightBlue,
                                ),
                                iconSize: 75,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

            ///Bottom container
            Container(
              height: 400.0,
              width: double.infinity,
              color: darkBlue,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Social Media, profile and legal Links:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Email contact
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_post_office,
                                color: Colors.white,
                                size: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    String? encodeQueryParameters(
                                        Map<String, String> params) {
                                      return params.entries
                                          .map((MapEntry<String, String> e) =>
                                              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                          .join('&');
                                    }

                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: contactEmail,
                                      query: encodeQueryParameters(<String,
                                          String>{
                                        'subject': 'Hello SoftwareLab X!',
                                        'body':
                                            'I\'d Just checked out the QR generator...',
                                      }),
                                    );
                                    unawaited(
                                      _openTrackedUri(
                                        uri: emailLaunchUri,
                                        destination: 'contact_email',
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    contactEmail,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
                                  )),
                            ]),
                        //location info
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_location,
                                color: Colors.white,
                                size: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    final Uri link = Uri.parse(
                                        'https://goo.gl/maps/wpm2LhGHeiw9LqXB7');
                                    unawaited(
                                      _openTrackedUri(
                                        uri: link,
                                        destination: 'location_map',
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '900 Biscayne Blvd, Miami, FL 33132',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ]),
                        const SizedBox(height: 30),
                        toggleLanguage
                            ? const Text('Siguenos en',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                            : const Text('Follow us on',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                        //Social media outlets
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //   icon: Image.asset('images/youtube.png',
                            //       height: 25,
                            //       color: Colors
                            //           .white), // Replace 'assets/icon.png' with your image asset
                            //   onPressed: () {
                            //     analytics.logEvent(
                            //       name: 'QuickQR - Youtube SoftwareLab',
                            //       parameters: <String, dynamic>{
                            //         'YouTube Redirect': data,
                            //       },
                            //     );
                            //     final Uri link = Uri.parse(YouTube);
                            //     launchURL(link);
                            //   },
                            // ),
                            // const SizedBox(width: 5),
                            IconButton(
                              onPressed: () {
                                final Uri link = Uri.parse(Instagram);
                                unawaited(
                                  _openTrackedUri(
                                    uri: link,
                                    destination: 'instagram',
                                  ),
                                );
                              },
                              icon: Image.asset('images/instagram.png',
                                  height: 25, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        IconButton(
                          icon: Image.asset(
                            'images/logo.png',
                            width: 100,
                          ),
                          onPressed: () {
                            final Uri link = Uri.parse(Website);
                            unawaited(
                              _openTrackedUri(
                                uri: link,
                                destination: 'company_website',
                              ),
                            );
                          },
                        ),
                        toggleLanguage
                            ? const Text(
                                'Todos los derechos reservados © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            : const Text(
                                'All rights reserved © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                      ],
                    ),
                    //Logo
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
