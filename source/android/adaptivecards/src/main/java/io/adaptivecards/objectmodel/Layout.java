/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class Layout {
  private transient long swigCPtr;
  private transient boolean swigCMemOwn;

  protected Layout(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(Layout obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void swigSetCMemOwn(boolean own) {
    swigCMemOwn = own;
  }

  @SuppressWarnings("deprecation")
  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        AdaptiveCardObjectModelJNI.delete_Layout(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public Layout() {
    this(AdaptiveCardObjectModelJNI.new_Layout__SWIG_0(), true);
  }

  public Layout(Layout arg0) {
    this(AdaptiveCardObjectModelJNI.new_Layout__SWIG_1(Layout.getCPtr(arg0), arg0), true);
  }

  public LayoutContainerType GetLayoutContainerType() {
    return LayoutContainerType.swigToEnum(AdaptiveCardObjectModelJNI.Layout_GetLayoutContainerType(swigCPtr, this));
  }

  public void SetLayoutContainerType(LayoutContainerType value) {
    AdaptiveCardObjectModelJNI.Layout_SetLayoutContainerType(swigCPtr, this, value.swigValue());
  }

  public TargetWidthType GetTargetWidth() {
    return TargetWidthType.swigToEnum(AdaptiveCardObjectModelJNI.Layout_GetTargetWidth(swigCPtr, this));
  }

  public void SetTargetWidth(TargetWidthType value) {
    AdaptiveCardObjectModelJNI.Layout_SetTargetWidth(swigCPtr, this, value.swigValue());
  }

  public boolean ShouldSerialize() {
    return AdaptiveCardObjectModelJNI.Layout_ShouldSerialize(swigCPtr, this);
  }

  public String Serialize() {
    return AdaptiveCardObjectModelJNI.Layout_Serialize(swigCPtr, this);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.Layout_SerializeToJsonValue(swigCPtr, this), true);
  }

  public boolean MeetsTargetWidthRequirement(HostWidth hostWidth) {
    return AdaptiveCardObjectModelJNI.Layout_MeetsTargetWidthRequirement(swigCPtr, this, hostWidth.swigValue());
  }

  public static Layout Deserialize(JsonValue json) {
    long cPtr = AdaptiveCardObjectModelJNI.Layout_Deserialize(JsonValue.getCPtr(json), json);
    return (cPtr == 0) ? null : new Layout(cPtr, true);
  }

  public static Layout DeserializeFromString(String jsonString) {
    long cPtr = AdaptiveCardObjectModelJNI.Layout_DeserializeFromString(jsonString);
    return (cPtr == 0) ? null : new Layout(cPtr, true);
  }

}