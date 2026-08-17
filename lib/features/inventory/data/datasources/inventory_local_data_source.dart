import '../models/inventory_item_model.dart';

abstract class InventoryLocalDataSource {
  Future<void> cacheItems(List<InventoryItemModel> items);
  Future<List<InventoryItemModel>> getCachedItems();
  Future<void> clearCache();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  static List<InventoryItemModel>? _cachedItems;

  @override
  Future<void> cacheItems(List<InventoryItemModel> items) async {
    _cachedItems = List.from(items);
  }

  @override
  Future<List<InventoryItemModel>> getCachedItems() async {
    if (_cachedItems != null) {
      return _cachedItems!;
    }

    // Default Fallback Demo Dataset
    _cachedItems = [
      const InventoryItemModel(
        id: '1',
        name: 'Wireless Mouse',
        sku: 'WM-001',
        category: 'Accessories',
        unit: 'Piece',
        lowStockQuantity: 10,
        stockQuantity: 42,
        retailSellPrice: 850,
        purchasePrice: 650,
      ),
      const InventoryItemModel(
        id: '2',
        name: 'USB Keyboard',
        sku: 'KB-002',
        category: 'Accessories',
        unit: 'Piece',
        lowStockQuantity: 10,
        stockQuantity: 7,
        retailSellPrice: 1250,
        purchasePrice: 950,
      ),
      const InventoryItemModel(
        id: '3',
        name: 'HD Monitor 24"',
        sku: 'MN-003',
        category: 'Monitor',
        unit: 'Piece',
        lowStockQuantity: 5,
        stockQuantity: 0,
        retailSellPrice: 14500,
        purchasePrice: 12000,
      ),
      const InventoryItemModel(
        id: '4',
        name: 'Office Chair',
        sku: 'CH-004',
        category: 'Furniture',
        unit: 'Piece',
        lowStockQuantity: 5,
        stockQuantity: 8,
        retailSellPrice: 7800,
        purchasePrice: 6500,
      ),
      const InventoryItemModel(
        id: '5',
        name: 'External HDD 1TB',
        sku: 'HD-005',
        category: 'Storage',
        unit: 'Piece',
        lowStockQuantity: 5,
        stockQuantity: 15,
        retailSellPrice: 6200,
        purchasePrice: 5200,
      ),
    ];

    return _cachedItems!;
  }

  @override
  Future<void> clearCache() async {
    _cachedItems = null;
  }
}
