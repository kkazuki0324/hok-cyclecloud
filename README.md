# hok-cyclecloud

Azure CycleCloudのデモ環境と、HPC初心者向けハンズオン一式です。

## 目的

- 初めてCycleCloudを使うお客様向けに、最短で検証を始められる構成を提供
- スケジューラーとしてPBSとSlurmの両方を体験可能

## 構成

- `infra/`: CycleCloudデモ環境のAzure Bicepテンプレート
- `Doc/`: ハンズオン資料

## デモ環境の構成イメージ

### 全体構成

- 管理系
	- CycleCloud管理VM (Web UI/管理プレーン)
	- User Assigned Managed Identity
	- Key Vault (シークレット管理)
	- Storage Account (ログ・資材置き場)
- ネットワーク
	- VNet `10.40.0.0/16`
	- 管理サブネット `10.40.1.0/24`
	- 計算サブネット `10.40.2.0/24`
	- NSG (443/22を許可)
- 計算系
	- PBSまたはSlurmクラスター
	- 要求時に計算ノードを自動起動、アイドル時に自動停止

### 代表的な利用パターン

- PoC/ハンズオン最小構成
	- Scheduler: `Standard_D4s_v5`
	- Compute: `Standard_HB120rs_v3` もしくは在庫のあるHPC向けサイズ
	- Max Core Count: 小さめ (例: 120)
- 拡張構成 (段階2)
	- パーティション/キュー分離
	- 複数VM SKU混在
	- コスト上限と優先度ポリシーの導入

詳細は `Doc/05-architecture-and-config.md` を参照してください。

## 使い方

1. `Doc/00-overview.md` で全体像を確認
2. `Doc/01-deploy-cyclecloud-demo.md` で環境構築
3. `Doc/05-architecture-and-config.md` で構成詳細を確認
4. `Doc/02-hands-on-pbs.md` または `Doc/03-hands-on-slurm.md` を実施
5. `Doc/04-cleanup.md` で後片付け

## 前提

- Azureサブスクリプション
- Azure CLI (`az`) とBicep
- SSH鍵ペア
- CycleCloudの利用権限

## 注意

- 本リポジトリは検証・ハンズオン用途の最小構成です。
- 本番利用時はネットワーク分離、認証強化、監視・バックアップ、運用設計を追加してください。
