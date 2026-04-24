# 02. ハンズオン (PBS編)

## ゴール

- CycleCloudでPBSクラスターを作成
- 簡単なMPIジョブを投入
- オートスケールの挙動を確認

## 1. クラスター作成

1. CycleCloudポータルにログイン
2. `Create Cluster` からPBSテンプレートを選択
3. 以下を設定

- Cluster Name: `pbs-demo`
- Scheduler VM Size: `Standard_D4s_v5`
- Execute VM Size: `Standard_HB120rs_v3` (在庫に応じて変更)
- Max Core Count: まずは小さく設定 (例: 120)

4. `Start` でデプロイ

## 2. ジョブ投入準備

CycleCloudからPBSのヘッドノードへ接続し、サンプルジョブを作成します。

```bash
cat > hello.pbs <<'EOF'
#!/bin/bash
#PBS -N hello-pbs
#PBS -l select=2:ncpus=4
#PBS -l walltime=00:05:00
#PBS -j oe

cd $PBS_O_WORKDIR
echo "Hello from PBS on $(hostname)"
sleep 60
EOF
```

## 3. ジョブ投入

```bash
qsub hello.pbs
qstat -a
```

## 4. スケーリング確認

- Queueに応じて計算ノードが起動されることを確認
- ジョブ完了後、アイドルノードが縮退することを確認

## 5. 確認ポイント

- `qstat -a` でジョブ状態遷移 (Q -> R -> C)
- CycleCloudのノード状態 (Started / Ready / Off)
- Azureポータル上のVM数変化

## 6. 追加演習

- `select` 数を増やして複数ノード利用を確認
- walltimeを変更してキュー滞留を観察
