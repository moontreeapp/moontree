import 'package:collection/collection.dart';

/// returns corresponding point on a corresponding linear map
/// example positiveInterpolation(3, .25, 10, 9, 65) -> 24.794871794871796
double positiveInterpolation(
  double input,
  double inputMin,
  double inputMax,
  double outputMin,
  double outputMax,
) =>
    outputMin +
    (input.abs() - inputMin) * (outputMax - outputMin) / (inputMax - inputMin);

/// linear interpolation given 2 ranges
double linearInterpolattion(
  double input,
  double inputMin,
  double inputMax,
  double outputMin,
  double outputMax,
) {
  if (input < inputMin) {
    return outputMin;
  } else if (input > inputMax) {
    return outputMax;
  } else {
    if (input < 0) {
      return outputMin -
          (input.abs() - inputMin) *
              (outputMin - outputMax) /
              (inputMax - inputMin);
    } else {
      return outputMin +
          (input - inputMin) * (outputMax - outputMin) / (inputMax - inputMin);
    }
  }
}

double multipleLinearInterpolation(
  double input, {
  required List<double> inputValues,
  required List<double> outputValues,
  double? inputMin,
  double? inputMax,
  double? outputMin,
  double? outputMax,
}) {
  inputMin = inputMin ?? inputValues.min;
  inputMax = inputMax ?? inputValues.max;
  outputMin = outputMin ?? outputValues.min;
  outputMax = outputMax ?? outputValues.max;
  // Check if the input is within the input range
  if (input < inputValues.min || input > inputValues.max) {
    throw ArgumentError('Input is outside the input range.');
  }
  double inputBelow = inputValues.min;
  double inputAbove = inputValues.max;
  double outputBelow = outputMin;
  double outputAbove = outputMax;
  for (final x in IterableZip([inputValues, outputValues])) {
    if (x.first >= inputBelow && x.first <= input) {
      inputBelow = x.first;
      outputBelow = x.last;
    }
    if (x.first <= inputAbove && x.first >= input) {
      inputAbove = x.first;
      outputAbove = x.last;
    }
  }
  if (outputBelow == outputAbove) {
    return outputBelow;
  }
  return linearInterpolattion(
      input, inputBelow, inputAbove, outputBelow, outputAbove);
}

/// given an example of a prior relationship we return the corresponding value
double correspondingRatio(
  double priorInput,
  double priorOutput,
  double newInput,
) =>
    newInput * priorOutput / priorInput;

/// not sure this works right
double polynomialInterpolation(
  double input,
  List<double> inputValues,
  List<double> outputValues,
) {
  // Check if the input is within the input range
  if (input < inputValues.first || input > inputValues.last) {
    throw ArgumentError('Input is outside the input range.');
  }
  // Perform polynomial interpolation
  double result = 0.0;
  for (int i = 0; i < inputValues.length; i++) {
    double term = outputValues[i];
    for (int j = 0; j < inputValues.length; j++) {
      if (j != i) {
        term *= (input - inputValues[j]) / (inputValues[i] - inputValues[j]);
      }
    }
    result += term;
  }
  return result;
}

/// don't think this works right
double polynomialInterpolationWithinRange(
  double input, {
  required List<double> inputValues,
  required List<double> outputValues,
  double? inputMin,
  double? inputMax,
  double? outputMin,
  double? outputMax,
}) {
  inputMin = inputMin ?? inputValues.min;
  inputMax = inputMax ?? inputValues.max;
  outputMin = outputMin ?? outputValues.min;
  outputMax = outputMax ?? outputValues.max;
  // Check if the input is within the input range
  if (input < inputValues.min || input > inputValues.max) {
    throw ArgumentError('Input is outside the input range.');
  }
  // Perform initial polynomial interpolation
  double result = 0.0;
  for (int i = 0; i < inputValues.length; i++) {
    double term = outputValues[i];
    for (int j = 0; j < inputValues.length; j++) {
      if (j != i) {
        term *= (input - inputValues[j]) / (inputValues[i] - inputValues[j]);
      }
    }
    result += term;
  }
  // If the result is outside the specified output range, interpolate recursively
  if (result < outputMin || result > outputMax) {
    double inputBelow = inputValues.min;
    double inputAbove = inputValues.max;
    double outputBelow = outputMin;
    double outputAbove = outputMax;
    for (final x in IterableZip([inputValues, outputValues])) {
      if (x.first > inputBelow && x.first < input) {
        inputBelow = x.first;
        outputBelow = x.last;
      }
      if (x.first < inputAbove && x.first > input) {
        inputAbove = x.first;
        outputAbove = x.last;
      }
    }
    return polynomialInterpolationWithinRange(
      input,
      inputValues: [inputBelow, inputAbove],
      outputValues: [outputBelow, outputAbove],
      inputMin: inputMin,
      inputMax: inputMax,
      outputMin: outputMin,
      outputMax: outputMax,
    );
  }
  return result;
}
