// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1381, EBLK  * I1376, U  I616);
void  hsG_0__0 (struct dummyq_struct * I1381, EBLK  * I1376, U  I616)
{
    U  I1644;
    U  I1645;
    U  I1646;
    struct futq * I1647;
    struct dummyq_struct * pQ = I1381;
    I1644 = ((U )vcs_clocks) + I616;
    I1646 = I1644 & ((1 << fHashTableSize) - 1);
    I1376->I662 = (EBLK  *)(-1);
    I1376->I663 = I1644;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1376);
    }
    if (I1644 < (U )vcs_clocks) {
        I1645 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1376, I1645 + 1, I1644);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I616 == 1)) {
        I1376->I665 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I662 = I1376;
        peblkFutQ1Tail = I1376;
    }
    else if ((I1647 = pQ->I1284[I1646].I685)) {
        I1376->I665 = (struct eblk *)I1647->I683;
        I1647->I683->I662 = (RP )I1376;
        I1647->I683 = (RmaEblk  *)I1376;
    }
    else {
        sched_hsopt(pQ, I1376, I1644);
    }
}
void  hs_0_M_7_21__simv_daidir (UB  * pcode, scalar  val)
{
    if (*(pcode + 2) == val) {
        if (fRTFrcRelCbk) {
            U  I1463 = 0;
            if (fScalarIsForced) {
                I1463 = 29;
            }
            else if (fScalarIsReleased) {
                I1463 = 30;
            }
            if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
                RP  I1510 = (RP )(pcode + 136);
                void * I1511 = hsimGetCbkMemOptCallback(I1510);
                if (I1511) {
                    SDaicbForHsimCbkMemOptNoFlagFrcRel(I1511, I1463, -1, -1, -1);
                }
                fScalarIsForced = 0;
                fScalarIsReleased = 0;
            }
        }
        return  ;
    }
    *(pcode + 2) = val;
    if (fRTFrcRelCbk) {
        U  I1463 = 0;
        if (fScalarIsForced) {
            I1463 = 29;
        }
        else if (fScalarIsReleased) {
            I1463 = 30;
        }
        if ((fScalarIsForced || fScalarIsReleased) && fRTFrcRelCbk && *(RP  *)((pcode + 136))) {
            RP  I1510 = (RP )(pcode + 136);
            void * I1511 = hsimGetCbkMemOptCallback(I1510);
            if (I1511) {
                SDaicbForHsimCbkMemOptNoFlagFrcRel(I1511, I1463, -1, -1, -1);
            }
            fScalarIsForced = 0;
            fScalarIsReleased = 0;
        }
    }
    *(pcode + 3) = X4val[val];
    RmaRtlXEdgesHdr  * I993 = (RmaRtlXEdgesHdr  *)(pcode + 8);
    RmaRtlEdgeBlock  * I721;
    U  I58 = I993->I58;
    scalar  I753 = (((I58) >> (16)) & ((1 << (8)) - 1));
    US  I1525 = (1 << (((I753) << 2) + (X4val[val])));
    if (I1525 & 31692) {
        rmaSchedRtlXEdges(I993, I1525, X4val[val]);
    }
    (I58) = (((I58) & ~(((U )((1 << (8)) - 1)) << (16))) | ((X4val[val]) << (16)));
    I993->I58 = I58;
    {
        unsigned long long * I1771 = derivedClk + (4U * X4val[val]);
        memcpy(pcode + 104 + 4, I1771, 25U);
    }
    {
        {
            RP  I1570;
            RP  * I653 = (RP  *)(pcode + 136);
            {
                I1570 = *I653;
                if (I1570) {
                    hsimDispatchCbkMemOptNoDynElabS(I653, val, 1U);
                }
            }
        }
    }
    {
        scalar  I1603;
        scalar  I1513;
        U  I1558;
        U  I1610;
        U  I1611;
        EBLK  * I1376;
        struct dummyq_struct * pQ;
        U  I1379;
        I1379 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        I1513 = X4val[val];
        I1603 = *(pcode + 144);
        *(pcode + 144) = I1513;
        I1558 = (I1603 << 2) + I1513;
        I1558 = 1 << I1558;
        if (I1558 & 2) {
            if (getCurSchedRegion()) {
                SchedSemiLerTBReactiveRegion_th((struct eblk *)(pcode + 152), I1379);
            }
            else {
                sched0_th(pQ, (EBLK  *)(pcode + 152));
            }
        }
        if (I1558 & 16) {
            if (getCurSchedRegion()) {
                SchedSemiLerTBReactiveRegion_th((struct eblk *)(pcode + 192), I1379);
            }
            else {
                sched0_th(pQ, (EBLK  *)(pcode + 192));
            }
        }
    }
    {
        scalar  I1773 = X4val[val];
        scalar  I1774 = *(scalar  *)(pcode + 232 + 2U);
        *(scalar  *)(pcode + 232 + 2U) = I1773;
        UB  * I993 = *(UB  **)(pcode + 232 + 8U);
        if (I993) {
            U  I1775 = I1773 * 2;
            U  I1776 = 1 << ((I1774 << 2) + I1773);
            *(pcode + 232 + 0U) = 1;
            while (I993){
                UB  * I1778 = *(UB  **)(I993 + 16U);
                if ((*(US  *)(I993 + 0U)) & I1776) {
                    *(*(UB  **)(I993 + 48U)) = 1;
                    (*(FP  *)(I993 + 32U))((void *)(*(RP  *)(I993 + 40U)), (((*(scalar  *)(I993 + 2U)) >> I1775) & 3));
                }
                I993 = I1778;
            };
            *(pcode + 232 + 0U) = 0;
            rmaRemoveNonEdgeLoads(pcode + 232);
        }
    }
    if (*(RP  *)(pcode + 272 + 0U)) {
        rmaChildClockPropAfterWrite(pcode + 272);
    }
    {
        typedef
        UB
         stateType;
        scalar  newval;
        stateType  state;
        U  iinput;
        UB  * pcode1;
        UB  * I1382;
        UB  * I1485;
        GateCount  I644;
        I644 = *(U  *)(pcode + 288);
        pcode += 296;
        for (; I644 > 0; I644--) {
            {
                typedef
                UB
                 stateType;
                typedef
                UB
                 * stateTypePtr;
                pcode1 = *(UB  **)(pcode + 0);
                iinput = (U )(((RP )pcode1) & 7);
                pcode1 = (UB  *)(((RP )pcode1) & ~7);
                {
                    RP  I1480 = 1;
                    if (I1480) {
                        state = *(stateTypePtr )(pcode1 + 12U);
                        state &= ~(3 << (iinput * 2));
                        state |= X4val[val] << (iinput * 2);
                        *(stateTypePtr )(pcode1 + 12U) = state;
                        newval = (*(U  *)(pcode1 + 8U) >> (state << 1)) & 3;
                        if (newval != *(pcode1 + 13U)) {
                            *(pcode1 + 13U) = newval;
                            (*(FP  *)(pcode1 + 0U))(pcode1, newval);
                        }
                    }
                }
            }
            pcode += 8;
        }
    }
}
void  hs_0_M_7_0__simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1713;
    *(pcode + 0) = val;
    if (*(pcode + 1)) {
        return  ;
    }
    hs_0_M_7_21__simv_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_7_1__simv_daidir (UB  * pcode, scalar  val, U  I608, scalar  * I1396, U  did)
{
    U  I1375 = 0;
    *(pcode + 1) = 1;
    fScalarIsForced = 1;
    hs_0_M_7_21__simv_daidir(pcode, val);
    fScalarIsForced = 0;
}
void  hs_0_M_7_2__simv_daidir (UB  * pcode)
{
    scalar  val;
    fScalarIsReleased = 1;
    val = *(pcode + 0);
    *(pcode + 1) = 0;
    hs_0_M_7_21__simv_daidir(pcode, val);
    fScalarIsReleased = 0;
}
void  hs_0_M_7_11__simv_daidir (UB  * pcode, scalar  val)
{
    *(pcode + 0) = val;
    if (*(pcode + 1)) {
        return  ;
    }
    hs_0_M_7_21__simv_daidir(pcode, val);
    fScalarIsReleased = 0;
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
