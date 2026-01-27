# AMP®-Parkinson's Disease Progression Prediction (2023)

## Competition Brief

**竞赛基本信息**
- **主办方**: AMP (Accelerating Medicines Partnership)
- **时间**: 2023年
- **类型**: 表格数据/医疗预测
- **数据规模**: 小样本数据集
- **评价目标**: SMAPE (Symmetric Mean Absolute Percentage Error)

**任务描述**
预测帕金森病患者的疾病进展情况。使用蛋白质和肽段数据（通过质谱测量脑脊液样本）来预测患者未来的 MDS-UPDRS 评分。

**数据特点**
- **蛋白质数据**: 227个蛋白质特征
- **肽段数据**: 来自多个质谱实验
- **时间序列**: 每个患者有多次访问记录
- **样本量**: 相对较小（小样本竞赛）
- **目标变量**: MDS-UPDRS 评分的进展

**评价指标**
SMAPE (Symmetric Mean Absolute Percentage Error)
- 对称性平均绝对百分比误差
- 范围 [0, 200]，越小越好
- 对异常值相对鲁棒

---

## Top Solutions Analysis

### 1st Place - Connecting Dotts (Dmitry Gordeev et al.)

**核心策略**
- **模型组合**: LightGBM + Neural Network 的简单平均
- **特征工程**: 精心设计的蛋白质和肽段聚合特征
- **数据处理**: 针对神经网络的标准化和二值化

**关键技术细节**

1. **特征工程**
   - 蛋白质和肽段的聚合统计量（均值、中位数、标准差）
   - 时间序列特征的构造
   - 蛋白质-肽段关系特征的提取

2. **模型架构**
   - **LightGBM**: 梯度提升树模型
   - **Neural Network**: 深度学习模型
   - **集成策略**: 简单平均

3. **数据预处理**
   - NN专用预处理: 特征缩放
   - 特征二值化处理
   - 缺失值处理策略

**代码要点**
```python
# 模型集成示例
final_prediction = (lgb_pred + nn_pred) / 2
```

### 2nd Place - No Luck, All Skill

**核心策略**
- 发布时间: 2023年6月19日
- 强调特征工程的重要性
- 多模型集成策略

**关键特征**
- 详细的特征工程流程
- 模型融合技术
- 验证策略设计

### 3rd Place - Hajime Tamura

**核心策略**
- 发布时间: 2023年5月19日
- **分组策略**: 将数据分成两组分别优化
- 简洁的解决方案（三个主要函数）

**关键创新**
- 数据分组优化
- 针对性模型训练
- 简化流程提升效率

### 4th/5th Place - Ambrosm (#5: Find the Control Group)

**核心策略**
- 发布时间: 2023年5月18日
- **控制组识别**: 关键创新点
- 利用对照组信息改进预测

**关键洞察**
- 识别并分离控制组样本
- 针对不同组别使用不同策略
- 提升模型区分度

### 9th Place - Makotu

**核心策略**
- 发布时间: 2023年5月18日
- 详细的特征工程和模型调优

### 13th Place - FNOA

**技术要点**
- 中等排名的稳定方案
- 实用的特征工程方法

### 43rd Place - Wojciech Victor Fulmyk (Top 3% Silver)

**重要发现**
- **XGBoost 和 LightGBM 表现不佳**
- 强调传统树模型在这个数据集上的局限性
- 探索其他模型方向

**技术要点**
```python
# 他们的发现表明传统 GBDT 可能不是最佳选择
# 需要考虑其他模型或更复杂的特征工程
```

### 89th Place - Giba (Non-Leaky Solution)

**核心策略**
- 强调无数据泄露的干净方案
- 可复现的验证策略

---

## Common Techniques Across Solutions

### 1. Feature Engineering Patterns

**蛋白质/肽段聚合特征**
```python
# 时间聚合
protein_stats = train.groupby('patient_id')['protein'].agg([
    'mean', 'median', 'std', 'min', 'max'
])

# 肽段聚合
peptide_stats = train.groupby('patient_id')['peptide'].agg([
    'mean', 'count', 'nunique'
])
```

**时间序列特征**
- 访问间隔时间
- 进展速度估计
- 基线和随访差异

**蛋白质-肽段关系**
- 蛋白质包含的肽数量
- 肽段来源的蛋白质信息

### 2. Model Selection Insights

