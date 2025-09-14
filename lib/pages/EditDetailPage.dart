import 'package:flutter/material.dart';
import '../widget/custom_footer.dart'; // ✅ Import reusable footer

class EditDetailsPage extends StatefulWidget {
  const EditDetailsPage({super.key});

  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final TextEditingController _nameController =
  TextEditingController(text: "John Smith");
  final TextEditingController _emailController =
  TextEditingController(text: "johnsmith@gmail.com");
  final TextEditingController _mobileController =
  TextEditingController(text: "XXXXXXXX89");

  String? _selectedIndustry;
  int _selectedIndex = 2; // Default selected index (Home)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Edit Details",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Personal Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                suffixIcon: const Icon(Icons.edit, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email ID",
                suffixIcon: const Icon(Icons.edit, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mobile No
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: "Mobile No.",
                suffixIcon: const Icon(Icons.edit, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Industry Dropdown
            DropdownButtonFormField<String>(
              value: _selectedIndustry,
              decoration: InputDecoration(
                labelText: "Industry Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "IT", child: Text("IT")),
                DropdownMenuItem(
                    value: "Manufacturing", child: Text("Manufacturing")),
                DropdownMenuItem(value: "Finance", child: Text("Finance")),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedIndustry = val;
                });
              },
            ),
            const SizedBox(height: 24),

            // Edit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Save details action here
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text(
                  "Edit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Custom reusable footer
      bottomNavigationBar: CustomFooter(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
              Navigator.pushNamed(context, '/calculator');
              break;
          }
        },
      ),
    );
  }
}
