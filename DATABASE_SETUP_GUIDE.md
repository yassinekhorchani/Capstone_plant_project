# Database Setup Guide for Plant Disease Detection App

This guide will help you set up **Firestore** for storing detection records and **Supabase** for storing plant images.

---

## Part 1: Firebase Firestore Setup

### Step 1: Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (the one you're already using for authentication)
3. Click on **"Firestore Database"** in the left sidebar
4. Click **"Create database"**
5. Choose **"Start in production mode"** (we'll add security rules next)
6. Select a location (choose the closest to your users, e.g., `us-central` or `europe-west`)
7. Click **"Enable"**

### Step 2: Set Up Firestore Security Rules

1. In the Firestore Database page, click on the **"Rules"** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Detections collection - users can only access their own detections
    match /detections/{detectionId} {
      // Allow users to read their own detections
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      
      // Allow users to create detections (will auto-add their userId)
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // Allow users to update their own detections
      allow update: if request.auth != null && 
                       resource.data.userId == request.auth.uid;
      
      // Allow users to delete their own detections
      allow delete: if request.auth != null && 
                       resource.data.userId == request.auth.uid;
    }
    
    // Deny all other access by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"**

### Step 3: Create Firestore Index (Optional but Recommended)

1. Go to the **"Indexes"** tab in Firestore
2. Click **"Create Index"**
3. Configure the index:
   - Collection ID: `detections`
   - Fields to index:
     - `userId` - Ascending
     - `timestamp` - Descending
4. Click **"Create"**

This will make queries faster when fetching user detection history.

---

## Part 2: Supabase Setup

### Step 1: Create a Supabase Project

1. Go to [Supabase](https://supabase.com/)
2. Click **"Start your project"** or **"New project"**
3. Sign in with GitHub (or create an account)
4. Click **"New project"**
5. Fill in the details:
   - **Project name**: `plant-disease-detection` (or any name you prefer)
   - **Database Password**: Create a strong password (save it somewhere safe!)
   - **Region**: Choose the closest to your users
   - **Pricing Plan**: Free (sufficient for development)
6. Click **"Create new project"**
7. Wait for the project to be provisioned (takes 1-2 minutes)

### Step 2: Create Storage Bucket for Plant Images

1. In your Supabase project dashboard, click **"Storage"** in the left sidebar
2. Click **"Create a new bucket"**
3. Configure the bucket:
   - **Name**: `plant-images`
   - **Public bucket**: Toggle **ON** (so images can be viewed publicly)
4. Click **"Create bucket"**

### Step 3: Set Up Storage Policies

1. Click on the `plant-images` bucket
2. Click on **"Policies"** tab
3. Click **"New Policy"** and create the following policies:

#### Policy 1: Allow Authenticated Users to Upload Images

Click **"Create a policy from scratch"** and configure:

- **Policy name**: `Allow authenticated uploads`
- **Allowed operation**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition**:

```sql
(bucket_id = 'plant-images'::text)
```

#### Policy 2: Allow Public Read Access

Click **"New Policy"** → **"Create a policy from scratch"**:

- **Policy name**: `Allow public downloads`
- **Allowed operation**: `SELECT`
- **Target roles**: `public`
- **Policy definition**:

```sql
(bucket_id = 'plant-images'::text)
```

#### Policy 3: Allow Users to Delete Their Own Images

Click **"New Policy"** → **"Create a policy from scratch"**:

- **Policy name**: `Allow authenticated deletes`
- **Allowed operation**: `DELETE`
- **Target roles**: `authenticated`
- **Policy definition**:

```sql
(bucket_id = 'plant-images'::text)
```

### Step 4: Get Supabase Credentials

1. In your Supabase project, click **"Settings"** (gear icon in left sidebar)
2. Click **"API"** in the settings menu
3. Copy the following values:

   - **Project URL** (under "Project URL")
   - **anon/public key** (under "Project API keys")

### Step 5: Update Flutter App with Supabase Credentials

1. Open the file: `lib/services/supabase_service.dart`
2. Replace the placeholder values:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';  // Paste your Project URL
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';  // Paste your anon key
```

**Example:**
```dart
static const String supabaseUrl = 'https://abcdefghijk.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## Part 3: Update Flutter Dependencies

Run the following command in your project directory:

```powershell
cd C:\Users\borhe\Capstone_plant_project\capstone_deepsea
flutter pub get
```

This will install the `cloud_firestore` package that was added to `pubspec.yaml`.

---

## Part 4: Test the Integration

### Test Detection Saving

1. Run your Flutter app:
   ```powershell
   flutter run -d R5CY42QYAZF
   ```

2. Log in to the app
3. Take a photo of a plant or upload from gallery
4. Wait for the detection result
5. You should see a snackbar message: **"Detection saved to history"**

### Verify in Firebase Console

1. Go to Firebase Console → Firestore Database
2. You should see a `detections` collection
3. Click on it to see your detection records with fields:
   - `userId`
   - `plantType`
   - `condition`
   - `isHealthy`
   - `confidence`
   - `imageUrl`
   - `timestamp`

### Verify in Supabase Console

1. Go to Supabase Dashboard → Storage → `plant-images` bucket
2. Navigate to the `detections` folder
3. You should see uploaded images named like: `userId_timestamp.jpg`
4. Click on any image to view it

---

## Part 5: Firestore Data Structure

Each detection record in Firestore has the following structure:

```javascript
{
  "userId": "firebase_user_uid",
  "plantType": "Tomato",
  "condition": "Early Blight",
  "isHealthy": false,
  "confidence": 0.95,
  "imageUrl": "https://xyz.supabase.co/storage/v1/object/public/plant-images/detections/user_123_timestamp.jpg",
  "timestamp": Timestamp(seconds=1700000000, nanoseconds=0)
}
```

---

## Security Notes

✅ **Firestore Rules**: Users can only read/write their own detection records
✅ **Supabase Policies**: Only authenticated users can upload images
✅ **Public Images**: Images are publicly accessible via URL (needed for displaying in app)
⚠️ **API Keys**: The Supabase anon key is safe to use in client-side code (it's designed for this)

---

## Troubleshooting

### Issue: "User not authenticated" error
**Solution**: Make sure the user is logged in before scanning a plant. Check `FirebaseAuth.instance.currentUser`.

### Issue: Firestore permission denied
**Solution**: 
1. Verify your Firestore security rules are correctly set up
2. Make sure the user is authenticated
3. Check that `userId` field matches the authenticated user's UID

### Issue: Supabase upload fails (401 Unauthorized)
**Solution**:
1. Verify you've created the storage bucket named `plant-images`
2. Check that storage policies are correctly configured
3. Ensure you've copied the correct anon key

### Issue: Supabase upload fails (404 Not Found)
**Solution**:
1. Make sure the bucket name in the code matches the bucket in Supabase
2. Verify the Supabase URL is correct (should end with `.supabase.co`)

### Issue: Images not displaying
**Solution**:
1. Make sure the bucket is set to **public**
2. Check that the "Allow public downloads" policy is created
3. Verify the image URL format is correct

---

## Next Steps

Once everything is working, you can:

1. **View Detection History**: Create a screen to display all user detections from Firestore
2. **Add Statistics**: Show charts of healthy vs diseased plants
3. **Image Gallery**: Display all scanned images from Supabase
4. **Export Data**: Allow users to download their detection history
5. **Admin Dashboard**: View all detections across all users (requires admin role)

---

## Cost Considerations

### Firebase (Free Tier - Spark Plan)
- **Firestore**: 1 GB storage, 50K reads/day, 20K writes/day, 20K deletes/day
- **Sufficient for**: Thousands of detections per day

### Supabase (Free Tier)
- **Storage**: 1 GB
- **Bandwidth**: 2 GB/month
- **Sufficient for**: ~1000 image uploads (assuming 1 MB per image)

Both services have generous free tiers that should be sufficient for development and moderate usage.

---

## Support

If you encounter any issues:
1. Check the browser console in Firebase/Supabase dashboards
2. Check Flutter app logs using `flutter logs`
3. Verify all credentials are correctly copied
4. Ensure you're using the latest versions of packages

**Happy coding! 🌱**
