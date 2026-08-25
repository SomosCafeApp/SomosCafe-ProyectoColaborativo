import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool initialIsFavorite;
  final VoidCallback? onTap;

  const FavoriteButton({
    super.key,
    this.initialIsFavorite = false,
    this.onTap,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFavorite = !isFavorite;
        });
        if (widget.onTap != null) widget.onTap!();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? const Color(0xFFE53935) : const Color(0xFF6C757D),
          size: 20,
        ),
      ),
    );
  }
}