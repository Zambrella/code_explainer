import 'package:code_explainer/annotation.dart';
import 'package:flutter/material.dart';

class AnnotationListItem extends StatelessWidget {
  const AnnotationListItem({
    super.key,
    required this.annotation,
    required this.onDelete,
  });

  final Annotation annotation;
  final void Function(Annotation) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => onDelete(annotation),
      ),
      title: Text(
        annotation.text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
