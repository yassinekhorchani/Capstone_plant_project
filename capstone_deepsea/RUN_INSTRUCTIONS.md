# How to Run the App with Gemini API

The app requires a Google Gemini API key to provide AI-powered plant care advice.

## Setup

1. **Get your API key:**
   - Visit https://aistudio.google.com/app/apikey
   - Click "Create API key"
   - Copy your key (starts with `AIza...`)

2. **Run the app with your API key:**

### On Windows (PowerShell):
```powershell
cd capstone_deepsea
flutter run -d YOUR_DEVICE_ID --dart-define=GEMINI_API_KEY=AIzaSyDI5MjEpO_17zz4AlxwmBT_pS0Md6v9zB0
```

### On macOS/Linux:
```bash
cd capstone_deepsea
flutter run -d YOUR_DEVICE_ID --dart-define=GEMINI_API_KEY=AIzaSyDI5MjEpO_17zz4AlxwmBT_pS0Md6v9zB0
```

Replace `AIzaSyDI5MjEpO_17zz4AlxwmBT_pS0Md6v9zB0` with your actual API key.

## For Your Device

Your device ID is: `R5CY42QYAZF`

**Quick command to run:**
```powershell
cd capstone_deepsea; flutter run -d R5CY42QYAZF --dart-define=GEMINI_API_KEY=AIzaSyDI5MjEpO_17zz4AlxwmBT_pS0Md6v9zB0
```

## Security Note

⚠️ **Never commit your API key to Git!** The `.env.example` file is for reference only. Your actual key should only be passed via the `--dart-define` flag.

## Troubleshooting

If you get "GEMINI_API_KEY not found" error:
- Make sure you're using the `--dart-define=GEMINI_API_KEY=your_key` flag
- Check that your API key is valid at https://aistudio.google.com/app/apikey
- Ensure there are no spaces in the command

## Model Information

The app uses `gemini-1.5-flash-latest` which is:
- ✅ Compatible with the free tier
- ✅ Works with google_generative_ai package v0.4.7
- ✅ Supports text generation via v1beta API
