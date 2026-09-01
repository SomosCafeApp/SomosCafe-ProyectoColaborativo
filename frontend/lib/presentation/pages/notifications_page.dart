import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // --- Canales de Notificación ---
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _soundNotifications = true;

  // --- Preferencias Adicionales (Horario) ---
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  final List<NotificationItem> _recentActivity = [
    NotificationItem(
      id: '1',
      title: 'Pedido en Camino',
      subtitle: 'Tu pedido #1234 llegará en 15 minutos',
      time: 'Hace 5 min',
      icon: Icons.inventory_2_outlined,
      iconBgColor: const Color(0xFFF4EFEA),
      iconColor: const Color(0xFF8C6239),
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      title: '30% de Descuento',
      subtitle: '¡Oferta especial en todos los Frappés!',
      time: 'Hace 1 hora',
      icon: Icons.card_giftcard,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
      isUnread: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Nuevo Premio Desbloqueado',
      subtitle: 'Has ganado 100 puntos. ¡Canjéalos ahora!',
      time: 'Hace 2 horas',
      icon: Icons.military_tech_outlined,
      iconBgColor: const Color(0xFFFFF8E1),
      iconColor: const Color(0xFFF57F17),
    ),
    NotificationItem(
      id: '4',
      title: 'Pedido Entregado',
      subtitle: 'Tu pedido #1233 fue entregado exitosamente',
      time: 'Hace 1 día',
      icon: Icons.inventory_2_outlined,
      iconBgColor: const Color(0xFFF4EFEA),
      iconColor: const Color(0xFF8C6239),
    ),
  ];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8C6239),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'a.m.' : 'p.m.';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);
    final mutedColor = textColor.withOpacity(0.4);
    final unreadDotColor = headerColor;
    final unreadBadgeBg = isDark ? const Color(0xFF3D2E26) : const Color(0xFFEFEBE4);
    final unreadBadgeText = isDark ? const Color(0xFFD7B89A) : const Color(0xFF6D4C41);
    final unreadBorderColor = isDark ? const Color(0xFF6D4C41) : const Color(0xFFD7CCC8);
    final infoCardBg = isDark ? const Color(0xFF17324A).withOpacity(0.5) : const Color(0xFFE1F5FE).withOpacity(0.6);
    final infoIconBg = isDark ? const Color(0xFF1E4A6B) : const Color(0xFFBBDEFB);
    final timeBoxBorder = isDark ? Colors.white24 : Colors.grey.shade300;

    int unreadCount = _recentActivity.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // --- HEADER SUPERIOR CON REGRESO Y TÍTULO ---
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            width: double.infinity,
            color: headerColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gestiona tus preferencias de alertas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- CONTENIDO SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de Actividad Reciente + Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actividad Reciente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: unreadBadgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount nuevas',
                            style: TextStyle(
                              fontSize: 12,
                              color: unreadBadgeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de Notificaciones
                  ..._recentActivity.map((item) => _buildNotificationCard(item, unreadDotColor, cardColor, textColor, subtitleColor, mutedColor, unreadBorderColor)),

                  const SizedBox(height: 12),

                  // Tarjeta informativa "Mantente Informado"
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: infoCardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: infoIconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_none, color: Color(0xFF1976D2)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mantente Informado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configura cómo quieres recibir actualizaciones sobre tus pedidos, ofertas especiales y más.',
                                style: TextStyle(fontSize: 12, color: subtitleColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN CANALES DE NOTIFICACIÓN ---
                  Text(
                    'Canales de Notificación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildChannelTile(
                    title: 'Notificaciones Push',
                    subtitle: 'Recibe alertas en tu dispositivo',
                    icon: Icons.smartphone_outlined,
                    iconBg: isDark ? const Color(0xFF3D2E26) : const Color(0xFFF5F2EC),
                    iconColor: const Color(0xFF8C6239),
                    value: _pushNotifications,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildChannelTile(
                    title: 'Correo Electrónico',
                    subtitle: 'Recibe ofertas y actualizaciones por email',
                    icon: Icons.email_outlined,
                    iconBg: isDark ? const Color(0xFF17324A) : const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                    value: _emailNotifications,
                    onChanged: (val) => setState(() => _emailNotifications = val),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildChannelTile(
                    title: 'SMS',
                    subtitle: 'Recibe confirmaciones por mensaje de texto',
                    icon: Icons.chat_bubble_outline_rounded,
                    iconBg: isDark ? const Color(0xFF3A1F1F) : const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFE53935),
                    value: _smsNotifications,
                    onChanged: (val) => setState(() => _smsNotifications = val),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildChannelTile(
                    title: 'Sonidos',
                    subtitle: 'Reproducir sonidos para notificaciones',
                    icon: Icons.volume_up_outlined,
                    iconBg: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFFFA000),
                    value: _soundNotifications,
                    onChanged: (val) => setState(() => _soundNotifications = val),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN PREFERENCIAS ADICIONALES ---
                  Text(
                    'Preferencias Adicionales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horario de Notificaciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recibe notificaciones solo en este horario',
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePickerBox(
                                label: 'Desde',
                                timeText: _formatTimeOfDay(_startTime),
                                onTap: () => _selectTime(context, true),
                                cardColor: cardColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                borderColor: timeBoxBorder,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePickerBox(
                                label: 'Hasta',
                                timeText: _formatTimeOfDay(_endTime),
                                onTap: () => _selectTime(context, false),
                                cardColor: cardColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                borderColor: timeBoxBorder,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta individual de Notificación
  Widget _buildNotificationCard(NotificationItem item, Color unreadDotColor, Color cardColor, Color textColor, Color subtitleColor, Color mutedColor, Color unreadBorderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: item.isUnread
            ? Border.all(color: unreadBorderColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: unreadDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los Canales de Notificación
  Widget _buildChannelTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF8C6239),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Widget selector de horas (Desde / Hasta)
  Widget _buildTimePickerBox({
    required String label,
    required String timeText,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}