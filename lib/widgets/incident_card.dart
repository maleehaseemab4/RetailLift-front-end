import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoplifting_app/models/incident.dart';

class IncidentCard extends StatefulWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: _isHovered ? 6 : 0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            onTap: widget.onTap,
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: _isHovered
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
                image: DecorationImage(
                  image: NetworkImage(widget.incident.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: _isHovered ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            title: Text(
              widget.incident.cameraName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isHovered
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'MMM dd, hh:mm a',
                  ).format(widget.incident.timestamp),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.incident.prediction != null)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.incident.prediction?.toLowerCase() ==
                                  'shoplifting'
                              ? Colors.red
                              : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.incident.prediction!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (widget.incident.confidence != null)
                      Text(
                        '${(widget.incident.confidence! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    if (!widget.incident.isReviewed)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Unreviewed',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: _isHovered ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
