# Implementation Plan: Featured Stores - showAll Logic

## Problem Statement
Jab user **HomeScreen se Module Screen** (Selection Screen) par jaaye, toh **All Featured Stores** dikhane chahiye (bina kisi filter ke).  
Baki jagah (normal flow) purani **condition wali filtering** (`module.id == store.moduleId` + `module.pivot!.zoneId == store.zoneId`) chalni chahiye.

---

## Root Cause Found (Debug Round 2)
**`removeModule()` inside `splash_controller.dart` was calling `getFeaturedStoreList()` WITHOUT `showAll: true`**.  
This caused TWO parallel calls - one with `showAll: false` (from removeModule) and one with `showAll: true` (from InkWell). The `showAll: false` call was overwriting the correct data.

---

## Files Modified

### 1. `lib/features/store/controllers/store_controller.dart`
- Added `showAll` parameter to `getFeaturedStoreList()` (default `false`)
- `_prepareFeaturedStore()`: `showAll=true` → `addAll(stores)`, `showAll=false` → filter
- **Status: ✅ DONE**

### 2. `lib/features/splash/controllers/splash_controller.dart` ← **KEY FIX**
- `removeModule()` now calls `getFeaturedStoreList(showAll: true)` instead of `getFeaturedStoreList()`
- This was the ROOT CAUSE - it was overwriting data with empty filtered results
- **Status: ✅ DONE**

### 3. `lib/features/home/screens/home_screen.dart`
- `loadData()` → `getFeaturedStoreList(showAll: true)` when module is null
- `RefreshIndicator` → `getFeaturedStoreList(showAll: true)` when module is null
- `InkWell` → Removed redundant `getFeaturedStoreList` call (removeModule handles it now)
- **Status: ✅ DONE**

### 4. `lib/features/home/widgets/popular_store_view.dart`
- `itemCount: storeList.length` (no limit)
- **Status: ✅ ALREADY CORRECT**

---

## All `getFeaturedStoreList` Call Sites

| File | Line | showAll | Context |
|------|------|---------|---------|
| `splash_controller.dart` | 424 | `true` | `removeModule()` → Selection Screen |
| `home_screen.dart` | 114 | `true` | `loadData()` when module==null |
| `home_screen.dart` | 131 | `false` | `loadData()` for Pharmacy module |
| `home_screen.dart` | 380 | `true` | RefreshIndicator when module==null |
| `all_store_screen.dart` | 40 | `false` | AllStoreScreen initState |
| `all_store_screen.dart` | 100 | `false` | AllStoreScreen refresh |

---

## Testing Checklist
1. [ ] Hot restart → Selection Screen par ALL featured stores dikhein
2. [ ] Module select karo → Module ke andar filtered stores dikhein
3. [ ] Module icon tap karke wapas aao → ALL stores dikhein (single call, no race condition)
4. [ ] Pull-to-refresh on Selection Screen → ALL stores reload ho
5. [ ] Console logs show only ONE `getFeaturedStoreList` call at a time
