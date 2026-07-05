import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../main.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, sync, _) {
        return _buildChip(sync);
      },
    );
  }

  Widget _buildChip(SyncService sync) {
    IconData icon;
    Color color;
    String text;
    bool showSpinner = false;

    switch (sync.status) {
      case SyncStatus.pending:
        icon = Icons.schedule_rounded;
        color = AppColors.warning;
        text = '${sync.pendingCount} معلّق';
        break;
      case SyncStatus.syncing:
        icon = Icons.sync_rounded;
        color = AppColors.info;
        text = 'جاري المزامنة...';
        showSpinner = true;
        break;
      case SyncStatus.error:
        icon = Icons.sync_problem_rounded;
        color = AppColors.danger;
        text = 'خطأ في المزامنة';
        break;
      case SyncStatus.synced:
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.success;
        text = 'متزامن';
        break;
      case SyncStatus.idle:
        icon = Icons.cloud_off_rounded;
        color = AppColors.textSecondary;
        text = 'غير متصل';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncStatusIcon extends StatefulWidget {
  const SyncStatusIcon({super.key});

  @override
  State<SyncStatusIcon> createState() => _SyncStatusIconState();
}

class _SyncStatusIconState extends State<SyncStatusIcon>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  SyncStatus? _previousStatus;

  @override
  void initState() {
    super.initState();

    // Rotation animation for syncing
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Scale animation for success
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Shake animation for error
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleStatusChange(SyncStatus newStatus) {
    // Stop all animations first
    _rotationController.stop();
    _scaleController.stop();
    _shakeController.stop();

    switch (newStatus) {
      case SyncStatus.syncing:
        _rotationController.repeat();
        break;
      case SyncStatus.synced:
        if (_previousStatus == SyncStatus.syncing) {
          _scaleController.forward(from: 0);
        }
        break;
      case SyncStatus.error:
        _shakeController.forward(from: 0);
        break;
      default:
        break;
    }

    _previousStatus = newStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, sync, _) {
        // Handle status changes and trigger animations
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sync.status != _previousStatus) {
            _handleStatusChange(sync.status);
          }
        });

        return GestureDetector(
          onTap: () {
            if (sync.status == SyncStatus.pending || 
                sync.status == SyncStatus.error) {
              sync.syncNow();
            }
          },
          child: _buildIcon(sync),
        );
      },
    );
  }

  Widget _buildIcon(SyncService sync) {
    Color color;
    IconData icon;
    Widget? badge;

    switch (sync.status) {
      case SyncStatus.pending:
        color = AppColors.warning;
        icon = Icons.schedule_rounded;
        if (sync.pendingCount > 0) {
          badge = _buildBadge(sync.pendingCount, color);
        }
        break;
      case SyncStatus.syncing:
        color = AppColors.info;
        icon = Icons.sync_rounded;
        break;
      case SyncStatus.error:
        color = AppColors.danger;
        icon = Icons.sync_problem_rounded;
        break;
      case SyncStatus.synced:
        color = AppColors.success;
        icon = Icons.cloud_done_rounded;
        break;
      case SyncStatus.idle:
        color = AppColors.textSecondary;
        icon = Icons.cloud_off_rounded;
        break;
    }

    Widget iconWidget;

    if (sync.status == SyncStatus.syncing) {
      // Rotating sync icon
      iconWidget = RotationTransition(
        turns: _rotationController,
        child: Icon(icon, size: 24, color: color),
      );
    } else if (sync.status == SyncStatus.synced) {
      // Scale animation for success
      iconWidget = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = 1.0 + (_scaleAnimation.value * 0.3);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Icon(icon, size: 24, color: color),
      );
    } else if (sync.status == SyncStatus.error) {
      // Shake animation for error
      iconWidget = AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = _shakeAnimation.value * 10 * 
                         ((_shakeAnimation.value * 4).floor() % 2 == 0 ? 1 : -1);
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: Icon(icon, size: 24, color: color),
      );
    } else {
      iconWidget = Icon(icon, size: 24, color: color);
    }

    if (badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -4,
            top: -4,
            child: badge,
          ),
        ],
      );
    }

    return iconWidget;
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
