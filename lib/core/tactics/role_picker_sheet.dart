import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/player.dart';

Future<void> showRolePickerSheet(
  BuildContext context, {
  required Player player,
  required ValueChanged<AssignedRole> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) =>
        RolePickerSheet(player: player, onSelected: onSelected),
  );
}

class RolePickerSheet extends StatelessWidget {
  const RolePickerSheet({
    super.key,
    required this.player,
    required this.onSelected,
  });

  final Player player;
  final ValueChanged<AssignedRole> onSelected;

  @override
  Widget build(BuildContext context) {
    final roles = rolesForPosition(player.position);
    final currentRole = player.state.role;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(
                player.position.code,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            title: Text(player.name),
            subtitle: Text(player.position.code),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => context.push('/game/player/${player.id}'),
            ),
          ),
          const Divider(height: 1),
          for (final role in roles)
            RadioListTile<AssignedRole>(
              value: role,
              groupValue: currentRole,
              title: Text(roleDisplayInfo(role).label),
              subtitle: Text(roleDisplayInfo(role).description),
              onChanged: (value) {
                if (value == null) return;
                Navigator.of(context).pop();
                onSelected(value);
              },
            ),
        ],
      ),
    );
  }
}
