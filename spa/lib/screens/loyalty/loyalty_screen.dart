import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/loyalty_service.dart';
import '../../services/user_service.dart';
import '../../models/loyalty.dart';
import '../../models/user.dart';
import '../../widgets/app_bottom_nav.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  LoyaltyInfo? _loyaltyInfo;
  bool _isLoading = true;
  bool _useLoyaltyPoints = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyInfo();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final user = await UserService().getCurrentUser();
      setState(() {
        _useLoyaltyPoints = user?.autoApplyLoyaltyPoints ?? false;
      });
    } catch (e) {
      // Игнорируем ошибки загрузки настроек
    }
  }

  Future<void> _loadLoyaltyInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final info = await LoyaltyService().getLoyaltyInfo();
      setState(() {
        _loyaltyInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.buttonPrimary;
    }
  }

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'local_offer':
        return Icons.local_offer;
      case 'star_outline':
        return Icons.star_outline;
      default:
        return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadLoyaltyInfo,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  )
                : _loyaltyInfo == null
                    ? const Center(child: Text('Нет данных'))
                    : RefreshIndicator(
                        onRefresh: _loadLoyaltyInfo,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Шапка "Мои бонусы" как на референсе
                              _buildHeaderSummary(_loyaltyInfo!),
                              const SizedBox(height: 24),

                              // Линейка уровней и кэшбэка
                              _buildLevelsTimeline(_loyaltyInfo!),
                              const SizedBox(height: 32),

                              // Текущий уровень (карточка статуса)
                              _buildCurrentLevelCard(_loyaltyInfo!),
                              const SizedBox(height: 24),

                              // Прогресс до следующего уровня
                              if (_loyaltyInfo!.nextLevel != null) ...[
                                _buildProgressSection(_loyaltyInfo!),
                                const SizedBox(height: 32),
                              ],

                              // Использовать баллы автоматически
                              _buildUsePointsCard(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomNav(
          current: BottomNavItem.loyalty,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Мои бонусы',
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSummary(LoyaltyInfo info) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.card_giftcard,
              color: AppColors.buttonPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${info.currentBonuses}',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Бонусами можно оплачивать любые\nпроцедуры в PRIRODA SPA',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1 бонус = 1 рубль',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${_getLevelNumber(info.currentBonuses)} уровень',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsTimeline(LoyaltyInfo info) {
    // Статическая лестница уровней как на референсе
    final levels = [
      {
        'label': '1 уровень',
        'cashback': '+3%',
        'description': 'кэшбэк на spa\nпроцедуры',
        'threshold': 'потратить сумму от 30000',
      },
      {
        'label': '2 уровень',
        'cashback': '+5%',
        'description': 'кэшбэк на spa\nпроцедуры',
        'threshold': 'потратить сумму от 100000',
      },
      {
        'label': '3 уровень',
        'cashback': '+7%',
        'description': 'кэшбэк на spa\nпроцедуры',
        'threshold': 'потратить сумму от 200000',
      },
      {
        'label': '4 уровень',
        'cashback': '+10%',
        'description': 'кэшбэк на spa\nпроцедуры',
        'threshold': 'потратить сумму от 300000',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Уровни и кэшбэк'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Линия с делениями
              Row(
                children: List.generate(levels.length, (index) {
                  final isLast = index == levels.length - 1;
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.buttonPrimary,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: AppColors.borderLight,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              // Карточки уровней
              Row(
                children: levels.map((level) {
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          level['label'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.buttonPrimary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                level['cashback'] as String,
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.buttonPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level['description'] as String,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          level['threshold'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getLevelNumber(int bonuses) {
    if (bonuses < 100) return 0;
    if (bonuses < 500) return 1;
    if (bonuses < 1000) return 2;
    return 3;
  }

  Widget _buildCurrentLevelCard(LoyaltyInfo info) {
    final level = info.currentLevel;
    final nextLevel = info.nextLevel;
    if (level == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.buttonPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Начало пути',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Накоплено ${info.currentBonuses} бонусов',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final gradient = LinearGradient(
      colors: [
        _parseColor(level.colorStart),
        _parseColor(level.colorEnd),
      ],
    );
    final levelColor = _parseColor(level.colorStart);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _parseIcon(level.icon),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Накоплено ${info.currentBonuses} бонусов',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (nextLevel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ваш путь к ${nextLevel.name}!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(LoyaltyInfo info) {
    final currentLevel = info.currentLevel;
    final nextLevel = info.nextLevel;
    
    if (nextLevel == null || currentLevel == null) {
      return const SizedBox.shrink();
    }

    final levelColor = _parseColor(currentLevel.colorStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогресс до следующего уровня',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              nextLevel.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: info.progress,
            minHeight: 8,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.eco,
              size: 16,
              color: levelColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Ещё ${info.bonusesToNext} бонусов до "${nextLevel.name}"',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildBonusCard({
    required LoyaltyBonus bonus,
    required Color levelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _parseIcon(bonus.icon),
              color: levelColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bonus.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bonus.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsePointsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Использовать баллы',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Автоматически применять баллы лояльности при бронировании',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _useLoyaltyPoints,
            onChanged: (value) async {
              HapticFeedback.lightImpact();
              setState(() {
                _useLoyaltyPoints = value;
              });
              try {
                await LoyaltyService().updateAutoApply(value);
                // Обновляем кеш пользователя
                await UserService().refreshUser();
              } catch (e) {
                // Откатываем изменение при ошибке
                setState(() {
                  _useLoyaltyPoints = !value;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Не удалось сохранить настройку: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            activeColor: AppColors.buttonPrimary,
          ),
        ],
      ),
    );
  }
}
