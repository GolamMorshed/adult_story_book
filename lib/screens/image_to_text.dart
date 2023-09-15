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
  List<File?> selectedImages = [];
  TextEditingController extractedTextController = TextEditingController();
  TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<void> _selectAndExtractImage() async {
    final imagePicker = ImagePicker();

    while (true) {
      final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        break; // Exit the loop if the user cancels image selection.
      }

      final imageFile = File(pickedFile.path);

      setState(() {
        selectedImages.add(imageFile);
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

      // Append the extracted text to the existing text in the TextField.
      extractedTextController.text += text;
    }
  }

  @override
  void dispose() {
    // Dispose of the TextRecognizer and TextEditingController when they're no longer needed.
    textRecognizer.close();
    extractedTextController.dispose();
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
            selectedImages.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Image.file(selectedImages[index]!),
                      SizedBox(height: 8),
                      // Text(
                      //   'Extracted Text:',
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      SizedBox(height: 8),
                      Text(extractedTextController.text),
                    ],
                  );
                },
              ),
            )
                : Text('Select images from the gallery to extract text.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectAndExtractImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: extractedTextController,
              decoration: InputDecoration(
                labelText: 'Extracted Text',
                border: OutlineInputBorder(),
              ),
              maxLines: null, // Allows multiple lines in the TextField.
            ),
          ],
        ),
      ),
    );
  }
}
