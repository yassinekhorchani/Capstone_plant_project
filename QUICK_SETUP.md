# Quick Setup Checklist

## ✅ What I've Done

1. **Created Firestore Service** (`lib/services/firestore_service.dart`)
   - Saves detection results to Firestore
   - Retrieves user detection history
   - Gets detection statistics

2. **Created Supabase Service** (`lib/services/supabase_service.dart`)
   - Uploads plant images to Supabase Storage
   - Deletes images
   - Lists user images

3. **Updated Detection Screen** (`lib/screens/detection_screen.dart`)
   - Automatically saves detection results after ML prediction
   - Uploads image to Supabase
   - Saves metadata to Firestore
   - Shows success message

4. **Added Dependencies** (`pubspec.yaml`)
   - Added `cloud_firestore: ^5.4.4`

---

## 📋 What You Need to Do

### 1. Firebase Console (5 minutes)
- [ ] Go to Firebase Console
- [ ] Enable Firestore Database
- [ ] Set up security rules (copy from guide)
- [ ] Create index for faster queries

### 2. Supabase Console (5 minutes)
- [ ] Create Supabase account/project
- [ ] Create storage bucket named `plant-images`
- [ ] Make bucket public
- [ ] Set up 3 storage policies (insert, select, delete)
- [ ] Copy Project URL and anon key

### 3. Update Code (1 minute)
- [ ] Open `lib/services/supabase_service.dart`
- [ ] Replace `YOUR_SUPABASE_URL` with your actual URL
- [ ] Replace `YOUR_SUPABASE_ANON_KEY` with your actual key

### 4. Install Dependencies (1 minute)
Run in terminal:
```powershell
flutter pub get
```

### 5. Test It (2 minutes)
- [ ] Run the app
- [ ] Login
- [ ] Scan a plant
- [ ] Check for "Detection saved to history" message
- [ ] Verify in Firebase Console → Firestore
- [ ] Verify in Supabase Console → Storage

---

## 📂 Data Flow

```
User scans plant
    ↓
ML Model analyzes image
    ↓
[Detection Screen shows result]
    ↓
Image uploaded to Supabase → Get image URL
    ↓
Save to Firestore:
  - userId
  - plantType
  - condition
  - isHealthy
  - confidence
  - imageUrl (from Supabase)
  - timestamp
```

---

## 🔧 Files Modified/Created

**New Files:**
- `lib/services/firestore_service.dart`
- `lib/services/supabase_service.dart`
- `DATABASE_SETUP_GUIDE.md`
- `QUICK_SETUP.md` (this file)

**Modified Files:**
- `lib/screens/detection_screen.dart`
- `pubspec.yaml`

---

## 🎯 Next Features You Can Add

Once the setup is complete, you can add:

1. **Detection History Screen**
   ```dart
   // Get user's detections
   final detections = await _firestoreService.getUserDetections();
   ```

2. **Statistics Dashboard**
   ```dart
   // Get stats
   final stats = await _firestoreService.getDetectionStats();
   // Shows: total detections, healthy vs diseased
   ```

3. **Delete Detection**
   ```dart
   await _firestoreService.deleteDetection(detectionId);
   await _supabaseService.deleteImage(imageUrl);
   ```

---

## 📖 Full Details

See `DATABASE_SETUP_GUIDE.md` for:
- Step-by-step screenshots
- Security rules explanation
- Troubleshooting tips
- Cost estimates

---

**Need Help?** Check the troubleshooting section in DATABASE_SETUP_GUIDE.md
