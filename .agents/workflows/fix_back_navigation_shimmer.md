---
description: Fix Shimmer Effect on Back Navigation from Store Screen
---

## 🛑 Problem (Samasya)
Jab app start hoti hai aur aap "Module selection screen" par hote ho, wahan se Featured Store tap karne par Store Screen khulti hai. Lekin Back karne par hum pichli screen (Grocery/Food home) par aate hain aur wahan "Shimmer/Loading" ghumta rehta hai. 
Ye isliye hota hai kyunki system pichli screen ka poora data "Clear" kar deta hai.

## ✅ Solution Steps (Kaise Solve Karein)

### 1. StoreController Modification
Hum `lib/features/store/controllers/store_controller.dart` mein `getStoreDetails` function ko update karenge.
- **Pehle:** Wo `HomeScreen.loadData(true)` call kar raha tha (True matlab poora data reset kar do).
- **Ab:** Hum use \`HomeScreen.loadData(false)\` karenge (False matlab reset mat karo, bas piche loading chalao).

### 2. Recommended List Optimization
\`getRecommendedStoreList\` function hamesha data ko \`null\` kar deta hai. Hum ise change karenge taa ke agar data pehle se hai, toh wo use khali na kare balki sirf update kare.

### 3. Verification Flow
1. App Start karein.
2. Direct Kisi Featured store par tap karein.
3. Store load hone ke baad Back press karein.
4. Ab aapko pichli screen (BestStoreNearby) par data turant ya bina "Clear feel" ke dikhega.

## ⚠️ Safety Case (Revert)
Agar isse koi dusra flow break hota hai, toh hum \`git restore\` ka use karke wapas purane state par ja sakte hain.
