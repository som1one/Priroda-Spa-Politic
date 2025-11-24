import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/image_cache_manager.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/helpers.dart';

import '../../models/menu_category.dart';
import '../../models/service.dart';
import '../../models/loyalty.dart';
import '../../routes/route_names.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/connectivity_wrapper.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/animations.dart';
import '../../services/loyalty_service.dart';
import '../../screens/booking/yclients_booking_screen.dart';

class MenuSpaScreen extends StatefulWidget {
  const MenuSpaScreen({super.key});

  @override
  State<MenuSpaScreen> createState() => _MenuSpaScreenState();
}

class _MenuSpaScreenState extends State<MenuSpaScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  final _loyaltyService = LoyaltyService();
  List<MenuCategory> _rootCategories = [];
  final List<MenuCategory> _stack = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LoyaltyInfo? _loyaltyInfo;
  bool _isLoadingLoyalty = false;

  MenuCategory? get _currentCategory => _stack.isEmpty ? null : _stack.last;

  List<MenuCategory> get _visibleCategories =>
      _currentCategory?.children ?? _rootCategories;

  List<Service> get _visibleServices {
    // Собираем все услуги из всех категорий (без категорий)
    final allServices = <Service>[];
    
    void collectServices(List<MenuCategory> categories) {
      for (final category in categories) {
        // Добавляем услуги из категории
        allServices.addAll(category.services);
        // Рекурсивно собираем услуги из подкатегорий
        if (category.children.isNotEmpty) {
          collectServices(category.children);
        }
      }
    }
    
    collectServices(_rootCategories);
    return allServices;
  }

  List<Service> get _filteredServices {
    if (_searchQuery.isEmpty) return _visibleServices;
    return _visibleServices.where((service) {
      final query = _searchQuery.toLowerCase();
      return service.name.toLowerCase().contains(query) ||
          (service.subtitle?.toLowerCase().contains(query) ?? false) ||
          (service.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  bool get _hasServicesSection => _visibleServices.isNotEmpty;

  bool get _hasCategories => _visibleCategories.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _loadLoyaltyInfo();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadLoyaltyInfo() async {
    if (!_authService.isAuthenticated) return;
    
    setState(() {
      _isLoadingLoyalty = true;
    });

    try {
      final info = await _loyaltyService.getLoyaltyInfo();
      if (mounted) {
        setState(() {
          _loyaltyInfo = info;
          _isLoadingLoyalty = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLoyalty = false;
        });
      }
      // Не показываем ошибку, просто не загружаем информацию о бонусах
    }
  }

  Future<void> _handleBookingClick() async {
    // Открываем форму YClients для записи
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const YClientsBookingScreen(
          serviceId: 0, // Используем 0 для общей формы записи
        ),
      ),
    );
    
    // Обновляем информацию о бонусах после записи
    if (result != null && result['bookingCreated'] == true) {
      _loadLoyaltyInfo();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _authService.token;
      if (token != null) {
        _apiService.token = token;
      }

      final response = await _apiService.get('/menu/tree');
      final data = (response as List<dynamic>? ?? [])
          .map((item) {
            try {
              return MenuCategory.fromJson(
                Map<String, dynamic>.from(item as Map),
              );
            } catch (e) {
              print('❌ Ошибка парсинга категории: $e');
              print('Данные: $item');
              rethrow;
            }
          })
          .toList();

      if (!mounted) return;

      // Отладка: проверяем количество услуг
      print('📊 Загружено категорий: ${data.length}');
      for (final category in data) {
        print('📁 Категория: ${category.name} (ID: ${category.id}), услуг: ${category.services.length}');
        if (category.services.isEmpty) {
          print('  ⚠️ В категории нет услуг!');
        } else {
          for (final service in category.services) {
            print('  - Услуга: ${service.name} (ID: ${service.id}, активна: ${service.isActive}, categoryId: ${service.categoryId})');
          }
        }
        // Проверяем вложенные категории
        if (category.children.isNotEmpty) {
          print('  📂 Подкатегорий: ${category.children.length}');
          for (final child in category.children) {
            print('    📁 Подкатегория: ${child.name} (ID: ${child.id}), услуг: ${child.services.length}');
          }
        }
      }

      setState(() {
        _rootCategories = data;
        _stack.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки меню: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToCategory(MenuCategory category) {
    setState(() {
      _stack.add(category);
      _searchController.clear();
    });
  }

  void _navigateBack() {
    if (_stack.isNotEmpty) {
      setState(() {
        _stack.removeLast();
        _searchController.clear();
      });
    }
  }

  void _navigateToRoot() {
    setState(() {
      _stack.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      onRetry: _loadMenu,
      child: Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        title: Column(
          children: [
            SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  'Меню',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Аккуратный разделитель под заголовком
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.buttonPrimary.withOpacity(0.2),
                    AppColors.buttonPrimary.withOpacity(0.3),
                    AppColors.buttonPrimary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedStateSwitcher(
          child: _isLoading
              ? _buildSkeletonLoader()
              : _error != null
                  ? FadeInWidget(
                      child: EmptyState(
                        type: EmptyStateType.error,
                        title: 'Ошибка загрузки услуг',
                        error: _error,
                        onButtonPressed: _loadMenu,
                      ),
                    )
                  : _rootCategories.isEmpty
                      ? FadeInWidget(
                          child: const EmptyState(
                            type: EmptyStateType.noData,
                          ),
                        )
                      : SizedBox.expand(
                          child: Column(
                            children: [
                              // Поиск (только если есть услуги)
                              if (_hasServicesSection) _buildSearchBar(),
                              
                              // Контент
                              Expanded(
                                child: RefreshIndicator(
                              onRefresh: _loadMenu,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Красивая секция записи с бонусами (только в корне меню)
                                      if (_stack.isEmpty && _searchQuery.isEmpty)
                                        _buildBookingSection(),
                                      
                                      // Секция услуг (категории убраны)
                                      if (_hasServicesSection ||
                                          (_searchQuery.isNotEmpty &&
                                              _filteredServices.isNotEmpty))
                                        _buildServicesSection(),
                                      
                                      // Пустое состояние поиска
                                      if (_searchQuery.isNotEmpty &&
                                          _filteredServices.isEmpty) ...[
                                        const SizedBox(height: 48),
                                        const EmptyState(
                                          type: EmptyStateType.noSearchResults,
                                          compact: true,
                                        ),
                                      ],
                                      
                                      // Пустое состояние если нет услуг
                                      if (!_hasServicesSection && _searchQuery.isEmpty) ...[
                                        const SizedBox(height: 48),
                                        EmptyState(
                                          type: EmptyStateType.noData,
                                          title: 'Меню пусто',
                                          message: 'Пока нет доступных услуг',
                                          icon: Icons.restaurant_menu_outlined,
                                          compact: true,
                                        ),
                                      ],
                                      
                                      // Отступ снизу
                                      const SizedBox(height: 80),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                            ],
                          ),
                        ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNav(
          current: BottomNavItem.menu,
        ),
      ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Skeleton для заголовка
          const SkeletonText(width: 120, height: 24),
          const SizedBox(height: 16),
          // Skeleton для категорий в виде сетки
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return const SkeletonCategoryCard();
            },
          ),
          const SizedBox(height: 24),
          // Skeleton для услуг
          const SkeletonText(width: 80, height: 20),
          const SizedBox(height: 16),
          const SkeletonServiceCard(),
          const SizedBox(height: 12),
          const SkeletonServiceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.buttonPrimary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск услуг...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.buttonPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search,
              color: AppColors.buttonPrimary,
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    if (_stack.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: _navigateToRoot,
              child: Text(
                'Главная',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.buttonPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...(_stack.map((category) {
              final index = _stack.indexOf(category);
              return Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _stack.removeRange(index + 1, _stack.length);
                        _searchController.clear();
                      });
                    },
                    child: Text(
                      category.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: index == _stack.length - 1
                            ? AppColors.textPrimary
                            : AppColors.buttonPrimary,
                        fontWeight: index == _stack.length - 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_stack.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Категории',
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 26,
                letterSpacing: -0.5,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Подкатегории',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 22,
                letterSpacing: -0.3,
              ),
            ),
          ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.88,
          ),
          itemCount: _visibleCategories.length,
          itemBuilder: (context, index) {
            final category = _visibleCategories[index];
            return ScaleInWidget(
              duration: Duration(milliseconds: 300 + (index * 50)),
              child: _CategoryCard(
                category: category,
                onTap: () => _navigateToCategory(category),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookingSection() {
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Декоративные элементы
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Контент
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Иконка и заголовок
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Записаться на услугу',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Выберите удобное время',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Информация о бонусах
                  if (_loyaltyInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.warning,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Получите бонусы за запись!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _loyaltyInfo!.currentBonuses > 0
                                      ? 'У вас ${_loyaltyInfo!.currentBonuses} бонусов. Используйте их при записи!'
                                      : 'За каждую запись вы получаете бонусы, которые можно использовать для оплаты',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.white.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_isLoadingLoyalty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Загрузка информации о бонусах...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Кнопка записи
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleBookingClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Записаться онлайн',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Подсказка
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Выберите услугу, мастера и удобное время в форме записи',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    final servicesToShow = _searchQuery.isNotEmpty
        ? _filteredServices
        : _visibleServices;

    if (servicesToShow.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _searchQuery.isNotEmpty ? 'Результаты поиска' : 'Услуги',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 26,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AnimatedListWidget(
          children: List.generate(
            servicesToShow.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < servicesToShow.length - 1 ? 16 : 0),
              child: _ServiceCard(
                service: servicesToShow[index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MenuCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = category.children?.isNotEmpty ?? false;
    final hasServices = category.services?.isNotEmpty ?? false;
    final itemCount = (hasChildren ? 1 : 0) + (hasServices ? 1 : 0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonPrimary.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Фоновое изображение
                if (category.imageUrl != null &&
                    category.imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: Helpers.resolveImageUrl(category.imageUrl!) ??
                          category.imageUrl!,
                      cacheManager: SpaImageCacheManager.instance,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.buttonPrimary.withOpacity(0.12),
                              AppColors.buttonPrimary.withOpacity(0.04),
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.buttonPrimary.withOpacity(0.15),
                              AppColors.buttonPrimary.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.buttonPrimary.withOpacity(0.15),
                          AppColors.buttonPrimary.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                
                // Градиент для лучшей читаемости
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Контент
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: -0.3,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 6,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (itemCount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasChildren && hasServices
                                    ? Icons.folder
                                    : hasChildren
                                        ? Icons.folder_outlined
                                        : Icons.spa,
                                size: 13,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                itemCount.toString(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Иконка стрелки
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: AppColors.buttonPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteNames.serviceDetail,
            arguments: {'serviceId': service.id},
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.buttonPrimary.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonPrimary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Изображение услуги
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.buttonPrimary.withOpacity(0.1),
                        AppColors.buttonPrimary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: service.imageUrl != null &&
                          service.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: Helpers.resolveImageUrl(service.imageUrl!) ??
                              service.imageUrl!,
                          cacheManager: SpaImageCacheManager.instance,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.spa_outlined,
                              color: AppColors.buttonPrimary.withOpacity(0.4),
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.transparent,
                          child: Icon(
                            Icons.spa_outlined,
                            color: AppColors.buttonPrimary.withOpacity(0.4),
                            size: 40,
                          ),
                        ),
                ),
              ),
              
              // Информация об услуге
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Название
                      Flexible(
                        child: Text(
                          service.name,
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Подзаголовок
                      if (service.subtitle != null &&
                          service.subtitle!.isNotEmpty)
                        Flexible(
                          child: Text(
                            service.subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Цена и длительность
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Цена
                          Flexible(
                            child: Text(
                              service.price != null
                                  ? '${service.price!.toStringAsFixed(0)} ₽'
                                  : 'По запросу',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.buttonPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Длительность
                          if (service.duration != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.buttonPrimary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.buttonPrimary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 15,
                                    color: AppColors.buttonPrimary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${service.duration} мин',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.buttonPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
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
              
              // Стрелка
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.buttonPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.buttonPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
