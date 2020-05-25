import 'package:avi_test_app/database/database.dart';
import 'package:avi_test_app/database/history.dart';
import 'package:avi_test_app/pages/logger.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/drawer.dart';

String vehiclenumber = 'detection failed';
String latitude;
String longitude;
String datetime;
String isBlacklisted;

class ImageInput extends StatefulWidget {
  final String userid;
  final String username;
  final String branchid;
  ImageInput({Key key, this.userid, this.username, this.branchid}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ImageInput();
  }
}

class _ImageInput extends State<ImageInput> {
  // To store the file provided by the image_picker
  File _imageFile;
  Position _position; 
  // To track the file uploading state
  bool _isUploading = false;

  String baseUrl = 'http://192.168.43.132/flutterdemoapi/api.php';

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>> _uploadImage(File image, String method) async {
    setState(() {
      _isUploading = true;
    });

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    
    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.fields['latitude'] = _position.latitude.toString();
    imageUploadRequest.fields['longitude'] = _position.longitude.toString();
    imageUploadRequest.fields['dateTime'] = _position.timestamp.toLocal().toString();
    imageUploadRequest.fields['method'] = method;
    imageUploadRequest.files.add(file);

    latitude= _position.latitude.toString();
    longitude=  _position.longitude.toString();
    datetime=  _position.timestamp.toLocal().toString();
    

    try {
      final streamedResponse = await imageUploadRequest.send();
      

      final response = await http.Response.fromStream(streamedResponse);
      print(response);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      _resetState();

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _startUploading(String method) async {
    final Map<String, dynamic> response = await _uploadImage(_imageFile,method);
    print(response);
    // Check if any error occured
    if (response == null) {
      Toast.show("Image Upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }else if( response.containsKey("error")){
          Toast.show(response['error'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      print(response['vehicleNo']);
      print(response['dateTime']);
      print(response['latitude']);
      print(response['longitude']);
      print(response['response']);
      Toast.show(response['response'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      vehiclenumber= response['vehicleNo'];
      isBlacklisted= response['response'];
      var db = new DatabaseHelper();
      var history = new History(vehiclenumber, datetime, latitude, longitude, isBlacklisted);
      await db.saveHistory(history);
    }
  }

  void _resetState() {
    setState(() {
      _isUploading = false;
      _imageFile = null;
    });
  }

  void _openImagePickerModal(BuildContext context) {
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300.0,
            padding: EdgeInsets.only(top:20.0,bottom: 20,left:5.0,right:5.0 ),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30.0,
                ),

                Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.blue,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                 onPressed: () async{
                    _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    // print ("yes");
                    // print(_position.timestamp.toLocal().toString());
                    _getImage(context, ImageSource.camera);
                  },
                child: Text("Use camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:Colors.white,
                        fontSize: 15.0,
                      )
                ),
                )
              ),
              Padding(padding:EdgeInsets.symmetric(vertical: 20.0,horizontal: 5.0) ,),
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.blue,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                 onPressed: () async{
                    _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    // print ("yes");
                    // print(_position.latitude.toString());
                    // print(_position.longitude.toString());
                    // print(_position.timestamp.toLocal().toString());
                    _getImage(context, ImageSource.gallery);
                  },
                child: Text("Use Gallery",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:Colors.white,
                        fontSize: 15.0,
                      )
                ),
                )
              )
              ],
            ),
          );
        });
  }

  Widget _buildUploadBtn() {
    Widget btnWidget = Container();

    if (_isUploading) {
      // File is being uploaded then show a progress indicator
      btnWidget = Container(
          margin: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator());
    } else if (!_isUploading && _imageFile != null) {
      // If image is picked by the user then show a upload btn

      btnWidget = Container(
        margin: EdgeInsets.all(10.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Padding(padding:EdgeInsets.symmetric(vertical: 20.0,horizontal: 5.0) ,),
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.blue,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
            _startUploading("blacklist");
          },
          child: Text("Blacklist This Vehicle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:Colors.white,
                  fontSize: 15.0,
                )
          ),
          )
        ),
        Padding(padding:EdgeInsets.symmetric(vertical: 20.0,horizontal: 5.0) ,),
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.blue,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
            _startUploading("check");
          },
          child: Text("Check This Vehicle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:Colors.white,
                  fontSize: 15.0,
                )
          ),
          )
        )
          ]
        )
      );
    }

    return btnWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to A V I '),
      ),
      drawer: DrawerUI(username: username,userid: userid,branchid: branchid),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
            child: OutlineButton(
              onPressed: () => _openImagePickerModal(context),
              borderSide:
                  BorderSide(color: Theme.of(context).accentColor, width: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text('Add Image'),
                ],
              ),
            ),
          ),
          _imageFile == null
              ? Text('Please pick an image')
              : Image.file(
                  _imageFile,
                  fit: BoxFit.cover,
                  height: 100.0,
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                ),
          _buildUploadBtn(),
        ],
      ),
    );
  }
}