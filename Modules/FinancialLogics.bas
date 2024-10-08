Attribute VB_Name = "FinancialLogics"
'@IgnoreModule MoveFieldCloserToUsage
Option Explicit
Private tb As Ctrl_TrialBalance
Private grouping As Ctrl_AccountsGrouping
Private account As Mdl_Accounts
Public Sub StoreTrialBalance(ByVal ws As Worksheet, ByVal wb As Workbook)

    Dim i As Long
    Dim lastrow As Long
    
    Set tb = New Ctrl_TrialBalance
    Set grouping = New Ctrl_AccountsGrouping
    lastrow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row
    
    For i = 2 To lastrow
        Set account = New Mdl_Accounts
    
        If ws.Cells(i, 2).value <> vbNullString And (ws.Cells(i, 7).value <> 0 Or ws.Cells(i, 8).value) <> 0 Then ' Check if the category cell is not empty
    
            account.accountCategory = ws.Cells(i, 2).value
            account.accountSubCategory = ws.Cells(i, 3).value
            account.accountSubCategoryL1 = ws.Cells(i, 4).value
            account.accountSubCategoryL2 = ws.Cells(i, 5).value
            account.accountName = ws.Cells(i, 6).value
            account.Debit = ws.Cells(i, 7).value
            account.Credit = ws.Cells(i, 8).value
       
            'DebugMessage "Account Added:" & account.accountName
    
            tb.AddAccount account
    
        End If
    
    Next i
    
    
    printIncomeStatement wb
    printBalanceSheet wb
End Sub



Private Sub printIncomeStatement(ByVal wb As Workbook)
    Dim psheet As Worksheet

    ' Add a new worksheet for Income Statement (PL)
    AddWorkSheet wb, "PL"
    
    ' Set the new sheet as the active one
    Set psheet = wb.Worksheets("PL")
    
    ' Merge and format cells for headers
    With psheet
        .Range(.Cells(1, 2), .Cells(1, 5)).Merge
        .Range(.Cells(2, 2), .Cells(2, 5)).Merge
        .Range(.Cells(3, 2), .Cells(3, 5)).Merge
        .Range(.Cells(4, 2), .Cells(4, 5)).Merge
        .Range(.Cells(5, 2), .Cells(6, 2)).Merge
        .Range(.Cells(5, 3), .Cells(6, 3)).Merge

        With .Range(.Cells(1, 2), .Cells(6, 3))
            .Font.Bold = True
            .VerticalAlignment = xlVAlignCenter
            .HorizontalAlignment = xlHAlignCenter
        End With

        ' Add borders to the headers
        With .Range(.Cells(5, 2), .Cells(6, 5))
            .Borders(xlEdgeTop).LineStyle = xlContinuous
            .Borders(xlEdgeBottom).LineStyle = xlContinuous
            .Borders(xlEdgeLeft).LineStyle = xlContinuous
            .Borders(xlEdgeRight).LineStyle = xlContinuous
            .Borders(xlInsideVertical).LineStyle = xlContinuous
            .Borders(xlInsideHorizontal).LineStyle = xlContinuous
        End With

        ' Set column widths
        .Columns("B").ColumnWidth = 51.27
        .Columns("C").ColumnWidth = 8
        .Columns("D").ColumnWidth = 13
        .Columns("E").ColumnWidth = 13
        
        ' Populate header values
        .Cells(1, 2).value = "Company Name"
        .Cells(2, 2).value = "Reg#"
        .Cells(3, 2).value = "INCOME STATEMENT FOR THE YEAR ENDED"
        .Cells(4, 2).value = "Reporting Period"
        .Cells(5, 3).value = "Notes"
    End With


    ' Generate the Income Statement entries
    GenerateIncomeStatement psheet

End Sub
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

Private Sub computeTax(tb As Ctrl_TrialBalance)
Dim tpyt As Double
Dim acc As Mdl_Accounts
Dim tctp As Double

Dim tctx As Double
Dim i As Long

