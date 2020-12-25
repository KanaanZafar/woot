import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:wootter_x/widgets/customWidgets.dart';

class ComposeWootPool extends StatelessWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final Function onCrossIconPressed;
  const ComposeWootPool({Key key, this.fbKey, this.onCrossIconPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 50.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(left: 5.0),
              width: fullWidth(context) * .7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                margin: EdgeInsets.only(right: 80),
                child: FormBuilder(
                  key: fbKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        attribute: 'option1',
                        decoration:
                            InputDecoration(hintText: "Please enter Option 1"),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(25),
                        ],
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        attribute: 'option2',
                        decoration:
                            InputDecoration(hintText: "Please enter Option 2"),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(25),
                        ],
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        attribute: 'option3',
                        decoration:
                            InputDecoration(hintText: "Please enter Option 3"),
                        validators: [
                          FormBuilderValidators.maxLength(25),
                        ],
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        attribute: 'option4',
                        decoration:
                            InputDecoration(hintText: "Please enter Option 4"),
                        validators: [
                          FormBuilderValidators.maxLength(25),
                        ],
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        attribute: 'option5',
                        decoration:
                            InputDecoration(hintText: "Please enter Option 5"),
                        validators: [
                          FormBuilderValidators.maxLength(25),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black54),
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  iconSize: 20,
                  onPressed: onCrossIconPressed,
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
