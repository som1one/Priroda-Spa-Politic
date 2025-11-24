import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/time_slot.dart';
import '../../models/service.dart';
import '../../services/booking_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../routes/route_names.dart';

class TimeSelectionScreen extends StatefulWidget {
  final int serviceId;
  final Service? service;
  final int staffId;
  final String staffName;

  const TimeSelectionScreen({
    super.key,
    required this.serviceId,
    this.service,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  final _bookingService = BookingService();
  List<TimeSlot> _timeSlots = [];
  Set<String> _availableDays = {};
  bool _isLoading = true;
  bool _isLoadingDays = true;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    // Инициализация locale для table_calendar
    _selectedDate = DateTime.now();
    _loadAvailableDays();
    _loadTimeSlots();
  }

  Future<void> _loadAvailableDays() async {
    setState(() {
      _isLoadingDays = true;
    });

    try {
      final days = await _bookingService.getAvailableDays(
        serviceId: widget.serviceId,
        staffId: widget.staffId,
        daysAhead: 60,
      );
      
      if (!mounted) return;
      
      setState(() {
        _availableDays = days.toSet();
        _isLoadingDays = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки доступных дней: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingDays = false;
      });
    }
  }

  Future<void> _loadTimeSlots({DateTime? date}) async {
    final targetDate = date ?? _selectedDate;
    
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedTimeSlot = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      print('🔍 Загрузка слотов для даты: $dateStr, service_id: ${widget.serviceId}, staff_id: ${widget.staffId}');
      
      final slots = await _bookingService.getAvailableTimeSlots(
        serviceId: widget.serviceId,
        staffId: widget.staffId,
        dateStr: dateStr,
      );
      
      print('✅ Получено слотов: ${slots.length}');
      
      if (!mounted) return;
      
      final filteredSlots = slots.where((slot) => slot.date == dateStr).toList();
      print('✅ После фильтрации: ${filteredSlots.length} слотов');
      
      setState(() {
        _timeSlots = filteredSlots;
        _isLoading = false;
        _selectedDate = targetDate;
      });
    } catch (e) {
      print('❌ Ошибка загрузки слотов: $e');
      
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Выберите время',
          style: AppTextStyles.heading3.copyWith(
            fontFamily: 'Inter24',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Инфо блок
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
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
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: AppColors.buttonPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.staffName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontFamily: 'Inter24',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.service != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.service!.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Выбор даты (горизонтальный календарь)
          _buildDateSelector(),
          // Список слотов времени
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null || _timeSlots.isEmpty
                    ? EmptyState(
                        type: EmptyStateType.noData,
                        message: 'Нет доступных слотов на выбранную дату',
                        onButtonPressed: _loadTimeSlots,
                      )
                    : _buildTimeSlotsList(),
          ),
          // Кнопка продолжить
          if (_selectedTimeSlot != null) _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 60)); // 2 месяца вперед
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: TableCalendar(
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.isBefore(firstDay)) return;
          _loadTimeSlots(date: selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        locale: 'ru_RU',
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.heading3.copyWith(
            fontFamily: 'Inter24',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.buttonPrimary,
            size: 28,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.buttonPrimary,
            size: 28,
          ),
        ),
        calendarStyle: CalendarStyle(
          // Стиль для сегодняшнего дня
          todayDecoration: BoxDecoration(
            color: AppColors.buttonPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Inter24',
            color: AppColors.buttonPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.0,
          ),
          // Стиль для выбранного дня
          selectedDecoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Inter24',
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.0,
          ),
          // Стиль для обычных дней
          defaultTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Inter18',
            color: AppColors.textPrimary,
            fontSize: 11,
            height: 1.0,
          ),
          // Стиль для выходных
          weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Inter18',
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.0,
          ),
          // Стиль для дней вне месяца
          outsideTextStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 9,
            height: 1.0,
          ),
          // Стиль для недоступных дней
          disabledTextStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted.withOpacity(0.4),
            fontSize: 9,
            height: 1.0,
          ),
          // Отступы - минимальные для предотвращения переполнения
          cellMargin: const EdgeInsets.all(1),
          cellPadding: EdgeInsets.zero,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.bodySmall.copyWith(
            fontFamily: 'Inter18',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.0,
          ),
          weekendStyle: AppTextStyles.bodySmall.copyWith(
            fontFamily: 'Inter18',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.0,
          ),
        ),
        enabledDayPredicate: (day) {
          // Отключаем прошедшие дни
          if (day.isBefore(firstDay)) return false;
          
          // Если загружаются дни, разрешаем все будущие дни
          if (_isLoadingDays) return true;
          
          // Разрешаем только дни, у которых есть доступные слоты
          final dateStr = DateFormat('yyyy-MM-dd').format(day);
          return _availableDays.contains(dateStr);
        },
        calendarBuilders: CalendarBuilders(
          // Кастомный билдер для ячеек с обрезкой
          defaultBuilder: (context, date, focused) {
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final hasSlots = _availableDays.contains(dateStr);
            final isSelected = isSameDay(date, _selectedDate);
            final isToday = isSameDay(date, DateTime.now());
            final isDisabled = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            
            return ClipRect(
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.buttonPrimary 
                      : (isToday 
                          ? AppColors.buttonPrimary.withOpacity(0.2) 
                          : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${date.day}',
                          style: isSelected
                              ? AppTextStyles.bodyMedium.copyWith(
                                  fontFamily: 'Inter24',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  height: 1.0,
                                )
                              : (isToday
                                  ? AppTextStyles.bodyMedium.copyWith(
                                      fontFamily: 'Inter24',
                                      color: AppColors.buttonPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      height: 1.0,
                                    )
                                  : (isDisabled
                                      ? AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textMuted.withOpacity(0.4),
                                          fontSize: 9,
                                          height: 1.0,
                                        )
                                      : AppTextStyles.bodyMedium.copyWith(
                                          fontFamily: 'Inter18',
                                          color: AppColors.textPrimary,
                                          fontSize: 11,
                                          height: 1.0,
                                        ))),
                        ),
                      ),
                      if (hasSlots && !isSelected && !isToday)
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: AppColors.buttonPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          // Помечаем дни с доступными слотами
          markerBuilder: (context, date, events) {
            return null; // Используем defaultBuilder вместо markerBuilder
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (_, __) => const SkeletonLoader(width: double.infinity, height: 48),
    );
  }

  Widget _buildTimeSlotsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final slot = _timeSlots[index];
        return _buildTimeSlotCard(slot);
      },
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    final isSelected = _selectedTimeSlot == slot.datetime;
    
    return InkWell(
      onTap: slot.available ? () => setState(() => _selectedTimeSlot = slot.datetime) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.buttonPrimary : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            slot.time,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Inter24',
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (slot.available ? AppColors.textPrimary : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Продолжить',
              style: AppTextStyles.bodyLarge.copyWith(
                fontFamily: 'Inter24',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedTimeSlot == null) return;
    
    Navigator.of(context).pushNamed(
      RouteNames.bookingConfirm,
      arguments: {
        'serviceId': widget.serviceId,
        'service': widget.service,
        'staffId': widget.staffId,
        'staffName': widget.staffName,
        'datetime': _selectedTimeSlot!,
      },
    );
  }
}

