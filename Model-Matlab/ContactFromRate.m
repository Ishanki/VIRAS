function r = ContactFromRate(V0,I,NoObj,NoInd,Aobj,Ah,Am,Acon,Amh,Rhs,Rsh,Rhm,Rmh,fobj,fmh)
    % Vector of inverses of all surface areas: surfaces, hands, mucous membranes
    A = [Aobj;Ah;Am];

    % Form transfer matrices:
    % M_hs is p.NoInd x p.NoObj
    M_hs = Rhs'.*fobj'.*Acon';
    %         M_hs = repmat(p.Rhs'.*p.fobj'.*p.Acon', p.NoInd, 1);
    % M_sh is p.NoObj x p.NoInd
    M_sh = Rsh.*fobj.*Acon;
    %         M_sh = repmat(p.Rsh.*p.fobj.*p.Acon, 1, p.NoInd);
    % M_hm is p.NoInd x p.NoInd
    M_hm = repmat(Rhm'.*fmh'.*Amh',NoInd,1).*eye(NoInd);
    % M_mh is p.NoInd x p.NoInd
    M_mh = repmat(Rmh'.*fmh'.*Amh',NoInd,1).*eye(NoInd);

    M = [zeros(NoObj),          M_sh,           zeros(NoObj, NoInd);...
     M_hs,                  zeros(NoInd), M_hm;...
     zeros(NoInd,NoObj),  M_mh,           zeros(NoInd)];

    r = (M*I).*(V0./A);
end