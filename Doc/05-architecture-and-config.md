# 05. デモ環境の構成と設計ポイント

このドキュメントは「結局どんな構成で作るのか」を最短で理解するための資料です。

## 1. アーキテクチャ概要

### 1.1 コンポーネント

| レイヤー | コンポーネント | 役割 |
|---|---|---|
| 管理 | CycleCloud管理VM | クラスター作成、テンプレート管理、ジョブ環境の制御 |
| 管理 | User Assigned Managed Identity | Azureリソース操作の認証基盤 |
| 管理 | Key Vault | 秘密情報管理 |
| 共通 | Storage Account | 設定・ログ・アーティファクト保管 |
| NW | VNet + 2サブネット | 管理系と計算系の分離 |
| NW | NSG | 管理面のアクセス制御 |
| 計算 | PBS/Slurmヘッドノード | スケジューラー実体 |
| 計算 | Computeノード群 | ジョブ実行、オートスケール対象 |

### 1.2 ネットワーク

- VNet: `10.40.0.0/16`
- 管理サブネット: `10.40.1.0/24`
- 計算サブネット: `10.40.2.0/24`
- 受信許可 (最小):
  - 443/TCP (CycleCloud Web)
  - 22/TCP (運用管理用SSH)

## 2. 推奨デモ構成

### 2.1 小規模PoC (初回向け)

- CycleCloud管理VM: `Standard_D4s_v5`
- Scheduler: `Standard_D4s_v5`
- Compute: `Standard_HB120rs_v3` または在庫がある同等HPC SKU
- Max Core Count: `120`
- 目的: 基本操作、キュー投入、スケーリング体験

### 2.2 標準PoC (複数チーム検証)

- 管理系は小規模PoC同等
- Partition/Queueを2つ以上に分割
- Compute SKUを2種用意 (高性能/低コスト)
- Max Core Count: `240-480` (予算とクォータ次第)
- 目的: 優先度制御、混載運用、コスト比較

## 3. スケジューラー別の違い

### 3.1 PBSを選ぶ場合

- コマンド中心の操作がシンプル
- 初学者向けにジョブ状態の学習がしやすい
- ハンズオンは `Doc/02-hands-on-pbs.md` を使用

### 3.2 Slurmを選ぶ場合

- HPCでの採用事例が多い
- partition/QoSによる柔軟な運用が可能
- ハンズオンは `Doc/03-hands-on-slurm.md` を使用

## 4. 最初に決めるべき設計項目

1. 利用リージョン (HPC SKU在庫)
2. 予算上限 (Max Core Count と VM SKU)
3. スケジューラー (PBS or Slurm)
4. ジョブ種別 (短時間多数 or 長時間少数)
5. 共有ストレージ要否 (NFS/Azure NetApp Filesなど)

## 5. 本番化に向けた拡張ポイント

- ネットワーク: Bastion/Private Endpoint/受信元IP制限
- 運用: 監視、アラート、ログ集約
- 認可: RBAC最小権限化
- 可用性: 障害時の再作成手順、イメージ標準化
- コスト: 自動停止ポリシー、SKU見直し、定期レポート

## 6. 実装との対応表

- IaC本体: `infra/main.bicep`
- 構築手順: `Doc/01-deploy-cyclecloud-demo.md`
- 実習 (PBS): `Doc/02-hands-on-pbs.md`
- 実習 (Slurm): `Doc/03-hands-on-slurm.md`
- 後片付け: `Doc/04-cleanup.md`
