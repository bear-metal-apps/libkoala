import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onSuccess;
  final String title;
  final double maxWidth;

  const SignUpPage({
    super.key,
    this.onSuccess,
    this.title = 'Sign Up',
    this.maxWidth = 300.0,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
        widget.onSuccess?.call();
      } else if (authProvider.error != null) {
        final error = authProvider.error!;
        if (error.contains('weak-password') ||
            error.contains('password-too-short')) {
          setState(() => _passwordError = 'Password is too weak');
        } else if (error.contains('email-already-in-use') ||
            error.contains('user_already_exists')) {
          setState(() => _emailError = 'Email is already in use');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        }
      }
    } catch (e) {
      if (!mounted) return;
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
    final maxWidth = widget.maxWidth;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
              ),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container(
                      //   width: maxWidth,
                      //   constraints: BoxConstraints(maxWidth: maxWidth),
                      //   child: OutlinedButton.icon(
                      //     onPressed: _isLoading
                      //         ? null
                      //         : () async {
                      //             final success = context
                      //                 .read<AuthProvider>()
                      //                 .signInWithOauth(
                      //                   provider: OAuthProvider.apple,
                      //                 );
                      //             if (await success) {
                      //               TextInput.finishAutofillContext();
                      //               widget.onSuccess?.call();
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 const SnackBar(
                      //                   content: Text('Apple sign-in failed'),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //     style: OutlinedButton.styleFrom(
                      //       minimumSize: const Size.fromHeight(50),
                      //     ),
                      //     label: const Text('Sign up with Apple'),
                      //     icon: const Icon(SimpleIcons.apple),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // Container(
                      //   width: maxWidth,
                      //   constraints: BoxConstraints(maxWidth: maxWidth),
                      //   child: OutlinedButton.icon(
                      //     onPressed: _isLoading
                      //         ? null
                      //         : () async {
                      //             final success = context
                      //                 .read<AuthProvider>()
                      //                 .signInWithOauth(
                      //                   provider: OAuthProvider.google,
                      //                 );
                      //             if (await success) {
                      //               TextInput.finishAutofillContext();
                      //               widget.onSuccess?.call();
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 const SnackBar(
                      //                   content: Text('Google sign-in failed'),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //     style: OutlinedButton.styleFrom(
                      //       minimumSize: const Size.fromHeight(50),
                      //     ),
                      //     label: const Text('Sign up with Google'),
                      //     icon: const Icon(SimpleIcons.google),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // Container(
                      //   width: maxWidth,
                      //   constraints: BoxConstraints(maxWidth: maxWidth),
                      //   child: OutlinedButton.icon(
                      //     onPressed: _isLoading
                      //         ? null
                      //         : () async {
                      //             final success = context
                      //                 .read<AuthProvider>()
                      //                 .signInWithOauth(
                      //                   provider: OAuthProvider.github,
                      //                 );
                      //             if (await success) {
                      //               TextInput.finishAutofillContext();
                      //               widget.onSuccess?.call();
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 const SnackBar(
                      //                   content: Text('GitHub sign-in failed'),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //     style: OutlinedButton.styleFrom(
                      //       minimumSize: const Size.fromHeight(50),
                      //     ),
                      //     label: const Text('Sign up with GitHub'),
                      //     icon: const Icon(SimpleIcons.github),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      // TextDivider(),
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
                                constraints: BoxConstraints(
                                  minWidth: 200,
                                  maxWidth: 300,
                                ),
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
                                FocusScope.of(
                                  context,
                                ).requestFocus(_emailFocusNode);
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
                                FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocusNode);
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
                                        _confirmPasswordController
                                            .text
                                            .isNotEmpty
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Beariscope & Beargenda use the same accounts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
