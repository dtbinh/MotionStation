/*
 * @(#)hist_binsearch_u32_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:25 2004
 *
 *		built from:	hist_binsearch_u32_rt.c
 */

#ifndef hist_binsearch_u32_rt_h
#define hist_binsearch_u32_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_Hist_BinSearch_U32(int_T     firstBin, 
                                         int_T     lastBin, 
                                         uint32_T  data, 
                                         const uint32_T  *bin,
                                         uint32_T  *hist );

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* hist_binsearch_u32_rt_h */