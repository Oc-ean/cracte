import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:cracte/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({super.key});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final FormGroup _formGroup = fb.group({
    FormControlName.search: FormControl<String>(),
  });

  late final RecipeSearchCubit _searchCubit;
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCubit = getIt<RecipeSearchCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchCubit.searchGoals(query: query);
      } else {
        _searchCubit.clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackIconButton(),
        title: _buildSearchField(),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchField() {
    return ReactiveForm(
      formGroup: _formGroup,
      child: CustomFormTextField<String>(
        name: FormControlName.search,
        hintText: 'Search Recipe',
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        borderRadius: 24.0,
        isUnderlined: true,
        // filled: true,
        suffix: ReactiveValueListenableBuilder<String>(
          formControlName: FormControlName.search,
          builder: (context, control, _) {
            return control.value?.isNotEmpty == true
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      control.value = '';
                      _searchCubit.clearSearch();
                    },
                  )
                : const SizedBox.shrink();
          },
        ),
        textCapitalization: TextCapitalization.none,
        onChanged: (control) {
          if (control!.isNotEmpty) {
            _performSearch(control);
          }
          return control;
        },
        onSubmitted: (control) {
          if (control.value?.isNotEmpty == true) {
            _searchCubit.searchGoals(query: control.value!);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<RecipeSearchCubit, RecipeSearchState>(
      bloc: _searchCubit,
      builder: (context, state) {
        return switch (state) {
          RecipeSearchInitial() => _buildInitialView(context),
          RecipeSearchLoading() => const DummyLoadingPostLists(),
          RecipeSearchEmpty() => _buildEmptyView(context),
          RecipeSearchLoaded() => _buildResultsList(state, context),
          RecipeSearchError() => CustomErrorWidget(onPressed: () {}),
          _ => CustomErrorWidget(onPressed: () {}),
        };
      },
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(searchLottie, height: 300),
          const SizedBox(height: 6),
          Text(
            'Start typing to search recipe',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final searchText =
        _formGroup.control(FormControlName.search).value?.toString() ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(errorSearchLottie, height: 300, width: 300),
          const SizedBox(height: 6),
          Text(
            'No Posts Found Matching "$searchText"',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(RecipeSearchLoaded state, BuildContext context) {
    if (state.recipes.isEmpty) {
      return _buildEmptyView(context);
    }

    final recipes = state.recipes;

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: sortRecipe(recipes).length,
      itemBuilder: (context, index) {
        final recipe = sortRecipe(recipes)[index];
        return HorizontalRecipeCard(
          recipe: recipe,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _searchCubit.clearSearch();
    super.dispose();
  }
}
