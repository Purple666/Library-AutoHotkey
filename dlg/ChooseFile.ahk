﻿/*
    Initializes, shows, and gets results from a common file dialog that allows the user to choose a file(s).
    Parameters:
        Owner:
            The Gui object or handle to the owner window. This parameter can be zero.
        Title:
            Sets the title of the dialog.
            This parameter can be a string or a pointer to a null-terminated string.
            If a NULL pointer is specified, the default title will be used.
        FileName:
            The file name that appears in the File name edit box when that dialog box is opened.
            To specify a directory, this string must end with a backslash.
            If the directory does not exist, parent directories are searched.
        Filter:
            Sets the file types that the dialog can open. If omitted, the filter defaults to All Files (*.*). 
            This parameter should be a string with the format: "Images:*.jpg;*.bmp;*.png|*Audio:*.wav;*.mp3\mp3".
            The asterisk at the beginning of the description indicates the filter selected by default. If not set, the first one is shown.
            In the last filter, the '\' character must be followed by the name of the default extension to be added to file names.
        CustomPlaces:
            Adds folders to the list of places available for the user to open items.
            This parameter should be an array of paths to a directory. Non-existent directories are omitted.
        Flags:
            Sets flags to control the behavior of the dialog.
            0x00040000  FOS_HIDEPINNEDPLACES    Hide all of the standard namespace locations shown in the navigation pane.
            0x00000200  FOS_ALLOWMULTISELECT    Enables the user to select multiple items in the open dialog.
            0x00001000  FOS_FILEMUSTEXIST       The item returned must exist.
            0x10000000  FOS_FORCESHOWHIDDEN     Include hidden and system items.
            0x02000000  FOS_DONTADDTORECENT     Do not add the item being opened to the recent documents list (SHAddToRecentDocs).
            Reference: https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/ne-shobjidl_core-_fileopendialogoptions.
            The default flag is FOS_FILEMUSTEXIST.
    Return:
        Returns an object with the following keys.
        Result             Receive a string with the chosen file, or an array if the FOS_ALLOWMULTISELECT flag was specified. It is set to an empty array if there was an error.
        FileName           Receives the text currently entered in the dialog's File name edit box.
        FileTypeIndex      Receives the index of the selected file type in the filter.
    ErrorLevel:
        If the function succeeds, it receives 0 (S_OK). Otherwise, it receives an HRESULT error code, including the following.
        0x04C7  ERROR_CANCELLED      The user closed the window by cancelling the operation.
    Example:
        R := ChooseFile(0,, A_ComSpec, "Images:*.jpg;*.bmp;*.png|*Audio:*.wav;*.mp3\mp3", [A_Desktop,A_Temp])
        MsgBox("Result:`n" . R.Result . "`n`nFileName:`n" . R.FileName . "`n`nFileTypeIndex:`n" . R.FileTypeIndex . "`n`nErrorLevel:`n" . ErrorLevel)        
*/
ChooseFile(Owner, Title := 0, FileName := "", Filter := "All files:*.*", CustomPlaces := "", Flags := 0x1000)
{
    local


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileOpenDialog interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ifileopendialog.
    ; --------------------------------------------------------------------------------------------------------------------
    local IFileOpenDialog := ComObjCreate("{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}", "{D57C7288-D4AD-4768-BE02-9D969532D960}")
    vt              := (n) => NumGet(NumGet(IFileOpenDialog,"Ptr")+n*A_PtrSize, "Ptr")


    ; --------------------------------------------------------------------------------------------------------------------
    ; Initialize variables.
    ; --------------------------------------------------------------------------------------------------------------------
    Resources := { }  ; Stores certain data and resources to be freed at the end of the function.


    ; --------------------------------------------------------------------------------------------------------------------
    ; Check the parameters.
    ; --------------------------------------------------------------------------------------------------------------------
    Owner := Type(Owner) == "Gui" ? Owner.hWnd : Owner
    if Type(Owner) !== "Integer"
        throw Exception("ChooseFile function: invalid parameter #1.", -1, "Invalid data type.")
    if Owner && !WinExist("ahk_id" . Owner)
        throw Exception("ChooseFile function: invalid parameter #1.", -1, "The specified window does not exist.")

    if !(Type(Title) ~= "^(Integer|String)$")
        throw Exception("ChooseFile function: invalid parameter #2.", -1, "Invalid data type.")
    Title := Type(Title) == "Integer" ? Title : Trim(Title~="^\s*$"?A_ScriptName:Title,"`s`t`r`n")

    if Type(FileName) !== "String"
        throw Exception("ChooseFile function: invalid parameter #3.", -1, "Invalid data type.")
    FileName := Trim(FileName, "`s`t`r`n")

    if Type(Filter) !== "String"
        throw Exception("ChooseFile function: invalid parameter #4.", -1, "Invalid value.")

    if !(Type(CustomPlaces) ~= "^(Object|String)$")
        throw Exception("ChooseFile function: invalid parameter #5.", -1, "Invalid value.")
    CustomPlaces := CustomPlaces == "" ? [] : IsObject(CustomPlaces) ? CustomPlaces : [CustomPlaces]

    if Type(Flags) !== "Integer"
        throw Exception("ChooseFile function: invalid parameter #6.", -1, "Invalid data type.")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetTitle method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-settitle.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(17), "Ptr", IFileOpenDialog
                  , "Ptr", Type(Title) == "Integer" ? Title : &Title
           , "UInt")
    

    ; --------------------------------------------------------------------------------------------------------------------
    ; Sets the file name that appears in the File name edit box when that dialog box is opened.
    ; --------------------------------------------------------------------------------------------------------------------
    if FileName !== ""
    {
        Directory := FileName

        if InStr(FileName, "\")
        {
            if !(FileName ~= "\\$")
            {
                SplitPath(FileName, File, Directory)
                ; IFileDialog::SetFileName.
                ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfilename.
                DllCall(vt.call(15), "Ptr", IFileOpenDialog, "Ptr", &File, "UInt")
            }
            
            while InStr(Directory,"\") && !DirExist(Directory)
                Directory := SubStr(Directory, 1, InStr(Directory,"\",,-1)-1)
            if DirExist(Directory)
            {
                DllCall("Shell32.dll\SHParseDisplayName", "Ptr", &Directory, "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "UInt", 0, "UInt")
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "Ptr", PIDL, "PtrP", IShellItem:=0, "UInt")
                Resources[IShellItem] := PIDL

                ; IFileDialog::SetFolder method.
                ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfolder.
                DllCall(vt.call(12), "Ptr", IFileOpenDialog, "UPtr", IShellItem, "UInt")
            }
        }
        else
            DllCall(vt.call(15), "Ptr", IFileOpenDialog, "Ptr", &FileName, "UInt")
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; COMDLG_FILTERSPEC structure
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shtypes/ns-shtypes-_comdlg_filterspec.
    ; --------------------------------------------------------------------------------------------------------------------
    FileTypes     := 0  ; The number of valid elements in the filter.
    FileTypeIndex := 1  ; The index of the file type that appears as selected in the dialog.
    Escape        := 0

    Resources.SetCapacity("COMDLG_FILTERSPEC", StrSplit(Filter,"|").Length() * 2*A_PtrSize)
    loop parse, Filter, "|"
    {
        if !InStr(A_LoopField, ":")
            continue

        ++FileTypes
        desc   := StrSplit(A_LoopField,":")[1]
        types  := StrSplit(StrSplit(A_LoopField,"\")[1], ":")[2]
        defext := InStr(A_LoopField,"\") ? StrSplit(A_LoopField,"\")[2] : ""
        
        if desc ~= "^\*"
        {
            FileTypeIndex := A_Index
            desc := SubStr(desc, 2)
        }

        if defext !== ""
            ; IFileDialog::SetDefaultExtension method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setdefaultextension.
            DllCall(vt.call(22), "Ptr", IFileOpenDialog, "Ptr", &defext, "UInt")

        Resources["#" . FileTypes] := desc
        Resources["@" . FileTypes] := types

        NumPut(Resources.GetAddress("#" . A_Index), Resources.GetAddress("COMDLG_FILTERSPEC") + A_PtrSize * 2*(FileTypes-1), "Ptr")      ; COMDLG_FILTERSPEC.pszName.
        NumPut(Resources.GetAddress("@" . A_Index), Resources.GetAddress("COMDLG_FILTERSPEC") + A_PtrSize * (2*(FileTypes-1)+1), "Ptr")  ; COMDLG_FILTERSPEC.pszSpec.
    }
    

    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetFileTypes method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfiletypes.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(4), "Ptr", IFileOpenDialog, "UInt", FileTypes, "Ptr", Resources.GetAddress("COMDLG_FILTERSPEC"), "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetFileTypeIndex method.
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(5), "Ptr", IFileOpenDialog, "UInt", FileTypeIndex, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; Adds folders to the list of places available for the user to open or save items.
    ; --------------------------------------------------------------------------------------------------------------------
    loop CustomPlaces.Length()
    {
        if DirExist(CustomPlaces[A_Index])
        {
            DllCall("Shell32.dll\SHParseDisplayName", "Ptr", CustomPlaces.GetAddress(A_Index), "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "UInt", 0, "UInt")
            DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "Ptr", PIDL, "PtrP", IShellItem:=0, "UInt")
            Resources[IShellItem] := PIDL

            ; IFileDialog::AddPlace method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-addplace.
            DllCall(vt.call(21), "Ptr", IFileOpenDialog, "Ptr", IShellItem, "UInt", 0, "UInt")
        }
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetOptions method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setoptions.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(9), "Ptr", IFileOpenDialog, "UInt", Flags, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IModalWindow::Show method.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-imodalwindow-show.
    ; --------------------------------------------------------------------------------------------------------------------
    R := { Result:[] , FileName:"" , FileTypeIndex:0 }
    ErrorLevel := DllCall(vt.call(3), "Ptr", IFileOpenDialog, "Ptr", Owner, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::GetFileTypeIndex method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-getfiletypeindex.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(6), "Ptr", IFileOpenDialog, "UIntP", FileTypeIndex, "UInt")
        R.FileTypeIndex := FileTypeIndex


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::GetFileName method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-getfilename.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(16), "Ptr", IFileOpenDialog, "PtrP", pBuffer:=0, "UInt")
    {
        R.FileName := StrGet(pBuffer, "UTF-16")
        DllCall("Ole32.dll\CoTaskMemFree", "Ptr", pBuffer, "Int")
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileOpenDialog::GetResults method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifileopendialog-getresults.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(27), "Ptr", IFileOpenDialog, "PtrP", IShellItemArray:=0, "UInt")
    {
        ; IShellItemArray::GetCount method.
        ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getcount.
        DllCall(NumGet(NumGet(IShellItemArray,"Ptr")+7*A_PtrSize,"Ptr"), "Ptr", IShellItemArray, "UIntP", Count, "UInt")

        R.Result.SetCapacity(Count)
        VarSetCapacity(Buffer, 32767 * 2)
        loop Count
        {
            ; IShellItemArray::GetItemAt method.
            ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getitemat.
            DllCall(NumGet(NumGet(IShellItemArray,"Ptr")+8*A_PtrSize,"Ptr"), "Ptr", IShellItemArray, "UInt", A_Index-1, "PtrP", IShellItem:=0, "UInt")

            DllCall("Shell32.dll\SHGetIDListFromObject", "Ptr", IShellItem, "PtrP", PIDL:=0, "UInt")
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "Ptr", PIDL, "Str", Buffer, "UInt", 32767, "UInt", 0, "UInt")
            Resources[IShellItem] := PIDL
            R.Result.Push(Buffer)
        } 

        ObjRelease(IShellItemArray)
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; Free resources and return.
    ; --------------------------------------------------------------------------------------------------------------------
    for IShellItem, PIDL in Resources
    {
        if Type(IShellItem) == "Integer"
        {
            ObjRelease(IShellItem)
            DllCall("Ole32.dll\CoTaskMemFree", "Ptr", PIDL, "Int")
        }
    }
    ObjRelease(IFileOpenDialog)

    if R.Result.Length() && !(Flags & 0x00000200)
        R.Result := R.Result[1]

    return R
}
