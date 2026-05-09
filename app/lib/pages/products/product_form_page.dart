import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _specController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _warningStockController;
  late TextEditingController _categoryController;
  late TextEditingController _remarkController;
  bool _isLoading = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.product?.code ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _specController = TextEditingController(text: widget.product?.spec ?? '');
    _unitController = TextEditingController(text: widget.product?.unit ?? '个');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '0');
    _costPriceController = TextEditingController(text: widget.product?.costPrice.toString() ?? '0');
    _warningStockController = TextEditingController(text: widget.product?.warningStock.toString() ?? '0');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    _remarkController = TextEditingController(text: widget.product?.remark ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _specController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _warningStockController.dispose();
    _categoryController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'code': _codeController.text,
        'name': _nameController.text,
        'spec': _specController.text,
        'unit': _unitController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'costPrice': double.tryParse(_costPriceController.text) ?? 0,
        'warningStock': int.tryParse(_warningStockController.text) ?? 0,
        'category': _categoryController.text,
        'remark': _remarkController.text,
      };

      if (isEdit) {
        await ProductService().updateProduct(widget.product!.id, data);
      } else {
        await ProductService().createProduct(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? '修改成功' : '添加成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑商品' : '新增商品'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('基本信息', [
              _buildTextField(_codeController, '商品编码', required: true),
              _buildTextField(_nameController, '商品名称', required: true),
              _buildTextField(_specController, '规格型号'),
              _buildTextField(_unitController, '单位'),
            ]),
            const SizedBox(height: 16),
            _buildSection('价格信息', [
              _buildTextField(_priceController, '参考单价', keyboardType: TextInputType.number),
              _buildTextField(_costPriceController, '成本单价', keyboardType: TextInputType.number),
              _buildTextField(_warningStockController, '预警库存', keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 16),
            _buildSection('其他信息', [
              _buildTextField(_categoryController, '商品分类'),
              _buildTextField(_remarkController, '备注', maxLines: 3),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? '保存修改' : '确认添加'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: required
            ? (value) => value?.isEmpty == true ? '请输入$label' : null
            : null,
      ),
    );
  }
}