**成功模型**
- LightGBM (部分方案)
- Neural Networks / MLP
- 集成方法

**需要谨慎的模型**
- XGBoost (43rd方案指出效果不佳)
- 纯线性模型
- 单一模型（推荐集成）

### 3. Validation Strategies

**关键原则**
- 避免患者级别的数据泄露
- 时间基础的分割
- 分组交叉验证

```python
from sklearn.model_selection import GroupKFold

gkf = GroupKFold(n_splits=5)
for train_idx, val_idx in gkf.split(X, y, groups=patient_ids):
    # 训练和验证
```

### 4. Data Leakage Prevention

**常见陷阱**
- 同一患者的多次访问分散在训练/验证集
- 未来信息泄露到训练集
- 蛋白质/肽段测试集信息泄露

**预防措施**
- 严格的患者级别分割
- 时间有序分割
- 仔细的特征构造审计

---

## Code Templates

### Basic Feature Engineering

```python
import pandas as pd
import numpy as np

def create_protein_features(train_proteins, test_proteins):
    """创建蛋白质聚合特征"""
    def process(df):
        stats = df.groupby('patient_id')['NPX'].agg([
            ('protein_mean', 'mean'),
            ('protein_std', 'std'),
            ('protein_min', 'min'),
            ('protein_max', 'max')
        ]).reset_index()
        return stats

    train_stats = process(train_proteins)
    test_stats = process(test_proteins)

    return train_stats, test_stats

def create_peptide_features(train_peptides, test_peptides):
    """创建肽段聚合特征"""
    def process(df):
        stats = df.groupby('patient_id')['PeptideAbundance'].agg([
            ('peptide_mean', 'mean'),
            ('peptide_std', 'std'),
            ('peptide_count', 'count')
        ]).reset_index()
        return stats

    train_stats = process(train_peptides)
    test_stats = process(test_peptides)

    return train_stats, test_stats

def create_time_features(train_clinical, test_clinical):
    """创建时间序列特征"""
    def process(df):
        df = df.copy()
        df['visit_month'] = df['visit_month'].astype(int)
        df['pred_month'] = df['visit_month'] + df['updrs_test_month']

        # 计算自基线以来的时间
        df['months_since_baseline'] = df.groupby('patient_id')['visit_month'].transform(lambda x: x - x.min())

        return df

    return process(train_clinical), process(test_clinical)
```

### Model Training Template

```python
import lightgbm as lgb
from sklearn.model_selection import GroupKFold
from sklearn.metrics import mean_absolute_error

def smape(y_true, y_pred):
    """SMAPE 评估指标"""
    return 100 * np.mean(2 * np.abs(y_pred - y_true) / (np.abs(y_true) + np.abs(y_pred) + 1e-8))

def train_lightgbm(X_train, y_train, groups, params=None):
    """训练 LightGBM 模型"""
    if params is None:
        params = {
            'objective': 'regression',
            'metric': 'mae',
            'learning_rate': 0.01,
            'num_leaves': 31,
            'max_depth': -1,
            'feature_fraction': 0.8,
            'bagging_fraction': 0.8,
            'bagging_freq': 5,
            'verbose': -1
        }

    gkf = GroupKFold(n_splits=5)
    models = []
    scores = []

    for train_idx, val_idx in gkf.split(X_train, y_train, groups=groups):
        X_tr, X_val = X_train.iloc[train_idx], X_train.iloc[val_idx]
        y_tr, y_val = y_train.iloc[train_idx], y_train.iloc[val_idx]

        train_data = lgb.Dataset(X_tr, label=y_tr)
        val_data = lgb.Dataset(X_val, label=y_val, reference=train_data)

        model = lgb.train(
            params,
            train_data,
            num_boost_round=10000,
            valid_sets=[train_data, val_data],
            callbacks=[lgb.early_stopping(100), lgb.log_evaluation(0)]
        )

        pred = model.predict(X_val)
        score = smape(y_val, pred)

        models.append(model)
        scores.append(score)

    print(f'Average SMAPE: {np.mean(scores):.2f}')

    return models, scores

# 使用示例
# models, scores = train_lightgbm(X_train, y_train, patient_ids)
```

### Neural Network Template

