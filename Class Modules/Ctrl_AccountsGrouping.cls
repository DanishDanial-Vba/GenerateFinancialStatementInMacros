VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Ctrl_AccountsGrouping"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'@Folder "Controller"
Option Explicit
Private account As Mdl_Accounts
Public Property Get GetAccountsByFilter(ByVal TrialBalance As Ctrl_TrialBalance, _
                                        Optional ByRef Category As String = vbNullString, _
                                        Optional ByRef SubCategory As String = vbNullString, _
                                        Optional ByRef SubCategoryL1 As String = vbNullString, _
                                        Optional ByRef SubCategoryL2 As String = vbNullString, _
                                        Optional ByRef accountName As String = vbNullString) As Collection
    
    Dim i As Long
    Dim result As Collection
    Dim account As Mdl_Accounts
    
    ' Initialize the result collection
    Set result = New Collection
    
    
    
    ' Ensure tb.accounts is not Nothing
    If Not TrialBalance.accounts Is Nothing Then
        ' Loop through the accounts in the trial balance
        For i = 1 To TrialBalance.accounts.Count
            ' Ensure each account is not Nothing
            Set account = TrialBalance.accounts.Item(i)
            If Not account Is Nothing Then
                ' Filter accounts based on provided criteria, checking each optional filter
                If (Category = vbNullString Or account.accountCategory = Category) And _
                   (SubCategory = vbNullString Or account.accountSubCategory = SubCategory) And _
                   (SubCategoryL1 = vbNullString Or account.accountSubCategoryL1 = SubCategoryL1) And _
                   (SubCategoryL2 = vbNullString Or account.accountSubCategoryL2 = SubCategoryL2) And _
                   (accountName = vbNullString Or account.accountName = accountName) Then
                   
                   ' If all filters match, add the account to the result collection
                   result.Add account
                End If
            Else
                Debug.Print "Error: account object at index " & i & " is Nothing."
            End If
        Next i
    Else
        Debug.Print "Error: TrialBalance.accounts is not initialized."
    End If
    
    
    ' Return the filtered result collection
    Set GetAccountsByFilter = GroupByAccountName(result)
End Property

Private Function GroupByAccountName(ByVal col As Collection) As Collection
    If Not col Is Nothing Then

    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary") ' Instantiate the dictionary

    Dim account As Mdl_Accounts
    Dim groupedAccount As Mdl_Accounts
    Dim accountName As String
    Dim i As Long
    Dim sortedAccounts() As Mdl_Accounts
    Dim resultCollection As Collection

    ' Initialize the result collection
    Set resultCollection = New Collection

    ' Iterate through the collection of accounts
    For Each account In col
        accountName = account.accountName

        ' Check if account already exists in the dictionary
        If dict.Exists(accountName) Then
            ' Get the existing account from the dictionary
            Set groupedAccount = dict(accountName)
            ' Add the balances to the existing account
            groupedAccount.Debit = groupedAccount.Debit + account.Debit
            groupedAccount.Credit = groupedAccount.Credit + account.Credit
        Else
            ' Create a new account entry in the dictionary
            Set groupedAccount = New Mdl_Accounts ' Ensure the new clsAccounts object is instantiated
            groupedAccount.accountName = account.accountName
            groupedAccount.accountCategory = account.accountCategory
            groupedAccount.accountSubCategory = account.accountSubCategory
            groupedAccount.accountSubCategoryL1 = account.accountSubCategoryL1
            groupedAccount.accountSubCategoryL2 = account.accountSubCategoryL2
            groupedAccount.Debit = account.Debit
            groupedAccount.Credit = account.Credit

            ' Add it to the dictionary
            dict.Add accountName, groupedAccount
        End If
    Next account
    If dict.Count > 0 Then
        ' Transfer grouped accounts from dictionary to array for sorting
        ReDim sortedAccounts(1 To dict.Count)

        For i = 1 To dict.Count
            Set sortedAccounts(i) = dict.Items()(i - 1) ' Store dictionary items in an array for sorting
        Next i
    Else
        Exit Function
    End If
    
    QuickSort sortedAccounts, LBound(sortedAccounts), UBound(sortedAccounts)

    ' Add sorted accounts to the result collection
    For i = LBound(sortedAccounts) To UBound(sortedAccounts)
        resultCollection.Add sortedAccounts(i)
    Next i

    ' Return the grouped and sorted collection
    Set GroupByAccountName = resultCollection
