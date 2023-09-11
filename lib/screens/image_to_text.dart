// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
//
// void main() {
//   runApp(MaterialApp(
//     home: ImageToTextConverter(),
//   ));
// }
//
// class ImageToTextConverter extends StatefulWidget {
//   @override
//   _ImageToTextConverterState createState() => _ImageToTextConverterState();
// }
//
// class _ImageToTextConverterState extends State<ImageToTextConverter> {
//   File? _pickedImage;
//   String _extractedText = '';
//
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final inputImage = InputImage.fromFilePath(pickedFile.path);
//       final textDetector = GoogleMlKit.vision.textDetector();
//       final RecognisedText recognisedText = await textDetector.processImage(inputImage);
//
//       String extractedText = '';
//       for (TextBlock block in recognisedText.blocks) {
//         for (TextLine line in block.lines) {
//           extractedText += line.text + '\n';
//         }
//       }
//
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//         _extractedText = extractedText;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image to Text Converter'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_pickedImage != null)
//               Image.file(_pickedImage!, height: 200.0),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text('Pick an Image'),
//             ),
//             SizedBox(height: 20.0),
//             Text('Extracted Text:', style: TextStyle(fontSize: 16.0)),
//             SizedBox(height: 10.0),
//             Text(_extractedText),
//           ],
//         ),
//       ),
//     );
//   }
// }
