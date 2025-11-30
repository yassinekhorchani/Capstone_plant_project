"""
Retrain PlantVillage Model with TensorFlow 2.14
This script creates a compatible model for TFLite conversion
"""

import os
import numpy as np
import shutil
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow.keras.applications import EfficientNetB5
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
from tensorflow.keras.regularizers import l2

print(f"TensorFlow version: {tf.__version__}")
print(f"Keras version: {tf.keras.__version__}")

# Configuration
IMG_HEIGHT, IMG_WIDTH = 224, 224
BATCH_SIZE = 32
EPOCHS = 10
LEARNING_RATE = 0.0001

# Dataset path - MODIFY THIS to point to your PlantVillage dataset
# Download from: https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset
DATA_PATH = input("Enter the path to PlantVillage 'color' folder (or press Enter to use default): ").strip()
if not DATA_PATH:
    DATA_PATH = 'C:/Users/borhe/Downloads/plantvillage/color'  # Default path
    print(f"Using default path: {DATA_PATH}")

if not os.path.exists(DATA_PATH):
    print(f"\n❌ ERROR: Dataset path does not exist: {DATA_PATH}")
    print("\nPlease download PlantVillage dataset from:")
    print("https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset")
    print("\nExtract it and provide the path to the 'color' folder.")
    exit(1)

# Create working directories
BASE_DIR = 'plantvillage_split'
TRAIN_DIR = os.path.join(BASE_DIR, 'train')
TEST_DIR = os.path.join(BASE_DIR, 'test')
VAL_DIR = os.path.join(BASE_DIR, 'val')

print("\n📁 Preparing dataset directories...")
for directory in [TRAIN_DIR, TEST_DIR, VAL_DIR]:
    os.makedirs(directory, exist_ok=True)

# Collect all image files
print("📸 Collecting image files...")
image_files = []
for root, dirs, files in os.walk(DATA_PATH):
    for file in files:
        if file.lower().endswith(('.jpg', '.jpeg', '.png')):
            image_files.append(os.path.join(root, file))

print(f"Found {len(image_files)} images")

# Shuffle and split dataset
np.random.seed(42)
np.random.shuffle(image_files)

train_size = int(len(image_files) * 0.8)
test_size = int(len(image_files) * 0.1)

train_files = image_files[:train_size]
test_files = image_files[train_size:train_size + test_size]
val_files = image_files[train_size + test_size:]

print(f"Training samples: {len(train_files)}")
print(f"Testing samples: {len(test_files)}")
print(f"Validation samples: {len(val_files)}")

# Copy files to split directories
def copy_files(file_list, dest_dir):
    print(f"  Copying files to {dest_dir}...")
    for f in file_list:
        class_name = os.path.basename(os.path.dirname(f))
        class_dir = os.path.join(dest_dir, class_name)
        os.makedirs(class_dir, exist_ok=True)
        dest_path = os.path.join(class_dir, os.path.basename(f))
        if not os.path.exists(dest_path):
            shutil.copy2(f, dest_path)

print("\n📋 Copying files to split directories...")
copy_files(train_files, TRAIN_DIR)
copy_files(test_files, TEST_DIR)
copy_files(val_files, VAL_DIR)

# Data generators with augmentation
print("\n🔄 Setting up data generators...")
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest'
)

val_datagen = ImageDataGenerator(rescale=1./255)
test_datagen = ImageDataGenerator(rescale=1./255)

train_generator = train_datagen.flow_from_directory(
    TRAIN_DIR,
    target_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=True
)

val_generator = val_datagen.flow_from_directory(
    VAL_DIR,
    target_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=False
)

test_generator = test_datagen.flow_from_directory(
    TEST_DIR,
    target_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=False
)

num_classes = train_generator.num_classes
print(f"Number of classes: {num_classes}")

# Save class names
class_names = sorted(list(train_generator.class_indices.keys()))
with open('class_names_new.txt', 'w') as f:
    for class_name in class_names:
        f.write(f"{class_name}\n")
print(f"✅ Class names saved to class_names_new.txt")

# Clear TensorFlow session
print("\n🧹 Clearing TensorFlow session...")
tf.keras.backend.clear_session()

# Build model
print("\n🏗️ Building EfficientNetB5 model...")
base_model = EfficientNetB5(
    weights='imagenet',
    include_top=False,
    input_shape=(IMG_HEIGHT, IMG_WIDTH, 3),
    pooling='max'
)

# Add custom layers
x = base_model.output
x = Dense(1024, activation='relu', kernel_regularizer=l2(0.001))(x)
x = Dropout(0.5)(x)
x = Dense(512, activation='relu', kernel_regularizer=l2(0.001))(x)
x = Dropout(0.3)(x)
predictions = Dense(num_classes, activation='softmax')(x)

# Create final model
model = Model(inputs=base_model.input, outputs=predictions)

# Compile model
print("⚙️ Compiling model...")
model.compile(
    optimizer=Adam(learning_rate=LEARNING_RATE),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

print("\n📊 Model Summary:")
model.summary()

# Callbacks
early_stopping = EarlyStopping(
    monitor='val_loss',
    patience=3,
    restore_best_weights=True,
    verbose=1
)

checkpoint = ModelCheckpoint(
    'best_model_tf214.keras',
    monitor='val_loss',
    save_best_only=True,
    verbose=1
)

# Train model
print(f"\n🚀 Starting training for {EPOCHS} epochs...")
print("=" * 60)
history = model.fit(
    train_generator,
    epochs=EPOCHS,
    validation_data=val_generator,
    callbacks=[early_stopping, checkpoint],
    verbose=1
)

# Evaluate on test set
print("\n📈 Evaluating model on test set...")
loss, accuracy = model.evaluate(test_generator, verbose=1)
print(f"\n✅ Test Loss: {loss:.4f}")
print(f"✅ Test Accuracy: {accuracy * 100:.2f}%")

# Save final model
print("\n💾 Saving final model...")
model.save('plant_model_tf214.keras')
print("✅ Model saved as plant_model_tf214.keras")

# Also save as H5 format for compatibility
model.save('plant_model_tf214.h5')
print("✅ Model saved as plant_model_tf214.h5")

print("\n" + "=" * 60)
print("✅ TRAINING COMPLETE!")
print("=" * 60)
print(f"\nNext steps:")
print("1. Run: python convert_to_tflite_tf214.py")
print("2. This will convert the model to TFLite format")
print("3. Then replace the model in your Flutter app")
