# Tabular Knowledge Base

> Last updated: 2025-01-22
> Source count: 1

## Original Summaries

### CMI - Problematic Internet Use (2024) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/child-mind-institute-problematic-internet-use)
**Category:** Tabular (表格数据 + 时序混合)
**Key Techniques:**
- **中间分数预测**：预测 PCIAT-PCIAT_Total 而非直接预测 sii
- **多seed平均**：减少seed引起的方差
- **高fold交叉验证**：10-fold stratified KFold
- **Pseudo Labeling**：填充缺失target
- **GBM主导的集成**：LGBM + XGBoost + CatBoost
- **Tweedie Loss**：处理偏态分布
- **时序特征工程**：k-means聚类
- **特征清洗**：去除异常特征、PCA降维

**Results:** 多seed平均、预测中间分数、Pseudo Labeling 是关键技术

---

## Competition Brief (竞赛简介)

### CMI - Problematic Internet Use (2024)

**竞赛背景：**
- **主办方**：Child Mind Institute
- **目标**：预测儿童和青少年的问题性网络使用严重程度（sii）
- **应用场景**：理解与抑郁和焦虑等心理健康问题相关的网络使用行为

**数据集规模：**
- 总样本数：约 3,900+（训练集）
- 特征：表格数据 + 部分时序数据
- 类别：4 分类（sii = 0, 1, 2, 3）

**数据特点：**
1. **混合数据类型**：表格数据（身体活动、健康指标）+ 时序数据
2. **target 缺失**：训练集中部分样本的 sii 缺失
3. **中间分数**：PCIAT-PCIAT_Total 是 sii 的连续分数版本
4. **类别分布不均**：约 58.3% 为 0 类（无问题）

**评估指标：**
- **Quadratic Weighted Kappa (QWK)**：衡量预测与实际的一致性
- 分数范围：-1 到 1，越高越好
- 特点：对分类错误的惩罚与严重程度成正比

**关键挑战：**
1. **Seed 敏感**：不同 seed 导致 LB 分数剧烈波动
2. **数据泄露**：公开 notebook 泄露了训练数据
3. **LB 不可靠**：Private LB 大幅 shake（波动）
4. **Target 缺失**：需要 Pseudo Labeling 处理

---

## Code Templates

### 中间分数预测 (PCIAT-PCIAT_Total)

**关键洞察：** 预测连续分数比直接预测类别更有效

```python
import numpy as np
import pandas as pd
from lightgbm import LGBMRegressor
from sklearn.model_selection import StratifiedKFold

# 原始 sii 标签: 0, 1, 2, 3
# PCIAT-PCIAT_Total: 连续分数 (0-100)

def train_intermediate_target_model(X_train, y_train_total, X_test):
    """
    预测 PCIAT-PCIAT_Total (中间分数)，然后转换为 sii
    """
    # 根据 sii 创建分层的 bins
    # 这确保每个 fold 中各类别比例一致
    train_df = X_train.copy()
    train_df['sii'] = (y_train_total > 30).astype(int) + \
                      (y_train_total > 50).astype(int) + \
                      (y_train_total > 80).astype(int)

    # 10-fold stratified KFold
    n_folds = 10
    skf = StratifiedKFold(n_splits=n_folds, shuffle=True, random_state=42)

    # 存储预测结果
    oof_preds = np.zeros(len(X_train))
    test_preds = np.zeros(len(X_test))

    for fold, (train_idx, val_idx) in enumerate(skf.split(X_train, train_df['sii'])):
        X_tr, X_val = X_train.iloc[train_idx], X_train.iloc[val_idx]
        y_tr, y_val = y_train_total.iloc[train_idx], y_train_total.iloc[val_idx]

        # LightGBM 回归器
        model = LGBMRegressor(
            n_estimators=1000,
            learning_rate=0.05,
            num_leaves=31,
            max_depth=-1,
            random_state=42 + fold  # 每个 fold 不同 seed
        )

        model.fit(X_tr, y_tr, eval_set=[(X_val, y_val)],
                  early_stopping_rounds=100, verbose=False)

        # 预测中间分数
        oof_preds[val_idx] = model.predict(X_val)
        test_preds += model.predict(X_test) / n_folds

    return oof_preds, test_preds

def convert_total_to_sii(pred_total):
    """
    将 PCIAT-PCIAT_Total 转换为 sii 标签
    阈值: 0-30→0, 31-50→1, 51-80→2, 81-100→3
    """
    pred_sii = np.zeros(len(pred_total))
    pred_sii[pred_total > 30] = 1
    pred_sii[pred_total > 50] = 2
    pred_sii[pred_total > 80] = 3
    return pred_sii.astype(int)
```

