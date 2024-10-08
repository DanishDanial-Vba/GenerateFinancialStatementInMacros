Attribute VB_Name = "Validations"
Option Explicit
Private tb As Ctrl_TrialBalance
Private grouping As Ctrl_AccountsGrouping
Private account As Mdl_Accounts
Public Function ValidateTrialBalance(ByVal ws As Worksheet) As Boolean
    Dim requiredHeaders As Variant
    Dim i As Integer
    
    ' Array of expected header values
    requiredHeaders = Array("Account Category", "Account Sub Category", "Account Sub Category L1", "Account Sub Category L2", "Account Name", "Debit", "Credit")
    
    ' Loop through each expected header and check if it matches the header in the worksheet
    For i = LBound(requiredHeaders) To UBound(requiredHeaders)
        If ws.Cells(1, i + 2).value <> requiredHeaders(i) Then
            ValidateTrialBalance = False
            Exit Function
        End If
    Next i
    
    ' If all headers match
    ValidateTrialBalance = True
End Function

