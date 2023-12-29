import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CameraIconButton(
              color: Colors.green,
              subName: 'Entry',
            ),
            SizedBox(height: 20),
            CameraIconButton(
              color: Colors.red,
              subName: 'Exit',
            ),
          ],
        ),
      ),
    );
  }
}

class CameraIconButton extends StatelessWidget {
  final Color color;
  final String subName;

  const CameraIconButton({
    required this.color,
    required this.subName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Open the camera for taking a photo
        final cameras = await availableCameras();
        final firstCamera = cameras.first;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(camera: firstCamera),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      child: Icon(
        Icons.camera_alt,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String _capturedImagePath;
  late String url;
  var Data;
  late String numberPlate;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            print(image.path);

            setState(() {
              _capturedImagePath = image.path;
            });

            // Process the captured image for number plate recognition
            // String numberPlate =
            numberPlate = await recognizeLicensePlate(_capturedImagePath);

            // Display the recognized number plate
            // url = 'http://192.168.125.60:5000/recognize';
            // final response =
            //  await http.get(Uri.parse('http://127.0.0.1:5000/recognize'));
            // final Uri apiUrl = Uri.parse(url);
            // Data = await Getdata(apiUrl);
            // final response = await http.get(Uri.parse(url));
            // final dev = json.decode(response.body) as Map<String, dynamic>;
            // setState(() {
            //   numberPlate = dev['numberPlate'];
            // });
            showNumberPlateDialog(context, numberPlate);
          } catch (e) {
            print('Error capturing photo: $e');
          }
        },
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Future<String> recognizeLicensePlate(String imagePath) async {
  try {
    // final response = await http.get('http://127.0.0.1:5000/recognize' as Uri);
    // var request = http.MultipartRequest('POST', Uri.parse('http://192.168.125.60:5000/recognize'));
    //request.files.add(await http.MultipartFile.fromPath('imagePath', imagePath));
    //var response = await request.send();
    final response =
        await http.get(Uri.parse('http://192.168.125.60:5000/recognize'));
    if (response.statusCode == 200) {
      final dev = json.decode(response.body) as Map<String, dynamic>;
      var numberPlat = dev['numberPlate'];
      return numberPlat;
    } else {
      throw Exception('Failed to recognize license plate');
    }
  } catch (e) {
    return 'ERROR';
  }
}

void showNumberPlateDialog(BuildContext context, String numberPlate) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Number Plate Recognition Result'),
        content: Text('Number Plate: $numberPlate'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Registration',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController(); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your login form fields here
            // For simplicity, let's just add a username and password field
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your login logic here
                // For simplicity, let's assume login is successful
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text(
                'Don\'t have an account? Register here',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your registration form fields here
            // For simplicity, let's add society name, city, mobile number, username, and password
            TextFormField(
              decoration: InputDecoration(labelText: 'Society Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'vehicle number'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your registration logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
