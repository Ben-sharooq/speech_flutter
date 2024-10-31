import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToText extends StatefulWidget {
  const SpeechToText({super.key});

  @override
  State<SpeechToText> createState() => _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechToText> {
  bool isListening = false;
  late stt.SpeechToText _speechToText;

  String text = "";
  double confidence = 1.0;
  int tapCount = 0; // Counter to track button taps

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(confidence * 100).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration: const Duration(microseconds: 1000),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _captureVoice,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,

            
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Successfullycopied text')));
                    },
                    child: Text(
                      'Copy Text',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _captureVoice() async {
    tapCount++; // Increment tap count

    if (!isListening) {
      if (tapCount == 1) {
        // Clear the previous text when starting a new recording
        setState(() {
          text = "";
        });

        bool available = await _speechToText.initialize();
        if (available) {
          setState(() => isListening = true);
          _speechToText.listen(
            onResult: (result) => setState(() {
              text = result.recognizedWords;

              if (result.hasConfidenceRating && result.confidence > 0) {
                confidence = result.confidence;
              }
            }),
          );
        } else {
          // Handle initialization error
          print("Speech recognition not available");
        }
      } else if (tapCount == 2) {
        // Stop listening on second tap
        setState(() => isListening = false);
        _speechToText.stop();
        tapCount = 0; // Reset tap count
      }
    } else {
      // Stop listening on single tap while listening
      setState(() => isListening = false);
      _speechToText.stop();
      tapCount = 0; // Reset tap count
    }
  }
}
