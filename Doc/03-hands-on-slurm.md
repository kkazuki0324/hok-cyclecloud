# 03. ハンズオン (Slurm編)

## ゴール

- CycleCloudでSlurmクラスターを作成
- `sbatch`でバッチジョブ投入
- ノードの自動起動・自動停止を確認

## 1. クラスター作成

1. CycleCloudポータルで `Create Cluster`
2. Slurmテンプレートを選択
3. 以下を設定

- Cluster Name: `slurm-demo`
- Scheduler VM Size: `Standard_D4s_v5`
- Execute VM Size: `Standard_HB120rs_v3` (在庫に応じて変更)
- Max Core Count: まずは小さく設定 (例: 120)

4. `Start` でデプロイ

## 2. ジョブスクリプト作成

```bash
cat > hello.slurm <<'EOF'
#!/bin/bash
#SBATCH --job-name=hello-slurm
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:05:00
#SBATCH --output=hello-slurm.%j.out

echo "Hello from Slurm on $(hostname)"
srun hostname
sleep 60
EOF
```

## 3. ジョブ投入と確認

```bash
sbatch hello.slurm
squeue
sacct -j <JOB_ID> --format=JobID,State,Elapsed
```

## 4. スケーリング確認

- キュー投入後に計算ノードが起動される
- 完了後にアイドルノードが停止される

## 5. 確認ポイント

- `squeue` の状態遷移 (PD -> R -> CG/COMPLETED)
- `sinfo` のノード状態
- CycleCloudとAzureポータルでのノード数変化

## 6. 追加演習

- パーティションを分けて優先度を比較
- 複数ジョブ同時投入でスケーリング上限確認
