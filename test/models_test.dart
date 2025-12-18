import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/models/household.dart';
import 'package:frigo_zen/models/enums.dart';

void main() {
  group('Batch Model Tests', () {
    test('should create Batch from map', () {
      final now = DateTime.now();
      final map = {
        'quantity': 5,
        'expirationDate': Timestamp.fromDate(now),
        'addedAt': Timestamp.fromDate(now),
        'storeName': 'Test Store',
      };

      final batch = Batch.fromMap(map);

      expect(batch.quantity, 5);
      expect(batch.storeName, 'Test Store');
      // Precision might be slightly off due to Timestamp conversion
      expect(batch.expirationDate.millisecondsSinceEpoch, closeTo(now.millisecondsSinceEpoch, 1000));
    });

    test('should serialize Batch to map', () {
      final now = DateTime.now();
      final batch = Batch(
        id: 'batch1',
        quantity: 2,
        expirationDate: now,
        addedAt: now,
        storeName: 'Another Store',
      );

      final map = batch.toMap();

      expect(map['quantity'], 2);
      expect(map['storeName'], 'Another Store');
      expect(map['expirationDate'], isA<Timestamp>());
    });
    test('should NOT include id in map if empty', () {
      final now = DateTime.now();
      final batch = Batch(
        id: '',
        quantity: 2,
        expirationDate: now,
        addedAt: now,
      );

      final map = batch.toMap();

      expect(map.containsKey('id'), false);
      expect(map['quantity'], 2);
    });

    test('StorageLocation.fromId should parse legacy strings', () {
      expect(StorageLocation.fromId('loc_fridge'), StorageLocation.fridge);
      expect(StorageLocation.fromId('loc_pantry'), StorageLocation.pantry);
      expect(StorageLocation.fromId('loc_freezer'), StorageLocation.freezer);
      expect(StorageLocation.fromId('Frigo'), StorageLocation.fridge); // Test raw string if possible, or we fix normalization
      
      // Test robust inputs
      expect(StorageLocation.fromId(0.0), StorageLocation.fridge); // Double handling
      expect(StorageLocation.fromId('0'), StorageLocation.fridge); // String number
      expect(StorageLocation.fromId('0.0'), StorageLocation.fridge); // String double
    });
  });

  group('InventoryItem Model Tests', () {
    test('should create InventoryItem from map', () {
      final now = DateTime.now();
      final map = {
        'name': 'Milk',
        'cleanedName': 'milk',
        'canonicalName': 'milk',
        'category': 'Dairy',
        'location': 'Fridge',
        'totalQuantity': 2,
        'earliestExpirationDate': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
        'dvm': 7,
        'batches': [
          {
            'quantity': 2,
            'expirationDate': Timestamp.fromDate(now),
            'addedAt': Timestamp.fromDate(now),
          }
        ]
      };

      final item = InventoryItem.fromMap(map, 'doc123');

      expect(item.id, 'doc123');
      expect(item.name, 'Milk');
      // Verify location parsing (Fridge -> 0)
      expect(item.location.id, 0); 
      expect(item.batches.length, 1);
      expect(item.batches.first.quantity, 2);
    });

    test('should create InventoryItem with integer location', () {
      final now = DateTime.now();
      final map = {
        'name': 'Cheese',
        'location': 2, // Freezer
        'cleanedName': '', 'canonicalName': '',
        'category': 'cat_dairy_eggs',
        'totalQuantity': 1,
        'earliestExpirationDate': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
      };
      final item = InventoryItem.fromMap(map, 'doc456');
      expect(item.location.id, 2);
    });
  });

  group('ShoppingItem Model Tests', () {
    test('should create ShoppingItem from map (legacy string)', () {
      final now = DateTime.now();
      final map = {
        'name': 'Bread',
        'cleanedName': 'bread',
        'canonicalName': 'bread',
        'quantity': 1,
        'category': 'Bakery',
        'location': 'Pantry', // Legacy string
        'createdAt': Timestamp.fromDate(now),
        'isChecked': false,
      };

      final item = ShoppingItem.fromMap(map, 'shop123');

      expect(item.id, 'shop123');
      expect(item.name, 'Bread');
      expect(item.isChecked, false);
      expect(item.location, 1); // Pantry -> 1
    });

    test('should create ShoppingItem from map (integer)', () {
      final now = DateTime.now();
      final map = {
        'name': 'Juice',
        'location': 0, // Fridge
        'createdAt': Timestamp.fromDate(now),
        'isChecked': false,
      };
      final item = ShoppingItem.fromMap(map, 'shop789');
      expect(item.location, 0);
    });
  });

  group('Household Model Tests', () {
    test('should create Household from map', () {
      final map = {
        'name': 'My Home',
        'members': ['user1', 'user2'],
        'ownerId': 'user1',
        'createdAt': Timestamp.now(),
      };

      final household = Household.fromMap(map, 'house123');

      expect(household.id, 'house123');
      expect(household.name, 'My Home');
      expect(household.members.length, 2);
      expect(household.ownerId, 'user1');
    });
  });
}
