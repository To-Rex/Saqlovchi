import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../responsive.dart';

class ExpensesPage extends StatelessWidget {
  ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: Responsive.getPadding(
            context,
            basePadding: const EdgeInsets.all(defaultPadding),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context),
                _buildInputSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sarlavha qismi
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Center(
        child: Text(
          'Xarajatlar',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, baseSize: 22),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xarajat kiritish qismi
  Widget _buildInputSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 14)),
              decoration: InputDecoration(
                hintText: 'Xarajat nomi',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: Responsive.getFontSize(context, baseSize: 13)),
                filled: true,
                fillColor: Colors.black.withOpacity(0.06),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 1.5), borderRadius: BorderRadius.circular(10)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade400, width: 1), borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding / 2, vertical: defaultPadding / 2)
              ),
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 14),
              ),
              decoration: InputDecoration(
                hintText: 'Miqdori (UZS)',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: Responsive.getFontSize(context, baseSize: 13),
                ),
                filled: true,
                //fillColor: Colors.grey.shade800.withOpacity(0.8),
                fillColor: Colors.black.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2,
                  vertical: defaultPadding / 2,
                ),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          AnimatedScaleButton(),
        ],
      ),
    );
  }
}

class AnimatedScaleButton extends StatefulWidget {
  const AnimatedScaleButton({super.key});

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        // Tugma bosilganda logika shu yerga qo'shiladi
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: Responsive.getFontSize(context, baseSize: 16),
                color: Colors.white,
              ),
              SizedBox(width: defaultPadding / 4),
              Text(
                'Kiritish',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}