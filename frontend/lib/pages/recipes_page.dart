import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/animations.dart';
import '../core/constants/app_colors.dart';
import '../models/drink_recipe.dart';
import '../providers/product_provider.dart';
import '../providers/recipes_provider.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/drink_studio/studio_dialogs.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/recipes/recipe_card.dart';
import 'drink_studio_page.dart';

/// Perfil → Mis recetas: bebidas recientes (se registran solas al
/// pedirlas desde el estudio) y recetas guardadas a propósito.
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RecipesProvider>().fetchRecipes());
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), backgroundColor: AppColors.primary));
  }

  void _prepare(DrinkRecipe recipe) {
    final products = context.read<ProductProvider>().products;
    final matches = products.where((p) => p.id == recipe.productId);
    if (matches.isEmpty) {
      _snack('Esta bebida ya no está en el menú');
      return;
    }
    DrinkStudioPage.open(context, matches.first, recipe: recipe);
  }

  Future<void> _toggleSaved(DrinkRecipe recipe) async {
    final error = await context.read<RecipesProvider>().setSaved(recipe, !recipe.isSaved);
    if (!mounted) return;
    _snack(error ?? (recipe.isSaved ? 'Receta quitada de guardadas' : 'Receta guardada'));
  }

  Future<void> _rename(DrinkRecipe recipe) async {
    final name = await showRecipeNameDialog(context, initial: recipe.name);
    if (name == null || !mounted) return;
    final error = await context.read<RecipesProvider>().rename(recipe, name);
    if (error != null && mounted) _snack(error);
  }

  Future<void> _delete(DrinkRecipe recipe) async {
    final ok = await showStyledConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: '¿Eliminar receta?',
      message: 'Se quitará "${recipe.title}" de tus recetas.',
      confirmLabel: 'Eliminar',
    );
    if (!ok || !mounted) return;
    final error = await context.read<RecipesProvider>().delete(recipe);
    if (error != null && mounted) _snack(error);
  }

  Widget _list(RecipesProvider recipes, List<DrinkRecipe> items, String empty) {
    if (recipes.isLoading && items.isEmpty) return const Center(child: CoffeeCupLoader());
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.local_cafe_outlined, size: 56, color: AppColors.primary),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(recipes.errorMessage ?? empty, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: recipes.fetchRecipes,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          return RecipeCard(
            recipe: r,
            onPrepare: () => _prepare(r),
            onToggleSaved: () => _toggleSaved(r),
            onDelete: () => _delete(r),
            onRename: r.isSaved ? () => _rename(r) : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipesProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const ProfileSubPageHeader(title: 'Mis recetas', subtitle: 'Tus bebidas del estudio'),
            const TabBar(
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: [Tab(text: 'Recientes'), Tab(text: 'Guardadas')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _list(recipes, recipes.recent, 'Aún no has pedido bebidas desde el estudio. Prepara una y aparecerá aquí.'),
                  _list(recipes, recipes.saved, 'Guarda tus recetas favoritas con el ícono de marcador al preparar tu bebida.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
