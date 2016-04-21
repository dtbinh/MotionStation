/* $Revision: 1.2 $ */
#ifndef	__LCC__RPCPROXY_H__
#define	__LCC__RPCPROXY_H__
#define	__midl_proxy
#ifndef	INC_OLE2
#define	INC_OLE2
#endif
#ifndef	GUID_DEFINED
#define	GUID_DEFINED
typedef	struct _GUID {
	unsigned long Data1;
	unsigned short Data2;
	unsigned short Data3;
	unsigned char Data4[8];
}	GUID;
#endif
#if	!defined( __IID_DEFINED__ )
#define	__IID_DEFINED__
typedef	GUID IID;
typedef	IID *LPIID;
#define	IID_NULL GUID_NULL
#define	IsEqualIID(riid1, riid2) IsEqualGUID(riid1, riid2)
typedef	GUID CLSID;
typedef	CLSID *LPCLSID;
#define	CLSID_NULL GUID_NULL
#define	IsEqualCLSID(rclsid1, rclsid2) IsEqualGUID(rclsid1, rclsid2)
#ifndef	_REFGUID_DEFINED
#define	_REFGUID_DEFINED
typedef	const GUID *REFGUID;
#endif	
#ifndef	_REFIID_DEFINED
#define	_REFIID_DEFINED
typedef	const IID *REFIID;
#endif	
#ifndef	_REFCLSID_DEFINED
#define	_REFCLSID_DEFINED
typedef	const CLSID *REFCLSID;
#endif	
#endif	
struct	tagCInterfaceStubVtbl;
struct	tagCInterfaceProxyVtbl;
typedef	struct tagCInterfaceStubVtbl * PCInterfaceStubVtblList;
typedef	struct tagCInterfaceProxyVtbl * PCInterfaceProxyVtblList;
typedef	const char * PCInterfaceName;
typedef	int __stdcall IIDLookupRtn( const IID * pIID, int * pIndex );
typedef	IIDLookupRtn * PIIDLookup;
typedef	struct tagProxyFileInfo {
	const PCInterfaceProxyVtblList *pProxyVtblList;
	const PCInterfaceStubVtblList *pStubVtblList;
	const PCInterfaceName * pNamesArray;
	const IID ** pDelegatedIIDs;
	const PIIDLookup pIIDLookupRtn;
	unsigned short TableSize;
	unsigned short TableVersion;
	unsigned long Filler1;
	unsigned long Filler2;
	unsigned long Filler3;
	unsigned long Filler4;
}ProxyFileInfo;
typedef	ProxyFileInfo ExtendedProxyFileInfo;
#ifndef	__LCC_RPC_
#include	<rpc.h>
#endif
#ifndef	__LCC__RPCNDR__
#include	<rpcndr.h>
#endif
#ifndef	_STRING_H_DEFINED_
#include	<string.h>
#endif
#include	<memory.h>
typedef	struct tagCInterfaceProxyHeader {
#ifdef	USE_STUBLESS_PROXY
	const void * pStublessProxyInfo;
#endif
	const IID * piid;
}	CInterfaceProxyHeader;
typedef	struct tagCInterfaceProxyVtbl {
	CInterfaceProxyHeader header;
	void *Vtbl[1];
}	CInterfaceProxyVtbl;
typedef void ( _stdcall * PRPC_STUB_FUNCTION) (IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
typedef	struct tagCInterfaceStubHeader {
	const IID *piid;
	const MIDL_SERVER_INFO *pServerInfo;
	unsigned long DispatchTableCount;
	const PRPC_STUB_FUNCTION *pDispatchTable;
}	CInterfaceStubHeader;
typedef	struct tagCInterfaceStubVtbl {
	CInterfaceStubHeader header;
	IRpcStubBufferVtbl Vtbl;
}	CInterfaceStubVtbl;
typedef	struct tagCStdStubBuffer {
	const struct IRpcStubBufferVtbl * lpVtbl; 
	long RefCount;
	struct IUnknown * pvServerObject;
}	CStdStubBuffer;
typedef	struct tagCStdPSFactoryBuffer {
	const IPSFactoryBufferVtbl *lpVtbl;
	long RefCount;
	const ProxyFileInfo ** pProxyFileList;
	long Filler1; 
}	CStdPSFactoryBuffer;
void	RPC_ENTRY NdrProxyInitialize(void *,PRPC_MESSAGE,PMIDL_STUB_MESSAGE,PMIDL_STUB_DESC,unsigned int);
void	RPC_ENTRY NdrProxyGetBuffer( void *,PMIDL_STUB_MESSAGE);
void	RPC_ENTRY NdrProxySendReceive(void *,MIDL_STUB_MESSAGE *);
void	RPC_ENTRY NdrProxyFreeBuffer(void *,MIDL_STUB_MESSAGE *);
HRESULT	RPC_ENTRY NdrProxyErrorHandler(DWORD);
void	RPC_ENTRY NdrStubInitialize( PRPC_MESSAGE,PMIDL_STUB_MESSAGE,PMIDL_STUB_DESC,IRpcChannelBuffer *);
void	_stdcall NdrStubForwardingFunction(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void	RPC_ENTRY NdrStubGetBuffer(IRpcStubBuffer *,IRpcChannelBuffer *, PMIDL_STUB_MESSAGE);
HRESULT	RPC_ENTRY NdrStubErrorHandler( DWORD dwExceptionCode);
HRESULT	STDMETHODCALLTYPE CStdStubBuffer_QueryInterface( IRpcStubBuffer *, REFIID,void **);
ULONG	STDMETHODCALLTYPE CStdStubBuffer_AddRef( IRpcStubBuffer *This);
ULONG	STDMETHODCALLTYPE CStdStubBuffer_Release( IRpcStubBuffer *This);
ULONG	STDMETHODCALLTYPE NdrCStdStubBuffer_Release( IRpcStubBuffer *This, IPSFactoryBuffer * pPSF);
HRESULT	STDMETHODCALLTYPE CStdStubBuffer_Connect( IRpcStubBuffer *This, IUnknown *pUnkServer);
void	STDMETHODCALLTYPE CStdStubBuffer_Disconnect( IRpcStubBuffer *This);
HRESULT	STDMETHODCALLTYPE CStdStubBuffer_Invoke( IRpcStubBuffer *This, RPCOLEMESSAGE *pRpcMsg, IRpcChannelBuffer *pRpcChannelBuffer);
IRpcStubBuffer	* STDMETHODCALLTYPE CStdStubBuffer_IsIIDSupported( IRpcStubBuffer *This, REFIID riid);
ULONG	STDMETHODCALLTYPE CStdStubBuffer_CountRefs( IRpcStubBuffer *This);
HRESULT	STDMETHODCALLTYPE CStdStubBuffer_DebugServerQueryInterface( IRpcStubBuffer *This, void **ppv);
void	STDMETHODCALLTYPE CStdStubBuffer_DebugServerRelease( IRpcStubBuffer *This, void *pv);
#define	CStdStubBuffer_METHODS  CStdStubBuffer_QueryInterface, CStdStubBuffer_AddRef, \
	CStdStubBuffer_Release, CStdStubBuffer_Connect,  CStdStubBuffer_Disconnect, \
	CStdStubBuffer_Invoke, CStdStubBuffer_IsIIDSupported, CStdStubBuffer_CountRefs, \
	CStdStubBuffer_DebugServerQueryInterface, CStdStubBuffer_DebugServerRelease


#define	IID_GENERIC_CHECK_IID(name,pIID,index) memcmp( pIID, name##_ProxyVtblList[ index ]->header.piid, 16 )
#define	IID_BS_LOOKUP_SETUP int result, low=-1;
#define	IID_BS_LOOKUP_INITIAL_TEST(name, sz, split)  if ((result = name##_CHECK_IID(split))>0) {low=sz-split;}\
	else if ( !result )  { low = split; goto found_label; }

#define	IID_BS_LOOKUP_NEXT_TEST(name, split ) \
	if ( ( result = name##_CHECK_IID( low + split )) >= 0 ) \
	{ low = low + split; if ( !result ) goto found_label; }

#define	IID_BS_LOOKUP_RETURN_RESULT(name, sz, index ) \
	low = low + 1;  \
	if ( ( low >= sz ) || (result = name##_CHECK_IID( low ) )) goto not_found_label; \
	found_label: (index) = low; return 1; \
	not_found_label: return 0;

HRESULT	RPC_ENTRY NdrDllGetClassObject (REFCLSID,REFIID riid,void **,const ProxyFileInfo **, const CLSID *,CStdPSFactoryBuffer *);
HRESULT	RPC_ENTRY NdrDllCanUnloadNow(CStdPSFactoryBuffer *);
#ifndef	NT35_STRICT
HRESULT	RPC_ENTRY NdrDllRegisterProxy(HMODULE,const ProxyFileInfo **,const CLSID *);
HRESULT	RPC_ENTRY NdrDllUnregisterProxy(HMODULE,const ProxyFileInfo **,const CLSID *);
#define	REGISTER_PROXY_DLL_ROUTINES(pProxyFileList, pClsID) HINSTANCE hProxyDll = 0; \
	BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) { if(fdwReason == DLL_PROCESS_ATTACH) hProxyDll = hinstDLL; return TRUE;} \
	HRESULT STDAPICALLTYPE DllRegisterServer() {return NdrDllRegisterProxy(hProxyDll, pProxyFileList, pClsID); } \
	HRESULT STDAPICALLTYPE DllUnregisterServer() { return NdrDllUnregisterProxy(hProxyDll, pProxyFileList, pClsID); } 
#define	STUB_FORWARDING_FUNCTION NdrStubForwardingFunction
ULONG	STDMETHODCALLTYPE CStdStubBuffer2_Release(IRpcStubBuffer *This);
ULONG	STDMETHODCALLTYPE NdrCStdStubBuffer2_Release(IRpcStubBuffer *This,IPSFactoryBuffer * pPSF);
#define	CStdStubBuffer_DELEGATING_METHODS 0, 0, CStdStubBuffer2_Release, 0, 0, 0, 0, 0, 0, 0
#endif	
#ifdef	PROXY_CLSID
#define	CLSID_PSFACTORYBUFFER extern CLSID PROXY_CLSID;
#else	
#ifdef	PROXY_CLSID_IS
#define	CLSID_PSFACTORYBUFFER const CLSID CLSID_PSFactoryBuffer = PROXY_CLSID_IS;
#define	PROXY_CLSID CLSID_PSFactoryBuffer
#else	
#define	CLSID_PSFACTORYBUFFER
#endif	
#endif	
#ifndef	PROXY_CLSID
#define	GET_DLL_CLSID  ( aProxyFileList[0]->pStubVtblList[0] != 0 ? aProxyFileList[0]->pStubVtblList[0]->header.piid : 0)
#else	
#define	GET_DLL_CLSID &PROXY_CLSID
#endif	
#define	EXTERN_PROXY_FILE(name)  const ProxyFileInfo name##_ProxyFileInfo;
#define	PROXYFILE_LIST_START  const ProxyFileInfo * aProxyFileList[] = {
#define	REFERENCE_PROXY_FILE(name)  & name##_ProxyFileInfo 
#define	PROXYFILE_LIST_END  0 };
#define	DLLDATA_GETPROXYDLLINFO(pPFList,pClsid)  void RPC_ENTRY GetProxyDllInfo( const ProxyFileInfo*** pInfo, const CLSID ** pId){*pInfo = pPFList;*pId = pClsid;};
#define	DLLGETCLASSOBJECTROUTINE(pPFlist, pClsid,pFactory)  HRESULT STDAPICALLTYPE DllGetClassObject ( \
	REFCLSID rclsid,  REFIID riid,  void ** ppv ) {return NdrDllGetClassObject(rclsid,riid,ppv,pPFlist,pClsid,pFactory );}
#define	DLLCANUNLOADNOW(pFactory)  HRESULT STDAPICALLTYPE DllCanUnloadNow() { return NdrDllCanUnloadNow( pFactory );}

#define	DLLDUMMYPURECALL  void  _purecall(void) {  }
#define	CSTDSTUBBUFFERRELEASE(pFactory)  ULONG STDMETHODCALLTYPE CStdStubBuffer_Release(IRpcStubBuffer *This) {return NdrCStdStubBuffer_Release(This,(IPSFactoryBuffer *)pFactory); } 

#ifdef	PROXY_DELEGATION
#define	CSTDSTUBBUFFER2RELEASE(pFactory)  ULONG STDMETHODCALLTYPE CStdStubBuffer2_Release(IRpcStubBuffer *This) {return NdrCStdStubBuffer2_Release(This,(IPSFactoryBuffer *)pFactory);}
#else
#define	CSTDSTUBBUFFER2RELEASE(pFactory) 
#endif	
#ifdef	REGISTER_PROXY_DLL
#define	DLLREGISTRY_ROUTINES(pProxyFileList,pClsID ) REGISTER_PROXY_DLL_ROUTINES(pProxyFileList,pClsID )
#else
#define	DLLREGISTRY_ROUTINES(pProxyFileList,pClsID ) 
#endif	
#define	DLLDATA_ROUTINES(pProxyFileList,pClsID ) CLSID_PSFACTORYBUFFER CStdPSFactoryBuffer gPFactory = {0,0,0,0}; DLLDATA_GETPROXYDLLINFO(pProxyFileList,pClsID) \
	DLLGETCLASSOBJECTROUTINE(pProxyFileList,pClsID,&gPFactory)  DLLCANUNLOADNOW(&gPFactory) \
	CSTDSTUBBUFFERRELEASE(&gPFactory) CSTDSTUBBUFFER2RELEASE(&gPFactory) DLLDUMMYPURECALL \
	DLLREGISTRY_ROUTINES(pProxyFileList, pClsID) \

#define	DLLDATA_STANDARD_ROUTINES  DLLDATA_ROUTINES((const ProxyFileInfo**) pProxyFileList, &CLSID_PSFactoryBuffer) 
#endif	