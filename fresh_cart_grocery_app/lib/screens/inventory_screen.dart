import 'package:flutter/material.dart';
import '../services/inventory_service.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  IconData _toIcon(String s) {
    switch (s) {
      case 'store':
        return Icons.store;
      case 'apple':
        return Icons.apple;
      case 'set_meal':
        return Icons.set_meal;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_drink':
        return Icons.local_drink;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'favorite':
        return Icons.favorite;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: inventoryService.myProducts,
        builder: (context, prodSnap) {
          final products = prodSnap.data ?? const <Map<String, dynamic>>[];
          if (prodSnap.connectionState == ConnectionState.waiting &&
              products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (products.isEmpty) {
            return const Center(child: Text('No products yet', style: TextStyle(color: Colors.white)));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    final stock = (p['stock'] ?? 0) as int;
                    final logo = (p['logo'] ?? 'store') as String;
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _toIcon(logo),
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(p['name'] ?? 'Unnamed'),
                        subtitle: Text(
                          'Price: \$${(p['price'] ?? 0.0).toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Stock',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await inventoryService.updateStock(
                                          p['id'],
                                          stock + 1,
                                        );
                                      },
                                      child: const Icon(
                                        Icons.add_circle_outline,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _showStockEditDialog(
                                        context,
                                        p['id'],
                                        stock,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '$stock',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Restock',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 9),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showEditBottomSheet(
                                context,
                                p['id'],
                                p['name'] ?? '',
                                (p['price'] ?? 0.0).toDouble(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditBottomSheet(
    BuildContext context,
    String productId,
    String currentName,
    double currentPrice,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final priceCtrl = TextEditingController(
      text: currentPrice.toStringAsFixed(2),
    );
    final inventoryService = InventoryService();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Product',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Product name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixText: '\$',
                  prefixStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final priceStr = priceCtrl.text.trim();
                        if (name.isEmpty) return;
                        final price = double.tryParse(priceStr);
                        if (price == null || price < 0) return;

                        await inventoryService.updateProduct(
                          productId,
                          name,
                          price,
                        );
                        if (Navigator.of(sheetContext).canPop()) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showStockEditDialog(
    BuildContext context,
    String productId,
    int currentStock,
  ) async {
    final stockCtrl = TextEditingController(text: currentStock.toString());
    final inventoryService = InventoryService();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Stock', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: stockCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Stock quantity',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final stockStr = stockCtrl.text.trim();
                final stock = int.tryParse(stockStr);
                if (stock == null || stock < 0) return;

                await inventoryService.updateStock(productId, stock);
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0.00');
    final stockCtrl = TextEditingController(text: '0');
    String logoKey = 'store';
    final logos = <String>[
      'store',
      'apple',
      'set_meal',
      'shopping_cart',
      'local_drink',
      'bakery_dining',
      'favorite',
      'local_cafe',
    ];
    final inventoryService = InventoryService();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Add Product', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Product name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixText: '\$',
                        prefixStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Initial stock',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Logo',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      child: DropdownButton<String>(
                        value: logoKey,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        items: logos
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Row(
                                  children: [
                                    Icon(_toIcon(key), color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(key, style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              logoKey = v;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final price = double.tryParse(priceCtrl.text.trim());
                    if (price == null || price < 0) return;
                    final stock = int.tryParse(stockCtrl.text.trim());
                    if (stock == null || stock < 0) return;

                    await inventoryService.addProduct(
                      name,
                      stock,
                      price,
                      logoKey,
                    );
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