End If
End Function
Public Function GroupByCategory(ByVal col As Collection) As Collection
If Not col Is Nothing Then
        
    
    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary") ' Instantiate the dictionary

    Dim account As Mdl_Accounts
    Dim groupedAccount As Mdl_Accounts
    Dim accountCategory As String
    Dim i As Long
    Dim sortedAccounts() As Mdl_Accounts
    Dim resultCollection As Collection

    ' Initialize the result collection
    Set resultCollection = New Collection

    ' Iterate through the collection of accounts
    For Each account In col
        accountCategory = account.accountCategory

        ' Check if account already exists in the dictionary
        If dict.Exists(accountCategory) Then
            ' Get the existing account from the dictionary
            Set groupedAccount = dict(accountCategory)
            ' Add the balances to the existing account
            groupedAccount.Debit = groupedAccount.Debit + account.Debit
            groupedAccount.Credit = groupedAccount.Credit + account.Credit
        Else
            ' Create a new account entry in the dictionary
            Set groupedAccount = New Mdl_Accounts ' Ensure the new clsAccounts object is instantiated
            groupedAccount.accountName = account.accountCategory
            groupedAccount.accountCategory = account.accountCategory
            groupedAccount.accountSubCategory = vbNullString
            groupedAccount.accountSubCategoryL1 = vbNullString
            groupedAccount.accountSubCategoryL2 = vbNullString
            groupedAccount.Debit = account.Debit
            groupedAccount.Credit = account.Credit

            ' Add it to the dictionary
            dict.Add accountCategory, groupedAccount
        End If
    Next account
    If dict.Count > 0 Then
        ' Transfer grouped accounts from dictionary to array for sorting
        ReDim sortedAccounts(1 To dict.Count)

        For i = 1 To dict.Count
            Set sortedAccounts(i) = dict.Items()(i - 1) ' Store dictionary items in an array for sorting
        Next i
    Else
        Exit Function
    End If
    
    QuickSort sortedAccounts, LBound(sortedAccounts), UBound(sortedAccounts)

    ' Add sorted accounts to the result collection
    For i = LBound(sortedAccounts) To UBound(sortedAccounts)
        resultCollection.Add sortedAccounts(i)
    Next i

    ' Return the grouped and sorted collection
    Set GroupByCategory = resultCollection
End If
End Function
Public Function GroupBySubCategory(ByVal col As Collection) As Collection
    If Not col Is Nothing Then

    
    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary") ' Instantiate the dictionary

    Dim account As Mdl_Accounts
    Dim groupedAccount As Mdl_Accounts
    Dim accountSubCategory As String
    Dim i As Long
    Dim sortedAccounts() As Mdl_Accounts
    Dim resultCollection As Collection

    ' Initialize the result collection
    Set resultCollection = New Collection

    ' Iterate through the collection of accounts
    For Each account In col
        accountSubCategory = account.accountSubCategory

        ' Check if account already exists in the dictionary
        If dict.Exists(accountSubCategory) Then
            ' Get the existing account from the dictionary
            Set groupedAccount = dict(accountSubCategory)
            ' Add the balances to the existing account
            groupedAccount.Debit = groupedAccount.Debit + account.Debit
            groupedAccount.Credit = groupedAccount.Credit + account.Credit
        Else
            ' Create a new account entry in the dictionary
            Set groupedAccount = New Mdl_Accounts ' Ensure the new clsAccounts object is instantiated
            groupedAccount.accountName = account.accountSubCategory
            groupedAccount.accountCategory = account.accountCategory
            groupedAccount.accountSubCategory = account.accountSubCategory
            groupedAccount.accountSubCategoryL1 = vbNullString
            groupedAccount.accountSubCategoryL2 = vbNullString
            groupedAccount.Debit = account.Debit
            groupedAccount.Credit = account.Credit

            ' Add it to the dictionary
            dict.Add accountSubCategory, groupedAccount
        End If
    Next account
    If dict.Count > 0 Then
        ' Transfer grouped accounts from dictionary to array for sorting
        ReDim sortedAccounts(1 To dict.Count)

        For i = 1 To dict.Count
            Set sortedAccounts(i) = dict.Items()(i - 1) ' Store dictionary items in an array for sorting
        Next i
    Else
        Exit Function
    End If
    
    QuickSort sortedAccounts, LBound(sortedAccounts), UBound(sortedAccounts)

    ' Add sorted accounts to the result collection
    For i = LBound(sortedAccounts) To UBound(sortedAccounts)
        resultCollection.Add sortedAccounts(i)
    Next i

    ' Return the grouped and sorted collection
    Set GroupBySubCategory = resultCollection
End If
End Function

