import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widget/custom_footer.dart';
import '../widget/custom_header.dart';
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

  String? result;
  String? errorMessage;
  bool isLoading = false;

  final metals = ['Aluminum', 'Copper', 'Steel', 'Brass', 'Titanium'];
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
    super.dispose();
  }

  Future<void> _calculateWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      // TODO: Replace this with a real API call.
      // Example (uncomment when endpoint is ready):
      // final response = await ApiClient().post<Map<String, dynamic>>(
      //   '/calculator/estimate',
      //   data: {
      //     'mode': calcMode,
      //     'shape': selectedShape,
      //     'metal': selectedMetal,
      //     'unit': selectedUnit,
      //     'length': lengthController.text,
      //     'diameter': diameterController.text,
      //     'width': widthController.text,
      //     'thickness': heightController.text,
      //   },
      // );
      // final data = response.data!;

      await Future.delayed(const Duration(milliseconds: 800));
      final mock = {
        'weightKg': 12.34,
        'price': 789.0,
        'currency': 'USD',
      };

      setState(() {
        result = 'Mode: $calcMode\nShape: $selectedShape\nMetal: '
            '${selectedMetal ?? '-'}\nUnit: $selectedUnit\n\n'
            'Weight: ${mock['weightKg']} kg\n'
            'Estimated Price: ${mock['currency']} ${mock['price']}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to fetch live result. Showing placeholder.';
        result = 'Mode: $calcMode\nShape: $selectedShape\nMetal: '
            '${selectedMetal ?? '-'}\nUnit: $selectedUnit\n\n'
            'Weight: 10.0 kg\nEstimated Price: USD 500.0';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: const CustomHeader(isHome: false),
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
                                  items: metals
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
                          Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.analytics_outlined,
                                      color: Color(0xFF00695C),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      result!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
      bottomNavigationBar: CustomFooter(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/about');
              break;
            case 1:
              Navigator.pushNamed(context, '/quote');
              break;
            case 2:
              Navigator.pushNamed(context, '/home');
              break;
            case 3:
              Navigator.pushNamed(context, '/analytics');
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }
}

extension _MutedText on Color {
  TextStyle get textStyle => TextStyle(color: this);
}