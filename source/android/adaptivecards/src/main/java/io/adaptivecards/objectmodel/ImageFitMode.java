/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public enum ImageFitMode {
  Cover,
  Contain,
  Fill;

  public final int swigValue() {
    return swigValue;
  }

  public static ImageFitMode swigToEnum(int swigValue) {
    ImageFitMode[] swigValues = ImageFitMode.class.getEnumConstants();
    if (swigValue < swigValues.length && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (ImageFitMode swigEnum : swigValues)
      if (swigEnum.swigValue == swigValue)
        return swigEnum;
    throw new IllegalArgumentException("No enum " + ImageFitMode.class + " with value " + swigValue);
  }

  @SuppressWarnings("unused")
  private ImageFitMode() {
    this.swigValue = SwigNext.next++;
  }

  @SuppressWarnings("unused")
  private ImageFitMode(int swigValue) {
    this.swigValue = swigValue;
    SwigNext.next = swigValue+1;
  }

  @SuppressWarnings("unused")
  private ImageFitMode(ImageFitMode swigEnum) {
    this.swigValue = swigEnum.swigValue;
    SwigNext.next = this.swigValue+1;
  }

  private final int swigValue;

  private static class SwigNext {
    private static int next = 0;
  }
}

