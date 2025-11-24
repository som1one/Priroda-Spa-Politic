import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/image_cache_manager.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/loyalty_service.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../models/loyalty.dart';
import '../../routes/route_names.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/connectivity_wrapper.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../utils/api_exceptions.dart';
import '../../widgets/animations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  final _userService = UserService();
  final _loyaltyService = LoyaltyService();
  User? _user;
  List<Booking> _bookings = [];
  LoyaltyInfo? _loyaltyInfo;
  bool _isLoading = true;
  bool _isLoadingBookings = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  bool _hasCheckedInitialRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedInitialRefresh) {
      _hasCheckedInitialRefresh = true;
      final result = ModalRoute.of(context)?.settings.arguments;
      if (result is Map && result['refreshBookings'] == true) {
        _loadBookings();
      }
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _authService.token;
      if (token != null) {
        _apiService.token = token;
      }

      final response = await _apiService.get('/auth/me');
      final user = User.fromJson(response);

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
      _userService.updateCachedUser(user);

      await Future.wait([
        _loadBookings(),
        _loadLoyalty(),
      ]);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getErrorMessage(e)),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });

    try {
      final token = _authService.token;
      if (token != null) {
        _apiService.token = token;
      }

      final response = await _apiService.get('/bookings');
      final List<dynamic> bookingsData = response is List 
          ? response 
          : (response['bookings'] as List<dynamic>? ?? []);

      final bookings = bookingsData
          .where((json) => json is Map<String, dynamic>)
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _loadLoyalty() async {
    try {
      final info = await _loyaltyService.getLoyaltyInfo();
      if (!mounted) return;
      setState(() {
        _loyaltyInfo = info;
      });
    } catch (e) {
      // Игнорируем ошибки загрузки лояльности
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      onRetry: _loadProfile,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Профиль',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
          ],
        ),
        toolbarHeight: 88,
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedStateSwitcher(
          child: _isLoading
              ? _buildSkeletonLoader()
              : _error != null
                  ? FadeInWidget(
                      child: _buildErrorState(),
                    )
                  : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _ProfileHeaderCard(user: _user),
                          const SizedBox(height: 16),
                          if (_loyaltyInfo != null) _LoyaltyCard(loyaltyInfo: _loyaltyInfo!),
                          if (_loyaltyInfo != null) const SizedBox(height: 24),
                          _UpcomingBookingsSection(
                            isLoading: _isLoadingBookings,
                            bookings: _bookings,
                          ),
                          const SizedBox(height: 24),
                          _QuickLinks(
                            onSettings: () => Navigator.of(context).pushNamed(RouteNames.settings),
                            onSupport: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Скоро добавим поддержку прямо в приложении')),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNav(
          current: BottomNavItem.profile,
        ),
      ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const SkeletonProfileHeader(),
          const SizedBox(height: 16),
          // Skeleton для карточки лояльности
          const SkeletonCard(
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(height: 24),
          // Skeleton для заголовка "Предстоящие записи"
          const SkeletonText(width: 180, height: 24),
          const SizedBox(height: 12),
          // Skeleton для карточек записей
          const SkeletonBookingCard(),
          const SizedBox(height: 12),
          const SkeletonBookingCard(),
          const SizedBox(height: 24),
          // Skeleton для "Быстрые ссылки"
          const SkeletonText(width: 150, height: 20),
          const SizedBox(height: 12),
          const SkeletonCard(
            height: 64,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          const SizedBox(height: 12),
          const SkeletonCard(
            height: 64,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки профиля',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Попробуйте повторить позже',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final User? user;

  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    final resolved = avatarUrl != null && avatarUrl.isNotEmpty
        ? Helpers.resolveImageUrl(avatarUrl) ?? avatarUrl
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC1CC), width: 2.5),
                ),
                  child: ClipOval(
                    child: resolved != null && resolved.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: resolved,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            cacheManager: SpaImageCacheManager.instance,
                            placeholder: (_, __) => Container(
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.cardBackground,
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 36,
                            ),
                          ),
                  ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Гость',
                  style: AppTextStyles.heading4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user?.uniqueCode != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWithOpacity10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Код: ${user!.uniqueCode}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            // Копируем код в буфер обмена
                            // TODO: Добавить функционал копирования
                          },
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
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
}

class _LoyaltyCard extends StatelessWidget {
  final LoyaltyInfo loyaltyInfo;

  const _LoyaltyCard({required this.loyaltyInfo});

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.buttonPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = loyaltyInfo.currentLevel;
    final nextLevel = loyaltyInfo.nextLevel;
    final currentBonuses = loyaltyInfo.currentBonuses;
    
    if (currentLevel == null) {
      return const SizedBox.shrink();
    }

    int bonusesToNext = 0;
    double progress = 0.0;
    String statusText = currentLevel.name;
    String subtitleText = '';

    if (nextLevel != null) {
      bonusesToNext = nextLevel.minBonuses - currentBonuses;
      final range = nextLevel.minBonuses - currentLevel.minBonuses;
      if (range > 0) {
        progress = ((currentBonuses - currentLevel.minBonuses) / range).clamp(0.0, 1.0);
      }
      subtitleText = 'Осталось $bonusesToNext бонусов до следующего уровня.';
    } else {
      progress = 1.0;
      subtitleText = 'Вы на максимальном уровне';
    }

    if (currentLevel == null) {
      return const SizedBox.shrink();
    }

    final levelColorStart = _parseColor(currentLevel.colorStart);
    final levelColorEnd = _parseColor(currentLevel.colorEnd);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.loyalty),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [levelColorStart, levelColorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: levelColorStart.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ваш уровень лояльности:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Бонусы: $currentBonuses',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitleText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBDBDBD),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingBookingsSection extends StatelessWidget {
  final bool isLoading;
  final List<Booking> bookings;

  const _UpcomingBookingsSection({
    required this.isLoading,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final futureBookings = bookings
        .where((b) => b.appointmentDateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (!isLoading) {
                  Navigator.of(context).pushNamed(RouteNames.bookings);
                }
              },
              child: Text(
                'Предстоящие записи',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            if (!isLoading && futureBookings.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.bookings);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Все',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.buttonPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.buttonPrimary,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (futureBookings.isEmpty)
          const CompactEmptyState(
            message: 'Нет ближайших записей',
          )
        else
          AnimatedListWidget(
            children: futureBookings.take(2).map((booking) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteNames.bookings);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F2),
                      borderRadius: BorderRadius.circular(18),
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
                                booking.serviceName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDateTime(booking.appointmentDateTime),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _QuickLinks extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onSupport;

  const _QuickLinks({
    required this.onSettings,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые ссылки',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        _QuickLinkTile(
          icon: Icons.settings_outlined,
          title: 'Настройки',
          onTap: onSettings,
        ),
        const SizedBox(height: 12),
        _QuickLinkTile(
          icon: Icons.help_outline,
          title: 'Помощь и поддержка',
          onTap: onSupport,
        ),
      ],
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F2),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F2),
            borderRadius: BorderRadius.circular(18),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.buttonPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]} в '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
