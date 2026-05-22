import 'package:flutter/material.dart';

class UiChung {
  static const Color mauChinh = Color(0xFF9A5A16);
  static const Color mauNen = Color(0xFFFFFAF4);
  static const Color mauPhu = Color(0xFFFFE0B2);

  static Widget loading({String text = 'Đang tải dữ liệu...'}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: mauChinh),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget trong(
    String message, {
    IconData icon = Icons.inbox_outlined,
    String? moTa,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 78, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (moTa != null && moTa.trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                moTa,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget loi(
    Object? error, {
    String title = 'Đã xảy ra lỗi',
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 78, color: Colors.red.shade300),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Không xác định lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauChinh,
                  foregroundColor: Colors.white,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget tieuDeMuc(
    String title, {
    IconData icon = Icons.circle,
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 14, 16, 8),
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(icon, color: mauChinh),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Widget card({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.all(12),
    EdgeInsets padding = const EdgeInsets.all(14),
    double radius = 16,
    double elevation = 2,
  }) {
    return Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  static Widget nutChinh({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    Color color = mauChinh,
  }) {
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : icon == null
        ? Text(text, style: const TextStyle(fontWeight: FontWeight.bold))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: child,
      ),
    );
  }

  static Widget nutPhu({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color color = mauChinh,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.circle, size: icon == null ? 0 : 20),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  static Widget anhMang(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final image = url.trim().isEmpty
        ? Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          )
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  static Widget dongThongTin(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: mauChinh),
            const SizedBox(width: 7),
          ],
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.trim().isEmpty ? 'Chưa có' : value)),
        ],
      ),
    );
  }

  static void thongBaoThanhCong(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  static void thongBaoLoi(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static void thongBao(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