```python
import tensorflow as tf
from sklearn.preprocessing import StandardScaler

def create_nn_model(input_dim, hidden_units=[256, 128, 64]):
    """创建神经网络模型"""
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_dim,)),
    ])

    for units in hidden_units:
        model.add(tf.keras.layers.Dense(
            units,
            activation='relu',
            kernel_regularizer=tf.keras.regularizers.l2(0.01)
        ))
        model.add(tf.keras.layers.Dropout(0.3))
        model.add(tf.keras.layers.BatchNormalization())

    model.add(tf.keras.layers.Dense(1, activation='linear'))

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='mae',
        metrics=['mae']
    )

    return model

def train_nn(X_train, y_train, groups, epochs=100, batch_size=32):
    """训练神经网络"""
    # 标准化
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)

    gkf = GroupKFold(n_splits=5)
    models = []
    scores = []

    for train_idx, val_idx in gkf.split(X_train_scaled, y_train, groups=groups):
        X_tr, X_val = X_train_scaled[train_idx], X_train_scaled[val_idx]
        y_tr, y_val = y_train.iloc[train_idx], y_train.iloc[val_idx]

        model = create_nn_model(X_train.shape[1])

        early_stop = tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        )

        history = model.fit(
            X_tr, y_tr,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=[early_stop],
            verbose=0
        )

        pred = model.predict(X_val).flatten()
        score = smape(y_val, pred)

        models.append((model, scaler))
        scores.append(score)

    print(f'Average SMAPE: {np.mean(scores):.2f}')

    return models, scores
```

### Ensemble Template

```python
def ensemble_predictions(lgb_models, nn_models, X_test):
    """集成多个模型的预测"""
    # LightGBM 预测
    lgb_preds = np.mean([model.predict(X_test) for model in lgb_models], axis=0)

    # NN 预测（需要标准化）
    _, scaler = nn_models[0]
    X_test_scaled = scaler.transform(X_test)
    nn_preds = np.mean([
        model.predict(X_test_scaled).flatten()
        for model, _ in nn_models
    ], axis=0)

    # 简单平均
    final_pred = (lgb_preds + nn_preds) / 2

    return final_pred
```

---

## Best Practices

### 1. Data Understanding

**蛋白质数据特性**
- 227个蛋白质可能来自不同通路
- 部分蛋白质可能高度相关
- 需要探索蛋白质-疾病关系

**肽段数据特性**
- 肽数量远大于蛋白质数
- 多个肽段可能来自同一蛋白质
- 肽段丰度需要归一化

**临床数据特性**
- MDS-UPDRS 评分范围 0-260
- 不同子评分（第一部分到第四部分）
- 访问时间间隔不均匀

### 2. Feature Engineering Guidelines

**DOs**
- ✅ 创建患者级别的聚合特征
- ✅ 利用时间序列信息
- ✅ 探索蛋白质-肽段关系
- ✅ 考虑蛋白质生物学意义
- ✅ 使用领域知识构造特征

**DON'Ts**
- ❌ 在测试集上计算统计量
- ❌ 混合不同患者的未来信息
- ❌ 忽略数据的时间顺序
- ❌ 过度使用目标编码（容易泄露）

### 3. Model Selection Strategy

**推荐流程**
1. 从简单模型开始（线性模型、决策树）
2. 尝试 LightGBM（部分方案有效）
3. 探索神经网络（1st方案使用）
4. 集成多个模型
5. 针对性调整超参数

**模型选择考虑**
- 数据量小 → 简单模型或强正则化
- 特征多 → 特征选择或降维
- 时序特性 → 考虑时间序列模型
- 集成收益 → 尝试模型融合

### 4. Validation Strategy

**推荐方法**
```python
# 患者级别的 Group K-Fold
from sklearn.model_selection import GroupKFold

gkf = GroupKFold(n_splits=5)
for fold, (train_idx, val_idx) in enumerate(gkf.split(X, y, groups=patient_ids)):
    print(f'Fold {fold + 1}')
    # 训练和验证
```

**时间序列分割**
```python
from sklearn.model_selection import TimeSeriesSplit

tscv = TimeSeriesSplit(n_splits=5)
for fold, (train_idx, val_idx) in enumerate(tscv.split(X)):
    # 确保验证集在时间上晚于训练集
```

### 5. Common Pitfalls

**数据泄露**
- ❌ 将同一患者的多次访问分散到训练和验证集
- ❌ 在分割前计算全局统计量
- ❌ 使用未来信息预测过去