### 多 Seed 平均

**关键洞察：** 多个 seed 平均可以减少预测方差

```python
import numpy as np
from lightgbm import LGBMRegressor

def multi_seed_prediction(X_train, y_train, X_test, seeds=[42, 123, 456, 789, 1011]):
    """
    多个 seed 训练模型，取平均预测
    """
    test_preds_all = []

    for seed in seeds:
        model = LGBMRegressor(
            n_estimators=1000,
            learning_rate=0.05,
            random_state=seed
        )

        model.fit(X_train, y_train)
        test_preds_all.append(model.predict(X_test))

    # 平均预测
    test_preds_mean = np.mean(test_preds_all, axis=0)

    return test_preds_mean

# 更进一步：多 fold × 多 seed
def multi_fold_multi_seed(X_train, y_train, X_test, n_folds=5, seeds=10):
    """
    多 fold × 多 seed = 更稳定的预测
    """
    n_folds = 5
    seeds = list(range(10))  # 10 个 seeds

    test_preds = []

    for seed in seeds:
        for fold in range(n_folds):
            model = LGBMRegressor(
                n_estimators=1000,
                random_state=seed + fold * 100
            )
            # ... train and predict
            test_preds.append(model.predict(X_test))

    # 50 个模型的平均 (5 folds × 10 seeds)
    return np.mean(test_preds, axis=0)
```

### Pseudo Labeling

**关键洞察：** 用模型预测填充缺失的 target

```python
import numpy as np
import pandas as pd

def pseudo_labeling(X_train, y_train, X_missing, n_iterations=3):
    """
    Pseudo Labeling 迭代填充缺失 target
    """
    # 分割有标签和无标签数据
    has_label = ~y_train.isna()
    X_labeled = X_train[has_label]
    y_labeled = y_train[has_label]
    X_unlabeled = X_train[~has_label]

    # 初始模型（仅用有标签数据训练）
    model = LGBMRegressor(random_state=42)
    model.fit(X_labeled, y_labeled)

    # 迭代预测和训练
    for iteration in range(n_iterations):
        # 预测无标签数据
        pseudo_labels = model.predict(X_unlabeled)

        # 合并有标签和伪标签数据
        X_combined = pd.concat([X_labeled, X_unlabeled])
        y_combined = pd.concat([y_labeled, pd.Series(pseudo_labels, index=X_unlabeled.index)])

        # 重新训练模型
        model = LGBMRegressor(random_state=42 + iteration)
        model.fit(X_combined, y_combined)

    return model

# 注意：CV 计算时不使用 pseudo labels
def cv_with_pseudo(X_train, y_train, X_missing):
    """
    交叉验证时不使用 pseudo labels
    """
    has_label = ~y_train.isna()
    X_labeled = X_train[has_label]
    y_labeled = y_train[has_label]

    # 训练 pseudo 模型（用于最终预测）
    pseudo_model = pseudo_labeling(X_train, y_train, X_missing)

    # CV 仅用有标签数据
    from sklearn.model_selection import cross_val_score
    cv_model = LGBMRegressor(random_state=42)
    cv_scores = cross_val_score(cv_model, X_labeled, y_labeled, cv=5)

    return pseudo_model, cv_scores
```

### Tweedie Loss

**关键洞察：** 处理偏态分布的目标变量

