import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/ui/widgets/text_divider.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';

/// Shows the sign up page as a modal bottom sheet.
Future<void> showSignUpSheet(
  BuildContext context, {
  void Function()? onSuccess,
  void Function(String error)? onError,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            16, //Makes sure you can still see it even when there's a keyboard
        top: 16,
        left: 16,
        right: 16,
      ),
      child: _SignUpSheetContent(onSuccess: onSuccess, onError: onError),
    ),
  );
}

class _SignUpSheetContent extends StatefulWidget {
  final void Function()? onSuccess;
  final void Function(String error)? onError;

  const _SignUpSheetContent({this.onSuccess, this.onError});

  @override
  State<_SignUpSheetContent> createState() => _SignUpSheetContentState();
}

class _SignUpSheetContentState extends State<_SignUpSheetContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_clearErrors);
    _confirmPasswordController.addListener(_clearErrors);
    _emailController.addListener(_clearErrors);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      final String email = _emailController.text;
      final String name = _nameController.text;
      final String password = _passwordController.text;
      final success = await authProvider.signUp(
        email: email,
        password: password,
        name: name,
      );
      if (!mounted) return;
      if (success) {
        TextInput.finishAutofillContext();
        if (widget.onSuccess != null) widget.onSuccess!();
        Navigator.of(context).maybePop();
      } else if (authProvider.error != null) {
        final error = authProvider.error!;
        if (error.contains('weak-password') ||
            error.contains('password-too-short')) {
          setState(() => _passwordError = 'Password is too weak');
        } else if (error.contains('email-already-in-use') ||
            error.contains('user_already_exists')) {
          setState(() => _emailError = 'Email is already in use');
        } else {
          if (widget.onError != null) widget.onError!(error);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (widget.onError != null) widget.onError!(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Beariscope Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: 300,
            constraints: const BoxConstraints(maxWidth: 300),
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text('Sign up with Apple'),
              icon: const Icon(SimpleIcons.apple),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 300,
            constraints: const BoxConstraints(maxWidth: 300),
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text('Sign up with Google'),
              icon: const Icon(SimpleIcons.google),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 300,
            constraints: const BoxConstraints(maxWidth: 300),
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text('Sign up with GitHub'),
              icon: const Icon(SimpleIcons.github),
            ),
          ),
          const SizedBox(height: 16),
          TextDivider(),
          const SizedBox(height: 16),
          AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  autofillHints: const [AutofillHints.name],
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    errorText: _passwordError,
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocusNode);
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    errorText:
                        (_passwordController.text !=
                                _confirmPasswordController.text) &&
                            _confirmPasswordController.text.isNotEmpty
                        ? 'Passwords do not match'
                        : null,
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isLoading ? null : _signup,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
