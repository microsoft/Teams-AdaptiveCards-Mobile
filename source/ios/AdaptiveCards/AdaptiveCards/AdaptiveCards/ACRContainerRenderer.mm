//
//  ACRContainerRenderer
//  ACRContainerRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRContainerRenderer.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRColumnView.h"
#import "ACRRendererPrivate.h"
#import "ACRViewPrivate.h"
#import "Container.h"
#import "SharedAdaptiveCard.h"
#import "UtiliOS.h"
#import "FlowLayout.h"
#import "AreaGridLayout.h"

@implementation ACRContainerRenderer

+ (ACRContainerRenderer *)getInstance
{
    static ACRContainerRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRContainer;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Container> containerElem = std::dynamic_pointer_cast<Container>(elem);
    
    //Layout
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

    ACRColumnView *container = [[ACRColumnView alloc] initWithStyle:(ACRContainerStyle)containerElem->GetStyle()
                                                        parentStyle:[viewGroup style]
                                                         hostConfig:acoConfig
                                                          superview:viewGroup];
    container.rtl = rootView.context.rtl;

    [viewGroup addArrangedSubview:container];
    
    [self configureBorderForElement:acoElem container:container config:acoConfig];

    configBleed(rootView, elem, container, acoConfig);

    renderBackgroundImage(containerElem->GetBackgroundImage(), container, rootView);

    container.frame = viewGroup.frame;

    [ACRRenderer render:container
               rootView:rootView
                 inputs:inputs
          withCardElems:containerElem->GetItems()
          andHostConfig:acoConfig];

    [container setClipsToBounds:NO];

    std::shared_ptr<BaseActionElement> selectAction = containerElem->GetSelectAction();
    ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];
    [container configureForSelectAction:acoSelectAction rootView:rootView];

    [container configureLayoutAndVisibility:GetACRVerticalContentAlignment(containerElem->GetVerticalContentAlignment().value_or(VerticalContentAlignment::Top))
                                  minHeight:containerElem->GetMinHeight()
                                 heightType:GetACRHeight(containerElem->GetHeight())
                                       type:ACRContainer];

    [rootView.context popBaseCardElementContext:acoElem];

    container.accessibilityElements = [container getArrangedSubviews];

    return container;
}

-(std::shared_ptr<Layout>)finalLayoutToApply:(ACOBaseCardElement *)acoElem config:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Container> containerElem = std::dynamic_pointer_cast<Container>(elem);
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
    std::shared_ptr<Container> containerElem = std::dynamic_pointer_cast<Container>(elem);
    auto backgroundImageProperties = containerElem->GetBackgroundImage();

    renderBackgroundImage(rootView, backgroundImageProperties.get(), imageView, image);
}

- (void)configureBorderForElement:(ACOBaseCardElement *)acoElem container:(ACRContentStackView *)container config:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Container> containerElem = std::dynamic_pointer_cast<Container>(elem);
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    bool shouldShowBorder = containerElem->GetShowBorder();
    if(shouldShowBorder)
    {
        ACRContainerStyle style = (ACRContainerStyle)containerElem->GetStyle();
        container.layer.borderWidth = config->GetBorderWidth(containerElem->GetElementType());
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
