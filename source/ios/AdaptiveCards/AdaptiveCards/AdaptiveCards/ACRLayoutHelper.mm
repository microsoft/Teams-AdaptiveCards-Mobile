//
//  ACRWidthDistributor.m
//  AdaptiveCards
//
//  Created by Abhishek on 08/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRLayoutHelper.h"
#import "Column.h"
#import "ColumnSet.h"
#import "Table.h"
#import "TableRow.h"
#import "TableCell.h"
#import "UtiliOS.h"
#import "ACOHostConfigPrivate.h"

using namespace AdaptiveCards;

@implementation ACRLayoutHelper

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)distributeWidth:(float)parentWidth
               rootView:(ACRView *)rootView
             forElement:(std::shared_ptr<AdaptiveCard> const &)card
          andHostConfig:(ACOHostConfig *)config
{
    // we will not do width distribution if flow layout do't apply anywhere in card
    if(![self shouldUseNewLayout:rootView forElement:card andHostConfig:config])
    {
        return;
    }
    std::vector<std::shared_ptr<BaseCardElement>> body = card->GetBody();
    float childrenWidth = parentWidth/(body.size()) ;
    for (const auto &element : body) 
    {
        [self distribute:childrenWidth rootView:rootView forElement:element andHostConfig:config];
    }
}

