import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_complete/core/error/exceptions.dart';
import 'package:inventory_management_complete/features/inventory/domain/entities/inventory_item_entity.dart';
import 'package:inventory_management_complete/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_complete/features/inventory/domain/usecases/add_inventory_item_usecase.dart';
import 'package:mocktail/mocktail.dart';

//Mock The repository using Mock
class MockInventoryRepository extends Mock implements InventoryRepository {}

//Fake the Entity so that it can handle any pass from the usecase
class FakeInventoryItemEntity extends Fake implements InventoryItemEntity {}

void main() {
  //Lateinitialize usecase and mock repository
  late AddInventoryItemUseCase addInventoryItemUseCase;
  late MockInventoryRepository mockInventoryRepository;

  //set up all
  setUpAll(() {
    registerFallbackValue(FakeInventoryItemEntity());
  });

  setUp(() {
    mockInventoryRepository = MockInventoryRepository();
    addInventoryItemUseCase = AddInventoryItemUseCase(mockInventoryRepository);
  });

  final items = InventoryItemEntity(
    id: '124',
    name: 'Test',
    sku: 'SKU-124',
    category: 'Test',
    unit: 'Pcs',
    stockQuantity: 10,
    lowStockQuantity: 5,
    retailSellPrice: 50,
    purchasePrice: 25,
  );

  group("Add Inventory Item useCase Test", () {
    test("First Chek it's return the acctual data", () async {
      // Arrange
      when(()=> mockInventoryRepository.addInventoryItem(items))
          .thenAnswer((_) async => items);
      // Act
      final result = await addInventoryItemUseCase(items);
      // Assert
      expect(items, equals(result));
      verify(() => mockInventoryRepository.addInventoryItem(items)).called(1);
      verifyNoMoreInteractions(mockInventoryRepository);
    });

    test("Now Check network or other error", () async {
      // Arrange
      when(() => mockInventoryRepository.addInventoryItem(items))
          .thenThrow(Exception("Failed to add item"));

      // Act & Assert (একসাথে টেস্ট করতে হবে)
      expect(
            () => addInventoryItemUseCase(items),
        throwsA(isA<Exception>()),
      );

      // Verify
      verify(() => mockInventoryRepository.addInventoryItem(items)).called(1);
    });

    test('should throw ValidationException and NOT call repository when price is negative', () async {
      // Arrange
      final invalidItem = items.copyWith(retailSellPrice: -50);

      // Act & Assert
      expect(() => addInventoryItemUseCase(invalidItem), throwsA(isA<ValidationException>()));

      // verify
      verifyNever(() => mockInventoryRepository.addInventoryItem(any()));
    });

  });
}
