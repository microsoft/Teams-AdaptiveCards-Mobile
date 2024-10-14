/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class CarouselPage extends StyledCollectionElement {
  private transient long swigCPtr;
  private transient boolean swigCMemOwnDerived;

  protected CarouselPage(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.CarouselPage_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(CarouselPage obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void swigSetCMemOwn(boolean own) {
    swigCMemOwnDerived = own;
    super.swigSetCMemOwn(own);
  }

  @SuppressWarnings("deprecation")
  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_CarouselPage(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public CarouselPage() {
    this(AdaptiveCardObjectModelJNI.new_CarouselPage__SWIG_0(), true);
  }

  public CarouselPage(CarouselPage arg0) {
    this(AdaptiveCardObjectModelJNI.new_CarouselPage__SWIG_1(CarouselPage.getCPtr(arg0), arg0), true);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.CarouselPage_SerializeToJsonValue(swigCPtr, this), true);
  }

  public void PopulateKnownPropertiesSet() {
    AdaptiveCardObjectModelJNI.CarouselPage_PopulateKnownPropertiesSet(swigCPtr, this);
  }

  public static CarouselPage Deserialize(ParseContext context, JsonValue root) {
    long cPtr = AdaptiveCardObjectModelJNI.CarouselPage_Deserialize(ParseContext.getCPtr(context), context, JsonValue.getCPtr(root), root);
    return (cPtr == 0) ? null : new CarouselPage(cPtr, true);
  }

  public static CarouselPage DeserializeWithoutCheckingType(ParseContext context, JsonValue root) {
    long cPtr = AdaptiveCardObjectModelJNI.CarouselPage_DeserializeWithoutCheckingType(ParseContext.getCPtr(context), context, JsonValue.getCPtr(root), root);
    return (cPtr == 0) ? null : new CarouselPage(cPtr, true);
  }

  public void DeserializeChildren(ParseContext context, JsonValue value) {
    AdaptiveCardObjectModelJNI.CarouselPage_DeserializeChildren(swigCPtr, this, ParseContext.getCPtr(context), context, JsonValue.getCPtr(value), value);
  }

  public LayoutVector GetLayouts() {
    return new LayoutVector(AdaptiveCardObjectModelJNI.CarouselPage_GetLayouts(swigCPtr, this), false);
  }

  public void SetLayouts(LayoutVector value) {
    AdaptiveCardObjectModelJNI.CarouselPage_SetLayouts(swigCPtr, this, LayoutVector.getCPtr(value), value);
  }

  public BaseCardElementVector GetItems() {
    return new BaseCardElementVector(AdaptiveCardObjectModelJNI.CarouselPage_GetItems__SWIG_0(swigCPtr, this), false);
  }

  public @androidx.annotation.Nullable Boolean GetRtl() {
    StdOptionalBool optvalue = new StdOptionalBool(AdaptiveCardObjectModelJNI.CarouselPage_GetRtl(swigCPtr, this), false);
    return optvalue.has_value() ? optvalue.value() : null;
  }

  public void SetRtl(@androidx.annotation.Nullable Boolean value) {
    StdOptionalBool optvalue = (value == null) ? new StdOptionalBool() : new StdOptionalBool(value);
    {
      AdaptiveCardObjectModelJNI.CarouselPage_SetRtl(swigCPtr, this, StdOptionalBool.getCPtr(optvalue), optvalue);
    }
  }

  public void GetResourceInformation(RemoteResourceInformationVector resourceInfo) {
    AdaptiveCardObjectModelJNI.CarouselPage_GetResourceInformation(swigCPtr, this, RemoteResourceInformationVector.getCPtr(resourceInfo), resourceInfo);
  }

  public static CarouselPage dynamic_cast(BaseCardElement baseCardElement) {
    long cPtr = AdaptiveCardObjectModelJNI.CarouselPage_dynamic_cast(BaseCardElement.getCPtr(baseCardElement), baseCardElement);
    return (cPtr == 0) ? null : new CarouselPage(cPtr, true);
  }

}