```python
import lightgbm as lgb

def train_with_tweedie_loss(X_train, y_train, X_val, y_val):
    """
    使用 Tweedie Loss 训练 LightGBM
    适用于偏态分布（如保险索赔、疾病严重程度）
    """
    train_data = lgb.Dataset(X_train, label=y_train)
    val_data = lgb.Dataset(X_val, label=y_val, reference=train_data)

    params = {
        'objective': 'tweedie',
        'tweedie_variance_power': 1.5,  # 1 < p < 2，控制偏态程度
        'metric': 'rmse',
        'learning_rate': 0.05,
        'num_leaves': 31,
        'max_depth': -1,
        'verbose': -1
    }

    model = lgb.train(
        params,
        train_data,
        num_boost_round=1000,
        valid_sets=[val_data],
        early_stopping_rounds=100,
        verbose_eval=False
    )

    return model
```

### 时序特征 k-means 聚类

**关键洞察：** 将时序数据聚类成类别特征

```python
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

def extract_time_series_cluster_features(time_series_data, n_clusters=5):
    """
    时序数据 k-means 聚类作为特征
    """
    # 假设 time_series_data 是 (n_samples, n_timesteps, n_features)
    n_samples = time_series_data.shape[0]

    # 展平时序数据: (n_samples, n_timesteps * n_features)
    ts_flat = time_series_data.reshape(n_samples, -1)

    # 标准化
    scaler = StandardScaler()
    ts_scaled = scaler.fit_transform(ts_flat)

    # k-means 聚类
    kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
    cluster_labels = kmeans.fit_predict(ts_scaled)

    # 聚类距离作为特征
    cluster_distances = kmeans.transform(ts_scaled)

    # 创建特征 DataFrame
    cluster_features = pd.DataFrame({
        f'ts_cluster_dist_{i}': cluster_distances[:, i]
        for i in range(n_clusters)
    })
    cluster_features['ts_cluster_label'] = cluster_labels

    return cluster_features

# 使用示例
# time_series_data 是原始时序数据
# cluster_features = extract_time_series_cluster_features(time_series_data)
# X_final = pd.concat([tabular_features, cluster_features], axis=1)
```

### 特征清洗和 PCA 降维

**关键洞察：** 去除异常特征，PCA 降维减少噪声

```python
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

def clean_features(X, threshold=0.99):
    """
    清洗异常特征
    - 去除高度相关的特征
    - 去除方差过小的特征
    """
    # 计算相关性矩阵
    corr_matrix = X.corr().abs()

    # 找到高度相关的特征对
    upper_tri = corr_matrix.where(
        np.triu(np.ones(corr_matrix.shape), k=1).astype(bool)
    )

    # 找出相关性 > threshold 的特征
    to_drop = [column for column in upper_tri.columns if any(upper_tri[column] > threshold)]

    # 去除高度相关的特征
    X_cleaned = X.drop(columns=to_drop)

    return X_cleaned, to_drop

def pca_reduction(X_train, X_test, variance_ratio=0.95):
    """
    PCA 降维
    """
    # 标准化
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # PCA
    pca = PCA(n_components=variance_ratio)
    X_train_pca = pca.fit_transform(X_train_scaled)
    X_test_pca = pca.transform(X_test_scaled)

    print(f"Original features: {X_train.shape[1]}")
    print(f"PCA components: {X_train_pca.shape[1]}")
    print(f"Variance explained: {pca.explained_variance_ratio_.sum():.4f}")

    return X_train_pca, X_test_pca, pca
```

### GBM Ensemble (LGBM + XGBoost + CatBoost)

**关键洞察：** 不同 GBM 的集成提升稳定性

