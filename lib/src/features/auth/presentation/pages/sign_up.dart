import 'dart:io';

import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final PageController _pageController = PageController();
  late CreateAccountCubit _createAccountCubit;
  final FormGroup formGroup = fb.group({
    FormControlName.name: FormControl<String>(),
    FormControlName.email: FormControl<String>(),
    FormControlName.bio: FormControl<String>(),
  });

  int _currentPage = 0;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestGalleryPermission(context);
    });

    _createAccountCubit = CreateAccountCubit(
      userRepository: getIt<UserRepository>(),
    );
  }

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStepDetails(String title, String description) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey(_currentPage),
        children: [
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReactiveForm(
        formGroup: formGroup,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
              bloc: _createAccountCubit,
              listener: (context, state) {
                if (state is CreateAccountSuccess) {
                  context.showSnackBarUsingText(
                    'Account created successfully',
                  );

                  context.push(Routes.home.path);
                } else if (state is CreateAccountFailure) {
                  context.showSnackBarUsingText(
                    state.message,
                    isError: true,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStepDetails(
                      _currentPage == 0
                          ? 'Choose Profile Picture'
                          : 'Create Account',
                      _currentPage == 0
                          ? 'Tap below to add your photo'
                          : 'Enter your name, email to continue',
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: context.theme.cardColor,
                                          border: Border.all(
                                            color: context.theme.cardColor,
                                          ),
                                        ),
                                        child: _profileImage != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.file(
                                                  _profileImage!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    galleryIcon,
                                                    width: 48,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      darkGrey,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Tap to choose a profile picture',
                                                    style: context
                                                        .textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              case 1:
                                return const Column(
                                  children: [
                                    CustomFormTextField<String>(
                                      name: FormControlName.name,
                                      hintText: 'Your Name',
                                      filled: true,
                                    ),
                                    SizedBox(height: 16),
                                    CustomFormTextField<String>(
                                      name: FormControlName.email,
                                      hintText: 'Email',
                                      filled: true,
                                      textCapitalization:
                                          TextCapitalization.none,
                                    ),
                                    SizedBox(height: 16),
                                    CustomFormTextField<String>(
                                      name: FormControlName.bio,
                                      hintText: 'Bio',
                                      filled: true,
                                      textCapitalization:
                                          TextCapitalization.none,
                                    ),
                                  ],
                                );

                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentPage == 0 && _profileImage != null)
                      CustomButton(
                        text: 'Next',
                        color: context.theme.primaryColor,
                        onTap: _nextPage,
                      ),
                    if (_currentPage == 1 &&
                        formGroup.control(FormControlName.name).valid &&
                        formGroup.control(FormControlName.email).valid)
                      CustomButton(
                        loading: state is CreateAccountLoading,
                        text: 'Sign Up',
                        color: context.theme.primaryColor,
                        onTap: () async {
                          final name = formGroup
                              .control(FormControlName.name)
                              .value as String;

                          final email = formGroup
                              .control(FormControlName.email)
                              .value as String;

                          final bio = formGroup
                              .control(FormControlName.bio)
                              .value as String;

                          final photoUrl = _profileImage?.path ?? '';
                          final id =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          final user = User(
                            id: id,
                            name: name,
                            email: email,
                            photoUrl: photoUrl,
                            bio: bio,
                          );

                          await _createAccountCubit.createAccount(user: user);
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
