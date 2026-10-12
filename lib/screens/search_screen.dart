import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_catalog.dart';
import '../models/product.dart';
import '../routes.dart';
import '../services/local_search.dart';
import '../services/ml_client.dart';
import '../services/speaker.dart';
import '../widgets/product_image.dart';
import '../widgets/voice_shortcut_button.dart';

/// Search by meaning ("something to keep my hands warm") through the ML
/// service, or by keyword on the device when the service is unavailable.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery);
  List<Product>? _results;
  bool _smart = false;
  bool _busy = false;
  String _searched = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(widget.initialQuery));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final repo = context.read<ProductRepository>();
    final ml = context.read<MlClient>();
    setState(() => _busy = true);
    final ids = await ml.search(q);
    if (!mounted) return;
    final smart = ids != null;
    final results = smart
        ? [for (final id in ids) if (repo.byId(id) case final p?) p]
        : localSearch(q, repo.allProducts);
    setState(() {
      _busy = false;
      _smart = smart;
      _searched = q;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      floatingActionButton: const VoiceShortcutButton(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          TextField(
            key: const Key('searchField'),
            controller: _controller,
            autofocus: widget.initialQuery.isEmpty,
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            decoration: InputDecoration(
              labelText: 'What are you looking for?',
              hintText: 'e.g. "something to keep my hands warm"',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () => _search(_controller.text),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_busy) const LinearProgressIndicator(),
          if (results != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                results.isEmpty
                    ? 'No products found for "$_searched".'
                    : '${results.length} ${results.length == 1 ? 'result' : 'results'} for "$_searched"'
                        '${_smart ? '' : ' (keyword search; smart search is unavailable)'}',
                key: const Key('searchSummary'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            for (final product in results)
              Card(
                child: ListTile(
                  leading: ProductImage(product: product, size: 56),
                  title: Text(product.name),
                  subtitle: Text(formatPrice(product.price)),
                  onTap: () => Navigator.pushNamed(context, Routes.productDetail, arguments: product),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