Dim col As Collection
 Set col = New Collection
    
    Set col = grouping.GetAccountsByFilter(tb, Category:="Tax Computation", SubCategory:="Amount Owing / (prepaid) at beginning of year")
    If Not col Is Nothing Then
    
    For i = 1 To col.Count
        tpyt = tpyt + (col.Item(i).Credit - col.Item(i).Debit)
    Next i
        
    Set col = New Collection
    
    Set col = grouping.GetAccountsByFilter(tb, Category:="Tax Computation", SubCategory:="Tax owing/ (prepaid) for the current year")
    For i = 1 To col.Count
        tctp = tctp + col.Item(i).Credit - col.Item(i).Debit
    Next i
    
    Set acc = New Mdl_Accounts
    
    acc.accountCategory = "Liabilities"
    acc.accountSubCategory = "Current Liabilities"
    acc.accountSubCategoryL1 = "Current Income Tax Liabilities"
    acc.accountSubCategoryL2 = ""
    acc.accountName = "Receiver of Revenue - Income Tax"
    acc.Debit = 0
    acc.Credit = tpyt + tctp

    tb.accounts.Add acc
    End If
End Sub





Private Sub CalculateTotalsAndProfits(ByVal sheet As Worksheet, ByRef row As Long, ByVal tRevenue As Double, ByVal tCOGS As Double, ByVal tExp As Double)
    Dim pbt As Double
    Dim tax As Double
    Dim pat As Double

    pbt = tRevenue - tCOGS - tExp
    tax = pbt * 0.28
    pat = pbt - tax

    With sheet.Cells(row, 2)
        .value = "Operating Profit"
        .Font.Bold = True
    End With
    With sheet.Cells(row, 4)
        .value = pbt
        .Font.Bold = True
    End With
    row = row + 1

    With sheet.Cells(row, 2)
        .value = "Taxation"
        .IndentLevel = 1
    End With
    sheet.Cells(row, 4).value = tax
    row = row + 1

    sheet.Cells(row, 2).value = "Net Profit after Tax"
    sheet.Cells(row, 4).value = pat

    TopThickBorders sheet.Range(sheet.Cells(row, 2), sheet.Cells(row, 5))
    row = row + 1

    Dim acc As Mdl_Accounts
    Set acc = New Mdl_Accounts
    acc.accountCategory = "Equity"
    acc.accountSubCategory = "Retained Earnings"
    acc.accountSubCategoryL1 = "Retained Earnings"
    acc.accountSubCategoryL2 = vbNullString
    acc.accountName = "Net (loss) / Profit for the year"
    acc.Debit = 0
    acc.Credit = pat
    tb.accounts.Add acc
    
    Set acc = New Mdl_Accounts
    acc.accountCategory = "Primary"
    acc.accountSubCategory = vbNullString
    acc.accountSubCategoryL1 = vbNullString
    acc.accountSubCategoryL2 = vbNullString
    acc.accountName = "Profit Before Tax"
    acc.Debit = 0
    acc.Credit = pbt
    tb.accounts.Add acc
    
    Set acc = New Mdl_Accounts
    acc.accountCategory = "Tax Computation"
    acc.accountSubCategory = "Tax owing/ (prepaid) for the current year"
    acc.accountSubCategoryL1 = "Current tax"
    acc.accountSubCategoryL2 = vbNullString
    acc.accountName = "Current tax"
    acc.Debit = 0
    acc.Credit = tax
    tb.accounts.Add acc
    
    
    
    
    VerticalSideBordersOnly sheet.Range(sheet.Cells(7, 2), sheet.Cells(row, 5))
    AccountingNumberFormat sheet.Range(sheet.Cells(7, 4), sheet.Cells(row, 5))
End Sub

