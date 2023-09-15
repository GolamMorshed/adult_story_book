import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(ImageToText());

class ImageToText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TextExtractor(),
    );
  }
}

class TextExtractor extends StatefulWidget {
  @override
  _TextExtractorState createState() => _TextExtractorState();
}

class _TextExtractorState extends State<TextExtractor> {
  File? selectedImage;
  String extractedText = '';
  TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<void> _selectAndExtractImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);

    setState(() {
      selectedImage = imageFile;
      extractedText = 'Extracting text...';
    });

    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String text = '';

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        text += line.text + ' ';
      }
      text += '\n';
    }

    setState(() {
      extractedText = text;
    });
  }

  @override
  void dispose() {
    // Dispose of the TextRecognizer when it's no longer needed.
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to Text Converter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImage != null
                ? Image.file(selectedImage!)
                : Text('Select an image from the gallery to extract text.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectAndExtractImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16),
            Text(
              'Extracted Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(extractedText),
          ],
        ),
      ),
    );
  }
}
