import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/models/product.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/utils/constants.dart';
import 'package:clothing_erp/widgets/product/sku_matrix_widget.dart';

class ProductFormPage extends StatefulWidget {
  final dynamic product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _styleNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _retailPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  String _selectedSeason = 'all';
  final List<String> _selectedColors = [];
  final List<String> _selectedSizes = [];
  final List<ProductSku> _skus = [];
  final List<String> _customColors = [];
  final List<String> _customSizes = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _isEditing = true;
      _loadProductData(widget.product as Product);
    }
  }

  void _loadProductData(Product product) {
    _styleNoController.text = product.styleNo ?? '';
    _nameController.text = product.name ?? '';
    _brandController.text = product.brand ?? '';
    _selectedSeason = product.season ?? 'all';
    _selectedColors.addAll(product.colors ?? []);
    _selectedSizes.addAll(product.sizes ?? []);
    _skus.addAll(product.skus ?? []);

    if (_skus.isNotEmpty) {
      _retailPriceController.text =
          _skus.first.retailPrice?.toStringAsFixed(2) ?? '';
      _wholesalePriceController.text =
          _skus.first.wholesalePrice?.toStringAsFixed(2) ?? '';
      _purchasePriceController.text =
          _skus.first.purchasePrice?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _styleNoController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _retailPriceController.dispose();
    _wholesalePriceController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  void _generateSkus() {
    _skus.clear();
    for (final color in _selectedColors) {
      for (final size in _selectedSizes) {
        final existingSku = widget.product?.skus?.where(
          (s) => s.colorName == color && s.sizeName == size,
        ).firstOrNull;

        _skus.add(ProductSku(
          id: existingSku?.id,
          colorName: color,
          sizeName: size,
          barcode: existingSku?.barcode ?? '${_styleNoController.text}-$color-$size',
          retailPrice: double.tryParse(_retailPriceController.text) ??
              existingSku?.retailPrice ??
              0,
          wholesalePrice: double.tryParse(_wholesalePriceController.text) ??
              existingSku?.wholesalePrice ??
              0,
          purchasePrice: double.tryParse(_purchasePriceController.text) ??
              existingSku?.purchasePrice ??
              0,
          stockQty: existingSku?.stockQty ?? 0,
        ));
      }
    }
    setState(() {});
  }

  void _applyBatchPrice() {
    final retail = double.tryParse(_retailPriceController.text);
    final wholesale = double.tryParse(_wholesalePriceController.text);
    final purchase = double.tryParse(_purchasePriceController.text);

    setState(() {
      for (int i = 0; i < _skus.length; i++) {
        _skus[i] = _skus[i].copyWith(
          retailPrice: retail ?? _skus[i].retailPrice,
          wholesalePrice: wholesale ?? _skus[i].wholesalePrice,
          purchasePrice: purchase ?? _skus[i].purchasePrice,
        );
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个颜色')),
      );
      return;
    }
    if (_selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个尺码')),
      );
      return;
    }

    if (_skus.isEmpty) {
      _generateSkus();
    }

    final productData = {
      'styleNo': _styleNoController.text.trim(),
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'season': _selectedSeason,
      'colors': _selectedColors,
      'sizes': _selectedSizes,
      'skus': _skus.map((e) => e.toJson()).toList(),
    };

    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.createProduct(productData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.error ?? '保存失败'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑商品' : '新建商品'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _styleNoController,
              decoration: const InputDecoration(
                labelText: '款号',
                hintText: '请输入款号',
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '请输入款号' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '商品名称',
                hintText: '请输入商品名称',
                prefixIcon: Icon(Icons.checkroom),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '请输入商品名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: '品牌',
                hintText: '请输入品牌（选填）',
                prefixIcon: Icon(Icons.branding_watermark),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeason,
              decoration: const InputDecoration(
                labelText: '季节',
                prefixIcon: Icon(Icons.wb_sunny),
              ),
              items: Season.values
                  .map((s) => DropdownMenuItem(
                        value: s.value,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeason = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildSizeSelector(),
            const SizedBox(height: 24),
            _buildBatchPriceSection(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generateSkus,
              icon: const Icon(Icons.grid_on),
              label: const Text('生成SKU矩阵'),
            ),
            const SizedBox(height: 16),
            if (_skus.isNotEmpty) ...[
              const Text(
                'SKU矩阵预览',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SkuMatrixWidget(
                    colors: _selectedColors,
                    sizes: _selectedSizes,
                    skus: _skus,
                    editable: true,
                    onPriceChanged: (sku) {
                      final index = _skus.indexWhere(
                        (s) =>
                            s.colorName == sku.colorName &&
                            s.sizeName == sku.sizeName,
                      );
                      if (index >= 0) {
                        setState(() {
                          _skus[index] = sku;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('保存商品'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '颜色',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: _showAddColorDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('自定义'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...ColorPresets.commonColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
              );
            }),
            ..._customColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '尺码',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: _showAddSizeDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('自定义'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...SizePresets.allPresets.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          final allSelected = entry.value
                              .every((s) => _selectedSizes.contains(s));
                          if (allSelected) {
                            _selectedSizes
                                .removeWhere((s) => entry.value.contains(s));
                          } else {
                            for (final size in entry.value) {
                              if (!_selectedSizes.contains(size)) {
                                _selectedSizes.add(size);
                              }
                            }
                          }
                        });
                      },
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.value.map((size) {
                        final isSelected = _selectedSizes.contains(size);
                        return FilterChip(
                          label: Text(size, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSizes.add(size);
                              } else {
                                _selectedSizes.remove(size);
                              }
                            });
                          },
                          selectedColor:
                              AppTheme.accentColor.withOpacity(0.15),
                          checkmarkColor: AppTheme.accentColor,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          );
        }),
        if (_customSizes.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _customSizes.map((size) {
              final isSelected = _selectedSizes.contains(size);
              return FilterChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSizes.add(size);
                    } else {
                      _selectedSizes.remove(size);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBatchPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '批量填价',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: _applyBatchPrice,
              child: const Text('应用到所有SKU'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _retailPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '零售价',
                  prefixText: '¥',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _wholesalePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '批发价',
                  prefixText: '¥',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _purchasePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '进货价',
                  prefixText: '¥',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddColorDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加自定义颜色'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '例如：雾霾蓝'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final color = controller.text.trim();
              if (color.isNotEmpty && !_customColors.contains(color)) {
                setState(() {
                  _customColors.add(color);
                  _selectedColors.add(color);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddSizeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加自定义尺码'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '例如：3XL'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final size = controller.text.trim();
              if (size.isNotEmpty && !_customSizes.contains(size)) {
                setState(() {
                  _customSizes.add(size);
                  _selectedSizes.add(size);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
