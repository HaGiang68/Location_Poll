import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/home/home_module.dart';
import 'package:location_poll/features/maps/map_module.dart';
import 'package:location_poll/features/poll/create/bloc/create_cubit.dart';
import 'package:location_poll/features/poll/create/bloc/create_state.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/global_ui/theme/buttons.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/input_field_decoration.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/models/choice.dart';
import 'package:location_poll/models/poll.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreatePage extends StatelessWidget {
  static const String routeName = '/create';
  static const String routeNameEdit = '/create/edit';

  final Poll? poll;

  const CreatePage({Key? key, this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<CreateCubit>()..createInit(poll),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create', style: OwnTextStylesDarkM.ownTextStyle()),
          backgroundColor: ColorTheme.barColorBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () =>
                Modular.to.navigate(HomeModule.routeName), //For popping of view
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              16,
              8,
              8,
            ),
            child: BlocListener<CreateCubit, CreateState>(
              listener: (context, state) {
                if (state is CreatePageSavePoll) {
                  showTopSnackBar(
                      context,
                      const CustomSnackBar.success(
                          message:
                              'Your poll has been successfully added to the table!'));
                  Modular.to.navigate(HomeModule.routeName);
                }
                if (state is CreatePageError) {
                  showTopSnackBar(
                      context, const CustomSnackBar.error(message: 'Error'));
                }
              },
              child: CreateView(),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateView extends StatelessWidget {
  CreateView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("dd-MM HH:mm");
    return BlocBuilder<CreateCubit, CreateState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                TextFormField(
                  initialValue: state.title,
                  onChanged: (value) {
                    context.read<CreateCubit>().titleChange(value);
                  },
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  maxLength: 50,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                    labelText: "Title",
                  ),
                  validator: (val) =>
                      state.isTitleNotEmpty ? null : 'Enter a title',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: state.question,
                  onChanged: (value) {
                    context.read<CreateCubit>().questionChange(value);
                  },
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  maxLength: 50,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                    labelText: "Question",
                  ),
                  validator: (val) =>
                      state.isQuestionNotEmpty ? null : 'Enter a question',
                ),

                const SizedBox(height: 10),
                const ChoiceList(),
                //Location
                ElevatedButton(
                  onPressed: () => {
                    Modular.to.pushNamed(
                        PollModule.routeName + MapsModule.routeName,
                        arguments: [
                          LatLng(state.location.latitude,
                              state.location.longitude),
                          state.parameter == 'km'
                              ? state.radius * 1000
                              : state.radius
                        ])
                  },
                  child: Text(
                    'Maps',
                    style: ButtonTextStylesWhite.buttonTextStyle(),
                  ),
                  style: ButtonStyles.fullSizeButton(),
                ),

                const SizedBox(height: 10),
                //Radius
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextFormField(
                          onChanged: (value) {
                            context
                                .read<CreateCubit>()
                                .radiusChange(double.parse(value));
                          },
                          initialValue: state.radius.toString(),
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          decoration: InputFieldDecorations.defaultDecoration(
                            context: context,
                            labelText: "Radius",
                          ),
                          validator: (val) => state.isRadiusNotEmpty
                              ? null
                              : 'Enter a correct radius',
                        ),
                      ),
                    ),
                    const Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: DropdownParameter(),
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                DateTimeField(
                  enabled: !state.isInEditMode || !state.isPollStarted,
                  readOnly: !state.isInEditMode || !state.isPollStarted,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                    labelText: 'Start Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (val) => validateDateTime(state, val!),
                  format: format,
                  initialValue: state.startDate,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      final ret = DateTimeField.combine(date, time);
                      context.read<CreateCubit>().startDateChange(ret);
                      return ret;
                    } else {
                      return currentValue;
                    }
                  },
                ),
                const SizedBox(height: 10),
                DateTimeField(
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                    labelText: 'End Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  initialValue: state.endDate,
                  validator: (val) => validateDateTime(state, val!),
                  format: format,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now(),
                        ),
                      );
                      final ret = DateTimeField.combine(date, time);
                      context.read<CreateCubit>().endDateChange(ret);
                      return ret;
                    } else {
                      return currentValue;
                    }
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                FloatingActionButton.extended(
                  key: const Key('save_poll'),
                  label: Text('Save',
                      style: ButtonTextStylesWhite.buttonTextStyle()),
                  icon: Icon(
                    Icons.add,
                    color: ColorTheme.colorWhite,
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<CreateCubit>().savePoll();
                    }
                  },
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  String? validateDateTime(CreateState state, DateTime val) {
    if (!state.isStartDateBeforeEndDate) {
      return "End date before start date";
    } else {
      return null;
    }
  }

  Widget buildAddButtonWidget(BuildContext context, int index) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.read<CreateCubit>().addChoice(Choice(
                  choice: '',
                  choiceId: index,
                  counter: 0,
                )),
            child: const Icon(
              Icons.add,
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondary),
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).secondaryHeaderColor;
                }
              }),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class DropdownParameter extends StatelessWidget {
  const DropdownParameter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateCubit, CreateState>(builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
        child: DropdownButton<String>(
            value: state.parameter,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            isExpanded: true,
            itemHeight: 60,
            dropdownColor: Theme.of(context).colorScheme.surface,
            focusColor: Theme.of(context).colorScheme.surface,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            underline: Container(
              height: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (String? value) {
              context.read<CreateCubit>().parameterChange(value);
            },
            items: <String>['km', 'm']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList()),
      );
    });
  }
}

class ChoiceList extends StatelessWidget {
  const ChoiceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateCubit, CreateState>(
      builder: (context, state) {
        final List<Choice> choices = state.choices;
        return Column(children: [
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: choices.length,
              itemBuilder: (BuildContext context, int index) {
                return choiceElement(
                    context, index, state.choices[index], choices.length);
              }),
          buildAddButtonWidget(context, choices.length)
        ]);
      },
    );
  }

  Widget choiceElement(
      BuildContext context, int index, Choice choice, int choiceLength) {
    return Row(
      children: [
        Expanded(
          flex: 15,
          child: TextFormField(
            onChanged: (value) {
              context.read<CreateCubit>().changeTextChoice(index, value);
            },
            initialValue: choice.choice.toString(),
            keyboardType: TextInputType.text,
            autocorrect: false,
            maxLength: 25,
            decoration: InputFieldDecorations.defaultDecoration(
              context: context,
              labelText: 'Choice ' + (index + 1).toString(),
            ),
            validator: (val) => val != '' ? null : 'Enter a choice.',
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        choiceLength > 2
            ? Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: deleteChoiceButtonWidget(context, index),
                ),
              )
            : Expanded(
                flex: 2,
                child: Container(),
              )
      ],
    );
  }

  Widget deleteChoiceButtonWidget(BuildContext context, int index) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
        onPressed: () {
          context.read<CreateCubit>().removeChoice(index);
        },
        child: const Icon(Icons.delete),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(const CircleBorder()),
          padding: MaterialStateProperty.all(const EdgeInsets.all(7)),
          backgroundColor:
              MaterialStateProperty.all(ColorTheme.deleteButtonColorRed),
        ),
      ),
    ]);
  }

  Widget buildAddButtonWidget(BuildContext context, int index) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Choice emptyChoice =
                  Choice(choice: "", choiceId: index, counter: 0);
              index < 10
                  ? context.read<CreateCubit>().addChoice(emptyChoice)
                  : showTopSnackBar(
                      context,
                      const CustomSnackBar.error(
                          message: 'Only 10 choices allowed'));
            },
            child: const Icon(Icons.add),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.secondary,
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).secondaryHeaderColor;
                }
              }),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
