import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/language_service.dart';
import '../../services/user_service.dart';
import '../../services/loyalty_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../models/loyalty.dart';
import '../../routes/route_names.dart';
import '../../app.dart' show LocalizationProvider;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedTheme = 'light';
  String _selectedLanguage = 'ru';
  
  User? _user;
  LoyaltyInfo? _loyaltyInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadData();
  }

  Future<void> _loadLanguage() async {
    final locale = await LanguageService().getLocale();
    if (mounted) {
      setState(() {
        _selectedLanguage = locale.languageCode;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final user = await UserService().getCurrentUser();
      final loyalty = await LoyaltyService().getLoyaltyInfo();
      if (mounted) {
        setState(() {
          _user = user;
          _loyaltyInfo = loyalty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Выйти из аккаунта?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Выйти',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.registration,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationProvider = LocalizationProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(l10n),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (!_isLoading && _user != null && _loyaltyInfo != null)
                    _buildLoyaltyWidget(_loyaltyInfo!),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle(l10n.generalSettings),
                  const SizedBox(height: 16),
                  _buildSwitchCard(
                    title: l10n.notifications,
                    value: _notificationsEnabled,
                    icon: Icons.notifications_outlined,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationCard(
                    title: l10n.support,
                    subtitle: l10n.contactUs,
                    icon: Icons.support_agent_outlined,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.support),
                          backgroundColor: AppColors.buttonPrimary,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(l10n.appearance),
                  const SizedBox(height: 16),
                  _buildLabel(l10n.theme),
                  const SizedBox(height: 12),
                  _buildSegmentedControl(
                    options: [l10n.light, l10n.dark],
                    selectedIndex: _selectedTheme == 'light' ? 0 : 1,
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedTheme = index == 0 ? 'light' : 'dark';
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(l10n.language),
                  const SizedBox(height: 16),
                  _buildLabel(l10n.appLanguage),
                  const SizedBox(height: 12),
                  _buildSegmentedControl(
                    options: [l10n.russian, l10n.english],
                    selectedIndex: _selectedLanguage == 'ru' ? 0 : 1,
                    onChanged: (index) async {
                      HapticFeedback.selectionClick();
                      final newLanguage = index == 0 ? 'ru' : 'en';
                      setState(() {
                        _selectedLanguage = newLanguage;
                      });
                      await LanguageService().setLanguage(newLanguage);
                      if (localizationProvider != null && mounted) {
                        localizationProvider.setLocale(Locale(newLanguage));
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(l10n.security),
                  const SizedBox(height: 16),
                  _buildSwitchCard(
                    title: l10n.biometricAuth,
                    subtitle: l10n.biometricAuthSubtitle,
                    value: _biometricEnabled,
                    icon: Icons.fingerprint_outlined,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(l10n.additional),
                  const SizedBox(height: 16),
                  _buildNavigationCard(
                    title: l10n.aboutApp,
                    icon: Icons.info_outline,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: const Text(
                            'О приложении',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PRIRODA SPA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.version('1.0.0'),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                l10n.close,
                                style: const TextStyle(color: AppColors.buttonPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationCard(
                    title: l10n.privacyPolicy,
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.privacyPolicy),
                          backgroundColor: AppColors.buttonPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationCard(
                    title: l10n.termsOfUse,
                    icon: Icons.description_outlined,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.termsOfUse),
                          backgroundColor: AppColors.buttonPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: l10n.clearCache,
                    icon: Icons.delete_outline,
                    color: AppColors.error,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Text(
                            l10n.clearCache,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          content: Text(l10n.clearCacheConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                l10n.cancel,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.cacheCleared),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              child: Text(
                                l10n.clear,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Выйти из аккаунта',
                    icon: Icons.logout_outlined,
                    color: AppColors.error,
                    onTap: _handleLogout,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.backgroundLight,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        l10n.settings,
        style: AppTextStyles.heading3.copyWith(
          fontFamily: 'Inter24',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoyaltyWidget(LoyaltyInfo info) {
    final level = info.currentLevel;
    if (level == null) return const SizedBox.shrink();

    final gradient = _getLoyaltyGradient(info);
    final metalName = _getMetalName(info);
    final nextLevel = info.nextLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(RouteNames.loyalty),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name,
                          style: AppTextStyles.heading3.copyWith(
                            fontFamily: 'Inter24',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metalName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontFamily: 'Inter18',
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    'Бонусы',
                    '${info.currentBonuses}',
                    Icons.stars_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatItem(
                    'Уровень',
                    '${_getLevelNumber(info.currentBonuses)}',
                    Icons.trending_up_rounded,
                  ),
                  if (nextLevel != null) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      'До след.',
                      '${info.bonusesToNext}',
                      Icons.flag_rounded,
                    ),
                  ],
                ],
              ),
              if (nextLevel != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: info.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              fontFamily: 'Inter24',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontFamily: 'Inter18',
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseLoyaltyColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.buttonPrimary;
    }
  }

  LinearGradient _getLoyaltyGradient(LoyaltyInfo info) {
    final level = info.currentLevel;
    if (level != null) {
      return LinearGradient(
        colors: [
          _parseLoyaltyColor(level.colorStart),
          _parseLoyaltyColor(level.colorEnd),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    
    // Fallback на основе бонусов, если уровень не определён (4 уровня)
    final bonuses = info.currentBonuses;
    if (bonuses < 100) {
      // Бронза
      return const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFFA0522D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (bonuses < 500) {
      // Серебро
      return const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFF808080)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (bonuses < 1000) {
      // Золото
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Алмаз
      return const LinearGradient(
        colors: [Color(0xFFB9F2FF), Color(0xFF4A90E2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  String _getMetalName(LoyaltyInfo info) {
    // Если есть уровень из backend — показываем его описание
    if (info.currentLevel != null) {
      return '${info.currentLevel!.name}';
    }
    
    // Fallback на основе бонусов (4 статуса)
    final bonuses = info.currentBonuses;
    if (bonuses < 100) return 'Бронзовый статус';
    if (bonuses < 500) return 'Серебряный статус';
    if (bonuses < 1000) return 'Золотой статус';
    return 'Алмазный статус';
  }

  int _getLevelNumber(int bonuses) {
    // Нумерация уровней без "обсидианового" уровня
    if (bonuses < 100) return 0;
    if (bonuses < 500) return 1;
    if (bonuses < 1000) return 2;
    if (bonuses < 2000) return 3;
    return 4;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          fontFamily: 'Inter24',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontFamily: 'Inter18',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    String? subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.buttonPrimary.withOpacity(0.15),
                          AppColors.buttonPrimary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.buttonPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontFamily: 'Inter24',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontFamily: 'Inter18',
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: value,
                    onChanged: onChanged,
                    activeColor: AppColors.buttonPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.buttonPrimary.withOpacity(0.15),
                          AppColors.buttonPrimary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.buttonPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontFamily: 'Inter24',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontFamily: 'Inter18',
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontFamily: 'Inter24',
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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

  Widget _buildSegmentedControl({
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(options.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.buttonPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    options[index],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Inter24',
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
