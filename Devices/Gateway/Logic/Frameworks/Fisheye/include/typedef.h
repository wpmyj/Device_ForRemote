/*
 *******************************************************************************
 *  Copyright (c) 2010-2016 VATICS Inc. All rights reserved.
 *
 *  +-----------------------------------------------------------------+
 *  | THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED |
 *  | AND COPIED IN ACCORDANCE WITH THE TERMS AND CONDITIONS OF SUCH  |
 *  | A LICENSE AND WITH THE INCLUSION OF THE THIS COPY RIGHT NOTICE. |
 *  | THIS SOFTWARE OR ANY OTHER COPIES OF THIS SOFTWARE MAY NOT BE   |
 *  | PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY OTHER PERSON. THE   |
 *  | OWNERSHIP AND TITLE OF THIS SOFTWARE IS NOT TRANSFERRED.        |
 *  |                                                                 |
 *  | THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE WITHOUT   |
 *  | ANY PRIOR NOTICE AND SHOULD NOT BE CONSTRUED AS A COMMITMENT BY |
 *  | VATICS INC.                                                     |
 *  +-----------------------------------------------------------------+
 *
 *******************************************************************************
 */

#ifndef _TYPEDEF_H_
#define _TYPEDEF_H_
#include <limits.h>

#if defined(_WIN32) || defined(_WIN32_)
#ifndef WIN32
#define	WIN32
#endif // WIN32
#endif // _WIN32 || _WIN32_

#if defined(WIN32) || defined(_WIN32_)
#ifndef _WIN32
#define	_WIN32
#endif // _WIN32
#endif // WIN32 || _WIN32_

#if defined(WIN32) || defined(_WIN32)
#ifndef _WIN32_
#define	_WIN32_
#endif // _WIN32_
#endif // WIN32 || _WIN32

#if defined(WIN32) || defined(_WIN32WCE)
#if !defined (_WINDOWS_)
#ifndef __AFXWIN_H__
#include <winsock2.h>
#include <windows.h>
#endif // __AFXWIN_H__
#endif // !_WINDOWS_
#endif // WIN32 || _WIN32WCE

#if !defined(__wtypes_h__) && !defined(_SCODE_)
typedef long SCODE;
#define	_SCODE_
#endif // !__wtypes_h__ && !_SCODE_

// to avoid confliction if including "windows.h"
#if !defined (_WINDOWS_) && !defined (__WINDOWS__) && !defined(WIN32) || !defined(_WIN32) // __WINDOWS__ for WINCE
// modify by allatin 2004/12/16 --------------------------------------------
// the following types are already define in windows.h

#ifndef __TYPES_H__		// for psos
// the following types are already define in psos.h

#ifndef UCHAR	// uc
typedef unsigned char   UCHAR;
#endif

#ifndef ULONG	// ul
typedef unsigned long   ULONG;
#endif

#ifndef USHORT	// us
typedef unsigned short  USHORT;
#endif

#ifndef UINT	// ui
typedef unsigned int    UINT;
#endif

#endif	// end of __TYPES_H__	// for psos

//  1 byte
#ifndef char	// c
typedef char            CHAR;
#endif

//  1 byte
#ifndef TCHAR	// c
typedef char           TCHAR;
#endif

#ifndef PCHAR	// pc
typedef char            *PCHAR;
#endif

#ifndef PUCHAR	// puc
typedef unsigned char   *PUCHAR;
#endif

#ifndef BYTE	// by
typedef unsigned char   BYTE;
#endif

#ifndef PBYTE	// pby
typedef BYTE*           PBYTE;
#endif

//  2 bytes
#ifndef SHORT	// s
typedef short           SHORT;
#endif

#ifndef PSHORT	// ps
typedef short           *PSHORT;
#endif

#ifndef PUSHORT	// pus
typedef unsigned short  *PUSHORT;
#endif

#ifndef WORD	// w
typedef unsigned short  WORD;
#endif

#ifndef PWORD	// pw
typedef WORD*           PWORD;
#endif

//  4 bytes
#ifndef DWORD	// dw
#ifdef __LP64__ 
typedef unsigned int   	DWORD;
#else
typedef unsigned long   DWORD;
#endif // __LP64__ 
#endif

#ifndef PDWORD	// pdw
typedef DWORD*          PDWORD;
#endif

#ifdef __LP64__
typedef unsigned long UINT_PTR;
#else
typedef unsigned int UINT_PTR;
#endif // __LP64__

#ifndef ULONG_PTR
typedef unsigned long   ULONG_PTR;
#endif

#ifndef DWORD_PTR
typedef ULONG_PTR	DWORD_PTR;
#endif

#ifndef PUINT	// pui
typedef UINT*           PUINT;
#endif

#ifndef LONG	// l
typedef long            LONG;
#endif

#ifndef PLONG	// pl
typedef long            *PLONG;
#endif

#ifndef PULONG	// plu
typedef unsigned long   *PULONG;
#endif


