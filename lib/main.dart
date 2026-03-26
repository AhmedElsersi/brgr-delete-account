import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Destination email ───────────────────────────
const String kSupportEmail = 'ahmed.elsersi@datumcompany.com';

// ── App colours (from colors.dart) ─────────────
class AppColors {
  static const bg        = Color(0xFF111113);
  static const bg2       = Color(0xFF18181b);
  static const bg3       = Color(0xFF242428);
  static const border    = Color(0xFF2e2e33);
  static const primary   = Color(0xFFffbb4d);
  static const text      = Color(0xFFf4f4f4);
  static const textMuted = Color(0xFF9c9c9d);
  static const red       = Color(0xFFd72505);
  static const redPale   = Color(0xFF2a1209);
  static const redLight  = Color(0xFFe96a52);
  static const green     = Color(0xFF10b981);
}

void main() => runApp(const BrgrDeleteApp());

class BrgrDeleteApp extends StatelessWidget {
  const BrgrDeleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delete Account — BRGR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.bg2,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DeleteAccountPage(),
    );
  }
}

// ════════════════════════════════════════════════
// PAGE
// ════════════════════════════════════════════════
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});
  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _emailCtrl    = TextEditingController();
  final _commentsCtrl = TextEditingController();
  String  _reason     = '';
  bool    _confirmed  = false;
  bool    _loading    = false;
  bool    _submitted  = false;
  String? _errorMsg;

  bool get _canSubmit =>
      _confirmed && _emailCtrl.text.trim().contains('@') && !_loading;

  // ── Build mailto: URL and launch ─────────────
  Future<void> _submit() async {
    setState(() { _loading = true; _errorMsg = null; });

    final userEmail = _emailCtrl.text.trim();
    final reason    = _reason.isEmpty ? 'Not provided' : _reason;
    final comments  = _commentsCtrl.text.trim().isEmpty
        ? 'None'
        : _commentsCtrl.text.trim();
    final sentAt    = DateTime.now().toLocal().toString();

    final subject = Uri.encodeComponent(
      'Account Deletion Request — $userEmail',
    );

    final body = Uri.encodeComponent(
      'Account Deletion Request\n'
          '========================\n\n'
          'User Email : $userEmail\n'
          'Reason     : $reason\n'
          'Comments   : $comments\n'
          'Submitted  : $sentAt\n\n'
          '------------------------\n'
          'This request was submitted via the BRGR account deletion page.\n'
          'Please process it within 30 days.',
    );

    final mailtoUri = Uri.parse(
      'mailto:$kSupportEmail?subject=$subject&body=$body',
    );

    try {
      final launched = await launchUrl(mailtoUri);
      if (launched) {
        setState(() { _submitted = true; });
      } else {
        setState(() {
          _errorMsg = 'Could not open your email app. '
              'Please email $kSupportEmail directly.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Could not open your email app. '
            'Please email $kSupportEmail directly.';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 56),
                    child: _submitted
                        ? const _SuccessView()
                        : _FormView(
                      emailCtrl:       _emailCtrl,
                      commentsCtrl:    _commentsCtrl,
                      reason:          _reason,
                      confirmed:       _confirmed,
                      loading:         _loading,
                      canSubmit:       _canSubmit,
                      errorMsg:        _errorMsg,
                      onReasonChanged: (v) => setState(() => _reason = v),
                      onConfirmChanged:(v) => setState(() => _confirmed = v ?? false),
                      onEmailChanged:  (_) => setState(() {}),
                      onSubmit:        _submit,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const _Footer(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// FORM VIEW
// ════════════════════════════════════════════════
class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController commentsCtrl;
  final String  reason;
  final bool    confirmed;
  final bool    loading;
  final bool    canSubmit;
  final String? errorMsg;
  final ValueChanged<String>  onReasonChanged;
  final ValueChanged<bool?>   onConfirmChanged;
  final ValueChanged<String>  onEmailChanged;
  final VoidCallback          onSubmit;

  const _FormView({
    required this.emailCtrl,
    required this.commentsCtrl,
    required this.reason,
    required this.confirmed,
    required this.loading,
    required this.canSubmit,
    required this.errorMsg,
    required this.onReasonChanged,
    required this.onConfirmChanged,
    required this.onEmailChanged,
    required this.onSubmit,
  });

  static const _reasons = [
    'I no longer use the app',
    'Privacy concerns',
    'Switching to another service',
    'Technical issues',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Badge ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.redPale,
            border: Border.all(color: AppColors.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 7),
              Text('Irreversible Action',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.redLight,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Heading ──
        RichText(
          text: TextSpan(
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: AppColors.text,
            ),
            children: const [
              TextSpan(text: 'Delete your\n'),
              TextSpan(
                text: 'account & data',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "We're sorry to see you go. Filling out this form will open your "
              "email app with a pre-filled deletion request.",
          style: GoogleFonts.dmSans(
            fontSize: 14.5, height: 1.7, color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 28),

        // ── What gets deleted ──
        const _InfoBox(),
        const SizedBox(height: 24),

        // ── Form card ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg2,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Registered Email Address'),
              const SizedBox(height: 7),
              _styledTextField(
                controller: emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: onEmailChanged,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Reason for leaving (optional)'),
              const SizedBox(height: 7),
              _StyledDropdown(
                value: reason.isEmpty ? null : reason,
                items: _reasons,
                onChanged: onReasonChanged,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Additional comments (optional)'),
              const SizedBox(height: 7),
              _styledTextField(
                controller: commentsCtrl,
                hint: "Let us know if there's anything we can improve…",
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ── Confirm checkbox ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: Checkbox(
                      value: confirmed,
                      onChanged: onConfirmChanged,
                      activeColor: AppColors.primary,
                      checkColor: Colors.black,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 13, height: 1.55, color: AppColors.textMuted,
                        ),
                        children: const [
                          TextSpan(text: 'I understand this action is '),
                          TextSpan(
                            text: 'permanent and cannot be undone',
                            style: TextStyle(
                              color: AppColors.redLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '. All my data will be erased within 30 days.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Error ──
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redPale,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Text(errorMsg!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.redLight,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    disabledBackgroundColor: const Color(0xFF4a2018),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF8a4030),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mail_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Send Deletion Request',
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Helper hint ──
              Center(
                child: Text(
                  'This will open your email app with the request pre-filled.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.2,
    ),
  );

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.text),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14, color: const Color(0xFF4a4a50),
        ),
        filled: true,
        fillColor: AppColors.bg3,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// DROPDOWN
// ════════════════════════════════════════════════
class _StyledDropdown extends StatelessWidget {
  final String?              value;
  final List<String>         items;
  final ValueChanged<String> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text('Select a reason…',
            style: GoogleFonts.dmSans(
              fontSize: 14, color: const Color(0xFF4a4a50),
            ),
          ),
          dropdownColor: AppColors.bg3,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textMuted),
          items: items.map((r) => DropdownMenuItem(
            value: r,
            child: Text(r,
              style: GoogleFonts.dmSans(
                fontSize: 14, color: AppColors.text,
              ),
            ),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// INFO BOX
// ════════════════════════════════════════════════
class _InfoBox extends StatelessWidget {
  const _InfoBox();

  static const _items = [
    'Your profile and personal information',
    'Order history and saved addresses',
    'Saved payment methods',
    'Loyalty points and rewards',
    'All app preferences and settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT WILL BE DELETED',
            style: GoogleFonts.syne(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          ..._items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5, color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// SUCCESS VIEW
// ════════════════════════════════════════════════
class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg2,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.12),
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: const Icon(Icons.check, color: AppColors.green, size: 30),
            ),
            const SizedBox(height: 20),
            Text('Email App Opened',
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your deletion request has been pre-filled in your\n'
                  'email app. Please review and hit Send to submit it\n'
                  'to our support team.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.65,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Image.asset(
              'assets/logo.png',
              height: 28,
              fit: BoxFit.contain,
              color: const Color(0xFF111113),   // tint black to match dark logo
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// FOOTER
// ════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '© 2024 BRGR  ·  All rights reserved',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: const Color(0xFF4a4a50),
        ),
      ),
    );
  }
}