**过拟合**
- ❌ 特征过多而样本过少
- ❌ 过度调参导致验证集泄露
- ❌ 复杂模型在小数据集上

**评估偏差**
- ❌ 使用错误的评估指标
- ❌ 忽略 SMAPE 的对称性
- ❌ 不关注预测的分布特性

### 6. Domain Knowledge Integration

**帕金森病相关**
- MDS-UPDRS 评分的临床意义
- 蛋白质标志物的生物学作用
- 疾病进展的非线性特性

**蛋白质组学**
- 质谱数据的技术变异
- 蛋白质-肽段的定量关系
- 缺失值的含义

### 7. Hyperparameter Tuning

**LightGBM 关键参数**
```python
params = {
    'learning_rate': 0.01,      # 降低学习率
    'num_leaves': 31,           # 控制复杂度
    'max_depth': -1,            # 不限制深度
    'min_data_in_leaf': 20,     # 小数据集增大此值
    'feature_fraction': 0.8,    # 特征采样
    'bagging_fraction': 0.8,    # 数据采样
    'bagging_freq': 5,
    'lambda_l1': 0.1,           # L1 正则化
    'lambda_l2': 0.1,           # L2 正则化
}
```

**神经网络关键参数**
```python
# 小数据集推荐
hidden_units = [128, 64, 32]   # 减少层数和单元数
dropout_rate = 0.3              # 增加 dropout
l2_reg = 0.01                   # L2 正则化
learning_rate = 0.001           # 适中学习率
batch_size = 32                 # 小批量
```

---

## Key Takeaways

1. **小样本竞赛特点**
   - 特征工程比模型复杂度更重要
   - 避免过拟合是关键
   - 简单模型集成可能优于复杂单模型

2. **医疗数据特殊性**
   - 需要理解领域知识
   - 数据泄露风险更高
   - 评估指标的临床意义

3. **成功的共同点**
   - 仔细的特征工程
   - 严格的验证策略
   - 模型集成
   - 避免数据泄露

4. **需要注意的陷阱**
   - XGBoost/LightGBM 不是万能的（43rd方案发现）
   - 数据泄露容易但难以发现
   - 小样本的过拟合风险

5. **推荐的学习路径**
   - 从 1st, 2nd, 3rd 方案学习顶级思路
   - 从 5th, 9th 方案学习实用技巧
   - 从 43rd 方案学习失败经验
   - 综合多个方案形成自己的方法

---

## Resources

### Official Writeups
- [1st Place Solution - Connecting Dotts](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/connecting-dotts-1st-place-solution)
- [2nd Place Solution - No Luck, All Skill](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/no-luck-all-skill-2nd-place-solution)
- [3rd Place Solution - Hajime Tamura](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/hajime-tamura-3rd-place-solution)
- [5th Place Solution - Ambrosm](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/ambrosm-5-find-the-control-group)
- [9th Place Solution - Makotu](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/makotu-9th-place-solution)
- [13th Place Solution - FNOA](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/fnoa-13th-place-solution)
- [43rd Place Solution - Wojciech Victor Fulmyk](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/wojciech-victor-fulmyk-43rd-top-3-silver-medal-sol)
- [89th Place Solution - Giba (Non-Leaky)](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/writeups/giba-top-89-non-leaky-solution)

### External Resources
- [H2O.ai Blog: Navigating the Parkinson's Disease Prediction Challenge with AI](https://h2o.ai/blog/2023/winners-insight-navigating-the-parkinsons-disease-prediction-challenge-with-ai/)
- [中文复现: 小样本比赛也能有稳定区分度](https://zhuanlan.zhihu.com/p/669527953)

### Competition Pages
- [Main Competition Page](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction)
- [Data Description](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction/data)
- [Discussion Forum](https://www.kaggle.com/c/amp-parkinsons-disease-progression-prediction/discussion)

### Code Notebooks
- [LightGBM Starter with Added Features](https://www.kaggle.com/code/sijovm/lightgbm-starter-with-added-features)
- [XGB Baseline with Added Features](https://www.kaggle.com/code/sijovm/xgb-baseline-with-added-features)
- [AMP® - PDPP EDA + TF Model](https://www.kaggle.com/code/callmewenhao/amp-pdpp-eda-tf-model)
- [AMP® - PDPP EDA](https://www.kaggle.com/code/gunesevitan/amp-pdpp-eda)
