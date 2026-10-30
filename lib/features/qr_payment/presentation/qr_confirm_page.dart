import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QrConfirmPage extends StatefulWidget {
  const QrConfirmPage({
    super.key,
    required this.amount,
    required this.currency,
    required this.recipient,
    this.remark = '',
  });
  final double amount;
  final String currency, recipient, remark;
  @override
  State<QrConfirmPage> createState() => _QrConfirmPageState();
}

class _QrConfirmPageState extends State<QrConfirmPage> {
  int digits = 0;
  bool complete = false;

  void enter() {
    if (complete) return;
    setState(() => digits++);
    if (digits == 4) {
      complete = true;
      Navigator.pop(context, true);
    }
  }

  Widget number(String label, double size) => SizedBox(
    width: size,
    height: size,
    child: OutlinedButton(
      onPressed: enter,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFEBEEF0),
        foregroundColor: const Color(0xFF333333),
        side: const BorderSide(color: Color(0xFF777777), width: 1),
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w500),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F2F2),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final top = MediaQuery.paddingOf(context).top;
        final bottom = MediaQuery.paddingOf(context).bottom;
        final width = constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;
        final keySize = (width * .205).clamp(56.0, 81.0);
        final keypadHeight = keySize * 4 + 36 + 68 + bottom;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(
                    height: top + 280,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: top + 175,
                          child: ClipPath(
                            clipper: const _ConfirmHeaderClipper(),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF303030),
                                    Color(0xFF777777),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: top + 8,
                          left: 8,
                          child: IconButton(
                            tooltip: 'Cancel confirmation',
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                        ),
                        Positioned(
                          top: top + 10,
                          left: 55,
                          right: 55,
                          child: const Column(
                            children: [
                              Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter PIN code for debit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: top + 90,
                          left: 24,
                          right: 24,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  14,
                                  24,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              NumberFormat(
                                                widget.currency == 'USD'
                                                    ? '#,##0.00'
                                                    : '#,##0',
                                              ).format(widget.amount),
                                              style: const TextStyle(
                                                fontSize: 29,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          widget.currency,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 13),
                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Color(0xFFDDDDDD),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            'Payment to',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Color(0xFFDDDDDD),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF00667D),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Text(
                                                'BANK',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFD71920),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.qr_code_2,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                spacing: 10,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    '000 123 333',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xFF333333),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 1,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFFF5060,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      widget.currency,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Color(
                                                          0xFFD71920,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                widget.recipient,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF8795A3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.remark.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        widget.remark,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: keypadHeight),
                    padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: width - 48,
                        child: Column(
                          children: [
                            Semantics(
                              label: '$digits of 4 demo PIN digits entered',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < 4; i++)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: i < digits
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFF2F2F2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF333333),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Demo • any 4 digits',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 16),
                            for (final row in [
                              ['1', '2', '3'],
                              ['4', '5', '6'],
                              ['7', '8', '9'],
                            ]) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (final digit in row)
                                    number(digit, keySize),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: keySize,
                                  height: keySize,
                                  child: IconButton(
                                    tooltip: 'Biometric demo',
                                    onPressed: () =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Biometric preview • Enter any 4 digits to confirm this demo payment',
                                            ),
                                          ),
                                        ),
                                    icon: const Icon(
                                      Icons.fingerprint,
                                      size: 28,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                number('0', keySize),
                                SizedBox(
                                  width: keySize,
                                  height: keySize,
                                  child: IconButton(
                                    tooltip: 'Delete PIN digit',
                                    onPressed: () {
                                      if (digits > 0) {
                                        setState(() => digits--);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 30,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _ConfirmHeaderClipper extends CustomClipper<Path> {
  const _ConfirmHeaderClipper();
  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - 15)
    ..quadraticBezierTo(size.width / 2, size.height + 30, 0, size.height - 15)
    ..close();
  @override
  bool shouldReclip(_ConfirmHeaderClipper oldClipper) => false;
}
