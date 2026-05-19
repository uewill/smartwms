import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/stock_provider.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/widgets/common/loading_widget.dart';
import 'package:clothing_erp/widgets/common/empty_widget.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  final _styleNoController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  bool _showFilter = false;

  @override
  void initState() {
    super.initState();
    context.read<StockProvider>().loadStockList();
  }

  @override
  void dispose() {
    _styleNoController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<StockProvider>().loadStockList(
          refresh: true,
          styleNo: _styleNoController.text.trim(),
          colorName: _colorController.text.trim(),
          sizeName: _sizeController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('库存查询'),
        actions: [
          IconButton(
            icon: Icon(_showFilter ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilter = !_showFilter;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilter)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _styleNoController,
                          decoration: const InputDecoration(
                            hintText: '款号',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _colorController,
                          decoration: const InputDecoration(
                            hintText: '颜色',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            hintText: '尺码',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilter,
                          child: const Text('查询'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _styleNoController.clear();
                            _colorController.clear();
                            _sizeController.clear();
                            context.read<StockProvider>().loadStockList(refresh: true);
                          },
                          child: const Text('重置'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: stockProvider.isLoading && stockProvider.stockList.isEmpty
                ? const LoadingWidget()
                : stockProvider.stockList.isEmpty
                    ? const EmptyWidget(message: '暂无库存数据')
                    : RefreshIndicator(
                        onRefresh: () =>
                            stockProvider.loadStockList(refresh: true),
                        child: ListView.builder(
                          itemCount: stockProvider.stockList.length,
                          itemBuilder: (context, index) {
                            final stock = stockProvider.stockList[index];
                            final isWarning = stock.isWarning == true;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              color: isWarning
                                  ? AppTheme.warningColor.withOpacity(0.05)
                                  : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isWarning
                                      ? AppTheme.warningColor.withOpacity(0.15)
                                      : AppTheme.primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    isWarning
                                        ? Icons.warning
                                        : Icons.inventory_2,
                                    color: isWarning
                                        ? AppTheme.warningColor
                                        : AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${stock.styleNo ?? ''} - ${stock.productName ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  '${stock.colorName ?? ''} / ${stock.sizeName ?? ''}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${stock.stockQty ?? 0}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isWarning
                                            ? AppTheme.errorColor
                                            : AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      isWarning
                                          ? '预警: ${stock.stockWarningQty ?? 0}'
                                          : '库存',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isWarning
                                            ? AppTheme.warningColor
                                            : AppTheme.textHintColor,
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
    );
  }
}