Public Function GroupBySubCategoryL1(ByVal col As Collection) As Collection
    
    If Not col Is Nothing Then
    
    
    
    
    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary") ' Instantiate the dictionary

    Dim account As Mdl_Accounts
    Dim groupedAccount As Mdl_Accounts
    Dim accountSubCategoryL1 As String
    Dim i As Long
    Dim sortedAccounts() As Mdl_Accounts
    Dim resultCollection As Collection

    ' Initialize the result collection
    Set resultCollection = New Collection

    ' Iterate through the collection of accounts
    For Each account In col
        accountSubCategoryL1 = account.accountSubCategoryL1

        ' Check if account already exists in the dictionary
        If dict.Exists(accountSubCategoryL1) Then
            ' Get the existing account from the dictionary
            Set groupedAccount = dict(accountSubCategoryL1)
            ' Add the balances to the existing account
            groupedAccount.Debit = groupedAccount.Debit + account.Debit
            groupedAccount.Credit = groupedAccount.Credit + account.Credit
        Else
            ' Create a new account entry in the dictionary
            Set groupedAccount = New Mdl_Accounts ' Ensure the new clsAccounts object is instantiated
            groupedAccount.accountName = account.accountSubCategoryL1
            groupedAccount.accountCategory = account.accountCategory
            groupedAccount.accountSubCategory = account.accountSubCategory
            groupedAccount.accountSubCategoryL1 = account.accountSubCategoryL1
            groupedAccount.accountSubCategoryL2 = vbNullString
            groupedAccount.Debit = account.Debit
            groupedAccount.Credit = account.Credit

            ' Add it to the dictionary
            dict.Add accountSubCategoryL1, groupedAccount
        End If
    Next account
    If dict.Count > 0 Then
        ' Transfer grouped accounts from dictionary to array for sorting
        ReDim sortedAccounts(1 To dict.Count)

        For i = 1 To dict.Count
            Set sortedAccounts(i) = dict.Items()(i - 1) ' Store dictionary items in an array for sorting
        Next i
    Else
        Exit Function
    End If
    
    QuickSort sortedAccounts, LBound(sortedAccounts), UBound(sortedAccounts)

    ' Add sorted accounts to the result collection
    For i = LBound(sortedAccounts) To UBound(sortedAccounts)
        resultCollection.Add sortedAccounts(i)
    Next i

    ' Return the grouped and sorted collection
    Set GroupBySubCategoryL1 = resultCollection
    End If
End Function
Public Function GroupBySubCategoryL2(ByVal col As Collection) As Collection
    If Not col Is Nothing Then

    
    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary") ' Instantiate the dictionary

    Dim account As Mdl_Accounts
    Dim groupedAccount As Mdl_Accounts
    Dim accountSubCategoryL2 As String
    Dim i As Long
    Dim sortedAccounts() As Mdl_Accounts
    Dim resultCollection As Collection

    ' Initialize the result collection
    Set resultCollection = New Collection

    ' Iterate through the collection of accounts
    For Each account In col
        accountSubCategoryL2 = account.accountSubCategoryL2

        ' Check if account already exists in the dictionary
        If dict.Exists(accountSubCategoryL2) Then
            ' Get the existing account from the dictionary
            Set groupedAccount = dict(accountSubCategoryL2)
            ' Add the balances to the existing account
            groupedAccount.Debit = groupedAccount.Debit + account.Debit
            groupedAccount.Credit = groupedAccount.Credit + account.Credit
        Else
            ' Create a new account entry in the dictionary
            Set groupedAccount = New Mdl_Accounts ' Ensure the new clsAccounts object is instantiated
            groupedAccount.accountName = account.accountSubCategoryL2
            groupedAccount.accountCategory = account.accountCategory
            groupedAccount.accountSubCategory = account.accountSubCategory
            groupedAccount.accountSubCategoryL1 = account.accountSubCategoryL1
            groupedAccount.accountSubCategoryL2 = account.accountSubCategoryL2
            groupedAccount.Debit = account.Debit
            groupedAccount.Credit = account.Credit

            ' Add it to the dictionary
            dict.Add accountSubCategoryL2, groupedAccount
        End If
    Next account
    If dict.Count > 0 Then
        ' Transfer grouped accounts from dictionary to array for sorting
        ReDim sortedAccounts(1 To dict.Count)

        For i = 1 To dict.Count
            Set sortedAccounts(i) = dict.Items()(i - 1) ' Store dictionary items in an array for sorting
        Next i
    Else
        Exit Function
    End If
    
    QuickSort sortedAccounts, LBound(sortedAccounts), UBound(sortedAccounts)

    ' Add sorted accounts to the result collection
    For i = LBound(sortedAccounts) To UBound(sortedAccounts)
        resultCollection.Add sortedAccounts(i)
    Next i

    ' Return the grouped and sorted collection
    Set GroupBySubCategoryL2 = resultCollection
End If
End Function
' QuickSort algorithm to sort array of clsAccounts
Private Sub QuickSort(ByRef arr() As Mdl_Accounts, ByRef first As Long, ByRef last As Long)
    Dim i As Long
    Dim j As Long

    Dim pivot As Mdl_Accounts
    Dim temp As Mdl_Accounts
    If first < last Then
        Set pivot = arr((first + last) \ 2)
        i = first
        j = last
        Do
            Do While arr(i).accountName < pivot.accountName
                i = i + 1
            Loop
            Do While arr(j).accountName > pivot.accountName
                j = j - 1
            Loop
            If i <= j Then
                Set temp = arr(i)
                Set arr(i) = arr(j)
                Set arr(j) = temp
                i = i + 1
                j = j - 1
            End If
        Loop While i <= j
        QuickSort arr, first, j
        QuickSort arr, i, last
    End If
End Sub


