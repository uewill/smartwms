import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/routes/app_routes.dart';
import 'package:clothing_erp/widgets/common/loading_widget.dart';
import 'package:clothing_erp/widgets/common/empty_widget.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品列表'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索款号/商品名',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setKeyword('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (value) {
                productProvider.setKeyword(value);
              },
            ),
          ),
          Expanded(
            child: productProvider.isLoading && productProvider.products.isEmpty
                ? const LoadingWidget()
                : productProvider.products.isEmpty
                    ? EmptyWidget(
                        message: '暂无商品',
                        onAction: () {
                          Navigator.pushNamed(context, AppRoutes.productForm);
                        },
                        actionLabel: '添加商品',
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            productProvider.loadProducts(refresh: true),
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: productProvider.products.length + 1,
                          itemBuilder: (context, index) {
                            if (index == productProvider.products.length) {
                              return productProvider.hasMore
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox();
                            }

                            final product = productProvider.products[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.productForm,
                                    arguments: product,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        color: Colors.grey.shade100,
                                        child: product.thumbUrl != null &&
                                                product.thumbUrl!.isNotEmpty
                                            ? Image.network(
                                                product.thumbUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                  Icons.checkroom,
                                                  size: 40,
                                                  color: AppTheme
                                                      .textHintColor,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.checkroom,
                                                size: 40,
                                                color:
                                                    AppTheme.textHintColor,
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.styleNo ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product.name ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme
                                                    .textSecondaryColor,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                if (product.colors != null)
                                                  Text(
                                                    '${product.colors!.length}色',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme
                                                            .textHintColor),
                                                  ),
                                                if (product.sizes != null)
                                                  ...[
                                                    const Text(' · ',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: AppTheme
                                                                .textHintColor)),
                                                    Text(
                                                      '${product.sizes!.length}码',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: AppTheme
                                                              .textHintColor),
                                                    ),
                                                  ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.productForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
