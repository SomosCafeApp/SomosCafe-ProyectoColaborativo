import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/image_picking.dart';
import '../../providers/auth_provider.dart';
import '../common/styled_confirm_dialog.dart';
import '../common/user_avatar.dart';

/// Foto de perfil dentro de "Datos personales": muestra la foto actual
/// (o las iniciales) y permite cambiarla o eliminarla. Se guarda al
/// instante, sin necesidad de pulsar "Guardar cambios".
class ProfilePhotoEditor extends StatelessWidget {
  const ProfilePhotoEditor({super.key});

  static const _danger = Color(0xFFE53935);

  Future<void> _change(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // La foto se muestra pequeña: no hace falta subirla en alta resolución.
    final image = await pickGalleryImage(context, maxSide: 800);
    if (image == null) return;

    final ok = await auth.updateProfileImage(image);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Foto de perfil actualizada'
          : auth.errorMessage ?? 'No se pudo actualizar la foto'),
    ));
  }

  Future<void> _remove(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showStyledConfirmDialog(
      context,
      icon: Icons.no_photography_outlined,
      title: 'Eliminar foto',
      message: 'Se quitará tu foto de perfil y volverán a verse tus iniciales.',
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;

    final ok = await auth.removeProfileImage();
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Foto de perfil eliminada'
          : auth.errorMessage ?? 'No se pudo eliminar la foto'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final busy = auth.isUpdatingPhoto;
    final hasPhoto = (user?.profileImage ?? '').isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: busy ? null : () => _change(context),
          child: Stack(
            children: [
              UserAvatar(
                imageUrl: user?.profileImage ?? '',
                initials: UserAvatar.initialsFor(user?.name ?? '', user?.lastName ?? ''),
                size: 104,
                fontSize: 34,
                border: Border.all(color: AppColors.primary.withAlpha(90), width: 3),
              ),
              if (busy)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(110),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: busy ? null : () => _change(context),
              child: Text(
                hasPhoto ? 'Cambiar foto' : 'Subir foto',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            if (hasPhoto)
              TextButton.icon(
                onPressed: busy ? null : () => _remove(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: _danger),
                label: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: _danger, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
