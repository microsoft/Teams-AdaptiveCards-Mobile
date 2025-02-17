/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class BadgeStyleDefinition {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected BadgeStyleDefinition(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(BadgeStyleDefinition obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  @SuppressWarnings("deprecation")
  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        AdaptiveCardObjectModelJNI.delete_BadgeStyleDefinition(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public void setFilledStyle(BadgeAppearanceDefinition value) {
    AdaptiveCardObjectModelJNI.BadgeStyleDefinition_filledStyle_set(swigCPtr, this, BadgeAppearanceDefinition.getCPtr(value), value);
  }

  public BadgeAppearanceDefinition getFilledStyle() {
    long cPtr = AdaptiveCardObjectModelJNI.BadgeStyleDefinition_filledStyle_get(swigCPtr, this);
    return (cPtr == 0) ? null : new BadgeAppearanceDefinition(cPtr, false);
  }

  public void setTintStyle(BadgeAppearanceDefinition value) {
    AdaptiveCardObjectModelJNI.BadgeStyleDefinition_tintStyle_set(swigCPtr, this, BadgeAppearanceDefinition.getCPtr(value), value);
  }

  public BadgeAppearanceDefinition getTintStyle() {
    long cPtr = AdaptiveCardObjectModelJNI.BadgeStyleDefinition_tintStyle_get(swigCPtr, this);
    return (cPtr == 0) ? null : new BadgeAppearanceDefinition(cPtr, false);
  }

  public static BadgeStyleDefinition Deserialize(JsonValue json, BadgeStyleDefinition defaultValue) {
    return new BadgeStyleDefinition(AdaptiveCardObjectModelJNI.BadgeStyleDefinition_Deserialize(JsonValue.getCPtr(json), json, BadgeStyleDefinition.getCPtr(defaultValue), defaultValue), true);
  }

  public BadgeStyleDefinition() {
    this(AdaptiveCardObjectModelJNI.new_BadgeStyleDefinition(), true);
  }

}
