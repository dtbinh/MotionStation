/*
 * @(#)qreslv_r_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:32 2004
 *
 *		built from:	qreslv_r_rt.c
 */

#ifndef qreslv_r_rt_h
#define qreslv_r_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_qreslvR(
                int_T	 m,
                int_T	 n,
			    int_T	 p,
                real32_T	*qr,
                real32_T	*bx,
                real32_T	*qraux,
                int_T	*jpvt,
                real32_T	*x,
                real32_T epsval);

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* qreslv_r_rt_h */