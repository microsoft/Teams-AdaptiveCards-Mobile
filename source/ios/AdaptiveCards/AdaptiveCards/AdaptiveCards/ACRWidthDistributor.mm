//
//  ACRWidthDistributor.m
//  AdaptiveCards
//
//  Created by Abhishek on 08/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRWidthDistributor.h"
#import "Column.h"
#import "ColumnSet.h"
#import "Table.h"
#import "TableRow.h"
#import "TableCell.h"

using namespace AdaptiveCards;

@implementation ACRWidthDistributor

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
    std::vector<std::shared_ptr<BaseCardElement>> body = card->GetBody();
    float childrenWidth = parentWidth/(body.size()) ;
    for (const auto &element : body) {
        [self distribute:childrenWidth rootView:rootView forElement:element andHostConfig:config];
    }
}

- (void)distribute:(float)parentWidth
          rootView:(ACRView *)rootView
        forElement:(std::shared_ptr<BaseCardElement> const &)elem
     andHostConfig:(ACOHostConfig *)config
{
    // self width is always equal to parent
    [rootView setWidthForElememt:elem->GetInternalId().Hash() width:parentWidth];
    
    // parent width is equally divided amongst all children
    switch (elem->GetElementType()) {
        case CardElementType::Container:
        {
            std::shared_ptr<Container> container = std::dynamic_pointer_cast<Container>(elem);
            float childrenWidth = parentWidth/(container->GetItems().size()) ;
            for (const auto &item : container->GetItems()) {
                [self distribute:childrenWidth rootView:rootView forElement:item andHostConfig:config];
            }
            break;
        }
        case CardElementType::ColumnSet:
        {
            std::shared_ptr<ColumnSet> columnSetElem = std::dynamic_pointer_cast<ColumnSet>(elem);
            float childrenWidth = parentWidth/(columnSetElem->GetColumns().size()) ;
            for (const auto &column : columnSetElem->GetColumns()) {
                [self distribute:childrenWidth rootView:rootView forElement:column andHostConfig:config];
            }
            break;
        }
        case CardElementType::Table:
        {
            std::shared_ptr<Table> table = std::dynamic_pointer_cast<Table>(elem);
            std::vector<std::shared_ptr<TableColumnDefinition>> colums = table->GetColumns();
            float childrenWidth = parentWidth/(colums.size());
            std::vector<std::shared_ptr<TableRow>> tableRows = table->GetRows();
            for (const auto &row : tableRows) {
                std::vector<std::shared_ptr<TableCell>> tableCells = row->GetCells();
                for (const auto &cell : tableCells) {
                    [self distribute:childrenWidth rootView:rootView forElement:cell andHostConfig:config];
                }
            }
            
            break;
        }
            
        default:
            break;
    }
}

@end
