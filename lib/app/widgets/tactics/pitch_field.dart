import 'package:flutter/material.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';

class PlacedPlayer {
  const PlacedPlayer({required this.slot, required this.player});

  final AssignedSlot slot;
  final Player? player;
}

/// Przypisuje graczy z listy [lineupPlayerIds] (kolejność = priorytet) do slotów
/// formacji. Dopasowanie: najpierw dokładna [Position], potem [PositionGroup],
/// w kolejności występowania graczy na liście. Nie modyfikuje [lineupPlayerIds]
/// — to czysto prezentacyjna funkcja pomocnicza dla [PitchField].
List<PlacedPlayer> placePlayersOnSlots({
  required List<AssignedSlot> slots,
  required List<String> lineupPlayerIds,
  required Map<String, Player> playersById,
}) {
  final pending = [
    for (final id in lineupPlayerIds)
      if (playersById[id] != null) playersById[id]!,
  ];
  final remainingSlots = [...slots];
  final placements = <String, Player>{};

  void takeMatches(bool Function(AssignedSlot slot, Player player) matches) {
    for (var i = pending.length - 1; i >= 0; i--) {
      final player = pending[i];
      final slotIndex = remainingSlots.indexWhere(
        (slot) => matches(slot, player),
      );
      if (slotIndex == -1) continue;
      final slot = remainingSlots.removeAt(slotIndex);
      placements[slot.key] = player;
      pending.removeAt(i);
    }
  }

  takeMatches((slot, player) => slot.position == player.position);
  takeMatches((slot, player) => slot.group == positionGroupOf(player.position));

  for (final player in pending) {
    if (remainingSlots.isEmpty) break;
    final slot = remainingSlots.removeAt(0);
    placements[slot.key] = player;
  }

  return [
    for (final slot in slots)
      PlacedPlayer(slot: slot, player: placements[slot.key]),
  ];
}

class PitchField extends StatelessWidget {
  const PitchField({
    super.key,
    required this.formation,
    required this.lineupPlayerIds,
    required this.playersById,
    required this.selectedId,
    required this.onTap,
    this.onLongPress,
    this.enableDragDrop = false,
    this.onAcceptDrop,
  });

  final Formation formation;
  final List<String> lineupPlayerIds;
  final Map<String, Player> playersById;
  final String? selectedId;
  final void Function(Player player) onTap;
  final void Function(Player player)? onLongPress;

  /// Gdy true, chip gracza jest przeciągalny i akceptuje przeciągnięty id
  /// (`onAcceptDrop`) — caller reużywa `_trySwap` do wykonania zamiany.
  final bool enableDragDrop;
  final void Function(String draggedPlayerId, String targetPlayerId)?
  onAcceptDrop;

  @override
  Widget build(BuildContext context) {
    final layout = FormationLayout.of(formation);
    final placements = placePlayersOnSlots(
      slots: layout.slots,
      lineupPlayerIds: lineupPlayerIds,
      playersById: playersById,
    );

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _PitchMarkingsPainter(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  for (final placement in placements)
                    if (placement.player != null)
                      Positioned(
                        left: placement.slot.x * constraints.maxWidth - 24,
                        top:
                            (1 - placement.slot.y) * constraints.maxHeight - 24,
                        child: _buildChip(context, placement.player!),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, Player player) {
    final chip = _PitchChip(
      player: player,
      selected: player.id == selectedId,
      onTap: () => onTap(player),
      onLongPress: onLongPress == null ? null : () => onLongPress!(player),
    );

    if (!enableDragDrop) return chip;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != player.id,
      onAcceptWithDetails: (details) =>
          onAcceptDrop?.call(details.data, player.id),
      builder: (context, candidateData, rejectedData) {
        final hovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: hovered
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: LongPressDraggable<String>(
            data: player.id,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(opacity: 0.85, child: chip),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: chip),
            child: chip,
          ),
        );
      },
    );
  }
}

class _PitchChip extends StatelessWidget {
  const _PitchChip({
    required this.player,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final Player player;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: selected
                  ? Colors.amber
                  : (player.state.injured ? Colors.red.shade200 : Colors.white),
              child: Text(
                player.position.code,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              player.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.16,
      paint,
    );
    final boxWidth = size.width * 0.5;
    final boxHeight = size.height * 0.12;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 0, boxWidth, boxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - boxHeight,
        boxWidth,
        boxHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
