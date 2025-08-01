import 'dart:io';

import 'package:cracte/src/common/common.dart';
import 'package:cracte/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:solar_icons/solar_icons.dart';

class CreatePage extends StatefulWidget {
  final Recipe? recipe;
  const CreatePage({super.key, this.recipe});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late final FormGroup formGroup;
  File? selectedImage;
  String? existingImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  List<Category> categories = [];
  Category? selectedCategory;

  bool get isEditMode => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadCategories();
  }

  void _initializeForm() {
    if (isEditMode) {
      final recipe = widget.recipe!;

      formGroup = fb.group({
        FormControlName.title: FormControl<String>(
          value: recipe.title,
          validators: [Validators.required],
        ),
        FormControlName.description: FormControl<String>(
          value: recipe.description,
          validators: [Validators.required],
        ),
        FormControlName.duration: FormControl<String>(
          value: recipe.duration.toString(),
          validators: [Validators.required],
        ),
        FormControlName.ingredients: FormArray<String>(
          recipe.ingredients
              .map(
                (ingredient) => FormControl<String>(
                  value: ingredient,
                  validators: [Validators.required],
                ),
              )
              .toList(),
        ),
        FormControlName.steps: FormArray<String>(
          recipe.steps
              .map(
                (step) => FormControl<String>(
                  value: step,
                  validators: [Validators.required],
                ),
              )
              .toList(),
        ),
      });

      if (recipe.image.isNotEmpty) {
        existingImage = recipe.image;
      }

      selectedCategory = recipe.category;
    } else {
      formGroup = fb.group({
        FormControlName.title: FormControl<String>(
          validators: [Validators.required],
        ),
        FormControlName.description: FormControl<String>(
          validators: [Validators.required],
        ),
        FormControlName.duration: FormControl<String>(
          validators: [Validators.required],
        ),
        FormControlName.ingredients: FormArray<String>([
          FormControl<String>(value: '', validators: [Validators.required]),
        ]),
        FormControlName.steps: FormArray<String>([
          FormControl<String>(value: '', validators: [Validators.required]),
        ]),
      });
    }
  }

  FormArray<String> get ingredientsFormArray =>
      formGroup.control(FormControlName.ingredients) as FormArray<String>;

  FormArray<String> get stepsFormArray =>
      formGroup.control(FormControlName.steps) as FormArray<String>;

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories =
          await getIt<CategoryRepository>().getCategories();
      setState(() {
        categories = fetchedCategories;
        if (categories.isNotEmpty) {
          selectedCategory = categories.first;
        }
      });
    } catch (e) {
      logman.error('Failed to load categories: $e');
      setState(() {
        categories = [Category.sampleData()];
        selectedCategory = categories.first;
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void addIngredient() {
    ingredientsFormArray.add(
      FormControl<String>(value: '', validators: [Validators.required]),
    );
  }

  void removeIngredient(int index) {
    if (ingredientsFormArray.controls.length > 1) {
      ingredientsFormArray.removeAt(index);
    }
  }

  void addStep() {
    stepsFormArray.add(
      FormControl<String>(value: '', validators: [Validators.required]),
    );
  }

  void removeStep(int index) {
    if (stepsFormArray.controls.length > 1) {
      stepsFormArray.removeAt(index);
    }
  }

  Future<void> saveRecipe(User user) async {
    if (formGroup.invalid) {
      formGroup.markAllAsTouched();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedImage == null && existingImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a recipe image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final title = formGroup.control(FormControlName.title).value as String;
      final description =
          formGroup.control(FormControlName.description).value as String;
      final duration =
          formGroup.control(FormControlName.duration).value as String;

      final ingredients = ingredientsFormArray.controls
          .map((control) => control.value!)
          .where((ingredient) => ingredient.trim().isNotEmpty)
          .toList();

      final steps = stepsFormArray.controls
          .map((control) => control.value!)
          .where((step) => step.trim().isNotEmpty)
          .toList();
      final now = DateTime.now();

      final recipe = Recipe(
        id: isEditMode
            ? widget.recipe!.id
            : now.millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        duration: int.parse(duration),
        ingredients: ingredients,
        steps: steps,
        image: selectedImage != null ? selectedImage!.path : existingImage!,
        category: selectedCategory!,
        authorId: isEditMode ? widget.recipe!.authorId : user.id,
        authorName: isEditMode ? widget.recipe!.authorName : user.name,
        authorImage: isEditMode ? widget.recipe!.authorImage : user.photoUrl,
        createdAt: isEditMode ? widget.recipe!.createdAt : now,
        updatedAt: now,
        isFavorite: isEditMode ? widget.recipe!.isFavorite : false,
      );

      isEditMode
          ? await getIt<RecipeRepository>().updateRecipe(recipe)
          : await getIt<RecipeRepository>().addRecipe(recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(recipe);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackIconButton(),
        title: Text(
          isEditMode ? 'Edit Recipe' : 'Create Recipe',
        ),
        actions: [
          BlocBuilder<UserCubit, UserState>(
            bloc: getIt<UserCubit>(),
            builder: (context, state) {
              final user = state is UserLoaded ? state.user : null;
              return TextButton(
                onPressed: () {
                  if (user != null && !isLoading) {
                    saveRecipe(user);
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: context.theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ReactiveForm(
        formGroup: formGroup,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImagePickerCard(
              selectedImage: selectedImage,
              existingImage: existingImage,
              onTap: pickImage,
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Basic Information',
              icon: SolarIconsOutline.documentText,
              children: [
                const SizedBox(height: 16),
                const StyledFormField(
                  name: FormControlName.title,
                  label: 'Recipe Title',
                  hintText: 'Enter recipe title',
                  icon: SolarIconsOutline.bookmark,
                ),
                const SizedBox(height: 16),
                const StyledFormField(
                  name: FormControlName.description,
                  label: 'Description',
                  hintText: 'Tell us about your recipe',
                  icon: SolarIconsOutline.text,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const StyledFormField(
                  name: FormControlName.duration,
                  label: 'Cooking Time (minutes)',
                  hintText: 'e.g., 30',
                  icon: SolarIconsOutline.clockCircle,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CategorySelector(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Ingredients',
              icon: SolarIconsOutline.leaf,
              trailing: AddButton(onPressed: addIngredient),
              children: [
                const SizedBox(height: 16),
                ReactiveFormArray<String>(
                  formArrayName: FormControlName.ingredients,
                  builder: (context, formArray, child) {
                    return Column(
                      children:
                          List.generate(formArray.controls.length, (index) {
                        return IngredientField(
                          key: ValueKey(
                            'ingredient_${formArray.controls[index].hashCode}',
                          ),
                          index: index,
                          formControl:
                              formArray.controls[index] as FormControl<String>,
                          onRemove: formArray.controls.length > 1
                              ? () => removeIngredient(index)
                              : null,
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Cooking Steps',
              icon: SolarIconsOutline.listArrowDown,
              trailing: AddButton(onPressed: addStep),
              children: [
                const SizedBox(height: 16),
                ReactiveFormArray<String>(
                  formArrayName: FormControlName.steps,
                  builder: (context, formArray, child) {
                    return Column(
                      children:
                          List.generate(formArray.controls.length, (index) {
                        return StepField(
                          key: ValueKey(
                            'step_${formArray.controls[index].hashCode}',
                          ),
                          index: index,
                          formControl:
                              formArray.controls[index] as FormControl<String>,
                          onRemove: formArray.controls.length > 1
                              ? () => removeStep(index)
                              : null,
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class StyledFormField extends StatelessWidget {
  final String name;
  final String label;
  final String hintText;
  final IconData icon;
  final int? maxLines;
  final TextInputType? keyboardType;

  const StyledFormField({
    required this.name,
    required this.label,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        CustomFormTextField<String>(
          name: name,
          maxLines: maxLines,
          prefix: Icon(icon),
          hintText: hintText,
          filled: true,
          fillColor: context.isDarkMode ? Colors.grey.shade900 : Colors.white,
        ),
      ],
    );
  }
}