'Balance Sheet
Private Sub printBalanceSheet(ByVal wb As Workbook)
    Dim sheet As Worksheet

    ' Add a new worksheet for Balance Sheet (BS)
    AddWorkSheet wb, "Notes"
    
    ' Set the new sheet as the active one
    Set sheet = wb.Worksheets("Notes")
    'sheet.Move after:=Sheets("PL")
    
    With sheet.Range(sheet.Cells(1, 2), sheet.Cells(1, 6))
        .Merge
        .HorizontalAlignment = xlCenter
        .Font.Bold = True
        .Font.Size = 16
        .value = "Company Name"
    End With
    With sheet.Range(sheet.Cells(2, 2), sheet.Cells(2, 6))
        .Merge
        .HorizontalAlignment = xlCenter
        .Font.Bold = True
        .Font.Size = 10
        .value = "Company Reg#"
    End With
    With sheet.Range(sheet.Cells(3, 2), sheet.Cells(3, 6))
        .Merge
        .HorizontalAlignment = xlCenter
        .Font.Bold = True
        .Font.Size = 10
        .value = "NOTES TO THE FINANCIAL STATEMENTS"
    End With
    With sheet.Range(sheet.Cells(4, 2), sheet.Cells(4, 6))
        .Merge
        .HorizontalAlignment = xlCenter
        .Font.Bold = True
        .Font.Size = 10
                            
    End With
    With sheet.Range(sheet.Cells(5, 2), sheet.Cells(6, 4))
        .Merge
        .HorizontalAlignment = xlCenter
        .Font.Bold = True
        .Font.Size = 16
        .Borders(xlEdgeTop).LineStyle = xlContinuous
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
        .Borders(xlEdgeLeft).LineStyle = xlContinuous
        .Borders(xlEdgeRight).LineStyle = xlContinuous
    End With
    With sheet.Range(sheet.Cells(5, 5), sheet.Cells(6, 6))
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
        .Borders(xlEdgeTop).LineStyle = xlContinuous
        .Borders(xlEdgeLeft).LineStyle = xlContinuous
        .Borders(xlEdgeRight).LineStyle = xlContinuous
        .Borders(xlInsideHorizontal).LineStyle = xlContinuous
        .Borders(xlInsideVertical).LineStyle = xlContinuous
    End With
    ' Generate the Balance Sheet entries
    GenerateBalanceSheet sheet
    GenerateBalanceSheetFace wb
'    tb.ReleaseMemory
 '   grouping.ReleaseMemory
