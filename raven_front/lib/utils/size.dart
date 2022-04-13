import 'package:flutter/material.dart';

double relativeHeight(context, height) =>
    MediaQuery.of(context).size.height * (height / 760);
