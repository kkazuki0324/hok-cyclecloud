# 04. 後片付け (Cleanup)

## 1. クラスター停止

CycleCloudポータルで以下を停止します。

- PBSクラスター
- Slurmクラスター

## 2. リソースグループ削除

検証が終わったら、リソースグループごと削除します。

```bash
az group delete \
  --name rg-cyclecloud-demo \
  --yes \
  --no-wait
```

## 3. 削除確認

```bash
az group exists --name rg-cyclecloud-demo
```

`false` になれば削除完了です。

## 4. コスト確認

- Azure Cost Managementで当日分の利用料を確認
- 検証用VMが残っていないことを確認