End Sub
Public Sub GenerateBalanceSheet(ByVal sheet As Worksheet)
    
    Dim subtotal As Double
    Dim row As Long
    Dim st As Long

    Dim tMbs As Double
    Dim tDwg As Double
    Dim tRsp As Double
    Dim tMbrloan As Double
    Dim tLtb As Double
    Dim tVehFin As Double

    Dim tCL As Double
    Dim tAp As Double
    Dim tAex As Double
    Dim tBOD As Double
    Dim tctb As Range
    Dim tVat As Double
    Dim tctp As Double
    Dim tcye As Double
    Dim tpyt As Double
    Dim tpbt As Double
    Dim tOprs As Double
    Dim tctx As Variant
    
    row = 8

    'Set up formatting
    SetHeader sheet, row, "2)", "Member Contributions"
    tMbs = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Equity", SubCategory:="Members Contribution"), vbNullString, 2)
    sheet.Cells(row, 5).value = tMbs
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    
    row = row + 1
    
     SetHeader sheet, row, "3)", "Retained Earnings"
    
    'TODO Is this comment still valid? => TODO Is this comment still valid? => TODO Is this comment still valid? => Opening reserves
    tOprs = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, _
                                            Category:="Equity", _
                                            SubCategory:="Retained Earnings", _
                                            accountName:="Opening Reserves"), vbNullString, 2)
    row = row - 1
    'row = row + IIf(tcye = 0, 0, -5)
    'TODO Is this comment still valid? => TODO Is this comment still valid? => Current year earnings
    
    tcye = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Equity", SubCategory:="Retained Earnings", accountName:="Net (loss) / Profit for the year"), "(+)", 2)
    
    row = row + IIf(tcye = 0, 0, -1)
    'TODO Is this comment still valid? => Drawings
    
    tDwg = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Equity", SubCategory:="Drawings", accountName:="Drawings"), vbNullString, 2)
    
    row = row + IIf(tDwg = 0, 1, 0)
    ' Total Retained Earnings
    
    tRsp = tOprs + tcye + tDwg
    sheet.Cells(row, 5).value = tRsp
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    'TODO Is this comment still valid? => Total Equity
    row = row + 1
            
    'Non Interst bearing borrowings
    SetHeader sheet, row, "4)", "Non-interest bearing borrowings"
    row = row + 1
    'Members Loan
    SetHeader sheet, row, "4.1)", "Members Loan"
    tMbrloan = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategory:="Non Current Liabilities", SubCategoryL1:="Non-Interest Bearing Borrowings", SubCategoryL2:="Members Loan"), vbNullString, 2)
    sheet.Cells(row, 5).value = tMbrloan
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
                
    'Interest bearing borrowings
    SetHeader sheet, row, "5)", "Interest bearing borrowings"
    row = row + 1
    'Long Term Borrowings
    SetHeader sheet, row, "5.1).", "Long Term Borrowings"
    tLtb = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategory:="Non Current Liabilities", SubCategoryL1:="Interest Bearing Borrowings", SubCategoryL2:="Long Term Borrowings"))
    sheet.Cells(row, 5).value = tLtb
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    'Vehicle Finance
    row = row + 1
    SetHeader sheet, row, "5.2)", "Vehicle Loans"
    tVehFin = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategory:="Non Current Liabilities", SubCategoryL1:="Interest Bearing Borrowings", SubCategoryL2:="Vehicle Loans"), vbNullString, 2)
    sheet.Cells(row, 5).value = tVehFin
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 2
    ' Current Liabilities
    SetHeader sheet, row, "6)", "Current Liabilities"
    row = row + 1
    'Trade and other Payables
    SetHeader sheet, row, "6.1)", "Trade and other payables"
    'Accounts Payable
    tAp = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Accounts Payable"))
    row = row + IIf(tAp = 0, 0, -1)
    'Accrued Expenses
    tAex = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Accrued Expenses"))
    row = row + IIf(tAex = 0, 0, 0)
    sheet.Cells(row, 5).value = tAp + tAex
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    tCL = tCL + tAp + tAex
    
    'Bank Overdraft and Current Tax Liabilities
    SetHeader sheet, row, "6.2)", "Bank Overdraft"
    tBOD = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategory:="Current Liabilities", SubCategoryL1:="Bank Over Draft"), vbNullString, 2)
    sheet.Cells(row, 5).value = tBOD
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + IIf(tBOD = 0, 0, 1)
    'Current Tax Liabilities
    SetHeader sheet, row, "6.3)", "Current Tax Liabilities"
    'Current VAT Liabilities
    tVat = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategory:="Current Liabilities", SubCategoryL1:="Current Vat Liabilities"), vbNullString, 2)
    row = row + IIf(tVat = 0, 0, -1)
    Set tctb = sheet.Cells(row, 5)
    'Current Income Tax Liabilities
    subtotal = 0
    subtotal = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Current Income Tax Liabilities"), vbNullString, 2)
    sheet.Cells(row, 5).value = subtotal + tVat
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    subtotal = 0
    row = row + 2
    ' Tax Computation
    SetHeader sheet, row, "7)", "Tax Computation"
    row = row + 1
    'Profit Before tax
    tpbt = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, accountName:="Profit Before Tax"), vbNullString, 0)
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    'Current Year Tax Liability
    tctp = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, accountName:="Current tax"), vbNullString, 0)
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    st = row + 1
    'Previous Year Tax Balances
    tpyt = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, accountName:="Amount Owing / (prepaid) at beginning of year"), vbNullString, 2)
    row = row + IIf(tpyt = 0, 0, -1)
    tpyt = tpyt + AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, accountName:="Interest charged for underestimation of provisional tax"), vbNullString, 2)
    row = row + IIf(tpyt = 0, 0, -1)
    tpyt = tpyt + AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, accountName:="Amount paid in respect of prior year"), vbNullString, 2)
    sheet.Cells(row, 5).value = Application.WorksheetFunction.Sum(sheet.Range(sheet.Cells(st, 5), sheet.Cells(row - 1, 5)))
    Dim tPytx As Range
    Set tPytx = sheet.Cells(row, 5)
    'Total Previous year balance after payments
    SetHeader sheet, row, vbNullString, "(i) - Amount Owing / (prepaid) in respect of prior year"
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    st = 0
    row = row + 2
    Dim tNtx As Range
    'TODO Is this comment still valid? => Current year tax balances
    SetHeader sheet, row, vbNullString, "Tax owing/ (prepaid) for the current year"
    'Current year liability
    tctp = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Current tax"), vbNullString, 1)
    row = row + IIf(tctp = 0, 0, -1)
    'Provisional tax paid
    tctx = -AddCreditAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Provisional tax payment"), vbNullString, 2)
    row = row + IIf(tctx = 0, 1, -1)
    row = row + 1
    SetHeader sheet, row, vbNullString, "(ii) - Normal tax"
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    Set tNtx = sheet.Cells(row, 5)
    tNtx.value = tctp - tctx
    row = row + 1
    SetHeader sheet, row, vbNullString, "Amount owing/(prepaid) at the end of year (i + ii)"
    sheet.Cells(row, 5).value = tNtx.value + tPytx.value
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    ' Additional tax computation can be added here
    
    ' Auto-fit columns
    sheet.Columns("B:F").AutoFit
    sheet.Columns("B").HorizontalAlignment = xlLeft
    sheet.Columns("F:F").ColumnWidth = sheet.Columns("E:E").ColumnWidth
    
    
    'Assets
    
    Dim tNca As Double
    Dim tFA As Double
    Dim tAcDP As Double
    Dim tInv As Variant
    Dim tAR As Variant
    Dim tCnc As Variant
    Dim tCA As Double
    Dim tCta As Double
    
    tNca = 0
    tFA = 0
    tAcDP = 0
    tCA = 0
    tInv = 0
    tAR = 0
    tCnc = 0
    tCta = 0
    
    
    row = row + 2
    SetHeader sheet, row, "8)", "Non-Current Assets"
    tNca = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategory:="Non Current Assets"), vbNullString, 0)
    sheet.Cells(row, 5).value = tNca
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    
    SetHeader sheet, row, "9)", "Property, plant and equipment"
    row = row + 1
    SetHeader sheet, row, vbNullString, "Cost of Assets"
    tFA = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Cost of Assets"), vbNullString, 2)
    sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6)).Borders(xlEdgeTop).LineStyle = xlContinuous
    With sheet.Cells(row, 3)
        .value = "Total(i)"
        .IndentLevel = 1
        .Font.Bold = True
    End With
    sheet.Cells(row, 5).value = tFA
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    SetHeader sheet, row, vbNullString, "Accumulated Depreciation"
    tAcDP = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Accumulated Depreciation"), vbNullString, 2)
    With sheet.Cells(row, 3)
        .value = "Total(ii)"
        .IndentLevel = 1
        .Font.Bold = True
    End With
    sheet.Cells(row, 5).value = tAcDP
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    SetHeader sheet, row, vbNullString, "Net Asset Value(i-ii)"
    sheet.Cells(row, 5).value = tFA + tAcDP
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 2
        
    SetHeader sheet, row, "10)", "Current Assets"
    row = row + 1
    SetHeader sheet, row, "10.1)", "Inventories"
    tInv = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Inventory"), vbNullString, 1)
    sheet.Cells(row, 5).value = tInv
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    SetHeader sheet, row, "10.2)", "Trade and other receivables"
    tAR = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Accounts Receivables"), vbNullString, 1)
    sheet.Cells(row, 5).value = tAR
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
        
    SetHeader sheet, row, "10.3)", "Cash and cash equivalents"
    tCnc = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GetAccountsByFilter(tb, SubCategoryL1:="Cash and Cash Equivalents"), vbNullString, 1)
    sheet.Cells(row, 5).value = tCnc
    NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
    row = row + 1
    
    AccountingNumberFormat sheet.Columns("E:F")
        
    '    Dim FASheet As Worksheet
    '
    '    AddWorkSheet sheet.Parent, "FA"
    '
    '    Set FASheet = sheet.Parent.Worksheets("FA")
    '
    '    AddFixedAssets FASheet
    
    

