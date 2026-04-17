---
description: Final Fix for Store to Module Back-Navigation Loading Issue
---

## 🛑 The Issue (Root Cause)
When navigating back from `StoreScreen` to a specific module (like Grocery), an infinite shimmer/loading occurs because:
1. The app was passing `fromModule: true` when opening a store.
2. In `StoreController`, `fromModule: true` triggers a full `HomeScreen.loadData(true)` call.
3. Upon pressing 'Back', the Grocery screen finds its data being reloaded/cleared, leading to a shimmer loop.

## ✅ The Final Solution
The fix is to stop the unnecessary reloading of the Home/Module data when we are just visiting a store within the same module.

## Step 1: Update Navigation Arguments
In every widget where you navigate to a store (e.g., `BestStoreNearbyView`, `PopularStoreCard`), change the `fromModule` argument to `false`.

**Example Change:**
```dart
// From this:
arguments: StoreScreen(store: store, fromModule: true),

// To this:
arguments: StoreScreen(store: store, fromModule: false),
```

## Step 2: Prevent Blind Data Resets
In `lib/features/store/screens/store_screen.dart`, ensure the `PopScope` does not aggressively call `resetStoreData()` which clears the lists needed by the previous screen.

## Step 3: Verification Flow
1. Open the Grocery Module.
2. Tap on a Featured/Popular Store.
3. Wait for the Store Screen to load.
4. Press the **System Back Button** or the **In-app Back Icon**.
5. The Grocery screen should now appear **instantly** without any shimmer because its data was never cleared.

