import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class NameRegistrationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String phone;

  const NameRegistrationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.phone,
  })  : assert(phone != '', 'Phone number is required'),
        assert(password != '', 'Password is required');

  @override
  State<NameRegistrationScreen> createState() => _NameRegistrationScreenState();
}

class _NameRegistrationScreenState extends State<NameRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushNamed(
      RouteNames.verifyEmail,
      arguments: {
        'email': widget.email,
        'password': widget.password,
        'phone': widget.phone,
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
      },
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите имя';
    }
    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    if (value.trim().length > 100) {
      return 'Имя должно содержать не более 100 символов';
    }
    return null;
  }

  String? _validateSurname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите фамилию';
    }
    if (value.trim().length < 2) {
      return 'Фамилия должна содержать минимум 2 символа';
    }
    if (value.trim().length > 100) {
      return 'Фамилия должна содержать не более 100 символов';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.buttonPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Осталось совсем чуть-чуть',
            style: AppTextStyles.heading3.copyWith(
              fontFamily: 'Inter24',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Пожалуйста, заполните оставшиеся поля, чтобы завершить регистрацию.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Inter18',
                      fontSize: 16,
                      height: 26 / 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Имя',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Inter24',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Введите ваше имя'),
                    keyboardType: TextInputType.name,
                    validator: _validateName,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Фамилия',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Inter24',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _surnameController,
                    decoration: _inputDecoration('Введите вашу фамилию'),
                    keyboardType: TextInputType.name,
                    validator: _validateSurname,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.buttonPrimary.withOpacity(0.25),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Продолжить',
                        style: AppTextStyles.button.copyWith(
                          fontFamily: 'Inter24',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        fontFamily: 'Inter24',
        fontSize: 16,
        color: const Color(0xFFB6BAC4),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.buttonPrimary.withOpacity(0.28),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.buttonPrimary.withOpacity(0.28),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.buttonPrimary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    );
  }
}

