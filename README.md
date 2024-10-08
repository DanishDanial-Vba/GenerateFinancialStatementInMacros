# Macros/vba Financial Statement Generator

## Description
The **Financial Statement Generator** is an Excel VBA project designed to automate the generation of financial statements along with accompanying notes from a given trial balance dataset. This tool simplifies the process of financial reporting, making it easier for accountants and financial professionals to prepare accurate statements efficiently.

## Features
- Generates comprehensive financial statements from trial balance data.
- Includes notes that explain various components of the financial statements.
- Utilizes accepted accounting categories and hierarchy to ensure compliance with standard practices.
- User-friendly interface within Excel for easy interaction.

## Installation Instructions
1. Download the project files from the repository.
2. Open Microsoft Excel.
3. Press `ALT + F11` to open the VBA editor.
4. Import the downloaded VBA files into your Excel workbook.
5. Follow any specific instructions provided in the files for setup.

## Usage Instructions
1. Input your trial balance data into the designated sheet with accepted categories.
2. Run the Main() sub to start the macro

```vba
Public Sub Main()
    
    frm_home.Show vbModeless
    
End Sub
```
3. Select the workbook and sheet containing the trial balance
4. click on process button to generate financials. 
5. Review the generated statements and notes for accuracy.
6. Make any necessary adjustments to the data or settings.


**Contributing**
**Contributions are welcome!** If you’d like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with clear messages.
4. Push your changes and open a pull request.
For larger changes, please open an issue first to discuss what you would like to change.

**Accepted Account Categories**
Below is the list of accepted account categories used in our VBA application:

This is an illustrative list and if you want to modify it, change the financial logics 


| **Account Category**      | **Account Sub Category**               | **Account Sub Category L1**         | **Account Sub Category L2**          |
|---------------------------|----------------------------------------|-------------------------------------|--------------------------------------|
| Revenue                   | Sales                                  |                                     |                                      |
| COGS                      | COGS                                   | Opening Inventory                    |                                      |
| COGS                      | Purchases                              |                                     |                                      |
| Expense                   | Other Expenses                         |                                     |                                      |
| Expense                   | Depreciation                          |                                     |                                      |
| Equity                    | Retained Earnings                      | Retained Earnings                    |                                      |
| Equity                    | Members Contribution                   | Members Contribution                 |                                      |
| Equity                    | Drawings                               | Drawings                             |                                      |
| Liabilities               | Non Current Liabilities                | Non-Interest Bearing Borrowings      | Members Loan                          |
| Liabilities               | Non Current Liabilities                | Interest Bearing Borrowings          | Long Term Borrowings                  |
| Liabilities               | Non Current Liabilities                | Interest Bearing Borrowings          | Vehicle Loans                         |
| Liabilities               | Current Liabilities                    | Bank Over Draft                     |                                      |
| Liabilities               | Current Liabilities                    | Accounts Payable                     |                                      |
| Liabilities               | Current Liabilities                    | Current Vat Liabilities              |                                      |
| Liabilities               | Current Liabilities                    | Current Income Tax Liabilities       |                                      |
| Liabilities               | Current Liabilities                    | Accrued Expenses                     |                                      |
| Assets                    | Property, plant and equipment          | Cost of Assets                      | Motor Vehicle                         |
| Assets                    | Property, plant and equipment          | Accumulated Depreciation            | Motor Vehicle                         |
| Assets                    | Property, plant and equipment          | Cost of Assets                      | Equipment                             |
| Assets                    | Property, plant and equipment          | Accumulated Depreciation            | Equipment                             |
| Assets                    | Current Assets                         | Inventory                            |                                      |
| Assets                    | Current Assets                         | Accounts Receivables                |                                      |
| Assets                    | Current Assets                         | Cash and Cash Equivalents           |                                      |
| Tax Computation           | Amount Owing / (prepaid) at beginning of year | Amount Owing / (prepaid) at beginning of year |                          |
| Tax Computation           | Amount Owing / (prepaid) at beginning of year | Interest charged for underestimation of provisional tax |      |
| Tax Computation           | Amount Owing / (prepaid) at beginning of year | Amount paid in respect of prior year |                             |
| Tax Computation           | Tax owing/ (prepaid) for the current year | Provisional tax payment             |                                      |

### Example
```vba
Private Sub GenerateIncomeStatement(ByVal sheet As Worksheet)
    
    Dim row As Long
    Dim subtotal As Double
    Dim tRevenue As Double
    Dim tCOGS As Double
    Dim tOpStk As Double
    Dim tClStk As Double
    Dim tPurchases As Double
    Dim tExp As Double

    row = 7
    
    ' Revenue
    SetHeader sheet, row, "Revenue"
    
    subtotal = AddCreditAccountRowsWithoutPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Revenue"), 1)
    
    With sheet.Cells(row, 2)
        .value = "Total Revenue"
        .Font.Bold = True
    End With
    sheet.Cells(row, 4).Formula = subtotal
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 4), sheet.Cells(row, 5))
    tRevenue = subtotal
    
    row = row + 2
    ' COGS
    
    SetHeader sheet, row, "Cost of Sales"
    
    subtotal = 0
    
    subtotal = AddDebitAccountRowsWithoutPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="COGS", SubCategoryL1:="Opening Inventory"), 1)
    
    tOpStk = subtotal
    
    row = row - 1
    
    subtotal = 0
    subtotal = AddDebitAccountRowsWithoutPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="COGS", SubCategory:="Purchases"), 2)
    
    tPurchases = subtotal
    
    'Total Purchase + Opening Stock
    
       
    sheet.Cells(row, 4).value = tOpStk + tPurchases
    With sheet.Range(sheet.Cells(row, 4), sheet.Cells(row, 5))
        .Borders(xlEdgeTop).LineStyle = xlContinuous
        .Font.Bold = True
    End With
    
    ' Closing Stock
    subtotal = 0
    subtotal = AddCreditAccountRowsWithoutPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategory:="Current Assets", SubCategoryL1:="Inventory"), 1)
    tClStk = subtotal
    
    
    SetHeader sheet, row, "Total Cost of Sales"
    tCOGS = tOpStk + tPurchases + tClStk
    sheet.Cells(row, 4).Formula = tCOGS
    'NormalBordersWithFontBold sheet.Range(sheet.Cells(row - 1, 4), sheet.Cells(row - 1, 5))
    

    ' Gross Profit
    row = row + 1
    SetHeader sheet, row, "Gross Profit"
    sheet.Cells(row, 4).value = tRevenue - tCOGS
    TopThickBorders sheet.Range(sheet.Cells(row, 2), sheet.Cells(row, 5))

    ' Expenses
    row = row + 2
    SetHeader sheet, row, "Expenses"
    subtotal = 0
    subtotal = AddDebitAccountRowsWithoutPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Expense"), 1)
    tExp = subtotal
    
    SetHeader sheet, row, "Total Expenses"
    sheet.Cells(row, 4).value = subtotal
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 2), sheet.Cells(row, 5))
                
    ' Calculate Totals and Profits
    row = row + 1
    CalculateTotalsAndProfits sheet, row, tRevenue, tCOGS, tExp
    computeTax tb
    
End Sub

```
