# PlantVillage Model Retraining Guide - TensorFlow 2.14

## Problem Summary
Your current model (`my_model_quantized_fixed.tflite`) loads successfully but gives random predictions because:
- Original model was trained with TensorFlow 2.18 + Keras 3.x
- Conversion to TFLite using TF 2.13 caused weight shape mismatch
- Dense layer expected shape `(2048, 38)` but received `(2048, 1024)`
- Result: All predictions show "Pepper bell healthy" with 2.63% confidence

## Solution: Retrain with TensorFlow 2.14
This ensures complete compatibility with your Android TFLite library (v2.14.0)

---

## 📋 Prerequisites

### 1. Download PlantVillage Dataset
- **Source**: https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset
- **What to download**: The entire dataset (download ZIP file)
- **Extract to**: `C:\Users\borhe\Downloads\plantvillage\`
- **You need**: The `color` folder inside the extracted files

### 2. Verify Dataset Structure
After extraction, you should have:
```
C:\Users\borhe\Downloads\plantvillage\
└── color\
    ├── Pepper__bell___Bacterial_spot\
    ├── Pepper__bell___healthy\
    ├── Potato___Early_blight\
    ├── Potato___healthy\
    ├── Potato___Late_blight\
    └── ... (38 classes total)
```

---

## 🚀 Step-by-Step Instructions

### Step 1: Setup TensorFlow 2.14 Environment
```powershell
# Run the setup script
.\setup_tf214_env.ps1

# This will:
# - Create virtual environment (venv_tf214)
# - Install TensorFlow 2.14.0
# - Install compatible Keras 2.14.0 (bundled with TF)
# - Install numpy, scikit-learn, Pillow
# - Verify installation
```

**Expected output:**
```
TensorFlow: 2.14.0
Keras: 2.14.0
```

---

### Step 2: Train the Model
```powershell
# Make sure you're in venv_tf214
.\venv_tf214\Scripts\Activate.ps1

# Run training script
python retrain_model_tf214.py
```

**What happens:**
1. You'll be prompted for dataset path (or press Enter for default)
2. Script splits dataset: 80% train, 10% test, 10% validation
3. Builds EfficientNetB5 model with custom layers:
   - Base: EfficientNetB5 (pretrained on ImageNet)
   - Dense(1024) + Dropout(0.5)
   - Dense(512) + Dropout(0.3)
   - Dense(38, softmax) ← **This is the fix!**
4. Trains for 10 epochs with early stopping
5. Saves best model as `plant_model_tf214.keras`

**Training time:** ~30-60 minutes (depending on your GPU/CPU)

**Expected accuracy:** ~95%+ (based on your original notebook results)

---

### Step 3: Convert to TFLite
```powershell
# Convert the trained model to TFLite format
python convert_to_tflite_tf214.py
```

**What happens:**
1. Loads `plant_model_tf214.keras`
2. Converts to TFLite with quantization
3. Saves as `my_model_tf214.tflite`
4. Tests the model to verify output shape is `[1, 38]`

**Expected output:**
```
✅ TFLite model saved: my_model_tf214.tflite
   File size: ~30 MB
   Output shape: (1, 38)
   Predicted class: [random number 0-37]
   Confidence: [meaningful percentage, not always 2.63%]
```

---

### Step 4: Deploy to Flutter App

#### A. Copy Model Files
```powershell
# Copy TFLite model to Flutter assets
Copy-Item my_model_tf214.tflite capstone_deepsea\assets\
Copy-Item my_model_tf214.tflite capstone_deepsea\android\app\src\main\assets\

# Copy class names
Copy-Item class_names_new.txt capstone_deepsea\assets\class_names.txt
Copy-Item class_names_new.txt capstone_deepsea\android\app\src\main\assets\class_names.txt
```

#### B. Update Java Code
Edit `capstone_deepsea\android\app\src\main\java\com\example\capstone_deepsea\TFLiteModelHelper.java`:

**Line 28:** Change from:
```java
private static final String MODEL_FILE_NAME = "my_model_quantized_fixed.tflite";
```

To:
```java
private static final String MODEL_FILE_NAME = "my_model_tf214.tflite";
```

#### C. Clean and Run
```powershell
cd capstone_deepsea
flutter clean
flutter run -d R5CY42QYAZF
```

---

## ✅ Verification

### Test with Different Images
1. Upload a healthy pepper leaf → Should predict "Pepper bell healthy" with HIGH confidence (>90%)
2. Upload a diseased tomato leaf → Should predict correct disease with HIGH confidence
3. Upload your photo → Should give LOW confidence or predict based on colors (expected behavior)

### Success Indicators
- ✅ Each image gives DIFFERENT predictions
- ✅ Confidence scores vary (not always 2.63%)
- ✅ Plant disease images show HIGH confidence (>80%)
- ✅ No "Cannot copy tensor" errors

---

## 📊 Expected Results

| Test Image | Expected Prediction | Confidence |
|------------|-------------------|------------|
| Healthy pepper leaf | Pepper__bell___healthy | >95% |
| Diseased tomato leaf | Tomato___[disease_name] | >90% |
| Random plant | Best matching class | 50-80% |
| Non-plant (your photo) | Random class | <30% |

---

## 🔧 Troubleshooting

### Issue: "Dataset path does not exist"
**Solution:** 
1. Download PlantVillage dataset from Kaggle
2. Extract to `C:\Users\borhe\Downloads\plantvillage\`
3. Run training script again and enter correct path when prompted

### Issue: "Out of memory during training"
**Solution:** 
1. Reduce `BATCH_SIZE` from 32 to 16 or 8 in `retrain_model_tf214.py`
2. Close other applications
3. Restart training

### Issue: "Model still gives random predictions after deployment"
**Solution:**
1. Verify you copied `my_model_tf214.tflite` (not the old model)
2. Verify `class_names.txt` has exactly 38 lines
3. Run `flutter clean` before `flutter run`

---

## 📝 Files Created

| File | Purpose |
|------|---------|
| `setup_tf214_env.ps1` | Create TF 2.14 environment |
| `requirements_tf214.txt` | Python dependencies |
| `retrain_model_tf214.py` | Training script |
| `convert_to_tflite_tf214.py` | TFLite conversion |
| `plant_model_tf214.keras` | Trained model (output) |
| `my_model_tf214.tflite` | TFLite model (output) |
| `class_names_new.txt` | Class labels (output) |

---

## 🎯 Why This Works

1. **TensorFlow 2.14.0** includes **Keras 2.14.0** (not Keras 3.x)
2. **No version mismatch** during training → saving → conversion
3. **Proper weight shapes**: Dense layer is correctly sized as `(2048, 38)`
4. **Compatible operators**: TFLite converter uses operators supported by Android library v2.14.0
5. **Quantization**: Model is optimized for mobile deployment

---

## 🆘 Need Help?

If you encounter issues:
1. Check TensorFlow version: `python -c "import tensorflow as tf; print(tf.__version__)"`
2. Should show: `2.14.0`
3. Check Keras version: `python -c "import tensorflow as tf; print(tf.keras.__version__)"`
4. Should show: `2.14.0` (NOT 3.x.x)

---

## ⏱️ Time Estimate

- Setup environment: 5-10 minutes
- Download dataset: 10-15 minutes (depends on internet speed)
- Train model: 30-60 minutes (depends on hardware)
- Convert to TFLite: 1-2 minutes
- Deploy to Flutter: 5 minutes
- **Total: ~1-1.5 hours**

---

**Ready to start?** Run: `.\setup_tf214_env.ps1`