```python
import numpy as np
from lightgbm import LGBMRegressor
from xgboost import XGBRegressor
from catboost import CatBoostRegressor

def train_gbm_ensemble(X_train, y_train, X_test):
    """
    训练 GBM 集成: LGBM + XGBoost + CatBoost
    """
    models = []
    test_preds = []

    # 1. LightGBM
    lgbm = LGBMRegressor(
        n_estimators=1000,
        learning_rate=0.05,
        num_leaves=31,
        max_depth=-1,
        random_state=42,
        verbose=-1
    )
    lgbm.fit(X_train, y_train)
    models.append(lgbm)
    test_preds.append(lgbm.predict(X_test))

    # 2. XGBoost
    xgb = XGBRegressor(
        n_estimators=1000,
        learning_rate=0.05,
        max_depth=6,
        random_state=42,
        verbosity=0
    )
    xgb.fit(X_train, y_train)
    models.append(xgb)
    test_preds.append(xgb.predict(X_test))

    # 3. CatBoost
    cat = CatBoostRegressor(
        iterations=1000,
        learning_rate=0.05,
        depth=6,
        random_state=42,
        verbose=False
    )
    cat.fit(X_train, y_train)
    models.append(cat)
    test_preds.append(cat.predict(X_test))

    # 简单平均
    ensemble_pred = np.mean(test_preds, axis=0)

    return models, ensemble_pred

# 带权重的集成
def weighted_gbm_ensemble(X_train, y_train, X_test, weights=[0.4, 0.3, 0.3]):
    """
    带权重的 GBM 集成
    weights: [lgbm, xgb, cat]
    """
    lgbm = LGBMRegressor(random_state=42, verbose=-1).fit(X_train, y_train)
    xgb = XGBRegressor(random_state=42, verbosity=0).fit(X_train, y_train)
    cat = CatBoostRegressor(random_state=42, verbose=False).fit(X_train, y_train)

    pred_lgbm = lgbm.predict(X_test)
    pred_xgb = xgb.predict(X_test)
    pred_cat = cat.predict(X_test)

    # 加权平均
    ensemble_pred = (
        weights[0] * pred_lgbm +
        weights[1] * pred_xgb +
        weights[2] * pred_cat
    )

    return ensemble_pred
```

### 数据增强（随机 NaN + 高斯噪声）

**关键洞察：** 添加噪声提高模型鲁棒性

```python
import numpy as np

def augment_data_with_noise(X_train, y_train, n_augmented=2, nan_ratio=0.1, noise_std=0.01):
    """
    数据增强：随机插入 NaN + 添加高斯噪声
    """
    X_aug_list = [X_train.copy()]
    y_aug_list = [y_train.copy()]

    for _ in range(n_augmented):
        X_aug = X_train.copy()

        # 1. 随机插入 NaN
        mask = np.random.random(X_aug.shape) < nan_ratio
        X_aug[mask] = np.nan

        # 2. 添加高斯噪声
        noise = np.random.normal(0, noise_std, X_aug.shape)
        X_aug = X_aug + noise

        X_aug_list.append(X_aug)
        y_aug_list.append(y_train.copy())

    # 合并原始数据和增强数据
    X_final = pd.concat(X_aug_list, axis=0, ignore_index=True)
    y_final = pd.concat(y_aug_list, axis=0, ignore_index=True)

    return X_final, y_final

# 使用示例（需要支持 NaN 处理的模型）
# X_aug, y_aug = augment_data_with_noise(X_train, y_train)
# model = LGBMRegressor().fit(X_aug, y_aug)
```

### 阈值优化（CGAS=80, SDS=35）

**关键洞察：** 特定健康分数的阈值可预测严重问题

