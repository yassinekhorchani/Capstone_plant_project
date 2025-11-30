package com.example.capstone_deepsea;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.capstone_deepsea/tflite";
    private TFLiteModelHelper modelHelper;
    
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("predictDisease")) {
                    try {
                        if (modelHelper == null) {
                            modelHelper = new TFLiteModelHelper(getAssets());
                        }
                        String imagePath = call.argument("imagePath");
                        Map<String, Object> prediction = modelHelper.predict(imagePath);
                        result.success(prediction);
                    } catch (Exception e) {
                        result.error("PREDICTION_ERROR", e.getMessage(), null);
                    }
                } else {
                    result.notImplemented();
                }
            });
    }
    
    @Override
    protected void onDestroy() {
        if (modelHelper != null) {
            modelHelper.close();
        }
        super.onDestroy();
    }
}
