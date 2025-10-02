import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerifyOTPModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Function(String identifier, String method, String otp) onSuccess;
  final String identifier;
  final String method;

  const VerifyOTPModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onSuccess,
    required this.identifier,
    required this.method,
  });

  @override
  State<VerifyOTPModal> createState() => _VerifyOTPModalState();
}

class _VerifyOTPModalState extends State<VerifyOTPModal> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResendLoading = false;
  String _error = '';
  int _timeLeft = 600; // 10 minutes in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isOpen) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(VerifyOTPModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _startTimer();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _stopTimer();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSubmit() async {
    final otp = _otpController.text.trim();
    
    if (otp.length != 6) {
      setState(() {
        _error = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final success = await AuthService.instance.verifyForgotPasswordOTP(
        identifier: widget.identifier,
        otp: otp,
        method: widget.method,
      );

      if (success) {
        widget.onSuccess(widget.identifier, widget.method, otp);
      } else {
        setState(() {
          _error = 'Invalid verification code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Invalid verification code. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResendLoading = true;
      _error = '';
    });

    try {
      final success = await AuthService.instance.sendForgotPasswordOTP(
        identifier: widget.identifier,
        method: widget.method,
      );

      if (success) {
        _startTimer();
        _otpController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent successfully')),
        );
      } else {
        setState(() {
          _error = 'Failed to resend code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to resend code. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
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
                    'Verify Reset Code',
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
              Text(
                "We've sent a 6-digit verification code to your ${widget.method}.",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.method == 'email' ? widget.identifier : '+${widget.identifier}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF00695C)),
                  ),
                ),
                onChanged: (value) {
                  // Only allow digits and limit to 6 characters
                  if (value.length > 6) {
                    _otpController.text = value.substring(0, 6);
                    _otpController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _otpController.text.length),
                    );
                  }
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Timer
              if (_timeLeft > 0)
                Center(
                  child: Text(
                    'Code expires in ${_formatTime(_timeLeft)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (_timeLeft == 0)
                const Center(
                  child: Text(
                    'Code has expired. Please request a new one.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
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
                      onPressed: _isLoading || _otpController.text.length != 6 ? null : _handleSubmit,
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
                          : const Text('Verify Code'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Resend Button
              Center(
                child: TextButton(
                  onPressed: _isResendLoading || _timeLeft > 0 ? null : _handleResend,
                  child: _isResendLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Resend Code',
                          style: TextStyle(color: Color(0xFF00695C)),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