```python
import numpy as np
from scipy.optimize import minimize

def optimize_thresholds(y_true, y_pred_total):
    """
    优化将 PCIAT-PCIAT_Total 转换为 sii 的阈值
    默认阈值: [30, 50, 80]
    """
    def qwk_loss(thresholds):
        t1, t2, t3 = thresholds
        pred_sii = np.zeros(len(y_pred_total))
        pred_sii[y_pred_total > t1] = 1
        pred_sii[y_pred_total > t2] = 2
        pred_sii[y_pred_total > t3] = 3

        # 计算 QWK（简化版本）
        from sklearn.metrics import cohen_kappa_score
        kappa = cohen_kappa_score(y_true, pred_sii, weights='quadratic')
        return -kappa  # 最小化负 QWK

    # 初始阈值
    x0 = [30, 50, 80]

    # 优化（确保 t1 < t2 < t3）
    bounds = [(0, 40), (40, 60), (60, 100)]
    constraints = {'type': 'ineq', 'fun': lambda x: x[1] - x[0]}

    result = minimize(qwk_loss, x0, bounds=bounds, constraints=constraints)

    optimal_thresholds = result.x
    print(f"Optimal thresholds: {optimal_thresholds}")

    return optimal_thresholds

# 特定阈值的使用（4th Place 发现）
def apply_specific_thresholds(pred_total):
    """
    使用特定健康分数阈值
    CGAS=80, SDS=35 可预测严重问题
    """
    pred_sii = np.zeros(len(pred_total))

    # 默认阈值
    pred_sii[pred_total > 30] = 1
    pred_sii[pred_total > 50] = 2
    pred_sii[pred_total > 80] = 3

    # 特殊情况：如果有 CGAS 或 SDS 数据，结合判断
    # 这需要原始数据中的这些特征
    # if has_cgas_data and cgas_score > 80:
    #     pred_sii = 3

    return pred_sii.astype(int)
```

---

## Best Practices

### 表格数据竞赛策略

| 策略 | 何时使用 | 说明 |
|------|---------|------|
| **预测中间分数** | 有连续分数和类别标签时 | 预测 PCIAT-PCIAT_Total 比直接预测 sii 更有效 |
| **多 Seed 平均** | Seed 导致结果波动大时 | 多个 seed 训练，取平均减少方差 |
| **高 Fold CV** | 数据量较小或类别不平衡时 | 10-fold stratified KFold 稳定验证 |
| **Pseudo Labeling** | Target 有缺失时 | 用模型预测填充缺失 target |
| **GBM Ensemble** | 单模型不够稳定时 | LGBM + XGBoost + CatBoost 集成 |
| **Tweedie Loss** | 目标变量偏态分布时 | 处理保险、疾病严重程度等偏态数据 |
| **时序聚类特征** | 有时序数据时 | k-means 聚类将时序转为类别特征 |
| **特征清洗** | 特征过多或有噪声时 | 去除高度相关特征，PCA 降维 |

### QWK 评估指标的优化

**Quadratic Weighted Kappa (QWK)：**
- 衡量预测与实际的一致性
- 分数范围：-1 到 1，越高越好
- 特点：对严重错误的惩罚更重

**优化策略：**

| 策略 | 效果 |
|------|------|
| **预测中间分数** | 预测连续值比直接分类更精细 |
| **阈值优化** | 在验证集上优化转换阈值 |
| **分层 KFold** | 确保每个 fold 中类别比例一致 |
| **多 Seed 平均** | 减少 seed 引起的 QWK 波动 |

### 数据增强策略

**表格数据增强：**

| 方法 | 适用场景 | 注意事项 |
|------|---------|---------|
| **随机 NaN** | 提高缺失值鲁棒性 | 需要模型支持 NaN 处理 |
| **高斯噪声** | 提高模型泛化能力 | 噪声强度需调参 |
| **特征 Shuffle** | 特征独立性强时 | 破坏特征相关性时慎用 |
| **SMOTE** | 类别不平衡时 | 可能导致过拟合 |

### Target 缺失处理

**处理策略对比：**

| 策略 | 优点 | 缺点 |
|------|------|------|
| **删除缺失样本** | 简单直接 | 损失数据，减少样本量 |
| **Pseudo Labeling** | 利用无标签数据 | 可能引入噪声 |
| **两阶段训练** | Stage 1 用有标签，Stage 2 用全部 | 需要精心设计 |

**推荐做法：**
```python
# 1. CV 计算时不使用 pseudo labels
# 2. 最终模型用 pseudo labels
# 3. 迭代多次，每次用上一轮的预测
```

### 模型选择指南

**表格数据竞赛模型选择：**

