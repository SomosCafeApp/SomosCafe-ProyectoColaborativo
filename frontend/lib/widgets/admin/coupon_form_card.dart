import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';
import '../../models/promotion.dart';
import 'admin_form_style.dart';

/// Datos que devuelve el formulario ya validados.
class CouponFormData {
  final String kind;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;
  final double? maximumDiscount;
  final double minimumPurchase;
  final int pointsCost;
  final int? redeemLimit;
  final int? validDays;

  const CouponFormData({
    required this.kind,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maximumDiscount,
    required this.minimumPurchase,
    required this.pointsCost,
    required this.redeemLimit,
    required this.validDays,
  });
}

/// Formulario inline para crear o editar un cupón de recompensas
/// (mismo patrón que el de promociones). Si [initial] no es null, edita.
class CouponFormCard extends StatefulWidget {
  final Coupon? initial;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<CouponFormData> onSubmit;

  const CouponFormCard({
    super.key,
    this.initial,
    required this.isSubmitting,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<CouponFormCard> createState() => _CouponFormCardState();
}

class _CouponFormCardState extends State<CouponFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _value;
  late final TextEditingController _max;
  late final TextEditingController _minPurchase;
  late final TextEditingController _points;
  late final TextEditingController _limit;
  late final TextEditingController _days;

  late PromotionDiscountType _type;
  late String _kind;

  bool get _isEditing => widget.initial != null;

  /// Los de regalo (bienvenida / cumpleaños) no cuestan puntos ni tienen límite.
  bool get _isGift => _kind != 'REWARD';

  String _num(num? v) => v == null ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _value = TextEditingController(text: _num(c?.discountValue));
    _max = TextEditingController(text: _num(c?.maximumDiscount));
    _minPurchase = TextEditingController(text: c == null || c.minimumPurchase == 0 ? '' : _num(c.minimumPurchase));
    _points = TextEditingController(text: c == null ? '' : '${c.pointsCost}');
    _limit = TextEditingController(text: c?.redeemLimit == null ? '' : '${c!.redeemLimit}');
    _days = TextEditingController(text: c?.validDays == null ? '' : '${c!.validDays}');
    _type = c?.discountType ?? PromotionDiscountType.percentage;
    _kind = c?.kind ?? 'REWARD';
  }

