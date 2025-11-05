import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие
              _buildGreeting(),
              
              // Header
              _buildHeader(),
              
              // Программа лояльности
              _buildLoyaltyCard(),
              
              const SizedBox(height: 24),
              
              // Популярные SPA-путешествия
              _buildPopularSection(),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              _buildActionButtons(),
              
              const SizedBox(height: 100), // Отступ для bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Логотип
          Row(
            children: [
              Icon(
                Icons.eco,
                color: AppColors.buttonPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PRIRODA SPA',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Аватар (кликабельный)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(RouteNames.profile);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Добрый день,',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Somlone !',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.buttonPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Иконка
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.loyaltyIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.loyaltyIcon,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Программа лояльности',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Повышай свой уровень!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Стрелка
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Популярные SPA-путешествия',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildSPACard(
                title: 'Энергия земли',
                subtitle: 'Массаж и уход для восстановления',
                imageUrl: null, // Можно добавить изображение позже
              ),
              const SizedBox(width: 16),
              _buildSPACard(
                title: 'Водные',
                subtitle: 'Расслабление и умиротворение',
                imageUrl: null,
              ),
              const SizedBox(width: 16),
              _buildSPACard(
                title: 'Воздушные',
                subtitle: 'Легкость и свежесть',
                imageUrl: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSPACard({
    required String title,
    required String subtitle,
    String? imageUrl,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.buttonPrimary.withOpacity(0.8),
            AppColors.buttonPrimaryPressed,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Placeholder для изображения
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.buttonPrimary.withOpacity(0.3),
            ),
            child: Center(
              child: Icon(
                Icons.spa,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          // Текст поверх
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Кнопка "Приобрести сертификат"
          _buildPrimaryButton(
            text: 'Приобрести сертификат',
            onPressed: () {
              // TODO: Навигация
            },
          ),
          const SizedBox(height: 12),
          // Кнопка "Приобрести абонемент"
          _buildSecondaryButton(
            text: 'Приобрести абонемент',
            onPressed: () {
              // TODO: Навигация
            },
          ),
          const SizedBox(height: 12),
          // Кнопка "Приобрести товары"
          _buildDisabledButton(
            text: 'Приобрести товары',
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.buttonPrimary.withOpacity(0.4),
          disabledForegroundColor: Colors.white.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onLongPress: null,
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 26 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondaryText,
          side: BorderSide(
            color: AppColors.buttonSecondary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: AppColors.buttonSecondaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 26 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 26 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // TODO: Навигация
          switch (index) {
            case 0:
              // Home - уже на главной
              break;
            case 1:
              // Menu
              break;
            case 2:
              // Bookings
              break;
            case 3:
              Navigator.of(context).pushNamed(RouteNames.profile);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.buttonPrimary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
