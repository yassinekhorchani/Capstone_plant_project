package com.example.capstone_deepsea;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import org.tensorflow.lite.Interpreter;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TFLiteModelHelper {
    private Interpreter interpreter;
    private List<String> classNames;
    private static final int INPUT_SIZE = 224;
    
    public TFLiteModelHelper(AssetManager assetManager) throws IOException {
        // Load model
        MappedByteBuffer modelBuffer = loadModelFile(assetManager, "plant_disease_model.tflite");
        interpreter = new Interpreter(modelBuffer);
        
        // Load class names
        classNames = loadClassNames(assetManager, "plant_labels.txt");
    }
    
    private MappedByteBuffer loadModelFile(AssetManager assetManager, String modelPath) throws IOException {
        AssetFileDescriptor fileDescriptor = assetManager.openFd(modelPath);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }
    
    private List<String> loadClassNames(AssetManager assetManager, String fileName) throws IOException {
        List<String> names = new ArrayList<>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(assetManager.open(fileName)));
        String line;
        while ((line = reader.readLine()) != null) {
            names.add(line.trim());
        }
        reader.close();
        return names;
    }
    
    public Map<String, Object> predict(String imagePath) throws IOException {
        // Load and preprocess image
        Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
        Bitmap resizedBitmap = Bitmap.createScaledBitmap(bitmap, INPUT_SIZE, INPUT_SIZE, true);
        
        // Convert to ByteBuffer
        ByteBuffer inputBuffer = ByteBuffer.allocateDirect(4 * INPUT_SIZE * INPUT_SIZE * 3);
        inputBuffer.order(ByteOrder.nativeOrder());
        
        int[] pixels = new int[INPUT_SIZE * INPUT_SIZE];
        resizedBitmap.getPixels(pixels, 0, INPUT_SIZE, 0, 0, INPUT_SIZE, INPUT_SIZE);
        
        for (int pixel : pixels) {
            inputBuffer.putFloat(((pixel >> 16) & 0xFF) / 255.0f); // R
            inputBuffer.putFloat(((pixel >> 8) & 0xFF) / 255.0f);  // G
            inputBuffer.putFloat((pixel & 0xFF) / 255.0f);         // B
        }
        
        // Run inference
        float[][] output = new float[1][classNames.size()];
        interpreter.run(inputBuffer, output);
        
        // Find top predictions
        int topIndex = 0;
        float topConfidence = output[0][0];
        for (int i = 1; i < output[0].length; i++) {
            if (output[0][i] > topConfidence) {
                topConfidence = output[0][i];
                topIndex = i;
            }
        }
        
        // Parse disease label
        String diseaseLabel = classNames.get(topIndex).trim();
        
        String plantType;
        String condition;
        boolean isHealthy = diseaseLabel.toLowerCase().contains("healthy");
        
        if (isHealthy) {
            // For healthy plants: extract plant name only
            // Example: "corn maize healthy" -> plantType="Corn Maize", condition="Healthy"
            condition = "Healthy";
            plantType = diseaseLabel.toLowerCase().replace("healthy", "").trim();
        } else {
            // For diseased plants: split into plant name and disease
            // Example: "tomato bacterial spot" -> plantType="Tomato", condition="Bacterial Spot"
            String[] words = diseaseLabel.split(" ");
            
            // First word(s) are plant type, rest is disease
            // Handle multi-word plant names like "corn maize", "cherry including sour"
            if (diseaseLabel.startsWith("corn maize")) {
                plantType = "corn maize";
                condition = diseaseLabel.substring(10).trim();
            } else if (diseaseLabel.startsWith("cherry including sour")) {
                plantType = "cherry";
                condition = diseaseLabel.substring(21).trim();
            } else if (diseaseLabel.startsWith("pepper bell")) {
                plantType = "pepper bell";
                condition = diseaseLabel.substring(11).trim();
            } else {
                // Single word plant name
                plantType = words[0];
                StringBuilder conditionBuilder = new StringBuilder();
                for (int i = 1; i < words.length; i++) {
                    if (i > 1) conditionBuilder.append(" ");
                    conditionBuilder.append(words[i]);
                }
                condition = conditionBuilder.toString();
            }
        }
        
        // Capitalize first letter of each word
        plantType = capitalizeWords(plantType);
        condition = capitalizeWords(condition);
        
        // Return result
        Map<String, Object> result = new HashMap<>();
        result.put("plantType", plantType);
        result.put("condition", condition);
        result.put("isHealthy", isHealthy);
        result.put("confidence", topConfidence);
        result.put("success", true);
        
        return result;
    }
    
    private String capitalizeWords(String str) {
        if (str == null || str.isEmpty()) return str;
        
        String[] words = str.split(" ");
        StringBuilder result = new StringBuilder();
        
        for (int i = 0; i < words.length; i++) {
            if (i > 0) result.append(" ");
            String word = words[i];
            if (word.length() > 0) {
                result.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    result.append(word.substring(1).toLowerCase());
                }
            }
        }
        
        return result.toString();
    }
    
    public void close() {
        if (interpreter != null) {
            interpreter.close();
        }
    }
}
