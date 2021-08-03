; ======================================================
; Example - copy AutoHotkey.exe into the script folder
; ======================================================

sFile := "AutoHotkeyU64.exe" ; change this as needed for the example
rsc := res(sFile)

list := ""

For i, obj in rsc
    list .= (list?"`n`n":"") "Type: " obj.type "`nName: " obj.name "`nLang: " obj.lang

msgbox list ; all resources in the specified file

; ========================================================================
; res class - list all resources in a resource file
;
;   Usage:
;
;       res_list := res(in_file)
;
;   Output:
;
;       Contains an array.  Each element in the array is an object that has
;       the following properties:
;
;           res_list.type (usually a number)
;           res_list.name (a string or number)
;           res_list.Lang (a number)
;
;           See comments at the bottom of this document to understand
;           the codes that relate to resource types, names, and langs.
; ========================================================================

res(sFile) {
    names := [], EnumCb := {}
    
    If !(hModule := DllCall("Kernel32\LoadLibrary","Str",sFile,"UPtr"))
        return false
    
    Loop (p := 3) {
        EnumCb.fnc := Enum_cb.Bind(List:=[])
        EnumCb.ptr := CallbackCreate(EnumCb.fnc, "F", p)
        
        If (A_Index = 1) {
            r1 := DllCall("EnumResourceTypesEx", "UPtr", hModule, "UPtr", EnumCb.ptr, "UPtr", 0, "UInt", 0x1, "UShort", 0)
            names := List.Clone()
        } Else If (A_Index = 2) {
            For name, typ in names {
                (IsInteger(typ)) ? typ := "#" typ : ""
                r1 := DllCall("EnumResourceNames", "UPtr", hModule, "Str", typ, "UPtr", EnumCb.ptr, "UPtr", 0, "Int")
            }
            names := List.Clone()
        } Else If (A_Index = 3) {
            For i, obj in names {
                typ  := ((IsInteger(obj[1])) ? "#" : "") obj[1]
                name := ((IsInteger(obj[2])) ? "#" : "") obj[2]
                DllCall("EnumResourceLanguagesEx", "UPtr", hModule, "Str", typ, "Str", name, "UPtr", EnumCb.ptr
                                                 , "UPtr", 0, "UInt", 0x1, "UShort", 0)
            }
            names := List.Clone()
        }
        CallbackFree(EnumCb.ptr), p++
    }
    
    r1 := DllCall("FreeLibrary","UPtr",hModule)
    return names

    Enum_cb(List, hModule, sType, p*) {
        typ := ((sType>>16) == 0) ? sType : StrGet(sType)
        
        If (p.Length = 1)
            List.Push(((sType>>16) == 0) ? sType : StrGet(sType))
        Else If (p.Length > 1)
            name := ((p[1]>>16) == 0) ? p[1] : StrGet(p[1])
        
        If (p.Length = 2)
            List.Push([typ, name])
        Else If (p.Length = 3)
            List.Push({type:typ, name:name, lang:p[2]})
        
        return true
    }
}

; =================================================================
; Resource Types
; =================================================================
; Accelerator   = 9                 X = common AutoHotkey resources
; AniCursor     = 21
; AniIcon       = 22
; Bitmap        = 2
; Cursor        = 1
; Dialog        = 5                 X
; DlgInclude    = 17
; Font          = 8
; FontDir       = 7
; Group_Cursor  = Cursor + 11 (12)
; Group_Icon    = Icon + 11 (14)    X
; HTML          = 23
; Icon          = 3                 X
; Manifest      = 24                X
; Menu          = 4                 X
; MessageTable  = 11
; PlugPlay      = 19
; RCDATA        = 10                X = for compiled scripts only
; String        = 6
; Version       = 16                X
; VXD           = 20

; VersionInfo LANG IDs
; ==================================================================
; Code    Language                Code    Language
; 0x0401  Arabic                  0x0415  Polish
; 0x0402  Bulgarian               0x0416  Portuguese (Brazil)
; 0x0403  Catalan                 0x0417  Rhaeto-Romanic
; 0x0404  Traditional Chinese     0x0418  Romanian
; 0x0405  Czech                   0x0419  Russian
; 0x0406  Danish                  0x041A  Croato-Serbian (Latin)
; 0x0407  German                  0x041B  Slovak
; 0x0408  Greek                   0x041C  Albanian
; 0x0409  U.S. English (1033)     0x041D  Swedish
; 0x040A  Castilian Spanish       0x041E  Thai
; 0x040B  Finnish                 0x041F  Turkish
; 0x040C  French                  0x0420  Urdu
; 0x040D  Hebrew                  0x0421  Bahasa
; 0x040E  Hungarian               0x0804  Simplified Chinese
; 0x040F  Icelandic               0x0807  Swiss German
; 0x0410  Italian                 0x0809  U.K. English
; 0x0411  Japanese                0x080A  Spanish (Mexico)
; 0x0412  Korean                  0x080C  Belgian French
; 0x0413  Dutch                   0x0C0C  Canadian French
; 0x0414  Norwegian ? Bokmal      0x100C  Swiss French
; 0x0810  Swiss Italian           0x0816  Portuguese (Portugal)
; 0x0813  Belgian Dutch           0x081A  Serbo-Croatian (Cyrillic)
; 0x0814  Norwegian ? Nynorsk

; VersionInfo CHARSETs
;===============================================
; Decimal Hexadecimal Character Set
; 0       0000        7-bit ASCII
; 932     03A4        Japan (Shift ? JIS X-0208)
; 949     03B5        Korea (Shift ? KSC 5601)
; 950     03B6        Taiwan (Big5)
; 1200    04B0        Unicode
; 1250    04E2        Latin-2 (Eastern European)
; 1251    04E3        Cyrillic
; 1252    04E4        Multilingual
; 1253    04E5        Greek
; 1254    04E6        Turkish
; 1255    04E7        Hebrew
; 1256    04E8        Arabic

; ==============================================
; typedef struct tagVS_FIXEDFILEINFO {
  ; DWORD dwSignature;          ffi[1]
  ; DWORD dwStrucVersion;       ffi[2]
  ; DWORD dwFileVersionMS;      ffi[3] most significant
  ; DWORD dwFileVersionLS;      ffi[4] least significant
  ; DWORD dwProductVersionMS;   ffi[5] most significant
  ; DWORD dwProductVersionLS;   ffi[6] least significant
  ; DWORD dwFileFlagsMask;      ffi[7]
  ; DWORD dwFileFlags;          ffi[8]
  ; DWORD dwFileOS;             ffi[9]
  ; DWORD dwFileType;           ffi[10]
  ; DWORD dwFileSubtype;        ffi[11]
  ; DWORD dwFileDateMS;         ffi[12] most significant
  ; DWORD dwFileDateLS;         ffi[13] least significant
; } VS_FIXEDFILEINFO;