- (void)distribute:(float)parentWidth
          rootView:(ACRView *)rootView
        forElement:(std::shared_ptr<BaseCardElement> const &)elem
     andHostConfig:(ACOHostConfig *)config
{
    // self width is always equal to parent
//    [rootView setWidthForElememt:elem->GetInternalId().Hash() width:parentWidth];
    
    // parent width is equally divided amongst all children
    switch (elem->GetElementType()) 
    {
        case CardElementType::Container:
        {
            std::shared_ptr<Container> container = std::dynamic_pointer_cast<Container>(elem);
            float childrenWidth = parentWidth/(container->GetItems().size()) ;
            for (const auto &item : container->GetItems()) 
            {
                [self distribute:childrenWidth rootView:rootView forElement:item andHostConfig:config];
            }
            break;
        }
        case CardElementType::ColumnSet:
        {
            std::shared_ptr<ColumnSet> columnSetElem = std::dynamic_pointer_cast<ColumnSet>(elem);
            
            std::shared_ptr<HostConfig> hostConfig = [config getHostConfig];
            unsigned int padding = hostConfig->GetSpacing().paddingSpacing;
            unsigned int spacing = getSpacing(elem->GetSpacing(), hostConfig);
            long numberOfColumns = columnSetElem->GetColumns().size();
            // removing padding of coloumSet and spacing between elemenets
            float availableSpace = (parentWidth - (2 * padding) - ((numberOfColumns - 1)*spacing));
            
            float childrenWidth = availableSpace/numberOfColumns ;
            for (const auto &column : columnSetElem->GetColumns())
            {
                [self distribute:childrenWidth rootView:rootView forElement:column andHostConfig:config];
            }
            break;
        }
        case CardElementType::Table:
        {
            std::shared_ptr<Table> table = std::dynamic_pointer_cast<Table>(elem);
            std::vector<std::shared_ptr<TableColumnDefinition>> colums = table->GetColumns();
            long numberOfColumns = colums.size();
            int cellSpacing = [config getHostConfig]->GetTable().cellSpacing;
            float availableSpace = (parentWidth - ((numberOfColumns - 1)*cellSpacing));
           
            //remove spacing b/w cells, padding is taken care by the cell renderer
            float childrenWidth = availableSpace/numberOfColumns;
            std::vector<std::shared_ptr<TableRow>> tableRows = table->GetRows();
            for (const auto &row : tableRows) 
            {
                std::vector<std::shared_ptr<TableCell>> tableCells = row->GetCells();
                for (const auto &cell : tableCells) 
                {
                    [self distribute:childrenWidth rootView:rootView forElement:cell andHostConfig:config];
                }
            }
            
            //set pixel width also for Table Columns
            for (const auto &colum : colums)
            {
                colum->SetPixelWidth(childrenWidth);
            }
            
            break;
        }
            
        case CardElementType::Column:
        {
            std::shared_ptr<Column> column = std::dynamic_pointer_cast<Column>(elem);
            /// set column width explicitly, this way we will bypass existing logic
            column->SetPixelWidth(parentWidth);
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)shouldUseNewLayout:(ACRView *)rootView
                forElement:(std::shared_ptr<AdaptiveCard> const &)card
             andHostConfig:(ACOHostConfig *)config
{
    NSObject<ACRIFeatureFlagResolver> *featureFlagResolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
    BOOL isGridLayoutEnabled = [featureFlagResolver boolForFlag:@"isGridLayoutEnabled"] ?: NO;

    if(!isGridLayoutEnabled)
    {
        return NO;
    }
    
    std::shared_ptr<AdaptiveCards::Layout> layout = [self layoutToApplyFrom:card->GetLayouts() andHostConfig:config];
    
    BOOL isFlow = (layout->GetLayoutContainerType() == LayoutContainerType::Flow);
    
    std::vector<std::shared_ptr<BaseCardElement>> body = card->GetBody();
    for (const auto &element : body)
    {
        isFlow = isFlow || ([self shouldUseNewLayoutForView:rootView forElement:element andHostConfig:config]);
    }
    
    return isFlow;
}

- (BOOL)shouldUseNewLayoutForView:(ACRView *)rootView
                       forElement:(std::shared_ptr<BaseCardElement> const &)elem
                    andHostConfig:(ACOHostConfig *)config
{
    switch (elem->GetElementType())
    {
        case CardElementType::Container:
        {
            std::shared_ptr<Container> container = std::dynamic_pointer_cast<Container>(elem);
            std::shared_ptr<AdaptiveCards::Layout> layout = [self layoutToApplyFrom:container->GetLayouts() andHostConfig:config];
            
            BOOL isFlow = (layout->GetLayoutContainerType() == LayoutContainerType::Flow);
            
            for (const auto &item : container->GetItems())
            {
                isFlow = isFlow || ([self shouldUseNewLayoutForView:rootView forElement:item andHostConfig:config]);
            }

            return isFlow;
        }
        case CardElementType::ColumnSet:
        {
            std::shared_ptr<ColumnSet> columnSetElem = std::dynamic_pointer_cast<ColumnSet>(elem);
            BOOL isFlow = NO;
            for (const auto &column : columnSetElem->GetColumns())
            {
                isFlow = isFlow || ([self shouldUseNewLayoutForView:rootView forElement:column andHostConfig:config]);
            }
            return isFlow;
        }
        case CardElementType::Table:
        {
            std::shared_ptr<Table> table = std::dynamic_pointer_cast<Table>(elem);
            std::vector<std::shared_ptr<TableColumnDefinition>> colums = table->GetColumns();
            std::vector<std::shared_ptr<TableRow>> tableRows = table->GetRows();
            BOOL isFlow = NO;
            for (const auto &row : tableRows)
            {
                std::vector<std::shared_ptr<TableCell>> tableCells = row->GetCells();
                for (const auto &cell : tableCells)
                {
                    isFlow = isFlow || ([self shouldUseNewLayoutForView:rootView forElement:cell andHostConfig:config]);
                }
            }
            return isFlow;
        }
        case CardElementType::TableCell:
        {
            std::shared_ptr<TableCell> container = std::dynamic_pointer_cast<TableCell>(elem);
            std::shared_ptr<AdaptiveCards::Layout> layout = [self layoutToApplyFrom:container->GetLayouts() andHostConfig:config];
            return (layout->GetLayoutContainerType() == LayoutContainerType::Flow);
        }
        case CardElementType::Column:
        {
            std::shared_ptr<Column> container = std::dynamic_pointer_cast<Column>(elem);
            std::shared_ptr<AdaptiveCards::Layout> layout = [self layoutToApplyFrom:container->GetLayouts() andHostConfig:config];
            return (layout->GetLayoutContainerType() == LayoutContainerType::Flow);
        }
            
        default:
            break;
    }
    return NO;
}

- (std::shared_ptr<AdaptiveCards::Layout>)layoutToApplyFrom:(std::vector<std::shared_ptr<Layout>>)layoutArray andHostConfig:(ACOHostConfig *)config
{
    ACRRegistration *reg = [ACRRegistration getInstance];
    HostWidthConfig hostWidthConfig = [config getHostConfig]->getHostWidth();
    HostWidth hostWidth = convertHostCardContainerToHostWidth([reg getHostCardContainer], hostWidthConfig);
    std::shared_ptr<Layout> final_layout;
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
    
    
    if (final_layout == nullptr)
    {
        final_layout = std::make_shared<Layout>();
        final_layout->SetLayoutContainerType(LayoutContainerType::Stack);
        final_layout->SetTargetWidth(TargetWidthType::Default);
    }
    
    return final_layout;
}


@end
