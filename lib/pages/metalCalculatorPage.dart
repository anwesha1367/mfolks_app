import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import '../components/app_scaffold.dart';
// If/when we wire the live API, we'll import ApiClient
// import '../services/api_client.dart';

class MetalCalculatorPage extends StatefulWidget {
  const MetalCalculatorPage({super.key});

  @override
  State<MetalCalculatorPage> createState() => _MetalCalculatorPageState();
}

class _MetalCalculatorPageState extends State<MetalCalculatorPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? selectedMetal;
  String selectedShape = 'Rod';
  String selectedUnit = 'cm';
  String calcMode = 'By Length';

  final lengthController = TextEditingController();
  final diameterController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final innerDiameterController = TextEditingController();
  final piecesController = TextEditingController(text: '1');

  String? result;
  String? errorMessage;
  bool isLoading = false;
  final GlobalKey _resultKey = GlobalKey();

  final shapes = ['Rod', 'Plate', 'Sheet', 'Pipe'];
  final units = ['cm', 'mm', 'inch'];
  final modes = ['By Length', 'By Weight'];

  // Use icons instead of missing assets to avoid overflow/errors
  final Map<String, IconData> shapeIcons = const {
    'Rod': Icons.adjust, // circle-like, represents rod end
    'Plate': Icons.crop_3_2,
    'Sheet': Icons.article_outlined,
    'Pipe': Icons.donut_large_outlined,
  };

  @override
  void dispose() {
    lengthController.dispose();
    diameterController.dispose();
    widthController.dispose();
    heightController.dispose();
    innerDiameterController.dispose();
    piecesController.dispose();
    super.dispose();
  }

  // ---- Logic ported from temp.dart (adapted to Flutter) ----

  // Densities in g/cm^3 (keys lowercased)
  static const Map<String, double> _metalDensities = {
    'steel': 7.85,
    'stainless-steel': 8.0,
    'aluminum': 2.70,
    'copper': 8.96,
    'brass': 8.5,
    'bronze': 8.8,
    'iron': 7.87,
    'zinc': 7.14,
    'nickel': 8.91,
    'titanium': 4.51,
    'lead': 11.34,
    'gold': 19.32,
    'silver': 10.49,
    'platinum': 21.45,
    'palladium': 12.02,
  };

  // Build full metal list from densities keys, prettified for display
  List<String> get _allMetalDisplayNames {
    final names = _metalDensities.keys
        .map((k) => _toDisplayName(k))
        .toSet()
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  String _toDisplayName(String key) {
    final words = key.replaceAll('-', ' ').split(' ');
    return words
        .where((w) => w.trim().isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  // Default USD per kg (fallback rates)
  static const Map<String, double> _defaultRatesPerKg = {
    'steel': 0.8,
    'stainless-steel': 2.5,
    'aluminum': 1.8,
    'copper': 9.2,
    'brass': 6.5,
    'bronze': 7.0,
    'iron': 0.7,
    'zinc': 2.5,
    'nickel': 18.5,
    'titanium': 35.0,
    'lead': 2.1,
    'gold': 65000,
    'silver': 800,
    'platinum': 32000,
    'palladium': 28000,
  };

  // Processing multipliers by shape kind
  static const Map<String, double> _processingMultiplier = {
    'sheet': 1.05,
    'round-bar': 1.08,
    'square-bar': 1.10,
    'rectangular-bar': 1.12,
    'pipe': 1.20,
    'coil': 1.15,
    'angle': 1.25,
    'channel': 1.30,
  };

  String _normalizedMetalKey(String? pretty) {
    if (pretty == null) return '';
    final p = pretty.trim().toLowerCase();
    switch (p) {
      case 'aluminum':
        return 'aluminum';
      case 'copper':
        return 'copper';
      case 'steel':
        return 'steel';
      case 'brass':
        return 'brass';
      case 'titanium':
        return 'titanium';
      default:
        return p.replaceAll(' ', '-');
    }
  }

  double _getDensity(String? pretty) {
    final key = _normalizedMetalKey(pretty);
    return _metalDensities[key] ?? 7.85; // default to steel-like
  }

  double _getRatePerKg(String? pretty) {
    final key = _normalizedMetalKey(pretty);
    return _defaultRatesPerKg[key] ?? 1.0;
  }

  // Convert a numeric string to double; empty -> 0
  double _toDouble(String? v) {
    if (v == null) return 0;
    final cleaned = v.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0;
    }

  // Convert input value to centimeters based on selectedUnit
  double _toCm(double value) {
    switch (selectedUnit) {
      case 'cm':
        return value;
      case 'mm':
        return value / 10.0;
      case 'inch':
        return value * 2.54;
      default:
        return value;
    }
  }

  // Calculate volume in cm^3 based on selected shape and inputs
  double _calculateVolumeCm3() {
    final length = _toCm(_toDouble(lengthController.text));
    final width = _toCm(_toDouble(widthController.text));
    final thickness = _toCm(_toDouble(heightController.text));
    final diameter = _toCm(_toDouble(diameterController.text));
    final innerDiameter = _toCm(_toDouble(innerDiameterController.text));

    switch (selectedShape) {
      case 'Rod':
        final radius = diameter / 2.0;
        return 3.141592653589793 * radius * radius * length;
      case 'Plate':
      case 'Sheet':
        return length * width * thickness;
      case 'Pipe':
        final outerR = diameter / 2.0;
        final innerR = innerDiameter > 0 ? innerDiameter / 2.0 : 0.0;
        final wallArea = 3.141592653589793 * (outerR * outerR - innerR * innerR);
        return wallArea * length;
      default:
        return 0;
    }
  }

  // Determine pricing multiplier kind from selected shape
  String _shapeKindForPricing() {
    switch (selectedShape) {
      case 'Rod':
        return 'round-bar';
      case 'Pipe':
        return 'pipe';
      case 'Plate':
      case 'Sheet':
        return 'sheet';
      default:
        return 'sheet';
    }
  }

  Map<String, double> _calculatePricing(double weightKg, double ratePerKg) {
    final materialCost = weightKg * ratePerKg;
    final kind = _shapeKindForPricing();
    final multiplier = _processingMultiplier[kind] ?? 1.0;
    final processingCost = materialCost * (multiplier - 1.0);
    final markup = materialCost * 0.15;
    final total = materialCost + processingCost + markup;
    return {
      'materialCost': materialCost,
      'processingCost': processingCost,
      'markup': markup,
      'total': total,
    };
  }

  Future<void> _calculateWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final pieces = _toDouble(piecesController.text);
      final numPieces = pieces > 0 ? pieces : 1.0;

      double weightKg = 0.0;
      double volumeCm3 = 0.0;

      if (calcMode == 'By Weight') {
        weightKg = _toDouble(lengthController.text); // reuse length field when By Weight? we add dedicated field below via validator; keep safe
      } else {
        volumeCm3 = _calculateVolumeCm3();
        final density = _getDensity(selectedMetal);
        weightKg = (volumeCm3 * density * numPieces) / 1000.0;
      }

      final ratePerKg = _getRatePerKg(selectedMetal);
      final pricing = _calculatePricing(weightKg, ratePerKg);

      final buffer = StringBuffer()
        ..writeln('Mode: $calcMode')
        ..writeln('Shape: $selectedShape')
        ..writeln('Metal: ${selectedMetal ?? '-'}')
        ..writeln('Unit: $selectedUnit')
        ..writeln('Pieces: ${numPieces.toStringAsFixed(0)}')
        ..writeln('')
        ..writeln('Weight: ${weightKg.toStringAsFixed(3)} kg')
        ..writeln('Volume: ${volumeCm3 > 0 ? volumeCm3.toStringAsFixed(3) : '-'} cm³')
        ..writeln('Rate: USD ${ratePerKg.toStringAsFixed(2)}/kg')
        ..writeln('Material Cost: USD ${pricing['materialCost']!.toStringAsFixed(2)}')
        ..writeln('Processing: USD ${pricing['processingCost']!.toStringAsFixed(2)}')
        ..writeln('Markup: USD ${pricing['markup']!.toStringAsFixed(2)}')
        ..writeln('Estimated Price: USD ${pricing['total']!.toStringAsFixed(2)}');

      setState(() {
        result = buffer.toString();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Calculation failed. Please check your inputs.';
        result = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildShapeSelector() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shapes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final shape = shapes[idx];
          final isSelected = selectedShape == shape;
          return ChoiceChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  shapeIcons[shape],
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFF00695C),
                ),
                const SizedBox(width: 6),
                Text(shape),
              ],
            ),
            pressElevation: 0,
            selectedColor: const Color(0xFF009688),
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? const Color(0xFF009688) : Colors.grey.shade300,
              ),
            ),
            onSelected: (_) => setState(() => selectedShape = shape),
          );
        },
      ),
    );
  }

  Widget _buildShapePreview() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(selectedShape),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 720, minHeight: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF009688), Color(0xFF00695C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                shapeIcons[selectedShape],
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedShape,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live preview of your selected shape',
                    style: Colors.white70.textStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? suffixText,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixText: suffixText,
      prefixIcon: Icon(icon ?? Icons.edit_note_outlined),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  List<TextInputFormatter> get _numFmt => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ];

  // Helpers to format fancy metrics from the multiline result string
  String _extractLine(String text, String startsWith) {
    final lines = text.split('\n');
    for (final l in lines) {
      if (l.trim().startsWith(startsWith)) {
        return l.trim().substring(startsWith.length).trim();
      }
    }
    return '-';
  }

  Future<void> _shareResultCard() async {
    try {
      final boundary = _resultKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mfolks_calc_result_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Metal Calculator Result');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share card')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 4,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: Image.asset(
                        //     'assets/mfolks-logo-1.png',
                        //     height: 48,
                        //   ),
                        // ),
                        //const SizedBox(height:8),

                        // Shape selector
                        _buildShapeSelector(),
                        const SizedBox(height: 16),


                        _buildShapePreview(),
                        const SizedBox(height: 16),

                        // Card with inputs
                        Card(
                          elevation: 6,
                          shadowColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Mode
                                DropdownButtonFormField<String>(
                                  value: calcMode,
                                  items: modes
                                      .map(
                                        (m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => calcMode = val ?? 'By Length'),
                                  decoration: _inputDecoration(
                                    label: 'Calculation Mode',
                                    icon: Icons.calculate_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Metal
                                DropdownButtonFormField<String>(
                                  value: selectedMetal,
                                  items: _allMetalDisplayNames
                                      .map((m) =>
                                          DropdownMenuItem(value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedMetal = val),
                                  decoration: _inputDecoration(
                                    label: 'Type',
                                    icon: Icons.category_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Unit
                                DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  items: units
                                      .map((u) =>
                                          DropdownMenuItem(value: u, child: Text(u)))
                                      .toList(),
                                  onChanged: (val) => setState(
                                      () => selectedUnit = val ?? 'cm'),
                                  decoration: _inputDecoration(
                                    label: 'Unit',
                                    icon: Icons.straighten,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    children: [
                                      if (calcMode == 'By Length') ...[
                                        if (selectedShape == 'Rod') ...[
                                          TextFormField(
                                            controller: lengthController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Length',
                                              suffixText: selectedUnit,
                                              icon: Icons.height,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter length'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: diameterController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Diameter',
                                              suffixText: selectedUnit,
                                              icon: Icons.circle_outlined,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter diameter'
                                                    : null,
                                          ),
                                        ],
                                        if (selectedShape == 'Plate' ||
                                            selectedShape == 'Sheet') ...[
                                          TextFormField(
                                            controller: lengthController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Length',
                                              suffixText: selectedUnit,
                                              icon: Icons.height,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter length'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: widthController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Width',
                                              suffixText: selectedUnit,
                                              icon: Icons.swap_horiz,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter width'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: heightController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Thickness',
                                              suffixText: selectedUnit,
                                              icon: Icons.swap_vert,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter thickness'
                                                    : null,
                                          ),
                                        ],
                                        if (selectedShape == 'Pipe') ...[
                                          TextFormField(
                                            controller: diameterController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Outer Diameter',
                                              suffixText: selectedUnit,
                                              icon: Icons.circle,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter outer diameter'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                  TextFormField(
                                    controller: innerDiameterController,
                                    inputFormatters: _numFmt,
                                    decoration: _inputDecoration(
                                      label: 'Inner Diameter',
                                      suffixText: selectedUnit,
                                      icon: Icons.circle_outlined,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter inner diameter'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                          TextFormField(
                                            controller: heightController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Wall Thickness',
                                              suffixText: selectedUnit,
                                              icon: Icons.straighten,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter wall thickness'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: lengthController,
                                            inputFormatters: _numFmt,
                                            decoration: _inputDecoration(
                                              label: 'Length',
                                              suffixText: selectedUnit,
                                              icon: Icons.height,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Enter length'
                                                    : null,
                                          ),
                                        ],
                                      ] else if (calcMode == 'By Weight') ...[
                                TextFormField(
                                  controller: lengthController,
                                  inputFormatters: _numFmt,
                                  decoration: _inputDecoration(
                                    label: 'Enter Weight',
                                    suffixText: 'kg',
                                    icon: Icons.scale,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Enter weight'
                                      : null,
                                ),
                                      ],
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: piecesController,
                                inputFormatters: _numFmt,
                                decoration: _inputDecoration(
                                  label: 'Pieces',
                                  suffixText: null,
                                  icon: Icons.confirmation_number_outlined,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Enter pieces'
                                    : null,
                              ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF009688),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _calculateWeight,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              valueColor: AlwaysStoppedAnimation(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Calculate',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (result != null) ...[
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              key: ValueKey(result),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF009688), Color(0xFF00695C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.analytics_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Estimation Result',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.shield_moon_outlined, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text('Simulated', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Big numbers row
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                final isWide = constraints.maxWidth > 560;
                                                return Wrap(
                                                  spacing: 12,
                                                  runSpacing: 12,
                                                  children: [
                                                    _MetricTile(
                                                      label: 'Weight',
                                                      value: _extractLine(result!, 'Weight:'),
                                                      icon: Icons.monitor_weight_outlined,
                                                      color: const Color(0xFF00695C),
                                                    ),
                                                    _MetricTile(
                                                      label: 'Total Price',
                                                      value: _extractLine(result!, 'Estimated Price:'),
                                                      icon: Icons.payments_outlined,
                                                      color: const Color(0xFF2E7D32),
                                                    ),
                                                    if (isWide)
                                                      _MetricTile(
                                                        label: 'Rate',
                                                        value: _extractLine(result!, 'Rate:'),
                                                        icon: Icons.query_stats_outlined,
                                                        color: const Color(0xFF1565C0),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(height: 20),
                                            const SizedBox(height: 8),
                                            // Raw summary text
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.description_outlined, color: Color(0xFF00695C)),
                                                const SizedBox(width: 8),
                                                Expanded(child: RepaintBoundary(
                                                  key: _resultKey,
                                                  child: Text(
                                                    result!,
                                                    style: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF37474F)),
                                                  ),
                                                )),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: result!));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Result copied')),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.copy_all_outlined),
                                                  label: const Text('Copy'),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton.icon(
                                                  onPressed: _shareResultCard,
                                                  icon: const Icon(Icons.ios_share_outlined),
                                                  label: const Text('Share Card'),
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
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

extension _MutedText on Color {
  TextStyle get textStyle => TextStyle(color: this);
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}