package com.example.ac_sdk


/**
 * Used to inform child elements of their rendering context. Renderers should apply all supplied
 * arguments relevant to their element, unless overridden by a declared property on that element.
 *
 * Renderers with any children must use the copy constructor to pass arguments on. If any arguments
 * were overridden by a declared property, the new value(s) must be set on the copied instance
 * before passing arguments on.
 */
data class RenderArgs(
    var ancestorHasFallback: Boolean = false,
    //var containerStyle: ContainerStyle = ContainerStyle.Default,
    var allowAboveTitleIconPlacement: Boolean = false,
    var containerCardId: Long = 0,
    var isColumnHeader: Boolean = false,
   // var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.Left,
    var isRootLevelActions: Boolean = false,
    var ancestorHasSelectAction: Boolean = false
) {
    constructor(renderArgs: RenderArgs) : this(
        ancestorHasFallback = renderArgs.ancestorHasFallback,
        //containerStyle = renderArgs.containerStyle,
        allowAboveTitleIconPlacement = renderArgs.allowAboveTitleIconPlacement,
        containerCardId = renderArgs.containerCardId,
        isColumnHeader = renderArgs.isColumnHeader,
       // horizontalAlignment = renderArgs.horizontalAlignment,
        isRootLevelActions = renderArgs.isRootLevelActions,
        ancestorHasSelectAction = renderArgs.ancestorHasSelectAction
    )
}