End Sub
Private Sub GenerateBalanceSheetFace(ByVal wb As Workbook)
    Dim sheet As Worksheet
    Dim row As Long
    Dim tNca As Double
    Dim tPPE As Double
    Dim tCA As Double
    Dim tAR As Double
    Dim tCnc As Double
    Dim tInv As Double
    
    Dim tAssets As Double
    
    AddWorkSheet wb, "BS"

        Set sheet = wb.Worksheets("BS")
        
        
        sheet.Range(sheet.Cells(1, 2), sheet.Cells(1, 6)).Merge
        sheet.Range(sheet.Cells(2, 2), sheet.Cells(2, 6)).Merge
        sheet.Range(sheet.Cells(3, 2), sheet.Cells(3, 6)).Merge
        sheet.Range(sheet.Cells(4, 2), sheet.Cells(4, 6)).Merge
        
        sheet.Range(sheet.Cells(5, 2), sheet.Cells(6, 3)).Merge
        sheet.Range(sheet.Cells(5, 4), sheet.Cells(6, 4)).Merge
        
        With sheet.Range(sheet.Cells(5, 2), sheet.Cells(6, 6))
                .Borders(xlEdgeBottom).LineStyle = xlContinuous
                .Borders(xlEdgeBottom).Weight = xlThick
                .Borders(xlEdgeLeft).LineStyle = xlContinuous
                .Borders(xlEdgeTop).LineStyle = xlContinuous
                .Borders(xlEdgeRight).LineStyle = xlContinuous
                .Borders(xlInsideHorizontal).LineStyle = xlContinuous
                .Borders(xlInsideVertical).LineStyle = xlContinuous
        End With
        row = 7
        
        SetHeader sheet, row, "ASSETS", vbNullString
        row = row + 1
        
        SetHeader sheet, row, vbNullString, "Tangible Assets"
        tPPE = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategory(grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategory:="Property, plant and equipment")), vbNullString, 1)
        sheet.Cells(row, 5).value = tPPE
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + IIf(tPPE = 0, 0, 2)
        
        
        
        SetHeader sheet, row, vbNullString, "Non-current assets"
        tNca = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategoryL1:="Non Current Investment")), vbNullString, 1)
        sheet.Cells(row, 5).value = tNca
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + IIf(tNca = 0, 1, 1)
        
        
        row = row + 1
        
        
        SetHeader sheet, row, vbNullString, "Current Assets"
        
        tInv = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategory:="Current Assets", SubCategoryL1:="Inventory")), vbNullString, 1)
        row = row + IIf(tInv = 0, 0, -1)
        
        tAR = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategory:="Current Assets", SubCategoryL1:="Accounts Receivables")), vbNullString, 1)
        row = row + IIf(tAR = 0, 0, -1)
        
        tCnc = AddDebitAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Assets", SubCategory:="Current Assets", SubCategoryL1:="Cash and Cash Equivalents")), vbNullString, 1)
        row = row + IIf(tAR = 0, 0, 0)
        
        tCA = tInv + tAR + tCnc
        sheet.Cells(row, 5).value = tCA
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + 2
        
        SetHeader sheet, row, "TOTAL", vbNullString
        tAssets = tCA + tPPE + tNca
        sheet.Cells(row, 5).value = tAssets
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        
        With sheet.Range(sheet.Cells(row, 2), sheet.Cells(row, 6))
                                .Borders(xlEdgeBottom).LineStyle = xlContinuous
                                .Borders(xlEdgeBottom).Weight = xlThick
        End With
        
        
        
        
        row = row + 2
        
        'Liabilities
        Dim tEqt As Double
        Dim tRsp As Double
        Dim tNcl As Double
        Dim tCL As Double
        Dim tAp As Double
        Dim tAex As Double
        Dim tBOD As Double
        Dim tVat As Double
        Dim tInt As Double
        
        
        Dim tLiabilities As Double
        
        
        SetHeader sheet, row, "EQUITY AND LIABILITIES", vbNullString
        row = row + 1
        SetHeader sheet, row, vbNullString, "Capital and reserves"
        tEqt = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Equity", SubCategoryL1:="Members Contribution")), vbNullString, 1)
        row = row + IIf(tEqt = 0, 0, -1)
        
        tRsp = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Equity", SubCategory:="Retained Earnings")), vbNullString, 1)
        row = row + IIf(tRsp = 0, 0, 0)
        
        sheet.Cells(row, 5).value = tEqt + tRsp
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + 1
        
        SetHeader sheet, row, vbNullString, "Non Current Liabilities"
        tNcl = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Non-Interest Bearing Borrowings")), vbNullString, 1)
        row = row + IIf(tNcl = 0, 0, -1)
        tNcl = tNcl + AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Interest Bearing Borrowings")), vbNullString, 1)
        row = row + IIf(tNcl = 0, 0, 0)
        
        sheet.Cells(row, 5).value = tNcl
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + 1
        
        SetHeader sheet, row, vbNullString, "Current Liabilities"
        
        tAp = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Accounts Payable")), vbNullString, 1)
        row = row + IIf(tAp = 0, 0, -1)
        tAex = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Accrued Expenses")), vbNullString, 1)
        row = row + IIf(tAex = 0, 0, -1)
        tBOD = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Bank Over Draft")), vbNullString, 1)
        row = row + IIf(tBOD = 0, 0, -1)
        tVat = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Current Vat Liabilities")), vbNullString, 1)
        row = row + IIf(tVat = 0, 0, -1)
        tInt = AddCreditAccountRowsWithPrefix(sheet, row, grouping.GroupBySubCategoryL1(grouping.GetAccountsByFilter(tb, Category:="Liabilities", SubCategoryL1:="Current Income Tax Liabilities")), vbNullString, 1)
        row = row + IIf(tInt = 0, 0, 0)
        
        sheet.Cells(row, 5).value = tAp + tAex + tBOD + tVat + tInt
        NormalBordersWithFontBold sheet.Range(sheet.Cells(row, 5), sheet.Cells(row, 6))
        row = row + 2
        
        SetHeader sheet, row, "TOTAL", vbNullString
        tLiabilities = tAp + tAex + tBOD + tVat + tInt + tNcl + tEqt + tRsp
        sheet.Cells(row, 5).value = tLiabilities
        
        sheet.Range(sheet.Cells(7, 2), sheet.Cells(row, 6)).BorderAround LineStyle:=xlContinuous
        With sheet.Range(sheet.Cells(7, 4), sheet.Cells(row, 6))
                                        .Borders(xlInsideVertical).LineStyle = xlContinuous
                                        .Borders(xlEdgeLeft).LineStyle = xlContinuous
                                        End With
        
        AccountingNumberFormat sheet.Columns("E:F")
        
        sheet.Columns("C:F").AutoFit
        sheet.Columns("b").ColumnWidth = 2
        sheet.Columns("f").ColumnWidth = sheet.Columns("e").ColumnWidth
        
        
