import 'package:flutter/material.dart';
import '../../../domain/entities/web_link.dart';

/// Form widget for managing web links in tour templates
class TourTemplateForm extends StatefulWidget {
  final List<WebLink> webLinks;
  final ValueChanged<List<WebLink>> onWebLinksChanged;

  const TourTemplateForm({
    super.key,
    required this.webLinks,
    required this.onWebLinksChanged,
  });

  @override
  State<TourTemplateForm> createState() => _TourTemplateFormState();
}

class _TourTemplateFormState extends State<TourTemplateForm> {
  late List<WebLink> _webLinks;

  @override
  void initState() {
    super.initState();
    _webLinks = List.from(widget.webLinks);
  }

  void _addWebLink() {
    setState(() {
      _webLinks.add(const WebLink(
        id: '',
        title: '',
        url: '',
      ));
    });
    widget.onWebLinksChanged(_webLinks);
  }

  void _removeWebLink(int index) {
    setState(() {
      _webLinks.removeAt(index);
    });
    widget.onWebLinksChanged(_webLinks);
  }

  void _updateWebLink(int index, WebLink webLink) {
    setState(() {
      _webLinks[index] = webLink;
    });
    widget.onWebLinksChanged(_webLinks);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Web Links',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: _addWebLink,
              icon: const Icon(Icons.add),
              label: const Text('Add Link'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_webLinks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.link_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'No web links added',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add links to provide additional information about the tour',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...List.generate(_webLinks.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _WebLinkFormItem(
                webLink: _webLinks[index],
                onChanged: (webLink) => _updateWebLink(index, webLink),
                onRemove: () => _removeWebLink(index),
              ),
            );
          }),
      ],
    );
  }
}

class _WebLinkFormItem extends StatefulWidget {
  final WebLink webLink;
  final ValueChanged<WebLink> onChanged;
  final VoidCallback onRemove;

  const _WebLinkFormItem({
    required this.webLink,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_WebLinkFormItem> createState() => _WebLinkFormItemState();
}

class _WebLinkFormItemState extends State<_WebLinkFormItem> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.webLink.title);
    _urlController = TextEditingController(text: widget.webLink.url);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _updateWebLink() {
    final webLink = WebLink(
      id: widget.webLink.id,
      title: _titleController.text.trim(),
      url: _urlController.text.trim(),
    );
    widget.onChanged(webLink);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Web Link',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter link title',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateWebLink(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'Enter web link URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateWebLink(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL is required';
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
