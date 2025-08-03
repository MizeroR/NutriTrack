import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? helperText;
  final IconData? prefixIcon;
  final bool showPasswordToggle;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.helperText,
    this.prefixIcon,
    this.showPasswordToggle = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null && widget.controller.text.isNotEmpty) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorText != null
                  ? Colors.red.shade300
                  : _isFocused
                  ? const Color(0xFF91C788)
                  : const Color(0xFFE5E7EB),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isObscured,
              keyboardType: widget.keyboardType,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? const Color(0xFF91C788)
                            : const Color(0xFF9CA3AF),
                      )
                    : null,
                suffixIcon: widget.showPasswordToggle
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF9CA3AF),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      )
                    : widget.controller.text.isNotEmpty && _errorText == null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              validator: widget.validator,
            ),
          ),
        ),
        if (widget.helperText != null && _errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              widget.helperText!,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
