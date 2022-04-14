import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def modeloutputs(Time,V,NoObj,NoInd):
    OUTmucosaload  = V[-1,NoObj+NoInd:NoObj+2*NoInd+1]
    OUTrisk  = V[-1,NoObj+2*NoInd+1+3*NoInd:-1]
    OUT  = [[OUTmucosaload],[OUTrisk]]
    return OUT

def saveout(tode,yode,risk,Obj,NoObj,NoInd):
    collabels = ['Time']
    Obj = Obj.flatten()
    objnames = Obj.tolist()
    for i in range(0,NoObj):
        collabels.append(objnames[i])
    for i in range(0,NoInd):
        collabels.append('Hands'+str(i+1))
    for i in range(0,NoInd):
        collabels.append('Mucosa'+str(i+1))
    collabels.append('Air')
    for i in range(0,NoInd):
        collabels.append('CumFom'+str(i+1))
    for i in range(0,NoInd):
        collabels.append('CumClosCon'+str(i+1))
    for i in range(0,NoInd):
        collabels.append('CumAeros'+str(i+1))
    for i in range(0,NoInd):
        collabels.append('CumTotal'+str(i+1))
    for i in range(0,NoInd):
        collabels.append('Risk'+str(i+1))
        
    df_Y = pd.DataFrame(data=np.concatenate([tode.reshape(-1,1),yode,risk],axis=1), columns=collabels)    
    df_Y.to_csv('Outputs.csv') 

def plotgen(tode,yode):
    plt.plot(tode,yode)

