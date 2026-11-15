# Blockchain-Based Supply Chain Management

A Flutter mobile application prototype for managing product and delivery workflows across a supply chain. The source currently available in this repository implements role-based user flows for producers, consumers, and carriers, backed by Firebase Authentication and Cloud Firestore.

> **Repository status:** This repository currently contains the Dart application source only. The Flutter package manifest, Firebase platform configuration, Solidity contracts, and deployment artifacts are not present in the tracked files. The project cannot currently be installed or run from this repository as-is.

## Overview

The application is organized around three user roles:

- **Producer** — creates and manages product listings, reviews incoming orders, and approves pending orders.
- **Consumer** — browses products, manages a cart, selects a carrier, places orders, and views order history.
- **Carrier** — configures a delivery price, views assigned deliveries, and marks deliveries as completed.

Authentication is implemented with Firebase Authentication. User profile and role information, products, carts, and order records are accessed through Cloud Firestore.

## Features visible in the source code

### Authentication and roles
- Email/password registration and sign-in.
- Role selection during registration (Producer, Consumer, Carrier).
- Role-based navigation to the corresponding dashboard.

### Producer workflow
- Add products with price, manufacture date, description, origin country, chemical information, and certifications.
- View and delete the producer's products.
- Review pending orders and approve them.
- View approved orders.

### Consumer workflow
- Browse products and inspect product details.
- Select product quantities and add items to a cart.
- Select a carrier and place an order.
- Review order history and order details.

### Carrier workflow
- Configure a fixed delivery price.
- View approved deliveries assigned to the carrier.
- Mark deliveries as completed.
- View completed delivery history.

## Technology

| Area | Technology evidenced in the tracked source |
| --- | --- |
| Mobile application | Flutter / Dart |
| Authentication | Firebase Authentication |
| Data storage and realtime updates | Cloud Firestore |
| Date formatting | intl |
| Smart contracts | Solidity is mentioned in the original repository description, but contract source files are not currently present |

## Source layout

```text
.
└── lib/
    ├── main.dart
    └── screens/
        ├── MyWalletScreen.dart
        ├── auth/
        ├── carrier/
        ├── consumer/
        ├── producer/
        └── shared/
```

The repository currently has 23 Dart files under lib/. The role-specific screens are grouped by user type, while authentication and shared navigation components have their own directories.

## Setup and current limitations

This repository is not yet a complete, reproducible Flutter project. Before setup instructions can be made executable, the following project files need to be recovered or recreated and verified:

1. pubspec.yaml with the actual Flutter and package dependency versions.
2. Firebase platform configuration for the intended targets (for example, Android, iOS, or Web). Do not commit private service-account credentials.
3. Firestore security rules and a documented data model.
4. The Solidity contracts, if they are part of the original graduation project, plus their compiler/deployment configuration.
5. Any required assets and platform-specific project folders.

Once those files are available, the expected Flutter workflow will be:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

These commands are listed as the standard Flutter workflow; they have **not** been run against this repository because its package manifest and platform configuration are missing.

## Important engineering notes

The source review identified areas that should be addressed before treating the application as production-ready:

- Cart documents are read from and written to a shared cart collection without a consumer ID filter. This can mix users' cart data unless Firestore rules or another mechanism prevents it.
- Order creation reads every document in cart and deletes those documents after checkout, rather than querying the signed-in consumer's cart.
- The producer's approved-order screen queries all documents with status Approved without filtering by the current producer.
- The producer and consumer carrier-selection screens use different Firestore paths and data models.
- Order status transitions and the Firestore document shape should be consolidated and documented.
- Several screens assume nested Firestore fields exist; malformed or partial documents may cause runtime exceptions.
- The wallet screen currently displays hard-coded sample balance and transaction values; its action buttons do not implement wallet operations.

See [PROJECT_AUDIT.md](PROJECT_AUDIT.md) for the detailed source-level review.

## Security

Firebase client-side role selection is not an authorization boundary by itself. Access control must be enforced with Firestore Security Rules (and, where appropriate, trusted backend logic). Never include Firebase Admin service-account keys, private keys, wallet seed phrases, or other secrets in this repository.

## Project context

This project was originally described as a graduation project combining a Flutter mobile application with a blockchain-based supply-chain system and Solidity smart contracts. The currently tracked source is insufficient to verify the smart-contract implementation or the integration between the mobile application and the blockchain layer.

## License

No license is currently provided. Unless a license is added, the repository's source remains under the default copyright terms; reuse and redistribution are not automatically granted.