  @override
  void dispose() {
    for (final controller in [_name, _description, _value, _max, _minPurchase, _points, _limit, _days]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _doubleOrNull(String text) => text.trim().isEmpty ? null : double.parse(text.replaceAll(',', '.').trim());

  int? _intOrNull(String text) => text.trim().isEmpty ? null : int.parse(text.trim());

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(CouponFormData(
      kind: _kind,
      name: _name.text.trim(),
      description: _description.text.trim(),
      discountType: _type,
      discountValue: double.parse(_value.text.replaceAll(',', '.').trim()),
      maximumDiscount: _type == PromotionDiscountType.percentage ? _doubleOrNull(_max.text) : null,
      minimumPurchase: _doubleOrNull(_minPurchase.text) ?? 0,
      pointsCost: _isGift ? 0 : int.parse(_points.text.trim()),
      redeemLimit: _isGift ? null : _intOrNull(_limit.text),
      validDays: _intOrNull(_days.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final style = AdminFormStyle.of(context);
    final isPercentage = _type == PromotionDiscountType.percentage;

    final digitsOnly = [FilteringTextInputFormatter.digitsOnly];
    final decimals = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    String? positiveInt(String? v, {String? message}) {
      final value = int.tryParse((v ?? '').trim());
      return (value == null || value < 1) ? (message ?? 'Ingresa un número mayor a 0') : null;
    }

    String? optionalPositiveInt(String? v) => (v ?? '').trim().isEmpty ? null : positiveInt(v);

    TextStyle input() => TextStyle(color: style.textColor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: style.cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminFormHeader(
              title: _isEditing ? 'Editar cupón' : 'Nuevo cupón',
              onClose: widget.isSubmitting ? null : widget.onClose,
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Tipo de cupón'),
            Wrap(
              spacing: 8,
              children: [
                for (final option in const [
                  ('REWARD', 'Canjeable'),
                  ('WELCOME', 'Bienvenida'),
                  ('BIRTHDAY', 'Cumpleaños'),
                ])
                  ChoiceChip(
                    label: Text(option.$2),
                    selected: _kind == option.$1,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _kind == option.$1 ? Colors.white : style.textColor,
                    ),
                    // El tipo no se cambia después de crear el cupón.
                    onSelected: _isEditing ? null : (_) => setState(() => _kind = option.$1),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(
                switch (_kind) {
                  'WELCOME' => 'Se regala automáticamente a cada cliente nuevo al verificar su cuenta. Solo puede haber uno habilitado.',
                  'BIRTHDAY' => 'Se regala el día del cumpleaños de cada cliente (una vez al año). Solo puede haber uno habilitado.',
                  _ => 'Los clientes lo canjean con puntos desde Recompensas.',
                },
                style: TextStyle(fontSize: 11, color: style.subtitleColor),
              ),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Nombre'),
            TextFormField(
              controller: _name,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              style: input(),
              decoration: style.decoration('Ej: 30% en tu próxima compra').copyWith(counterText: ''),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Descripción (opcional)'),
            TextFormField(
              controller: _description,
              maxLines: 2,
              maxLength: 140,
              style: input(),
              decoration: style.decoration('Se muestra en la tarjeta del cupón'),
            ),
            const SizedBox(height: 8),
            const AdminFieldLabel('Tipo de descuento'),
            Row(
              children: [
                for (final type in PromotionDiscountType.values) ...[
                  Expanded(
                    child: ChoiceChip(
                      label: SizedBox(width: double.infinity, child: Text(type.label, textAlign: TextAlign.center)),
                      selected: _type == type,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _type == type ? Colors.white : style.textColor,
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                  ),
                  if (type == PromotionDiscountType.percentage) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AdminFieldLabel(isPercentage ? 'Porcentaje de descuento' : 'Valor del descuento'),
            TextFormField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimals,
              style: input(),
              decoration: isPercentage ? style.decoration('Ej: 30', suffix: '%') : style.decoration('Ej: 5000', prefix: '\$ '),
              validator: (v) {
                final value = double.tryParse((v ?? '').replaceAll(',', '.').trim());
                if (value == null || value <= 0) return 'Ingresa un valor mayor a 0';
                if (isPercentage && value > 100) return 'No puede superar 100%';
                return null;
              },
            ),
            if (isPercentage) ...[
              const SizedBox(height: 16),
              const AdminFieldLabel('Tope del descuento (opcional)'),
              TextFormField(
                controller: _max,
                keyboardType: TextInputType.number,
                inputFormatters: digitsOnly,
                style: input(),
                decoration: style.decoration('Ej: 10000', prefix: '\$ '),
              ),
            ],
            const SizedBox(height: 16),
            const AdminFieldLabel('Compra mínima (opcional)'),
            TextFormField(
              controller: _minPurchase,
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              style: input(),
              decoration: style.decoration('Ej: 20000', prefix: '\$ '),
            ),
            if (!_isGift) ...[
            const SizedBox(height: 16),
            const AdminFieldLabel('Puntos para canjearlo'),
            TextFormField(
              controller: _points,
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              style: input(),
              decoration: style.decoration('Ej: 200', suffix: 'puntos'),
              validator: (v) => positiveInt(v),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Límite de canjes (opcional)'),
            TextFormField(
              controller: _limit,
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              style: input(),
              decoration: style.decoration('Vacío = sin límite', suffix: 'cupones'),
              validator: optionalPositiveInt,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: Text(
                'Cada persona solo puede canjearlo una vez (hasta que reactives el cupón).',
                style: TextStyle(fontSize: 11, color: style.subtitleColor),
              ),
            ),
            ],
            const SizedBox(height: 16),
            AdminFieldLabel(_isGift ? 'Días para usarlo desde que se entrega (opcional)' : 'Días para usarlo tras canjearlo (opcional)'),
            TextFormField(
              controller: _days,
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              style: input(),
              decoration: style.decoration('Vacío = no vence', suffix: 'días'),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                final value = int.tryParse(v!.trim());
                return (value == null || value < 1 || value > 365) ? 'Entre 1 y 365 días' : null;
              },
            ),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 14, left: 4),
                child: Text(
                  'Los cambios no afectan a los cupones que los clientes ya canjearon.',
                  style: TextStyle(fontSize: 11, color: style.subtitleColor),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: widget.isSubmitting ? null : _submit,
                child: widget.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isEditing ? 'Guardar cambios' : 'Crear cupón',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