def modelinputs():
    
    People = pd.read_excel('Inputs.xlsx',sheet_name='People')
    Materials = pd.read_excel('Inputs.xlsx',sheet_name='Materials')
    Objects = pd.read_excel('Inputs.xlsx',sheet_name='Objects')
    Air = pd.read_excel('Inputs.xlsx',sheet_name='Air',header=None)
    Sims = pd.read_excel('Inputs.xlsx',sheet_name='Sims',header=None)
    CloseTime = pd.read_excel('Inputs.xlsx',sheet_name='CloseTime',header=None,skiprows=1)
    CloseTransfer = pd.read_excel('Inputs.xlsx',sheet_name='CloseTransfer',header=None,skiprows=1)
    Contacts = pd.read_excel('Inputs.xlsx',sheet_name='Contacts',header=None,skiprows=1)
        
    # People
    NoInd = np.shape(People)
    NoInd = NoInd[0]
    IDInd = People["ID"]
    tin   = People["TimeIn"]
    tdur  = People["Duration"]
    LRVh  = People["LRVhands"]
    LRVm  = People["LRVmucosa"]
    Rhm   = People["HandMucosaRate"]
    Rmh   = People["MucosaHandRate"]
    tauh  = People["HalfLifeHands"]
    taum  = People["HalfLifeMucosa"]
    Amh   = People["MucosaContactArea"]
    fmh   = People["MucosaContactFrequency"]
    Ah    = People["HandArea"]
    Am    = People["MucosaArea"]
    k     = People["DoseReponse"]
    Rshed = People["SheddingRate"]
    Rinh  = People["InhalingRate"]*1e6
    Ldropl= People["LargeDropletsRatio"]
    Rdeph = People["DepositionHands"]
    Rdepm = People["DepositionMucosa"]
    V0m   = People["MucContamination"]
    Inf   = People["Infected"]
    Ceffh = People["CleanEff"]
    NoCleans = np.shape(People)
    NoCleans = NoCleans[1]-21
    Cleans = []
    for i in range(1,NoCleans):
        Cleans.append("Tc"+str(i))
    Tch = People[Cleans]  
        
    # Materials
    NoMat = np.shape(Materials)
    NoMat = NoMat[0]
    mat   = Materials["Description"]
    tau   = Materials["HalfLife"]
    
    # Objects
    NoObj = np.shape(Objects)
    NoObj = NoObj[0]
    Obj   = Objects["Description"]
    Aobj  = Objects["Area"]
    Acon  = Objects["ContactArea"]
    M = pd.DataFrame()
    for i in Objects["Material"]:
        M = M.append(Materials.loc[Materials['Description']==i])
    LRV = M["LRV"]
    taus = M["HalfLife"]
    Rhs = M["ToSurfaceRate"]
    Rsh = M["ToHandRate"]
    V0_obj = Objects["Contamination"]
    Rdep = Objects["DepositionRate"]
    Ceff = Objects["CleaningEff"]
    NoCleans = np.shape(Objects)
    NoCleans = NoCleans[1]-7
    Cleans = []
    for i in range(1,NoCleans):
        Cleans.append("Tclean"+str(i))
    Tc = Objects[Cleans]

    # Air
    Vair = Air.iloc[0,1]*1e6
    V0_air = Air.iloc[1,1]
    taua = Air.iloc[2,1]
    Rref = Air.iloc[3,1]*1e6
    
    # Contacts
    fobj  = Contacts
    
    # Close time
    CloseTime  = CloseTime
    
    # Close transfer rate
    CloseTransfer  = CloseTransfer
    
    # Simulations
    tini = Sims.iloc[0,1]
    tsim = Sims.iloc[1,1]
    epsilon = Sims.iloc[2,1]
    FigPop = Sims.iloc[3,1]
    FomitPath = Sims.iloc[4,1]
    AerosPath = Sims.iloc[5,1]
    ClosePath = Sims.iloc[6,1]
    InactPath = Sims.iloc[7,1]
    
    NoInd = NoInd
    IDInd = np.array(IDInd,ndmin=2)
    tin = np.array(tin,ndmin=2)
    tdur = np.array(tdur,ndmin=2)
    LRVh = np.array(LRVh,ndmin=2)
    LRVm = np.array(LRVm,ndmin=2)
    Rhm = np.array(Rhm,ndmin=2)
    Rmh = np.array(Rmh,ndmin=2)
    tauh = np.array(tauh,ndmin=2)
    taum = np.array(taum,ndmin=2)
    Amh = np.array(Amh,ndmin=2)
    fmh = np.array(fmh,ndmin=2)
    Ah = np.array(Ah,ndmin=2)
    Am = np.array(Am,ndmin=2)
    k = np.array(k,ndmin=2)
    Rshed = np.array(Rshed,ndmin=2)
    Rinh = np.array(Rinh,ndmin=2)
    Ldropl = np.array(Ldropl,ndmin=2)
    Rdeph = np.array(Rdeph,ndmin=2)
    Rdepm = np.array(Rdepm,ndmin=2)
    V0m = np.array(V0m,ndmin=2)
    Inf = np.array(Inf,ndmin=2)
    Ceffh = np.array(Ceffh,ndmin=2)
    Tch = np.array(Tch,ndmin=2)
    NoMat = NoMat
    mat = np.array(mat,ndmin=2)
    tau = np.array(tau,ndmin=2)
    NoObj = NoObj
    Obj = np.array(Obj,ndmin=2)
    Aobj = np.array(Aobj,ndmin=2)
    Acon = np.array(Acon,ndmin=2)
    LRV = np.array(LRV,ndmin=2)
    taus = np.array(taus,ndmin=2)
    Rhs = np.array(Rhs,ndmin=2)
    Rsh = np.array(Rsh,ndmin=2)
    V0_obj = np.array(V0_obj,ndmin=2)
    Rdep = np.array(Rdep,ndmin=2)
    Ceff = np.array(Ceff,ndmin=2)
    Tc = np.array(Tc,ndmin=2)
    Vair = np.array(Vair,ndmin=2)
    V0_air = np.array(V0_air,ndmin=2)
    taua = np.array(taua,ndmin=2)
    Rref = np.array(Rref,ndmin=2)
    fobj = np.array(fobj,ndmin=2)
    CloseTime = np.array(CloseTime,ndmin=2)
    CloseTransfer = np.array(CloseTransfer,ndmin=2)
    tini = np.array(tini,ndmin=2)
    tsim = np.array(tsim,ndmin=2)
    epsilon = np.array(epsilon,ndmin=2)
    FigPop = np.array(FigPop,ndmin=2)
    FomitPath = np.array(FomitPath,ndmin=2)
    AerosPath = np.array(AerosPath,ndmin=2)
    ClosePath = np.array(ClosePath,ndmin=2)
    InactPath = np.array(InactPath,ndmin=2)

    
    return NoInd,IDInd,tin,tdur,LRVh,LRVm,Rhm,Rmh,tauh,taum,Amh,fmh,Ah,Am,k,Rshed,Rinh,Ldropl,Rdeph,Rdepm,V0m,Inf,Ceffh,Tch,NoMat,mat,tau,NoObj,Obj,Aobj,Acon,LRV,taus,Rhs,Rsh,V0_obj,Rdep,Ceff,Tc,Vair,V0_air,taua,Rref,fobj,CloseTime,CloseTransfer,tini,tsim,epsilon,FigPop,FomitPath,AerosPath,ClosePath,InactPath