End Sub


Private Sub SetHeader(ByVal sheet As Worksheet, _
                      ByRef row As Long, _
                      Optional ByVal sectionNumber As String = vbNullString, _
                      Optional ByVal sectionName As String = vbNullString)
    sheet.Cells(row, 2).value = sectionNumber
    sheet.Cells(row, 3).value = sectionName
    sheet.Range(sheet.Cells(row, 2), sheet.Cells(row, 5)).Font.Bold = True
    
End Sub

Private Function AddCreditAccountRowsWithPrefix(ByVal sheet As Worksheet, _
                                                ByRef row As Long, _
                                                ByVal accounts As Collection, _
                                                Optional ByVal prefix As String, _
                                                Optional ByVal indent As Long = 1) As Double
    
    If accounts Is Nothing Then
        Exit Function
    Else
        Dim account As Mdl_Accounts
        Dim subtotal As Double
    
        subtotal = 0
        For Each account In accounts
            row = row + 1
            With sheet.Cells(row, 3)
                .value = prefix & account.accountName
                .IndentLevel = indent
            End With
            sheet.Cells(row, 5).value = account.Credit - account.Debit
            subtotal = subtotal + (account.Credit - account.Debit)
        Next account
        row = row + 1
        AddCreditAccountRowsWithPrefix = subtotal
    
    End If
