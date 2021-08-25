import numpy as np
import math as mth
from scipy.integrate import odeint
import IOs
import model
import Rates as R
from time import perf_counter
import pandas as pd

start = perf_counter()

NoInd,IDInd,tin,tdur,LRVh,LRVm,Rhm,Rmh,tauh,taum,Amh,fmh,Ah,Am,k,Rshed,Rinh,Ldropl,Rdeph,Rdepm,V0m,Inf,Ceffh,Tch,NoMat,mat,tau,NoObj,Obj,Aobj,Acon,LRV,taus,Rhs,Rsh,V0_obj,Rdep,Ceff,Tc,Vair,V0_air,taua,Rref,fobj,CloseTime,CloseTransfer,tini,tsim,epsilon,FigPop,FomitPath,AerosPath,ClosePath,InactPath = IOs.modelinputs()

Ind = lambda t: model.Presence(t, NoObj, tin, tdur, epsilon) 
psi = np.concatenate([np.zeros([NoObj+NoInd,1]),Inf.T])
Rcontto = lambda V,Ind: FomitPath*R.ContactToRate(V,Ind,NoObj,NoInd,Aobj,Ah,Am,Acon,Amh,Rhs,Rsh,Rhm,Rmh,fobj,fmh) 
Rcontfrom = lambda V,Ind: FomitPath*R.ContactFromRate(V,Ind,NoObj,NoInd,Aobj,Ah,Am,Acon,Amh,Rhs,Rsh,Rhm,Rmh,fobj,fmh)
Raerosol = AerosPath*R.AerosolGenRate(NoObj,NoInd,Rshed,Ldropl)
Rinhal = lambda V: AerosPath*R.InhalationRate(V,NoObj,NoInd,Rinh,Vair)
Rsmall = lambda V: AerosPath*R.SmallDropletsRate(V,np.concatenate([Rdep,Rdeph,Rdepm],axis=1),np.concatenate([Aobj,Ah,Am],axis=1),Vair)
Rlarge = lambda V: ClosePath*R.LargeDropletsRate(V,NoObj,NoInd,CloseTransfer,CloseTime,Ldropl)
Rairref = lambda V: R.AirRefreshRate(V,Rref,Vair)
Rinact = InactPath*mth.log(2)*1/np.expand_dims(np.concatenate([taus,tauh,taum,taua],axis=1),2)
Rclean = lambda t,V: R.CleanRate(t,V,NoObj,NoInd,tsim,Tc,Tch,LRV,LRVh,Ceff,Ceffh,epsilon)

y0 = model.initcond(V0_obj,V0_air,V0m,Inf,NoInd,NoObj,Rhs,Rsh,Rhm,Rmh,fmh,Acon,fobj,Aobj,Amh,Ah,Am,CloseTime,CloseTransfer,tauh,FomitPath,ClosePath,AerosPath,InactPath,Ldropl,Rshed)

tode = np.linspace(tini[0,0],tsim[0,0],100000)

def DynModel(V,t):
    VL = model.model(V,t,NoInd,psi,Ind,Rcontto,Rcontfrom,Rinact,Rclean,Raerosol,Rsmall,Rlarge,Rairref,Rinhal)
    return VL

#xin = DynModel(2,y0)

yode = odeint(DynModel, y0, tode)

RoI = model.risk(yode[:,NoObj+NoInd:NoObj+2*NoInd],k)

IOs.saveout(tode,yode,RoI,Obj,NoObj,NoInd)

# IOs.plotgen(tode,yode[:,0])

stop = perf_counter()
ex_time = stop - start 
print("****Total time*****: ", ex_time )

# optional output to Excel
# dfr = pd.DataFrame(yode[-1])
# filepath = 'yode_results.xlsx'
# dfr.to_excel(filepath, index=False)