#ifndef BOOLEAN	// b
	#if defined( __APPLE__ ) && defined( __MACH__ )
		#if defined(TARGET_OS_IPHONE)		
			#if !defined(OBJC_HIDE_64) && __LP64__
				#include <stdbool.h>
				typedef bool BOOLEAN;
			#else
				typedef signed char BOOLEAN;
			#endif
		#else
			typedef unsigned char BOOLEAN;
		#endif
	#else
		typedef unsigned char BOOLEAN;
	#endif
#endif

#ifndef BOOL	// b
typedef BOOLEAN         BOOL;
#endif

// bool is keyword in C++
#if !defined(bool) && !defined(__cplusplus)
typedef BOOLEAN         bool;
#endif

#ifndef PVOID	// pv
typedef void *          PVOID;
#endif

#ifndef HANDLE	// h
typedef void *          HANDLE;
#endif

#ifndef SOCKET	//sck
typedef int             SOCKET;
#endif




// --------- for floating point -------------
#ifndef FLOAT	// fl
#ifdef _DOUBLE_PRECISION
	typedef double FLOAT;
#else
	typedef float  FLOAT;
#endif // !FLOAT

#endif // __TYPES_H__

// 2004/06/09 added by perkins
#ifndef LPCSTR
#define	LPCSTR		const char *
#endif // LPCSTR

#ifndef LPSTR
#define	LPSTR		char *
#endif // LPSTR

#ifndef LPCTSTR
#define	LPCTSTR		const char *
#endif // LPCTSTR

#ifndef LPTSTR
#define	LPTSTR		char *
#endif // LPTSTR

#ifndef LPWSTR
#define	LPWSTR		char *
#endif // LPWSTR

#ifndef LPCWSTR
#define	LPCWSTR		const char *
#endif // LPCWSTR

#ifndef __stdcall
#define	__stdcall
#endif // __stdcall

#ifndef __cdecl
#define	__cdecl
#endif // __cdecl

#ifndef __fastcall
#define	__fastcall
#endif // __fastcall

#ifndef UNREFERENCED_PARAMETER
#define	UNREFERENCED_PARAMETER(P)	
#endif // !UNREFERENCED_PARAMETER

// perkins 2006/7/13 to help to convert between pointer and long, int
#define HandleToULong( h ) ((unsigned long)(h) )
#define HandleToLong( h )  ((long)(h) )
#define ULongToHandle( ul ) ((HANDLE) (ul) )
#define LongToHandle( h )   ((HANDLE)(h) )
#define PtrToUlong( p ) ((unsigned long)(p) )
#define PtrToLong( p )  ((long) (p) )
#define PtrToUint( p ) ((unsigned int) (long)(p) )
#define PtrToInt( p )  ((int) (long)(p) )
#define PtrToUshort( p ) ((unsigned short)(unsigned long)(p) )
#define PtrToShort( p )  ((short)(long)(p) )
#define IntToPtr( i )    ((void *)(long)((int)i))
#define UIntToPtr( ui )  ((void *)(unsigned long)((unsigned int)ui))
#define LongToPtr( l )   ((void *)((long)l))
#define ULongToPtr( ul ) ((void *)((unsigned long)ul))
#define	SocketToPtr(socket)		((void *)(unsigned long) socket)
#define	PtrToSocket(p)			((int) (long) p)

#ifndef S_OK
#define S_OK 0
#endif

#ifndef S_FAIL
#define S_FAIL (SCODE)(-1)
#endif

#else
#define	SocketToPtr(socket)		((void *) socket)
#define	PtrToSocket(p)			((SOCKET) p)
#endif // !_WINDOWS_ && !__WINDOWS__

#define PtrToDWORD(p)	((DWORD)(DWORD_PTR)(p))

// non-window conflict types

#ifndef SCHAR   //c
typedef signed char     SCHAR;
#endif

#ifndef SWORD	// sw
typedef signed short    SWORD;
#endif

#ifndef SDWORD	// sdw
#if defined(__LP64__)
typedef signed int	    SDWORD;
#else
typedef signed long     SDWORD;
#endif // 
#endif

#ifndef TASK
typedef void            TASK;
#endif

// for 64 bit data types
#if defined(_WIN32)
	typedef unsigned __int64 		QWORD;	// qw
	typedef __int64					SQWORD;	// sqw	
#elif defined(_EQUATOR_X_) || defined(__arm)
	typedef unsigned long long		QWORD;	// qw
  	typedef long long           	SQWORD;	// sqw
#elif defined(__GNUC__) || defined(_LINUX)
	typedef unsigned long long int	QWORD;	// qw
  	typedef long long int          	SQWORD;	// sqw
#endif


// --------- for fix point -------------
typedef signed short     FIX16;
typedef unsigned short   UFIX16;
typedef signed long      FIX;
typedef unsigned long    UFIX;


#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

#define ON  1
#define OFF 0

//#ifndef S_INVALID_VERSION
//#define S_INVALID_VERSION (SCODE)(-2)
//#endif

#endif // _TYPEDEF_H_
