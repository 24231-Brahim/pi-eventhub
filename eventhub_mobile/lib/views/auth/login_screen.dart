import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import 'register_screen.dart';
import '../events/events_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const EventsListScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Login failed'),
              backgroundColor: Colors.red.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lang = context.read<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              const Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language toggle
                    Align(
                      alignment: Alignment.topRight,
                      child: _LanguageToggle(lang: lang, l: l),
                    ),
                    const SizedBox(height: 20),
                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const Icon(Icons.event_available,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(l.appTitle,
                        style: theme.textTheme.headlineMedium!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 36),
                    // Card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l.login,
                                  style: theme.textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              _InputField(
                                controller: _emailCtrl,
                                label: l.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l.fieldRequired;
                                  if (!v.contains('@')) return l.invalidEmail;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _InputField(
                                controller: _passCtrl,
                                label: l.password,
                                icon: Icons.lock_outline,
                                obscure: _obscure,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l.fieldRequired;
                                  if (v.length < 6) return l.passwordMin;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: auth.loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: auth.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Text(l.login,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.noAccount,
                            style:
                                const TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                          child: Text(l.register,
                              style:
                                  const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Register Screen ────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'GUEST';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _role);
    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EventsListScreen()),
          (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.error ?? 'Register failed'),
          backgroundColor: Colors.red.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              const Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.person_add,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(l.appTitle,
                      style: theme.textTheme.headlineSmall!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 28),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l.register,
                                style: theme.textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            _InputField(
                              controller: _nameCtrl,
                              label: l.name,
                              icon: Icons.person_outline,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _emailCtrl,
                              label: l.email,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return l.fieldRequired;
                                if (!v.contains('@')) return l.invalidEmail;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _passCtrl,
                              label: l.password,
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return l.fieldRequired;
                                if (v.length < 6) return l.passwordMin;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // Role selector
                            DropdownButtonFormField<String>(
                              value: _role,
                              decoration: InputDecoration(
                                labelText: l.role,
                                prefixIcon:
                                    const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: 'GUEST',
                                    child: Text(l.guest)),
                                DropdownMenuItem(
                                    value: 'ORGANIZER',
                                    child: Text(l.organizer)),
                              ],
                              onChanged: (v) =>
                                  setState(() => _role = v ?? 'GUEST'),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: auth.loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : Text(l.register,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.haveAccount,
                          style: const TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.login,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final LanguageProvider lang;
  final AppLocalizations l;

  const _LanguageToggle({required this.lang, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangButton(
              label: 'FR',
              selected: lang.locale.languageCode == 'fr',
              onTap: () => lang.setLocale('fr')),
          _LangButton(
              label: 'AR',
              selected: lang.locale.languageCode == 'ar',
              onTap: () => lang.setLocale('ar')),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }
}
