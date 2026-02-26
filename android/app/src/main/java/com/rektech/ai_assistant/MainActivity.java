package com.rektech.ai_assistant;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rektech.ai_assistant/speech";
    private static final int PERMISSION_REQUEST_CODE = 100;
    private MethodChannel.Result pendingResult;
    private SpeechRecognizer speechRecognizer;
    private boolean isListening = false;
    private String lastPartialResult = "";
    private Handler timeoutHandler = new Handler(Looper.getMainLooper());
    private Runnable timeoutRunnable;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startSpeechRecognition")) {
                    pendingResult = result;
                    checkPermissionAndStart();
                } else if (call.method.equals("stopSpeechRecognition")) {
                    stopSpeechRecognition();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            });
    }

    private void checkPermissionAndStart() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, 
                new String[]{Manifest.permission.RECORD_AUDIO}, 
                PERMISSION_REQUEST_CODE);
        } else {
            startBackgroundSpeechRecognition();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, 
                                          @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startBackgroundSpeechRecognition();
            } else {
                if (pendingResult != null) {
                    pendingResult.error("PERMISSION_DENIED", "Microphone permission denied", null);
                    pendingResult = null;
                }
            }
        }
    }

    private void startBackgroundSpeechRecognition() {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            if (pendingResult != null) {
                pendingResult.error("UNAVAILABLE", "Speech recognition not available", null);
                pendingResult = null;
            }
            return;
        }

        // CRITICAL FIX: Don't start if already listening
        if (isListening && speechRecognizer != null) {
            System.out.println("⚠️ Already listening - skipping new recognition request");
            if (pendingResult != null) {
                pendingResult.success("");
                pendingResult = null;
            }
            return;
        }

        // Stop any existing recognition before creating new one
        if (speechRecognizer != null) {
            try {
                speechRecognizer.stopListening();
                speechRecognizer.destroy();
                // Give the service time to cleanup before creating new recognizer
                Thread.sleep(500);
            } catch (Exception e) {
                System.out.println("⚠️ Error stopping previous recognizer: " + e.getMessage());
            }
        }

        // Clear previous partial result
        lastPartialResult = "";

        // Create new speech recognizer
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this);

        // Set recognition listener
        speechRecognizer.setRecognitionListener(new RecognitionListener() {
            @Override
            public void onReadyForSpeech(Bundle params) {
                isListening = true;
                System.out.println("🎤 Ready for speech - Start speaking now!");
                
                // Set timeout for 5 seconds (reduced from 10 for faster response)
                timeoutRunnable = () -> {
                    if (isListening) {
                        System.out.println("⏱️ Timeout - stopping recognition");
                        stopSpeechRecognition();
                        if (pendingResult != null) {
                            if (!lastPartialResult.isEmpty()) {
                                pendingResult.success(lastPartialResult);
                            } else {
                                pendingResult.success("");
                            }
                            pendingResult = null;
                        }
                    }
                };
                timeoutHandler.postDelayed(timeoutRunnable, 5000);
            }

            @Override
            public void onBeginningOfSpeech() {
                System.out.println("🎤 Speech detected - listening...");
            }

            @Override
            public void onRmsChanged(float rmsdB) {
                // Audio level - can show visual feedback
            }

            @Override
            public void onBufferReceived(byte[] buffer) {
                // Audio buffer received
            }

            @Override
            public void onEndOfSpeech() {
                isListening = false;
                timeoutHandler.removeCallbacks(timeoutRunnable);
                System.out.println("🎤 Speech ended - processing...");
            }

            @Override
            public void onError(int error) {
                isListening = false;
                timeoutHandler.removeCallbacks(timeoutRunnable);
                String errorMessage = getErrorText(error);
                System.out.println("❌ Speech error: " + errorMessage + " (code: " + error + ")");
                
                if (pendingResult != null) {
                    // If we have partial result, use it
                    if (!lastPartialResult.isEmpty()) {
                        System.out.println("✅ Using last partial result: " + lastPartialResult);
                        pendingResult.success(lastPartialResult);
                    } else {
                        // Return empty on error
                        pendingResult.success("");
                    }
                    pendingResult = null;
                }
                
                lastPartialResult = "";
            }

            @Override
            public void onResults(Bundle results) {
                isListening = false;
                timeoutHandler.removeCallbacks(timeoutRunnable);
                
                ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                String recognizedText = "";
                
                // Try final results first
                if (matches != null && !matches.isEmpty()) {
                    recognizedText = matches.get(0);
                    System.out.println("✅ Final result: " + recognizedText);
                } 
                // Fallback to partial result
                else if (!lastPartialResult.isEmpty()) {
                    recognizedText = lastPartialResult;
                    System.out.println("✅ Using partial result: " + recognizedText);
                }
                
                if (pendingResult != null) {
                    pendingResult.success(recognizedText);
                    pendingResult = null;
                }
                
                lastPartialResult = "";
            }

            @Override
            public void onPartialResults(Bundle partialResults) {
                ArrayList<String> matches = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (matches != null && !matches.isEmpty()) {
                    lastPartialResult = matches.get(0);
                    System.out.println("📝 Partial: " + lastPartialResult);
                }
            }

            @Override
            public void onEvent(int eventType, Bundle params) {
                // Reserved for future use
            }
        });

        // Create recognition intent with optimized settings
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US");
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, "en-US");
        intent.putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, "en-US");
        intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5);
        intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
        intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 1500);
        intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 1500);
        intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 5000);

        // Start listening
        try {
            speechRecognizer.startListening(intent);
            System.out.println("🎤 Speech recognition started (background mode - no dialog)");
        } catch (Exception e) {
            if (pendingResult != null) {
                pendingResult.error("ERROR", "Failed to start: " + e.getMessage(), null);
                pendingResult = null;
            }
        }
    }

    private void stopSpeechRecognition() {
        if (timeoutHandler != null && timeoutRunnable != null) {
            timeoutHandler.removeCallbacks(timeoutRunnable);
        }
        
        if (speechRecognizer != null && isListening) {
            speechRecognizer.stopListening();
            isListening = false;
            System.out.println("🛑 Speech recognition stopped");
        }
    }

    private String getErrorText(int errorCode) {
        switch (errorCode) {
            case SpeechRecognizer.ERROR_AUDIO:
                return "Audio recording error";
            case SpeechRecognizer.ERROR_CLIENT:
                return "Client side error";
            case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS:
                return "Insufficient permissions";
            case SpeechRecognizer.ERROR_NETWORK:
                return "Network error";
            case SpeechRecognizer.ERROR_NETWORK_TIMEOUT:
                return "Network timeout";
            case SpeechRecognizer.ERROR_NO_MATCH:
                return "No speech match";
            case SpeechRecognizer.ERROR_RECOGNIZER_BUSY:
                return "Recognition service busy";
            case SpeechRecognizer.ERROR_SERVER:
                return "Server error";
            case SpeechRecognizer.ERROR_SPEECH_TIMEOUT:
                return "No speech input";
            case SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED:
                return "Language not supported";
            case SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE:
                return "Language unavailable";
            default:
                return "Unknown error (" + errorCode + ")";
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
        if (timeoutHandler != null && timeoutRunnable != null) {
            timeoutHandler.removeCallbacks(timeoutRunnable);
        }
    }
}