| 场景 | 推荐模型 | 理由 |
|------|---------|------|
| **表格数据（主要）** | LightGBM | 速度快，效果好 |
| **类别特征多** | CatBoost | 自动处理类别特征 |
| **需要调参灵活性** | XGBoost | 参数丰富，调参空间大 |
| **数据量大** | LightGBM | 内存效率高 |
| **集成** | LGBM + XGB + Cat | 多样性提升稳定性 |

**不推荐场景：**
- 神经网络：表格数据通常不如 GBM
- 深度学习：除非有特殊结构（如图嵌入）

---

## Top 10 Solutions Comparison (前 10 名方案对比分析)

> 基于前排解决方案的横向对比分析，提取共性技术和差异创新

### 前 5 名详细对比

#### 1st Place - Lennart Haupts

**核心架构：** GBM Ensemble (LGBM + XGBoost + CatBoost + ExtraTrees)

**关键技术：**
- **预测 PCIAT-PCIAT_Total**：预测中间分数而非直接预测 sii
- **10-Fold Stratified KFold**：高 fold 提升稳定性
- **特征清洗**：去除异常特征
- **PCA 降维**：减少特征噪声

**模型组合：**
```
LGBMRegressor
+ XGBoost Regressors
+ CatBoostRegressor
+ ExtraTreesRegressor
→ Ensemble (平均/加权)
```

#### 3rd Place

**核心架构：** LightGBM with Multi-Seed

**关键技术：**
- **Multi-Seed Training**：seed 不固定，5-fold 重复 100 次
- **Optuna 调参**：自动化超参数优化
- **数据增强**：
  - 随机插入 NaN
  - 添加高斯噪声
- **特征工程**：多样化的特征变换

**训练策略：**
```python
for seed in range(100):
    for fold in range(5):
        model = LGBMRegressor(random_state=seed)
        train_and_evaluate()
```

#### 5th Place

**核心架构：** Multi-Model Ensemble

**关键技术：**
- **时序特征工程**：k-means 聚类将时序转为类别特征
- **Pseudo Labeling**：填充缺失 target
- **多模型集成**：LGB + Cat + XGB + Lasso + NN

**模型组合：**
```
LGBM + CatBoost + XGBoost
+ Lasso (线性模型)
+ Neural Network
→ Ensemble
```

#### 7th Place

**核心架构：** LGBM + XGBoost Ensemble

**关键技术：**
- **Tweedie Loss**：处理偏态分布
- **Pseudo Labeling**：有效提升分数
- **缺失值处理**：用中位数填补
- **Multi-Seed Ensemble**：10 个 seed 平均

#### 4th Place (underfit squad)

**核心发现：**
- **CGAS=80 阈值**：CGAS 分数 > 80 可预测严重问题
- **SDS=35 阈值**：SDS 分数 > 35 可预测严重问题

**关键技术：**
- TabNet（效果不佳）
- 预测 PCIAT-PCIAT_Total
- 特征工程：CGAS, SDS 阈值

### 共性技术（"银弹" - 高分者共同使用）

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **预测中间分数** | 1st, 3rd, 5th, 7th | 预测 PCIAT-PCIAT_Total 比直接预测 sii |
| **多 Seed 平均** | 3rd, 7th | 减少 seed 引起的方差 |
| **Pseudo Labeling** | 5th, 7th | 填充缺失 target |
| **GBM Ensemble** | 1st, 5th, 7th | LGBM + XGBoost + CatBoost |
| **高 Fold CV** | 1st | 10-fold stratified KFold |
| **特征清洗** | 1st | 去除异常特征，PCA 降维 |

### 差异创新

**1st Place vs 其他：**

| 方面 | 1st Place | 其他 |
|------|-----------|------|
| **模型组合** | LGBM + XGB + Cat + ExtraTrees | 主要 3 个 GBM |
| **Fold 数量** | 10-fold | 5-fold 或更多 |
| **特征处理** | 严格清洗 + PCA | 较少使用 PCA |

**3rd Place vs 其他：**

