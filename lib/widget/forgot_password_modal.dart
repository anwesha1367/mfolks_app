import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Function(String identifier, String method) onSuccess;

  const ForgotPasswordModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final TextEditingController _identifierController = TextEditingController();
  String _method = 'email';
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }


  Future<void> _handleSubmit() async {
    final identifier = _identifierController.text.trim();
    
    if (identifier.isEmpty) {
      setState(() {
        _error = 'Please enter your email or phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final success = await AuthService.instance.sendForgotPasswordOTP(
        identifier: identifier,
        method: _method,
      );

      if (success) {
        widget.onSuccess(identifier, _method);
      } else {
        setState(() {
          _error = 'Failed to send reset code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to send reset code. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Enter your email or phone number to receive a reset code.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Method Selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _method = 'email'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _method == 'email' ? const Color(0xFF00695C) : Colors.white,
                          border: Border.all(
                            color: _method == 'email' ? const Color(0xFF00695C) : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email,
                              color: _method == 'email' ? Colors.white : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Email',
                              style: TextStyle(
                                color: _method == 'email' ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _method = 'phone'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _method == 'phone' ? const Color(0xFF00695C) : Colors.white,
                          border: Border.all(
                            color: _method == 'phone' ? const Color(0xFF00695C) : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              color: _method == 'phone' ? Colors.white : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Phone',
                              style: TextStyle(
                                color: _method == 'phone' ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input Field
              TextField(
                controller: _identifierController,
                keyboardType: _method == 'email' ? TextInputType.emailAddress : TextInputType.phone,
                decoration: InputDecoration(
                  hintText: _method == 'email' ? 'Enter your email' : 'Enter your phone number',
                  prefixIcon: Icon(
                    _method == 'email' ? Icons.email : Icons.phone,
                    color: const Color(0xFF00695C),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF00695C)),
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),
              if (_error.isNotEmpty) const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : widget.onClose,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Send Reset Code'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
