# データモデル

---

## GunplaItem（ガンプラ情報）

| フィールド | 型 | 備考 |
|-----------|-----|------|
| id | UUID | |
| name | String | 商品名 |
| grade | String | HG / MG 等 |
| price | Int? | |
| imageData | Data? | |
| url | URL? | |
| releaseDate | Date? | 発売日 |
| restockDate | Date? | 次回再販日 |
| purchasedDate | Date? | 購入日 |
| purchaseStoreId | UUID? | 店舗への参照 |
| priority | Priority | 最高・高・中・低 |

---

## Store（店舗）

| フィールド | 型 | 備考 |
|-----------|-----|------|
| id | UUID | |
| name | String | |
| latitude | Double | |
| longitude | Double | |
| isFavorite | Bool | |
| stockDelayRecords | [StockDelayRecord] | 差分データ配列 |
| averageDelayHours | Double | 平均ずれ時間 |
| stockTimes | [Date]? | 品出し時刻記録（最大5件） |
| memo | String? | 店舗メモ（自由記述） |

---

## StockDelayRecord（品出し差分記録）

| フィールド | 型 | 備考 |
|-----------|-----|------|
| id | UUID | |
| storeId | UUID | |
| itemId | UUID | |
| restockDate | Date | 再販予定日 |
| actualStockDate | Date | 実際の品出し日時 |
| delayHours | Double | 差分（時間） |

---

## PatrolPlan（巡回予定）

| フィールド | 型 | 備考 |
|-----------|-----|------|
| id | UUID | |
| date | Date | |
| storeId | UUID | |
| targetItemIds | [UUID] | |
| notifyEnabled | Bool | |
