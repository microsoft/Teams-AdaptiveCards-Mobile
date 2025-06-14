/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 4.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class SeparatorConfig {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected SeparatorConfig(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(SeparatorConfig obj) {
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
        AdaptiveCardObjectModelJNI.delete_SeparatorConfig(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public void setLineThickness(long value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineThickness_set(swigCPtr, this, value);
  }

  public long getLineThickness() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineThickness_get(swigCPtr, this);
  }

  public void setLineColor(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColor_set(swigCPtr, this, value);
  }

  public String getLineColor() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColor_get(swigCPtr, this);
  }

  public void setLineColorDefault(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorDefault_set(swigCPtr, this, value);
  }

  public String getLineColorDefault() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorDefault_get(swigCPtr, this);
  }

  public void setLineColorEmphasis(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorEmphasis_set(swigCPtr, this, value);
  }

  public String getLineColorEmphasis() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorEmphasis_get(swigCPtr, this);
  }

  public void setLineColorGood(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorGood_set(swigCPtr, this, value);
  }

  public String getLineColorGood() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorGood_get(swigCPtr, this);
  }

  public void setLineColorAttention(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorAttention_set(swigCPtr, this, value);
  }

  public String getLineColorAttention() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorAttention_get(swigCPtr, this);
  }

  public void setLineColorWarning(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorWarning_set(swigCPtr, this, value);
  }

  public String getLineColorWarning() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorWarning_get(swigCPtr, this);
  }

  public void setLineColorAccent(String value) {
    AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorAccent_set(swigCPtr, this, value);
  }

  public String getLineColorAccent() {
    return AdaptiveCardObjectModelJNI.SeparatorConfig_lineColorAccent_get(swigCPtr, this);
  }

  public static SeparatorConfig Deserialize(JsonValue json, SeparatorConfig defaultValue) {
    return new SeparatorConfig(AdaptiveCardObjectModelJNI.SeparatorConfig_Deserialize(JsonValue.getCPtr(json), json, SeparatorConfig.getCPtr(defaultValue), defaultValue), true);
  }

  public SeparatorConfig() {
    this(AdaptiveCardObjectModelJNI.new_SeparatorConfig(), true);
  }

}
