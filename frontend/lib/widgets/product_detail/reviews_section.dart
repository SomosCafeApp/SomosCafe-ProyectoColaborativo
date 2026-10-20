import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/reviews_provider.dart';

import 'review_form.dart';
import 'review_item_card.dart';

class ReviewsSection extends StatefulWidget {
  final String productId;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;

  const ReviewsSection({
    super.key,
    required this.productId,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ReviewsProvider>().fetchProductReviews(
        widget.productId,
      );
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _updateProductRating({
    required ReviewsProvider reviewsProvider,
  }) async {
    if (!mounted) return;

    context.read<ProductProvider>().updateProductRating(
      widget.productId,
      rating: reviewsProvider.averageRating,
      reviewCount: reviewsProvider.totalReviews,
    );
  }

  Future<bool> _handleSubmit({
    required ReviewsProvider reviewsProvider,
    required dynamic myReview,
    required int rating,
    required String comment,
  }) async {
    final success = myReview != null
        ? await reviewsProvider.updateMyReview(
            reviewId: myReview.id,
            rating: rating,
            comment: comment,
          )
        : await reviewsProvider.submitReview(
            productId: widget.productId,
            rating: rating,
            comment: comment,
          );

    if (!mounted) return success;

    if (success) {
      setState(() {
        _showForm = false;
      });

      await _updateProductRating(
        reviewsProvider: reviewsProvider,
      );
    }

    return success;
  }

  Future<void> _handleDelete({
    required ReviewsProvider reviewsProvider,
    required dynamic myReview,
  }) async {
    final success = await reviewsProvider.deleteMyReview(
      myReview.id,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _showForm = false;
      });

      await _updateProductRating(
        reviewsProvider: reviewsProvider,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final reviewsProvider = context.watch<ReviewsProvider>();
    final authProvider = context.watch<AuthProvider>();

    final isLoggedIn = authProvider.isLoggedIn;
    final myReview = reviewsProvider.myReview;

    final outerBg = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final innerCardBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final outlineColor = isDark
        ? AppColors.darkSurfaceSubtle
        : const Color(0xFFE5DDD5);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // ENCABEZADO
          // ----------------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reseñas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) {
                            final isSelected =
                                index <
                                reviewsProvider.averageRating.round();

                            return Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFFFC107),
                              size: 16,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${reviewsProvider.averageRating.toStringAsFixed(1)} '
                        '(${reviewsProvider.totalReviews})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ------------------------------------------------------
              // BOTÓN DE RESEÑA
              // ------------------------------------------------------

              if (isLoggedIn && !_showForm)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                    });
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                  ),
                  label: Text(
                    myReview != null
                        ? 'Editar reseña'
                        : 'Escribir reseña',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.textColor,
                    side: BorderSide(
                      color: outlineColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (isLoggedIn && _showForm)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = false;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 14,
                  ),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.textColor,
                    side: BorderSide(
                      color: outlineColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------------------
          // FORMULARIO
          // ----------------------------------------------------------

          if (_showForm) ...[
            ReviewForm(
              initialRating: myReview?.rating ?? 0,
              initialComment: myReview?.comment ?? '',
              isSubmitting: reviewsProvider.isSubmitting,
              submitLabel: myReview != null
                  ? 'Guardar Cambios'
                  : 'Publicar Reseña',
              onSubmit: (
                rating,
                comment,
              ) {
                return _handleSubmit(
                  reviewsProvider: reviewsProvider,
                  myReview: myReview,
                  rating: rating,
                  comment: comment,
                );
              },
            ),

            // --------------------------------------------------------
            // ELIMINAR RESEÑA
            // --------------------------------------------------------

            if (myReview != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: reviewsProvider.isSubmitting
                      ? null
                      : () => _handleDelete(
                          reviewsProvider: reviewsProvider,
                          myReview: myReview,
                        ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Eliminar mi reseña',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ]

          // ----------------------------------------------------------
          // CARGANDO
          // ----------------------------------------------------------

          else if (reviewsProvider.isLoading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ]

          // ----------------------------------------------------------
          // SIN RESEÑAS
          // ----------------------------------------------------------

          else if (reviewsProvider.reviews.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Este producto todavía no tiene reseñas.',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.mutedColor,
                ),
              ),
            ),
          ]

          // ----------------------------------------------------------
          // LISTA DE RESEÑAS
          // ----------------------------------------------------------

          else ...[
            Column(
              children: reviewsProvider.reviews.map(
                (review) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ReviewItemCard(
                      name: review.userName,
                      profileImage: review.userProfileImage,
                      comment: review.comment,
                      date: _formatDate(
                        review.createdAt,
                      ),
                      stars: review.rating,
                      cardBg: innerCardBg,
                      textColor: widget.textColor,
                      mutedColor: widget.mutedColor,
                    ),
                  );
                },
              ).toList(),
            ),
          ],

          // ----------------------------------------------------------
          // ERROR
          // ----------------------------------------------------------

          if (reviewsProvider.errorMessage != null &&
              !_showForm)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                reviewsProvider.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),

          // ----------------------------------------------------------
          // USUARIO NO AUTENTICADO
          // ----------------------------------------------------------

          if (!isLoggedIn) ...[
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para dejar tu reseña.',
              style: TextStyle(
                fontSize: 12,
                color: widget.mutedColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}