End Function


Private Function AddCreditAccountRowsWithoutPrefix(ByVal sheet As Worksheet, _
                                                   ByRef row As Long, _
                                                   ByVal accounts As Collection, _
                                                   Optional ByVal indent As Long = 0) As Double
    If accounts Is Nothing Then
        Exit Function
    
    Else
    
        Dim account As Mdl_Accounts
        Dim subtotal As Double
    
        subtotal = 0
        For Each account In accounts
            row = row + 1
            With sheet.Cells(row, 2)
                .value = account.accountName
                .IndentLevel = indent
            End With
            sheet.Cells(row, 4).value = account.Credit - account.Debit
            subtotal = subtotal + (account.Credit - account.Debit)
        Next account
        row = row + 1
    
        AddCreditAccountRowsWithoutPrefix = subtotal
    
    End If
    
End Function

Private Function AddDebitAccountRowsWithPrefix(ByVal sheet As Worksheet, _
                                               ByRef row As Long, _
                                               ByVal accounts As Collection, _
                                               Optional ByVal prefix As String, _
                                               Optional ByVal indent As Long = 1) As Double
    
    If accounts Is Nothing Then
        Exit Function
    Else
        Dim account As Mdl_Accounts
        Dim subtotal As Double
    
        subtotal = 0
        For Each account In accounts
            row = row + 1
            With sheet.Cells(row, 3)
                .value = prefix & account.accountName
                .IndentLevel = indent
            End With
            sheet.Cells(row, 5).value = account.Debit - account.Credit
            subtotal = subtotal + (account.Debit - account.Credit)
        Next account
        row = row + 1
        AddDebitAccountRowsWithPrefix = subtotal
    
    End If
