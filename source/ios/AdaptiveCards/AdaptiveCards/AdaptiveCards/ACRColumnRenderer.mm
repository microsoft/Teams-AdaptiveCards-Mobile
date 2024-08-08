//
//  ACRColumnRenderer
//  ACRColumnRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRColumnRenderer.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRColumnSetView.h"
#import "ACRColumnView.h"
#import "ACRRendererPrivate.h"
#import "Column.h"
#import "SharedAdaptiveCard.h"
#import "UtiliOS.h"
#import "FlowLayout.h"
#import "AreaGridLayout.h"

@implementation ACRColumnRenderer

+ (ACRColumnRenderer *)getInstance
{
    static ACRColumnRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRColumn;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    if (![viewGroup isKindOfClass:[ACRColumnSetView class]]) {
        return nil;
    }

    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Column> columnElem = std::dynamic_pointer_cast<Column>(elem);
    
    //Layout
    float widthOfElement = [rootView widthForElement:elem->GetInternalId().Hash()];
    std::shared_ptr<Layout> final_layout = [self finalLayoutToApply:acoElem config:acoConfig];
    if(final_layout->GetLayoutContainerType() == LayoutContainerType::Flow)
    {
        std::shared_ptr<FlowLayout> flow_layout = std::dynamic_pointer_cast<FlowLayout>(final_layout);
        // layout using flow layout
    }
    else if (final_layout->GetLayoutContainerType() == LayoutContainerType::AreaGrid)
    {
        std::shared_ptr<AreaGridLayout> grid_layout = std::dynamic_pointer_cast<AreaGridLayout>(final_layout);
        // layout using Area Grid
    }
    else
    {
        // default stack based layout
    }

    [rootView.context pushBaseCardElementContext:acoElem];

    ACRColumnView *column = [[ACRColumnView alloc] initWithStyle:(ACRContainerStyle)columnElem->GetStyle()
                                                     parentStyle:[viewGroup style]
                                                      hostConfig:acoConfig
                                                       superview:viewGroup];

    column.rtl = rootView.context.rtl;

    column.pixelWidth = columnElem->GetPixelWidth();
    auto width = columnElem->GetWidth();
    if (width.empty() || width == "stretch") {
        column.columnWidth = @"stretch";
    } else if (width == "auto") {
        column.columnWidth = @"auto";
    } else {
        try {
            column.relativeWidth = std::stof(width);
            column.hasMoreThanOneRelativeWidth = ((ACRColumnSetView *)viewGroup).hasMoreThanOneColumnWithRelatvieWidth;
        } catch (...) {
            [rootView addWarnings:ACRInvalidValue mesage:@"Invalid column width is given"];
            column.columnWidth = @"stretch";
        }
    }

    ACRColumnSetView *columnsetView = (ACRColumnSetView *)viewGroup;
    column.isLastColumn = columnsetView.isLastColumn;
    column.columnsetView = columnsetView;

    [ACRRenderer render:column
               rootView:rootView
                 inputs:inputs
          withCardElems:columnElem->GetItems()
          andHostConfig:acoConfig];

    [column configureLayoutAndVisibility:GetACRVerticalContentAlignment(columnElem->GetVerticalContentAlignment().value_or(VerticalContentAlignment::Top))
                               minHeight:columnElem->GetMinHeight()
                              heightType:GetACRHeight(columnElem->GetHeight())
                                    type:ACRColumn];

    [column setClipsToBounds:NO];

    std::shared_ptr<BaseActionElement> selectAction = columnElem->GetSelectAction();
    ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];

    [self configureBorderForElement:acoElem container:column config:acoConfig];
    
    [column configureForSelectAction:acoSelectAction rootView:rootView];

    column.shouldGroupAccessibilityChildren = YES;

    [viewGroup addArrangedSubview:column];

    // viewGroup and column has to be in view hierarchy before configBleed is called
    configBleed(rootView, elem, column, acoConfig, viewGroup);

    renderBackgroundImage(columnElem->GetBackgroundImage(), column, rootView);

    [rootView.context popBaseCardElementContext:acoElem];

    column.accessibilityElements = [column getArrangedSubviews];

    return column;
}

-(std::shared_ptr<Layout>)finalLayoutToApply:(ACOBaseCardElement *)acoElem config:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Column> containerElem = std::dynamic_pointer_cast<Column>(elem);
    ACRRegistration *reg = [ACRRegistration getInstance];
    HostWidthConfig hostWidthConfig = [acoConfig getHostConfig]->getHostWidth();
    HostWidth hostWidth = convertHostCardContainerToHostWidth([reg getHostCardContainer], hostWidthConfig);
    std::vector<std::shared_ptr<Layout>> layoutArray = containerElem->GetLayouts();
    std::shared_ptr<Layout> final_layout;
    if (const auto& layoutArray = containerElem->GetLayouts(); !layoutArray.empty())
    {
        for (const auto& layout : layoutArray)
        {
            if(layout->GetLayoutContainerType() == LayoutContainerType::None)
            {
                continue;
            }
            
            if(layout->MeetsTargetWidthRequirement(hostWidth))
            {
                final_layout = layout;
                break;
            }
            else if (layout->GetTargetWidth() == TargetWidthType::Default)
            {
                final_layout = layout;
            }
        }
    }
    
    if (final_layout == nullptr)
    {
        final_layout = std::make_shared<Layout>();
        final_layout->SetLayoutContainerType(LayoutContainerType::Stack);
        final_layout->SetTargetWidth(TargetWidthType::Default);
    }
    
    return final_layout;
}

- (void)configUpdateForUIImageView:(ACRView *)rootView acoElem:(ACOBaseCardElement *)acoElem config:(ACOHostConfig *)acoConfig image:(UIImage *)image imageView:(UIImageView *)imageView
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Column> columnElem = std::dynamic_pointer_cast<Column>(elem);
    auto backgroundImageProperties = columnElem->GetBackgroundImage();

    renderBackgroundImage(rootView, backgroundImageProperties.get(), imageView, image);
}

- (void)configureBorderForElement:(ACOBaseCardElement *)acoElem container:(ACRContentStackView *)container config:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Column> containerElem = std::dynamic_pointer_cast<Column>(elem);
    bool shouldShowBorder = containerElem->GetShowBorder();
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    if(shouldShowBorder)
    {
        container.layer.borderWidth = config->GetBorderWidth(containerElem->GetElementType());
        ACRContainerStyle style = (ACRContainerStyle)containerElem->GetStyle();
        auto borderColor = config->GetBorderColor([ACOHostConfig getSharedContainerStyle:style]);
        UIColor *color = [ACOHostConfig convertHexColorCodeToUIColor:borderColor];
        // we will add padding for any column element which has shouldShowBorder.
        [container applyPadding:config->GetSpacing().paddingSpacing priority:1000];
        [[container layer] setBorderColor:[color CGColor]];
    }
    
    bool roundedCorner = containerElem->GetRoundedCorners();
    if (roundedCorner)
    {
        container.layer.cornerRadius = config->GetCornerRadius(containerElem->GetElementType());
    }
}

@end