| 方面 | 3rd Place | 其他 |
|------|-----------|------|
| **训练策略** | 5-fold × 100-seed | 单次训练或少 seed |
| **调参方法** | Optuna 自动调参 | 手动调参 |
| **数据增强** | 随机 NaN + 高斯噪声 | 较少数据增强 |

**5th Place vs 其他：**

| 方面 | 5th Place | 其他 |
|------|-----------|------|
| **时序处理** | k-means 聚类 | 较少特殊处理 |
| **模型多样性** | GBM + 线性 + NN | 主要是 GBM |
| **Pseudo Labeling** | 显著有效 | 效果不一 |

**7th Place vs 其他：**

| 方面 | 7th Place | 其他 |
|------|-----------|------|
| **Loss 函数** | Tweedie Loss | 主要是 MSE/MAE |
| **缺失值处理** | 中位数填补 | 其他方法 |
| **Ensemble 策略** | 10-seed 平均 | 少 seed 或不用 |

### Target 预测策略对比

| 排名 | 预测目标 | 理由 |
|------|---------|------|
| **1st** | PCIAT-PCIAT_Total | 连续值比类别更精细 |
| **3rd** | PCIAT-PCIAT_Total | 同左 |
| **5th** | PCIAT-PCIAT_Total | 同左 |
| **7th** | PCIAT-PCIAT_Total | 同左 |

**结论：** 所有前排方案都选择预测中间分数

### 特征工程对比

| 排名 | 特征工程策略 |
|------|-------------|
| **1st** | 清洗异常特征 + PCA 降维 |
| **3rd** | 随机 NaN + 高斯噪声 |
| **5th** | 时序 k-means 聚类 |
| **7th** | 中位数填补缺失值 |

### 数据增强对比

| 排名 | 数据增强策略 |
|------|-------------|
| **1st** | 较少数据增强 |
| **3rd** | 随机 NaN + 高斯噪声 |
| **5th** | Pseudo Labeling |
| **7th** | Multi-Seed 平均 |

### Pseudo Labeling 对比

| 排名 | 是否使用 | 效果 |
|------|---------|------|
| **1st** | 未提及 | - |
| **3rd** | 未提及 | - |
| **5th** | 使用 | 显著有效 |
| **7th** | 使用 | 显著有效 |

**结论：** Pseudo Labeling 在 5th 和 7th 有效，可能需要正确实现

### 关键数据洞察总结

1. **预测中间分数是关键**：所有前排方案都预测 PCIAT-PCIAT_Total
2. **多 Seed 平均有效**：减少 seed 引起的方差
3. **Pseudo Labeling 需要正确实现**：5th 和 7th 报告有效
4. **GBM Ensemble 是主流**：LGBM + XGBoost + CatBoost
5. **高 Fold CV 提升稳定性**：10-fold 比 5-fold 更稳定
6. **特征清洗很重要**：去除异常特征，PCA 降维
7. **Tweedie Loss 适用于偏态数据**：7th Place 使用
8. **时序数据可聚类处理**：k-means 将时序转为类别特征

### 表格数据竞赛的最佳实践

| 方面 | 推荐 |
|------|------|
| **目标预测** | 预测中间分数（如有），而非直接预测类别 |
| **交叉验证** | 高 Fold（10-fold）Stratified KFold |
| **模型选择** | LGBM + XGBoost + CatBoost Ensemble |
| **Seed 策略** | Multi-Seed 平均减少方差 |
| **Target 缺失** | Pseudo Labeling（CV 不用 pseudo） |
| **特征工程** | 清洗异常特征，PCA 降维 |
| **数据增强** | 随机 NaN + 高斯噪声（需模型支持） |
| **Loss 函数** | Tweedie Loss（偏态数据） |
| **时序数据** | k-means 聚类转为类别特征 |

---

## Metadata
| Source | Date | Tags |
|--------|------|------|
| [Child Mind Institute - Problematic Internet Use](https://www.kaggle.com/competitions/child-mind-institute-problematic-internet-use) | 2025-01-22 | 表格数据, QWK, Pseudo Labeling, 多Seed平均, GBM Ensemble, Tweedie Loss |