End Function




Private Function AddDebitAccountRowsWithoutPrefix(ByVal sheet As Worksheet, _
                                                  ByRef row As Long, _
                                                  ByVal accounts As Collection, _
                                                  Optional ByVal indent As Long = 0) As Double
    
    
    If accounts Is Nothing Then
        Exit Function
    
    Else
    
        Dim account As Mdl_Accounts
        Dim subtotal As Double
    
        subtotal = 0
        For Each account In accounts
            row = row + 1
            With sheet.Cells(row, 2)
                .value = account.accountName
                .IndentLevel = indent
            End With
            sheet.Cells(row, 4).value = account.Debit - account.Credit
            subtotal = subtotal + (account.Debit - account.Credit)
        Next account
        row = row + 1
    
        AddDebitAccountRowsWithoutPrefix = subtotal
    
    End If
End Function
Private Sub AddWorkSheet(ByVal wb As Workbook, ByRef name As String)
    Dim ws As Worksheet
    On Error Resume Next

    ' Delete the sheet if it already exists
    Set ws = wb.Worksheets(name)
    If Not ws Is Nothing Then
        Application.DisplayAlerts = False
        ws.Delete
        Application.DisplayAlerts = True
    End If
    On Error GoTo 0

    ' Add a new worksheet
    Set ws = wb.Worksheets.Add
    ws.name = name

End Sub


Private Sub TopThickBorders(ByVal Range As Range)

    With Range
        .Font.Bold = True
        .Borders(xlEdgeTop).LineStyle = xlContinuous
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
        .Borders(xlEdgeTop).Weight = xlThick
    End With
        
End Sub

Private Sub NormalBordersWithFontBold(ByVal Range As Range)
    With Range
        .Font.Bold = True
        .Borders(xlEdgeTop).LineStyle = xlContinuous
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
    End With
End Sub


Private Sub VerticalSideBordersOnly(ByVal Range As Range)
    With Range
        .Borders(xlInsideVertical).LineStyle = xlContinuous
        .Borders(xlEdgeLeft).LineStyle = xlContinuous
        .Borders(xlEdgeRight).LineStyle = xlContinuous
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
    End With
End Sub


Private Sub AccountingNumberFormat(ByVal Range As Range)
    Range.NumberFormat = "#,##0.00;(#,##0.00);0.00"
End Sub


