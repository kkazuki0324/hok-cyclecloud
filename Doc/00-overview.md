# CycleCloud デモ環境 ハンズオン概要

## 対象

- HPCをこれから使いたい
- Azure CycleCloudを初めて触る
- スケジューラーとしてPBSまたはSlurmを試したい

## ゴール

- Azure上にCycleCloud管理環境を構築できる
- PBSまたはSlurmクラスターを作成できる
- ジョブ投入からスケール挙動の確認まで体験できる

## 全体フロー

1. インフラ準備 (`infra/main.bicep`)
2. CycleCloudセットアップ
3. 構成詳細の確認 (`Doc/05-architecture-and-config.md`)
4. クラスター作成 (PBS or Slurm)
5. ジョブ実行と確認
6. 後片付け

## 所要時間目安

- 環境デプロイ: 20-30分
- CycleCloud初期設定: 20分
- PBSハンズオン: 30-45分
- Slurmハンズオン: 30-45分

## 前提ツール

- Azure CLI
- Bicep
- SSHクライアント

## 推奨リージョン

- East US
- Japan East
- West Europe

利用予定VMサイズの在庫があるリージョンを選択してください。
