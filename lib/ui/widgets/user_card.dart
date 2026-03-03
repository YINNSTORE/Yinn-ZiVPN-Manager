import "package:flutter/material.dart";
import "../../data/models.dart";
import "status_chip.dart";

class UserCard extends StatelessWidget {
  final UserData user;
  final VoidCallback onRenew;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onRenew,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.password,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              StatusChip(text: user.status),
            ],
          ),
          const SizedBox(height: 8),
          Text("Expired: ${user.expired}"),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(onPressed: onRenew, icon: const Icon(Icons.update), label: const Text("Renew")),
              const SizedBox(width: 10),
              OutlinedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline), label: const Text("Delete")),
            ],
          ),
        ],
      ),
    );
  }
}