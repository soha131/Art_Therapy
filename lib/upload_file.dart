import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'cubit/Art_cubit.dart';
import 'cubit/Art_state.dart';
import 'cubit/auth_cubit.dart';
import 'models/local_language.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  _UploadFileScreenState createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  File? _selectedFile;
  static const double imageContainerHeightFactor = 0.25;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
  }

  void _showResultSheet(
      BuildContext context,
      String prediction,
      String diagnosis,
      String support,
      File imageFile,
      String userId,
      ) {
    double screenHeight = MediaQuery.of(context).size.height;
    var lang = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color(0xff09122C),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: ()  {
                      try {
                        context.read<AuthCubit>().saveResult(
                          diseaseName: prediction,
                          profilePicture: imageFile,
                        );

                        setState(() {
                          isSaved = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.translate("Saved to history!")),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        print("❌ Failed to save: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.translate("Failed to save!")),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child:  Icon(Icons.bookmark, color:  isSaved ? Colors.yellow :Colors.white),
                  ),
                  Text(
                    lang.translate("RESULT"),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: screenHeight * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                prediction,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    lang.translate("diagnosis"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    diagnosis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  Text(
                    lang.translate( "support"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    support,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    var lang = AppLocalizations.of(context);
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Image.asset('assets/logo.png', height: screenHeight * 0.05),
              const Divider(color: Colors.black26, thickness: 1.5),
              SizedBox(height: screenHeight * 0.05),
              Text(
                lang.translate("Upload Files"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),
              BlocBuilder<ArtCubit, ArtTherapyState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap:
                        () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        final XFile? photo = await ImagePicker()
                                            .pickImage(
                                              source: ImageSource.camera,
                                            );

                                        if (photo != null) {
                                          setState(() {
                                            _selectedFile = File(photo.path);
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.camera_alt),
                                      title: Text(
                                        lang.translate("Take a photo"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff3C3D37),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 50),

                                    ListTile(
                                      onTap: () async {
                                        final XFile? photo = await ImagePicker()
                                            .pickImage(
                                              source: ImageSource.gallery,
                                              maxWidth: 800,
                                              maxHeight: 800,
                                              imageQuality: 70,
                                            );

                                        if (photo != null) {
                                          setState(() {
                                            _selectedFile = File(photo.path);
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.image),
                                      title: Text(
                                        lang.translate("Choose from gallery"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff3C3D37),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .80,
                      height: screenHeight * imageContainerHeightFactor,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          _selectedFile == null
                              ? Semantics(
                                label: lang.translate(
                                  "Drag or Click to choose an Image",
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      lang.translate(
                                        "Drag or Click to choose an Image",
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(19),

                                    child: Image.file(
                                      _selectedFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedFile = null;
                                        });
                                        BlocProvider.of<ArtCubit>(
                                          context,
                                        ).emit(ArtTherapyInitial());
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 16,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: () {
                  if (_selectedFile != null) {
                    BlocProvider.of<ArtCubit>(context).Art(_selectedFile!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff09122C),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  lang.translate("RESULT"),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              BlocListener<ArtCubit, ArtTherapyState>(
                listener: (context, state) {

                  if (state is ArtTherapySuccess) {
                    _showResultSheet(
                      context,
                      state.prediction.prediction ?? 'Unknown',
                      state.prediction.diagnosis?? 'Unknown',
                      state.prediction.support?? 'Unknown',
                      _selectedFile!,
                      "",
                    );
                  } else if (state is ArtTherapyError) {
                    _showResultSheet(
                      context,
                      'Error',
                        'Error',
                        'Error',
                      _selectedFile!,""
                    );
                  }
                },
                child: Container(),
              ),
            ],
          ),
        ),

        bottomNavigationBar: _buildCustomBottomNavBar(context, activeTab: ""),
      ),
    );
  }

  Widget _buildCustomBottomNavBar(
    BuildContext context, {
    required String activeTab,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: screenHeight * 0.10,
          decoration: const BoxDecoration(color: Color(0xff09122C)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor:
                      activeTab == "history"
                          ? Colors.yellow
                          : Color(0xff09122C),
                  radius: screenWidth * .08,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      color:
                          activeTab == "history"
                              ? Color(0xff09122C)
                              : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      if (activeTab != "history") {
                        Navigator.pushReplacementNamed(context, "History");
                      }
                    },
                  ),
                ),
                CircleAvatar(
                  backgroundColor:
                      activeTab == "settings"
                          ? Colors.yellow
                          : Color(0xff09122C),
                  radius: screenWidth * .08,

                  child: IconButton(
                    icon: Icon(
                      Icons.person,
                      color:
                          activeTab == "settings"
                              ? Color(0xff09122C)
                              : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      if (activeTab != "settings") {
                        Navigator.pushReplacementNamed(context, "Setting");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
