import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _home();
}

class _home extends State<home> {
  File? image;
  String imagepath = "";
  String get = "";
  String detect = "";
  String accuracy = "";
  double x = 0;
  String get_percent = "";

  int check_getting_result=0;

  final _pic = new ImagePicker();

  Future<void> getcameraimage() async {
    final pickedfile =
        await _pic.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedfile != null) {
      image = File(pickedfile!.path);
      imagepath = image!.path;
      setState(() {});
    } else {
      final snackbar = SnackBar(
        content: Text(
          "An Error Occured",
          style: TextStyle(
              color: Colors.red, fontFamily: "SutonnyMJ", fontSize: 15),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(onPressed: () {}, label: "Undo"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> get_storage_image() async {
    final pickedfile =
        await _pic.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedfile != null) {
      image = File(pickedfile!.path);
      imagepath = image!.path;
      setState(() {});
    } else {
      final snackbar = SnackBar(
        content: Text(
          "An Error Occured",
          style: TextStyle(
              color: Colors.red, fontFamily: "SutonnyMJ", fontSize: 15),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(onPressed: () {}, label: "Undo"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> uploadimage() async {
    var dio = Dio();
    FormData data =
        FormData.fromMap({"file": await MultipartFile.fromFile(imagepath)});
    var response =
        await dio.post("http://192.168.0.104:8080/predict", data: data);
    if (response.statusCode == 200) {
      setState(() {
        get = response.data.toString();
        accuracy = get.split(", ").last.split("]").first;
        detect = get.split(", ").first.split("[").last;
        if (accuracy == '1.0') {
          x=100;
          accuracy = "100";
        }
        else {
          x = (int.parse(accuracy.substring(2, 6)) / 100);
          accuracy="$x";
        }
        //get_percent=convertNumber(x);
        if (x <= 70.00 || detect=="Garbage") {
          detect = "Invalid Result";
          accuracy="0";
        }
        check_getting_result=1;
      });
      showresult(context);
    }
    else {
      setState(() {
        detect="Invalid Result";
        accuracy="Invalid Accuracy";
      });
      showresult(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child:RefreshIndicator(
              onRefresh: () {
                return Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    image = null;
                    detect = "";
                    accuracy = "";
                    check_getting_result=0;
                    x=0;
                  });
                });
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 35),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Soil Detection",
                          style: TextStyle(
                              color: Colors.blue,
                              fontFamily: "Times New Roman",
                              fontSize: 25,
                          fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 50),
                        IconButton(
                          onPressed: () {
                            showexit(context);
                          },
                          icon: Icon(Icons.cancel, color: Colors.blue),
                          iconSize: 30,
                          color: Colors.blue,
                        )
                      ],
                    )),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.blue, width: 3))),
                    ),
                    SizedBox(
                      height: 55,
                    ),
                    Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3)),
                        child: image == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 60,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showoption(context);
                                    },
                                    icon: Icon(Icons.upload),
                                    color: Colors.blue,
                                    iconSize: 55,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Image Upload",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: "Times New Roman",
                                        fontSize: 18),
                                  )
                                ],
                              )
                            : Container(
                                child: Image.file(
                                  File(image!.path).absolute,
                                  fit: BoxFit.fill,
                                  width: 256,
                                  height: 256,
                                ),
                              )),
                    SizedBox(height: 55),
                    FloatingActionButton(
                      onPressed: () {
                        uploadimage();
                      },
                      backgroundColor: Colors.blue,
                      child:
                          Icon(Icons.search_rounded, color: Colors.white, size: 28),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Detect",
                      style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Times New Roman",
                          fontSize: 18),
                    ),
                    SizedBox(height: 30),
                    /*if(check_getting_result==1)
                      showoption(context)*/

                  ],
                ),
              ),
            ),
          ),
    );
  }

  showoption(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 80,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Text("Camera",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Times New Roman",
                              fontSize: 20)),
                      onTap: () {
                        getcameraimage();
                        Navigator.of(context).pop();
                        //build(context);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: Text("Gallery",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Times New Roman",
                              fontSize: 20)),
                      onTap: () {
                        get_storage_image();
                        Navigator.of(context).pop();
                      },
                    )
                  ]),
            ),
          );
        });
  }

  showexit(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Exit Confirm?",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: "Times New Roman",
                  fontSize: 20),
            ),
            icon: Icon(Icons.android_outlined,
                size: 50, color: Colors.blueAccent),
            content: Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Text("Yes",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: "Times New Roman",
                              fontSize: 20)),
                      onTap: () {
                        SystemNavigator.pop();
                      },
                    ),
                    GestureDetector(
                      child: Text("No",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: "Times New Roman",
                              fontSize: 20)),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ]),
            ),
          );
        });
  }


  showresult(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: 150,
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("$detect ",style: TextStyle(fontSize: 18,color: Colors.blue,fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("$accuracy% Accuracy",style: TextStyle(fontSize: 18,color: Colors.blue)),
                ],
              )



            ),
          );
        });
  }
}
