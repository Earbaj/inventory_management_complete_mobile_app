# 🛒 POS Billing & Sales Feature Documentation (`lib/features/posbilling/`)

This directory contains the production-grade **POS Billing & Sales Module** built with **Clean Architecture**, **BLoC State Management**, **Dio HTTP Engine**, and **5-Minute TTL RAM Cache Purge**.

---

## 📐 Architecture & Layer Breakdown

```
lib/features/posbilling/
├── domain/                          # 🧠 Pure Business Logic Layer
│   ├── entities/
│   │   ├── cart_item_entity.dart    # Cart Item Domain Entity
│   │   └── sale_entity.dart         # Sale Transaction Domain Entity
│   ├── repositories/
│   │   └── pos_repository.dart      # Abstract Interface Contract
│   └── usecases/
│       ├── create_sale_usecase.dart # Submits checkout transaction
│       └── get_sales_logs_usecase.dart# Fetches sales history logs
│
├── data/                            # 💾 Data Communication Layer
│   ├── models/
│   │   ├── cart_item_model.dart     # JSON DTO for Cart Items
│   │   └── sale_model.dart          # JSON DTO for Sale Transactions
│   ├── mappers/
│   │   └── pos_mapper.dart          # Translates DTO <-> Domain Entity
│   ├── datasources/
│   │   ├── pos_remote_data_source.dart # REST API (Dio)
│   │   └── pos_local_data_source.dart  # 5-Min TTL In-memory Cache
│   └── repositories/
│       └── pos_repository_impl.dart    # PosRepository Implementation
│
└── presentation/                    # 🎨 UI & State Management Layer
    └── bloc/
        ├── pos_event.dart           # BLoC Events (AddToCart, RemoveItem, SubmitCheckout, ClearCart)
        ├── pos_state.dart           # BLoC States (CartState, CheckoutLoading, CheckoutSuccess, Error)
        └── pos_bloc.dart            # POS Billing BLoC Controller
```

---

## 🌐 Target REST API Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/sales` | Submit new sale transaction (Free Tier: Max 5 sales) | ✅ Authenticated |
| `GET` | `/api/sales` | Fetch sales transaction history logs | ✅ Authenticated |

---

## 🔄 Sequence & Execution Flows

```mermaid
sequenceDiagram
    autonumber
    actor User as Cashier / Manager
    participant Screen as PosBillingScreen
    participant Bloc as PosBloc
    participant UC as CreateSaleUseCase
    participant Repo as PosRepositoryImpl
    participant RemoteDS as PosRemoteDataSourceImpl
    participant LocalDS as PosLocalDataSourceImpl

    User->>Screen: Adds products to cart & selects customer
    Screen->>Bloc: add(AddToCartEvent(item))
    Bloc->>Bloc: _emit(PosCartState)
    User->>Screen: Clicks Checkout & chooses payment
    Screen->>Bloc: add(SubmitCheckoutEvent(paymentMethod, paidAmount))
    Bloc->>Bloc: _emit(PosCheckoutLoadingState)
    Bloc->>UC: call(saleEntity)
    UC->>Repo: createSale(saleEntity)
    Repo->>RemoteDS: createSale(saleModel)
    alt REST API Checkout Success
        RemoteDS-->>Repo: SaleModel
        Repo->>LocalDS: cacheSales(updatedSales)
        Repo-->>UC: SaleEntity
        UC-->>Bloc: SaleEntity
        Bloc->>Bloc: _emit(PosCheckoutSuccessState) & reset cart
        Bloc-->>Screen: Displays Receipt / Invoice Success Modal
    else API Offline / Failure
        Repo-->>UC: Throws Failure
        UC-->>Bloc: Throws Failure
        Bloc->>Bloc: _emit(PosCheckoutErrorState)
        Bloc-->>Screen: Displays SnackBar error message
    end
```
