import 'package:flutter/material.dart';
import '../widget/custom_footer.dart';

class MetalCalculatorPage extends StatefulWidget {
  const MetalCalculatorPage({super.key});

  @override
  State<MetalCalculatorPage> createState() => _MetalCalculatorPageState();
}

class _MetalCalculatorPageState extends State<MetalCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedMetal;
  String selectedShape = "Rod";
  String selectedUnit = "cm";
  String calcMode = "By Length"; // NEW: default value

  final lengthController = TextEditingController();
  final diameterController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();

  String? result;

  final metals = ["Aluminum", "Copper", "Steel", "Brass", "Titanium"];
  final shapes = ["Rod", "Plate", "Sheet", "Pipe"];
  final units = ["cm", "mm", "inch"];
  final modes = ["By Length", "By Weight"]; // NEW dropdown values

  void calculateWeight() {
    // TODO: Replace with API call for live price
    setState(() {
      result =
      "Mode: $calcMode\nShape: $selectedShape\nMetal: $selectedMetal\nUnit: $selectedUnit\n\nCalculated live weight & price will be shown here.";
    });
  }

  Widget _buildShapePreview() {
    switch (selectedShape) {
      case "Rod":
        return Image.asset("assets/shapes/rod.png", height: 100);
      case "Plate":
        return Image.asset("assets/shapes/plate.png", height: 100);
      case "Sheet":
        return Image.asset("assets/shapes/sheet.png", height: 100);
      case "Pipe":
        return Image.asset("assets/shapes/pipe.png", height: 100);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Metal Calculator",
            style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App logo
              Image.asset("'assets/mfolks-logo.png'", height: 50),

              const SizedBox(height: 20),

              // Card container
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
                      // Preview always at top
                      _buildShapePreview(),
                      const SizedBox(height: 20),

                      // Dropdown: Mode (By Length / By Weight)
                      DropdownButtonFormField<String>(
                        value: calcMode,
                        items: modes
                            .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) => setState(() => calcMode = val!),
                        decoration: const InputDecoration(
                          labelText: "Calculation Mode",
                          prefixIcon: Icon(Icons.calculate),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metal type
                      DropdownButtonFormField<String>(
                        value: selectedMetal,
                        items: metals
                            .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedMetal = val),
                        decoration: const InputDecoration(
                          labelText: "Type",
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Shape
                      DropdownButtonFormField<String>(
                        value: selectedShape,
                        items: shapes
                            .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedShape = val ?? "Rod"),
                        decoration: const InputDecoration(
                          labelText: "Shape",
                          prefixIcon: Icon(Icons.square_foot),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Unit
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        items: units
                            .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedUnit = val ?? "cm"),
                        decoration: const InputDecoration(
                          labelText: "Unit",
                          prefixIcon: Icon(Icons.straighten),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input fields
                      if (calcMode == "By Length") ...[
                        if (selectedShape == "Rod") ...[
                          TextFormField(
                            controller: lengthController,
                            decoration: InputDecoration(
                              labelText: "Length",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.height),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: diameterController,
                            decoration: InputDecoration(
                              labelText: "Diameter",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.circle_outlined),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        if (selectedShape == "Plate" ||
                            selectedShape == "Sheet") ...[
                          TextFormField(
                            controller: lengthController,
                            decoration: InputDecoration(
                              labelText: "Length",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.height),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: widthController,
                            decoration: InputDecoration(
                              labelText: "Width",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.swap_horiz),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: heightController,
                            decoration: InputDecoration(
                              labelText: "Thickness",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.swap_vert),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        if (selectedShape == "Pipe") ...[
                          TextFormField(
                            controller: diameterController,
                            decoration: InputDecoration(
                              labelText: "Outer Diameter",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.circle),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: heightController,
                            decoration: InputDecoration(
                              labelText: "Wall Thickness",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.straighten),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: lengthController,
                            decoration: InputDecoration(
                              labelText: "Length",
                              suffixText: selectedUnit,
                              prefixIcon: const Icon(Icons.height),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ] else if (calcMode == "By Weight") ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Enter Weight",
                            suffixText: "kg",
                            prefixIcon: Icon(Icons.scale),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Calculate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009688),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: calculateWeight,
                          child: const Text("Calculate",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (result != null)
                Card(
                  color: Colors.teal.shade50,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(result!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
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
