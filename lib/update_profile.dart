import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'models/local_language.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _isPasswordVisible = false;
  String? selectedRelation;
  String? customRelation;
  String? selectedAge;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchUserData();

  }

  String mapRelationToEnglish(String relation) {
    switch (relation) {
      case 'أم':
      case 'Mother':
        return 'Mother';
      case 'أب':
      case 'Father':
        return 'Father';
      case 'أخ':
      case 'Brother':
        return 'Brother';
      case 'أخت':
      case 'Sister':
        return 'Sister';
      case 'معلم':
      case 'Teacher':
        return 'Teacher';
      default:
        return customRelation ?? 'Other';
    }
  }


  void _updateUser() {
    if (selectedRelation == null || selectedAge == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    context.read<AuthCubit>().updateUserData(
      name: nameController.text,
      relation: mapRelationToEnglish(selectedRelation!),
      age:  selectedAge!,

    );
  }
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var lang = AppLocalizations.of(context);
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    final authCubit = context.read<AuthCubit>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context, true); // بدل pushReplacement

          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthStates>(
          buildWhen: (previous, current) => current is UserLoaded,
          bloc: authCubit,
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserError) {
              return Center(child: Text(state.message));
            } else if (state is UserLoaded) {
              if (nameController.text.isEmpty) {
                nameController.text = state.user.name;
                emailController.text = state.user.email;
                selectedAge = state.user.age.toString();
                final allRelations = [
                  'Mother',
                  'Father',
                  'Brother',
                  'Sister',
                  'Teacher',
                  'Other',
                ];

                if (allRelations.contains(state.user.relation)) {
                  selectedRelation = isArabic
                      ? lang.translate(state.user.relation)
                      : state.user.relation;
                } else {
                  selectedRelation = lang.translate('Other');
                  customRelation = state.user.relation;
                }

              }}
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/darker_blue_image.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.15,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                      ),
                      height: screenHeight * 0.90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            lang.translate("Update Profile"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff09122C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildLabel(lang.translate("NAME"), screenWidth),
                          _buildTextField(
                            controller: nameController,
                            hintText: lang.translate("Your Name"),
                            icon: Icons.person,
                            screenWidth: screenWidth,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang.translate(
                                  "Please enter your name.",
                                );
                              }
                              if (value.length < 6) {
                                return lang.translate(
                                  "Name must be at least 6 characters.",
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildLabel(lang.translate("EMAIL"), screenWidth),
                          _buildTextField(
                            controller: emailController,
                            hintText: lang.translate("*****@gmail.com"),
                            icon: Icons.email,
                            screenWidth: screenWidth,
                            isPassword: false,
                            readOnly: true
                          ),
                          const SizedBox(height: 15),
                          _buildLabel(
                            lang.translate("What is your relationship with the child?"),
                            screenWidth,
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedRelation,
                            onChanged: (value) {
                              setState(() {
                                selectedRelation = value;
                                if (value != lang.translate('Other')) {
                                  customRelation = null;
                                }
                              });
                            },
                            items: [
                              lang.translate('Mother'),
                              lang.translate('Father'),
                              lang.translate('Brother'),
                              lang.translate('Teacher'),
                              lang.translate('Sister'),
                              lang.translate('Other'),
                            ]
                                .map(
                                  (relation) => DropdownMenuItem(
                                value: relation,
                                child: Text(relation),
                              ),
                            )
                                .toList(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (selectedRelation == lang.translate('Other'))
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextFormField(
                                onChanged: (value) => customRelation = value,
                                decoration: InputDecoration(
                                  hintText: lang.translate('Please specify...'),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.03,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 15),
                          _buildLabel(lang.translate("Age"), screenWidth),
                          DropdownButtonFormField<String>(
                            value: selectedAge,
                            onChanged: (value) => setState(() => selectedAge = value),
                            items: List.generate(
                              7,
                                  (index) => (6 + index).toString(),
                            ).map((age) {
                              return DropdownMenuItem(
                                value: age,
                                child: Text(age),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildLabel(lang.translate("gender"), screenWidth),
                          DropdownButtonFormField<String>(
                            value: selectedGender,
                            onChanged: (value) => setState(() => selectedGender = value),
                            items: [
                              lang.translate("male"),
                              lang.translate("female"),
                            ].map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.06,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff09122C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.03,
                                  ),
                                ),
                              ),
                              onPressed: _updateUser,
                              child: Text(
                                lang.translate("Save Changes"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02, bottom: 5),
      child: Align(
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double screenWidth,
    bool isPassword = false,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        cursorColor: Colors.grey,
        obscureText: isPassword && !_isPasswordVisible,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        readOnly: readOnly,
        onChanged: (text) {
          setState(() {
            controller.text = text;
          });
        },
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
