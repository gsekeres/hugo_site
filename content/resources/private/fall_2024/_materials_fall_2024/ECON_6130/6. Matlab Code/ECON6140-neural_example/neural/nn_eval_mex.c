

#include <math.h>
#include "mex.h"
//#include <lapack.h>
//#include <blas.h>
#include <stdlib.h>
#include <string.h>


/* Input Arguments */
#define	xx_in	    prhs[0]
#define	bias1_in	prhs[1]
#define	wght1_in	prhs[2]
#define	bias2_in	prhs[3]
#define	wght2_in	prhs[4]
#define	stdx_in	    prhs[5]
#define stdy_in     prhs[6]
#define	work1_in	prhs[7]
#define	work2_in	prhs[8]

/* Output Arguments */
#define out0    plhs[0]

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

void insert_sortd(ptrdiff_t m, mwIndex *VV, double *II){
    int i,j;
    mwIndex x;
    double xi;
    for(i=1;i<m;i++){
        x = VV[i];
        xi = II[i];
        
        j = i;
        
        while(j>0&&VV[j-1]>x){
            VV[j] = VV[j-1];
            II[j] = II[j-1];
            j--;
        }
        VV[j] = x;
        II[j] = xi;
    }
    return;
} 

/* Prints an MxN matrix to Screen*/
void insert_sort(ptrdiff_t m, double *VV, mwIndex *II){
    int i,j;
    double x;
    mwIndex xi;
    for(i=1;i<m;i++){
        x = VV[i];
        xi = II[i];
        
        j = i;
        
        while(j>0&&VV[j-1]>x){
            VV[j] = VV[j-1];
            II[j] = II[j-1];
            j--;
        }
        VV[j] = x;
        II[j] = xi;
    }
    return;
}

/* Prints an MxN matrix to Screen*/
void printmat_colmaj(ptrdiff_t m, ptrdiff_t n, double M[m*n]){
    ptrdiff_t x,y;
    printf("\n");
    for(x=0;x<m;x++){
        for(y=0;y<n;y++){
            printf("%1.8lf\t", M[y*m+x]);
        }
        printf("%\n");
    }
    return;
}



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )

