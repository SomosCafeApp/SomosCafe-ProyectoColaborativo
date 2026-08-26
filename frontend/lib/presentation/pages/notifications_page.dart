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
    const headerColor = Color(0xFF8C6239);
    const backgroundColor = Color(0xFFFAF7F2);
    const unreadDotColor = Color(0xFF8C6239);

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
                      const Text(
                        'Actividad Reciente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEBE4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount nuevas',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6D4C41),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de Notificaciones
                  ..._recentActivity.map((item) => _buildNotificationCard(item, unreadDotColor)),

                  const SizedBox(height: 12),

                  // Tarjeta informativa "Mantente Informado"
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5FE).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBBDEFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_none, color: Color(0xFF1976D2)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mantente Informado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Configura cómo quieres recibir actualizaciones sobre tus pedidos, ofertas especiales y más.',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN CANALES DE NOTIFICACIÓN ---
                  const Text(
                    'Canales de Notificación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildChannelTile(
                    title: 'Notificaciones Push',
                    subtitle: 'Recibe alertas en tu dispositivo',
                    icon: Icons.smartphone_outlined,
                    iconBg: const Color(0xFFF5F2EC),
                    iconColor: const Color(0xFF8C6239),
                    value: _pushNotifications,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                  _buildChannelTile(
                    title: 'Correo Electrónico',
                    subtitle: 'Recibe ofertas y actualizaciones por email',
                    icon: Icons.email_outlined,
                    iconBg: const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                    value: _emailNotifications,
                    onChanged: (val) => setState(() => _emailNotifications = val),
                  ),
                  _buildChannelTile(
                    title: 'SMS',
                    subtitle: 'Recibe confirmaciones por mensaje de texto',
                    icon: Icons.chat_bubble_outline_rounded,
                    iconBg: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFE53935),
                    value: _smsNotifications,
                    onChanged: (val) => setState(() => _smsNotifications = val),
                  ),
                  _buildChannelTile(
                    title: 'Sonidos',
                    subtitle: 'Reproducir sonidos para notificaciones',
                    icon: Icons.volume_up_outlined,
                    iconBg: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFFFA000),
                    value: _soundNotifications,
                    onChanged: (val) => setState(() => _soundNotifications = val),
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN PREFERENCIAS ADICIONALES ---
                  const Text(
                    'Preferencias Adicionales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horario de Notificaciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Recibe notificaciones solo en este horario',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePickerBox(
                                label: 'Desde',
                                timeText: _formatTimeOfDay(_startTime),
                                onTap: () => _selectTime(context, true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePickerBox(
                                label: 'Hasta',
                                timeText: _formatTimeOfDay(_endTime),
                                onTap: () => _selectTime(context, false),
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
  Widget _buildNotificationCard(NotificationItem item, Color unreadDotColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: item.isUnread
            ? Border.all(color: const Color(0xFFD7CCC8), width: 1.5)
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
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
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}