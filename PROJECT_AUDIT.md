# Source Code Audit

**Scope:** All 23 Dart files currently tracked under lib/ on the default branch.  
**Method:** Static source inspection through GitHub. No Flutter build, analyzer, emulator, Firebase project, or deployed contract environment was available. Findings below are source-level observations, not runtime test results.

## Repository inventory

| Area | Files |
| --- | --- |
| Application entry | lib/main.dart |
| Authentication | lib/screens/auth/LoginScreen.dart, RegisterScreen.dart |
| Producer | AddProductScreen.dart, CarrierSelectionScreen.dart, MyOrdersScreen.dart, MyProductsScreen.dart, PendingOrdersScreen.dart, ProducerDashboardScreen.dart |
| Consumer | CarrierSelectionScreen.dart, CartScreen.dart, ConsumerDashboardScreen.dart, OrderDetailsScreen.dart, OrderHistoryScreen.dart, ProductDetailsScreen.dart, ProductListScreen.dart |
| Carrier | CarrierDashboardScreen.dart, DeliveryDetailsScreen.dart, DeliveryHistoryScreen.dart, PendingDeliveriesScreen.dart, PriceSettingsScreen.dart |
| Shared / wallet | CustomDrawer.dart, MyWalletScreen.dart |

## Findings

### High priority

1. **Cart data is not scoped to the signed-in consumer.**  
   ProductListScreen writes to the top-level cart collection without a consumer identifier. CartScreen streams the whole collection, reads all cart documents at checkout, and deletes each processed document. Unless strict Firestore rules or another external mechanism isolate this data, different users can see or affect one another's carts.

2. **Producer order history is not scoped to the producer.**  
   MyOrdersScreen filters by status == Approved only. It does not filter by producer.producerId, so the UI query is not limited to the signed-in producer's orders. Firestore Security Rules must enforce access independently; the query should also be scoped correctly.

3. **Firestore authorization cannot be verified.**  
   No Firestore rules, indexes, schema documentation, or backend authorization code are present. Client-side role selection and navigation are not sufficient security controls.

### Medium priority

4. **Two carrier-selection implementations use incompatible data paths.**  
   The consumer flow reads carrier users from users where role == Carrier. The producer flow reads users/Carrier/details and writes a separate deliveries collection. These represent different data models and may not refer to the same carrier records or workflow.

5. **Order and delivery status flow needs consolidation.**  
   The consumer checkout writes orders with status Pending; the producer approves them to Approved; the carrier lists Approved deliveries and marks them Completed. This flow is visible in the code, but producer-side and carrier-side queries do not consistently scope records by the current actor. The separate deliveries collection is also used by the producer carrier-selection screen.

6. **Nested Firestore fields are accessed without consistent null/type checks.**  
   Examples include accesses such as order['consumer']['consumerName'] and order['producer']['producerEmail']. Missing or incorrectly typed nested data can produce runtime exceptions. Introduce typed models and validate snapshots before rendering.

7. **Authentication role fallback is inconsistent.**  
   LoginScreen defaults a missing role to lowercase producer, but subsequent role comparisons expect Producer, Consumer, or Carrier. A missing role therefore does not match any dashboard branch.

8. **Wallet UI contains placeholder data and no implemented transactions.**  
   MyWalletScreen displays a hard-coded balance and sample transactions. Withdraw, transaction-history, and pending-payment buttons have empty callbacks. Do not describe these as working wallet functionality.

9. **Input validation and lifecycle handling are incomplete in some screens.**  
   For example, PriceSettingsScreen parses a text value directly as a double without validating it first and does not dispose its controller. Review controllers and asynchronous state updates across the app.

### Repository completeness blockers

10. **No Flutter package manifest.**  
    pubspec.yaml is absent, so dependency versions cannot be established and standard Flutter commands cannot be run.

11. **No Firebase platform configuration.**  
    main.dart calls Firebase.initializeApp(), but no generated Firebase options file or platform configuration is tracked. The correct setup depends on the original target platforms and Firebase project.

12. **No Solidity source or blockchain integration artifacts.**  
    The repository description mentions Solidity and blockchain, but no contract source, ABI, deployment scripts, chain configuration, or mobile-to-contract integration code is present in the tracked tree.

13. **No tests, assets, or platform scaffolding.**  
    No test/, assets/, android/, ios/, or other Flutter platform directories are currently tracked.

## Recommended remediation order

1. Recover or recreate the complete Flutter project scaffold and dependency manifest.
2. Define a single Firestore schema for users, products, carts, orders, and deliveries.
3. Scope every user-owned query and write by authenticated user ID; enforce the same policy in Firestore Security Rules.
4. Consolidate the carrier-selection and delivery data models.
5. Introduce typed Firestore models, null-safe parsing, and explicit order-state transitions.
6. Correct authentication role validation and add tests for role routing and access boundaries.
7. Recover the original Solidity contracts and deployment/integration files before documenting blockchain functionality as implemented.
8. Run dart format, flutter analyze, and automated tests once the complete Flutter project is restored.

## Verification status

- [x] Inspected all 23 Dart files tracked under lib/.
- [x] Added repository documentation and a Flutter-oriented .gitignore.
- [ ] Flutter dependency resolution — blocked by missing pubspec.yaml.
- [ ] Static analysis and tests — not run; complete Flutter project unavailable.
- [ ] Firebase integration — not verified; project configuration unavailable.
- [ ] Solidity compilation and deployment — not verified; contract source unavailable.
