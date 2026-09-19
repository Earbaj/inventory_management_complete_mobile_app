import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_complete/features/inventory/domain/entities/inventory_item_entity.dart';

void main() {
  // Fixture: builds a valid InventoryItemEntity with sensible defaults.
  // Each test only overrides the fields relevant to its scenario.
  InventoryItemEntity buildItem({
    String id = 'item-1',
    String name = 'Bulb 100w',
    String sku = 'BULB-100',
    String category = 'Electronics',
    String unit = 'pcs',
    int stockQuantity = 50,
    int lowStockQuantity = 10,
    double retailSellPrice = 60,
    double purchasePrice = 40,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemEntity(
      id: id,
      name: name,
      sku: sku,
      category: category,
      unit: unit,
      stockQuantity: stockQuantity,
      lowStockQuantity: lowStockQuantity,
      retailSellPrice: retailSellPrice,
      purchasePrice: purchasePrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  group('InventoryItemEntity — data holding', () {
    test('stores all constructor fields correctly', () {
      final item = buildItem(
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      );

      expect(item.id, 'item-1');
      expect(item.name, 'Bulb 100w');
      expect(item.sku, 'BULB-100');
      expect(item.category, 'Electronics');
      expect(item.unit, 'pcs');
      expect(item.stockQuantity, 50);
      expect(item.lowStockQuantity, 10);
      expect(item.retailSellPrice, 60);
      expect(item.purchasePrice, 40);
      expect(item.createdAt, DateTime.parse('2026-01-01T00:00:00Z'));
      expect(item.updatedAt, isNull); // nullable field defaults to null
    });
  });

  group('InventoryItemEntity — equality', () {
    test('two instances with the same values are equal', () {
      expect(buildItem(), equals(buildItem()));
    });

    test('equal instances have the same hashCode', () {
      expect(buildItem().hashCode, buildItem().hashCode);
    });

    test('instances with a different field value are not equal', () {
      expect(buildItem(), isNot(equals(buildItem(sku: 'BULB-200'))));
    });

    test('instances with a different price are not equal', () {
      expect(buildItem(), isNot(equals(buildItem(retailSellPrice: 65))));
    });

    test('instances with a different catagory are not equal', () {
      expect(buildItem(), isNot(equals(buildItem(category: "Water"))));
    });

    test('an instance is equal to itself (identity)', () {
      final item = buildItem();
      expect(item, equals(item));
      expect(item is InventoryItemEntity, isTrue);
    });
  });

  group('InventoryItemEntity — isLowStock (business rule)', () {
    test('returns true when stock is positive and below threshold', () {
      // 5 items in stock, alert threshold is 10 → LOW
      expect(
        buildItem(stockQuantity: 5, lowStockQuantity: 10).isLowStock,
        isTrue,
      );
    });

    test('returns true when stock equals threshold (boundary case)', () {
      // <= means exact match is still "low" — without this test a bug could slip in
      expect(
        buildItem(stockQuantity: 10, lowStockQuantity: 10).isLowStock,
        isTrue,
      );
    });

    test('returns false when stock is above threshold', () {
      expect(
        buildItem(stockQuantity: 11, lowStockQuantity: 10).isLowStock,
        isFalse,
      );
    });

    test('returns false when stock is 0 (that is out-of-stock, not low)', () {
      // stock 0 means "finished", not "low" — two distinct UI states!
      expect(
        buildItem(stockQuantity: 0, lowStockQuantity: 10).isLowStock,
        isFalse,
      );
    });
  });

  group('InventoryItemEntity — isOutOfStock', () {
    test('returns true when stock is 0', () {
      expect(buildItem(stockQuantity: 0).isOutOfStock, isTrue);
    });

    test('returns true when stock is negative (defensive against bad data)', () {
      expect(buildItem(stockQuantity: -3).isOutOfStock, isTrue);
    });

    test('returns false when stock is positive', () {
      expect(buildItem(stockQuantity: 1).isOutOfStock, isFalse);
    });
  });

  group('InventoryItemEntity — alias getters', () {
    test('sellPrice mirrors retailSellPrice', () {
      expect(buildItem(retailSellPrice: 60).sellPrice, 60);
    });

    test('buyPrice mirrors purchasePrice', () {
      expect(buildItem(purchasePrice: 40).buyPrice, 40);
    });
  });

  group('InventoryItemEntity — copyWith', () {
    test('creates a modified copy with the given field changed', () {
      final original = buildItem();
      final updated = original.copyWith(stockQuantity: 30);

      expect(updated.stockQuantity, 30);
      expect(updated.name, 'Bulb 100w'); // everything else stays the same
    });

    test('does not mutate the original object (immutability)', () {
      // arrange
      final original = buildItem();

      // act
      original.copyWith(stockQuantity: 30);

      // assert — original still holds its old value
      expect(original.stockQuantity, 50);
    });

    test('keeps existing values for fields that are not passed', () {
      // arrange
      final original = buildItem(name: 'Old Name');

      // act — name is NOT passed
      final updated = original.copyWith(stockQuantity: 1);

      // assert — name is preserved, target field changed
      expect(updated.name, 'Old Name');
      expect(updated.stockQuantity, 1);
    });

    test('produces equal results when built the same way', () {
      final a = buildItem().copyWith(name: 'Changed');
      final b = buildItem().copyWith(name: 'Changed');

      // would also fail without Equatable
      expect(a, equals(b));
    });
  });
}