import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'models/local_language.dart';
import 'otp.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? selectedRelation;
  String? customRelation;
  String? selectedAge;
  String? selectedGender;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var lang = AppLocalizations.of(context);
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is RegisterSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EnterOtpScreen(email: emailController.text),
              ),
            );
          });
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
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
                  top: screenHeight * 0.08,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.2),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                lang.translate("Create new\nAccount"),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff09122C),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang.translate("Already Registered?"),
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "Login");
                                    },
                                    child: Text(
                                      lang.translate("Log in here."),
                                      style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              const SizedBox(height: 10),
                              _buildLabel(lang.translate("EMAIL"), screenWidth),
                              _buildTextField(
                                controller: emailController,
                                hintText: lang.translate("*****@gmail.com"),
                                icon: Icons.email,
                                screenWidth: screenWidth,
                              ),
                              const SizedBox(height: 10),
                              _buildLabel(
                                lang.translate("PASSWORD"),
                                screenWidth,
                              ),
                              _buildTextField(
                                controller: passwordController,
                                hintText: "******",
                                icon: Icons.lock,
                                screenWidth: screenWidth,
                                isPassword: true,
                              ),
                              _buildLabel(
                                lang.translate(
                                  "What is your relationship with the child?",
                                ),
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
                                items:
                                    [
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
                                    onChanged:
                                        (value) => customRelation = value,
                                    decoration: InputDecoration(
                                      hintText: lang.translate(
                                        'Please specify...',
                                      ),
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
                                onChanged:
                                    (value) =>
                                        setState(() => selectedAge = value),
                                items:
                                    List.generate(
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
                              _buildLabel(
                                lang.translate("gender"),
                                screenWidth,
                              ),
                              DropdownButtonFormField<String>(
                                value: selectedGender,
                                onChanged:
                                    (value) =>
                                        setState(() => selectedGender = value),
                                items:
                                    [
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
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff09122C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      String email =
                                          emailController.text
                                              .trim()
                                              .toLowerCase();
                                      String name = nameController.text.trim();
                                      String password =
                                          passwordController.text.trim();
                                      String finalRelation =
                                          selectedRelation ==
                                                  lang.translate('Other')
                                              ? (customRelation?.trim() ?? '')
                                              : (selectedRelation ?? '');
                                      context.read<AuthCubit>().signup(
                                        email: email,
                                        password: password,
                                        context: context,
                                        confirmPassword: password,
                                        name: name,
                                        relation: finalRelation,
                                        age: selectedAge ?? "",
                                        gender: selectedGender??""
                                      );
                                    }
                                  },
                                  child: Text(
                                    lang.translate("Sign Up"),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    String? Function(String?)? validator,
  }) {
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        validator: validator,
        controller: controller,
        cursorColor: Colors.grey,
        obscureText: isPassword && !_isPasswordVisible,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon:
              isPassword
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