{
    
    double *xx,*bias1,*wght1,*bias2,*wght2,*stdx,*stdy,*work1,*work2;

    double tmp;
    
    long ns, nh, nx, ii,ss,hh,nn,idx1,idx2,idx3,idx4,idx5,idx6;
    mwIndex II[6] = {0,1,2,3,4,5};
    mwIndex S[6]  = {0,0,0,0,0,0};
    ptrdiff_t one = 1;
    
    /*Check for proper number of arguments*/
    if (nrhs == 9)  { 
    }
    else{
        mexErrMsgTxt("9 inputs arguments required.");
    }
    
    /* Get Dimensions of Input Arguments*/
    
    nx  = mxGetM(xx_in);
    ns  = mxGetN(xx_in);
    nh  = mxGetM(work2_in);

    ptrdiff_t oneptr = 1;
    ptrdiff_t nhptr = nh;
    ptrdiff_t nxptr = nx;
    ptrdiff_t sixptr = 6;
    ptrdiff_t sevenptr  = 7;
    
    /*Create output argument*/
    mwSize mw_one = (mwSize)1;
    mwSize mw_ns  = (mwSize)ns;
    mwSize mw_nx  = (mwSize)nx;
    mwSize mw_nh  = (mwSize)nh;

    double  *Qval;
    mwIndex *Qidx;      
    mwIndex *jcs;
        
    out0  = mxCreateDoubleMatrix(mw_one,mw_ns,mxREAL); 
    Qval  = mxGetPr(out0); 
    Qidx  = mxGetIr(out0); 
    jcs   = mxGetJc(out0);
    
    /* Assign pointers to the input arguments*/
    xx    = mxGetPr(xx_in);
    work1 = mxGetPr(work1_in);
    work2 = mxGetPr(work2_in);
    bias1 = mxGetPr(bias1_in);
    wght1 = mxGetPr(wght1_in);
    bias2 = mxGetPr(bias2_in);
    wght2 = mxGetPr(wght2_in);
    stdx  = mxGetPr(stdx_in);
    stdy  = mxGetPr(stdy_in);


    //printmat_colmaj(oneptr,sixptr,stdx);
    for (ss=0;ss<ns;ss++){
        /*Standardize input variables*/
        for (ii=0;ii<nx;ii++){
            work1[ss*nx+ii] = (xx[ss*nx+ii]-stdx[ii])/stdx[nx+ii];

        }

         /*Compute first layer*/
         for (ii=0;ii<nh;ii++){
             work2[ss*nh+ii] = bias1[ii];

             /*matrix multiply, use built in?*/
             for (nn=0;nn<nx;nn++){
                    work2[ss*nh+ii] = work2[ss*nh+ii] + wght1[ii*nx+nn]*work1[ss*nx+nn];
             }
             /*activation function*/
             work2[ss*nh+ii] = log(1+exp(work2[ss*nh+ii]));
             //work2[ss*nh+ii] = 1/(1+exp(work2[ss*nh+ii]));
         }

        /*Compute second layer*/
        Qval[ss] = bias2[0];
        for (ii=0;ii<nh;ii++){
             Qval[ss] = Qval[ss]+wght2[ii]*work2[ss*nh+ii];
         }
        Qval[ss] = Qval[ss]*stdy[1]+stdy[0];

    }

  /*
    double x1ex[nx1];
    double x2ex[nx2];
    double x3ex[nx3];
    double x4ex[nx4];
    double x5ex[nx5];
    double x6ex[nx6];
    double xxtmp[6];
   */ 
    /*Create versions of x and y that have infinity in the end
     memcpy(x1ex, x1, nx1*sizeof(double));
     memcpy(x2ex, x2, nx2*sizeof(double));
     memcpy(x3ex, x3, nx3*sizeof(double));
     memcpy(x4ex, x4, nx4*sizeof(double));
     memcpy(x5ex, x5, nx5*sizeof(double));
     memcpy(x6ex, x6, nx6*sizeof(double));
     
    x1ex[0] = -DBL_MAX;
    x1ex[nx1-1] = DBL_MAX;
    
    x2ex[0] = -DBL_MAX;
    x2ex[nx2-1] = DBL_MAX;
    
    x3ex[0] = -DBL_MAX;
    x3ex[nx3-1] = DBL_MAX;
      
    x4ex[0] = -DBL_MAX;
    x4ex[nx4-1] = DBL_MAX;
    
    x5ex[0] = -DBL_MAX;
    x5ex[nx5-1] = DBL_MAX;
    
    x6ex[0] = -DBL_MAX;
    x6ex[nx6-1] = DBL_MAX;*/
    
    //for (ii=0;ii<ns;ii++){

        /*
        idx1 = 0;
        idx2 = 0;
        idx3 = 0;
        idx4 = 0;
        idx5 = 0;
        idx6 = 0;
        
        
        /*Copy over the current column of x*/
       /* memcpy(xxtmp, &xx[6*ii], 6*sizeof(double));
        
        while (x1ex[idx1]<=xxtmp[0]){
            idx1++;
        }
        while (x2ex[idx2]<=xxtmp[1]){
            idx2++;
        }
        while (x3ex[idx3]<=xxtmp[2]){
            idx3++;
        }
        while (x4ex[idx4]<=xxtmp[3]){
            idx4++;
        }
        while (x5ex[idx5]<=xxtmp[4]){
            idx5++;
        }
        while (x6ex[idx6]<=xxtmp[5]){
            idx6++;
        }
        
        /*xcord(jj) = (xx(jj)-x(idx1(jj)))/(x(idx1(jj)+1) - x(idx1(jj)));
        xcord[0] = (xxtmp[0] - x1[idx1-1])/(x1[idx1] - x1[idx1-1]);
        xcord[1] = (xxtmp[1] - x2[idx2-1])/(x2[idx2] - x2[idx2-1]);
        xcord[2] = (xxtmp[2] - x3[idx3-1])/(x3[idx3] - x3[idx3-1]);
        xcord[3] = (xxtmp[3] - x4[idx4-1])/(x4[idx4] - x4[idx4-1]);
        xcord[4] = (xxtmp[4] - x5[idx5-1])/(x5[idx5] - x5[idx5-1]);
        xcord[5] = (xxtmp[5] - x6[idx6-1])/(x6[idx6] - x6[idx6-1]);
        
        
        
        /*Sort the x cords
        S[0] = 0;
        S[1] = 0;
        S[2] = 0;
        S[3] = 0;
        S[4] = 0;
        S[5] = 0;
        
        II[0] = 0;
        II[1] = 1;
        II[2] = 2;
        II[3] = 3;
        II[4] = 4;
        II[5] = 5;
        
        insert_sort(sixptr,xcord,II);
        
        
        /*Compute the coordinate vectors
        Qidx[7*ii] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii] = xcord[0];
        S[II[0]] = -1;
               
        Qidx[7*ii+1] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+1] = xcord[1]-xcord[0];
        S[II[1]] = -1;

        Qidx[7*ii+2] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+2] = xcord[2]-xcord[1];
        S[II[2]] = -1;
        
        Qidx[7*ii+3] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+3] = xcord[3]-xcord[2];
        S[II[3]] = -1;
        
        Qidx[7*ii+4] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+4] = xcord[4]-xcord[3];
        S[II[4]] = -1;
        
        Qidx[7*ii+5] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+5] = xcord[5]-xcord[4];
        S[II[5]] = -1;
        
        Qidx[7*ii+6] = (idx1 + S[0]) + nx1*(idx2+S[1]) + nx1*nx2*(idx3+S[2]) + nx1*nx2*nx3*(idx4+S[3]) + nx1*nx2*nx3*nx4*(idx5+S[4]) + nx1*nx2*nx3*nx4*nx5*(idx6+S[5]);
        Qval[7*ii+6] = 1-xcord[5];  
        
        /*Sort the coordinate vectors
        insert_sortd(sevenptr,&Qidx[7*ii],&Qval[7*ii]);

        /*row indexes
        jcs[ii+1] = 7*(ii+1);
        */
   // }
   return;
}
