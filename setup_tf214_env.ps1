# Setup TensorFlow 2.14 Environment for Model Retraining
# Run this script to create a clean environment and install dependencies

Write-Host "=" -NoNewline -ForegroundColor Cyan; Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "  TensorFlow 2.14 Environment Setup for PlantVillage Model" -ForegroundColor Cyan
Write-Host "=" -NoNewline -ForegroundColor Cyan; Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host ""

# Step 1: Create virtual environment
Write-Host "📦 Step 1: Creating virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv_tf214") {
    Write-Host "   ⚠️  venv_tf214 already exists. Removing..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv_tf214
}
python -m venv venv_tf214
Write-Host "   ✅ Virtual environment created" -ForegroundColor Green
Write-Host ""

# Step 2: Activate virtual environment
Write-Host "🔌 Step 2: Activating virtual environment..." -ForegroundColor Yellow
& .\venv_tf214\Scripts\Activate.ps1
Write-Host "   ✅ Virtual environment activated" -ForegroundColor Green
Write-Host ""

# Step 3: Upgrade pip
Write-Host "⬆️  Step 3: Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
Write-Host "   ✅ Pip upgraded" -ForegroundColor Green
Write-Host ""

# Step 4: Uninstall any existing Keras 3.x (if present)
Write-Host "🧹 Step 4: Removing any Keras 3.x installations..." -ForegroundColor Yellow
pip uninstall -y keras keras-nightly 2>$null
Write-Host "   ✅ Keras cleaned" -ForegroundColor Green
Write-Host ""

# Step 5: Install TensorFlow 2.14 and dependencies
Write-Host "📥 Step 5: Installing TensorFlow 2.14 and dependencies..." -ForegroundColor Yellow
Write-Host "   (This may take several minutes...)" -ForegroundColor Gray
pip install -r requirements_tf214.txt --quiet
Write-Host "   ✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 6: Verify installation
Write-Host "🔍 Step 6: Verifying installation..." -ForegroundColor Yellow
python -c "import tensorflow as tf; print(f'   TensorFlow: {tf.__version__}'); print(f'   Keras: {tf.keras.__version__}')"
Write-Host "   ✅ Installation verified" -ForegroundColor Green
Write-Host ""

Write-Host "=" -NoNewline -ForegroundColor Green; Write-Host ("=" * 59) -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=" -NoNewline -ForegroundColor Green; Write-Host ("=" * 59) -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Download PlantVillage dataset from:" -ForegroundColor White
Write-Host "   https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Run training script:" -ForegroundColor White
Write-Host "   python retrain_model_tf214.py" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Convert to TFLite:" -ForegroundColor White
Write-Host "   python convert_to_tflite_tf214.py" -ForegroundColor Gray
Write-Host ""
