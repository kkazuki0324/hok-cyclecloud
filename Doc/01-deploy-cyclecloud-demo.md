# 01. CycleCloud デモ環境の構築

## 1. 事前確認

1. Azureへサインイン
2. 対象サブスクリプション選択
3. SSH公開鍵を用意

```bash
az login
az account set --subscription <SUBSCRIPTION_ID_OR_NAME>
```

## 2. リソースグループ作成

```bash
az group create \
  --name rg-cyclecloud-demo \
  --location japaneast
```

## 3. Bicepで基盤をデプロイ

`infra/main.bicep` は以下を作成します。

- CycleCloud管理VM
- VNet (管理用サブネット / 計算ノード用サブネット)
- NSG
- Storage Account
- Key Vault
- User Assigned Managed Identity

```bash
az deployment group create \
  --resource-group rg-cyclecloud-demo \
  --template-file infra/main.bicep \
  --parameters prefix=ccdemo \
               adminUsername=azureuser \
               adminSshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

## 4. デプロイ結果を確認

```bash
az deployment group show \
  --resource-group rg-cyclecloud-demo \
  --name <DEPLOYMENT_NAME> \
  --query properties.outputs
```

出力の `cycleCloudPublicIp` を控えてください。

## 5. CycleCloudのインストール

管理VMへSSH接続し、CycleCloudをインストールします。

```bash
ssh azureuser@<cycleCloudPublicIp>
```

CycleCloudのインストール方法は、利用バージョンに応じて公式手順を使用してください。

- Azure CycleCloud公式ドキュメント
  - https://learn.microsoft.com/azure/cyclecloud/

## 6. 初期設定

1. ブラウザーで `https://<cycleCloudPublicIp>` にアクセス
2. 管理ユーザーを作成
3. Azureアカウント情報を連携
4. プロジェクトを作成

## 7. テンプレート取り込み

CycleCloudのサンプルテンプレート、または社内標準テンプレートを取り込みます。

- PBSクラスター用テンプレート
- Slurmクラスター用テンプレート

取り込み後に、次のハンズオンへ進んでください。
