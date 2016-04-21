/* $Revision: 1.2 $ */
#ifndef _CUSTCNTL_INCLUDED
#define _CUSTCNTL_INCLUDED
#define CCHCCCLASS	32
#define CCHCCDESC	32
#define CCHCCTEXT	256
#define CCF_NOTEXT	1
#ifdef UNICODE
#define CCSTYLEFLAG	CCSTYLEFLAGW
#define LPCCSTYLEFLAG	LPCCSTYLEFLAGW
#define CCSTYLE	CCSTYLEW
#define CCINFO	CCINFOW
#define LPFNCCINFO	LPFNCCINFOW
#define LPCCINFO	LPCCINFOW
#define LPCCSTYLE	LPCCSTYLEW
#define LPFNCCSTYLE	LPFNCCSTYLEW
#define LPFNCCSIZETOTEXT	LPFNCCSIZETOTEXTW
#else
#define CCSTYLEFLAG	CCSTYLEFLAGA
#define LPCCSTYLEFLAG	LPCCSTYLEFLAGA
#define CCSTYLE	CCSTYLEA
#define LPCCSTYLE	LPCCSTYLEA
#define LPFNCCSTYLE	LPFNCCSTYLEA
#define LPFNCCSIZETOTEXT	LPFNCCSIZETOTEXTA
#define CCINFO	CCINFOA
#define LPCCINFO	LPCCINFOA
#define LPFNCCINFO	LPFNCCINFOA
#endif
typedef struct _CCSTYLEA {
	DWORD	flStyle;
	DWORD	flExtStyle;
	CHAR	szText[CCHCCTEXT];
	LANGID	lgid;
	WORD	wReserved1;
} CCSTYLEA,*LPCCSTYLEA;
typedef struct _CCSTYLEW {
	DWORD	flStyle;
	DWORD	flExtStyle;
	WCHAR	szText[CCHCCTEXT];
	LANGID	lgid;
	WORD	wReserved1;
} CCSTYLEW, *LPCCSTYLEW;
typedef WINBOOL (CALLBACK* LPFNCCSTYLEA)(HWND,LPCCSTYLEA);
typedef WINBOOL (CALLBACK* LPFNCCSTYLEW)(HWND,LPCCSTYLEW);
typedef int (CALLBACK* LPFNCCSIZETOTEXTA)(DWORD,DWORD,HFONT,LPSTR);
typedef int (CALLBACK* LPFNCCSIZETOTEXTW)(DWORD,DWORD,HFONT,LPWSTR);
typedef struct	_CCSTYLEFLAGA {
	DWORD flStyle;
	DWORD flStyleMask;
	LPSTR pszStyle;
} CCSTYLEFLAGA,*LPCCSTYLEFLAGA;
typedef struct _CCSTYLEFLAGW {
	DWORD flStyle;
	DWORD flStyleMask;
	LPWSTR pszStyle;
} CCSTYLEFLAGW, *LPCCSTYLEFLAGW;
typedef struct _CCINFOA {
	CHAR    szClass[CCHCCCLASS];
	DWORD   flOptions;
	CHAR    szDesc[CCHCCDESC];
	UINT    cxDefault;
	UINT    cyDefault;
	DWORD   flStyleDefault;
	DWORD	flExtStyleDefault;
	DWORD	flCtrlTypeMask;
	CHAR	szTextDefault[CCHCCTEXT];
	int	cStyleFlags;
	LPCCSTYLEFLAGA aStyleFlags;
	LPFNCCSTYLEA lpfnStyle;
	LPFNCCSIZETOTEXTA lpfnSizeToText;
	DWORD   dwReserved1;
	DWORD   dwReserved2;
} CCINFOA, *LPCCINFOA;
typedef struct _CCINFOW {
	WCHAR   szClass[CCHCCCLASS];
	DWORD   flOptions;
	WCHAR   szDesc[CCHCCDESC];
	UINT    cxDefault;
	UINT    cyDefault;
	DWORD	flStyleDefault;
	DWORD	flExtStyleDefault;
	DWORD	flCtrlTypeMask;
	int	cStyleFlags;
	LPCCSTYLEFLAGW aStyleFlags;
	WCHAR	szTextDefault[CCHCCTEXT];
	LPFNCCSTYLEW lpfnStyle;
	LPFNCCSIZETOTEXTW lpfnSizeToText;
	DWORD	dwReserved1;
	DWORD	dwReserved2;
} CCINFOW, *LPCCINFOW;
typedef UINT (CALLBACK* LPFNCCINFOA)(LPCCINFOA);
typedef UINT (CALLBACK* LPFNCCINFOW)(LPCCINFOW);
#endif