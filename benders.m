function [X,YZ,Longueur]=benders(X0,YZ0,P,N,D,A,b,Aeq,beq)

X = X0; 
A_z = [zeros(size(A,1),1),A];
b_z = b;
A_eqz = [zeros(size(Aeq,1),1),Aeq];
b_eqz = beq;
YZ = YZ0; 

%initialisation
k = 1; 
LB = -Inf; 
UB = +Inf; 
K = []; 
k = 0; 
stop = false; 
COL = N*(N-2) + (N-2)*(N-2); 
while(stop==false && k < 1000)
    
    %Sous-probl�me : on cherche x 
    fobjX=@(X)objectiveyz(YZ,X,P,N,D)
    X = patternsearch(fobjX,X,[],[]); 

    %On met � jour UB
    UB = min(UB,fobjX(X)); 
    ligne = zeros(1,1+COL);
    ligne(1) = -1; 
    
    cnt = 2; 
    for p = 1:N-2 %pour les y
        for q = 1:(N-2)
            ligne(cnt) = norm(X(q:q+D)- P(p:p+D)); 
            cnt = cnt + 1; 
        end 
    end 
   
    for p = 1:(N-2) %pour les z
        for q = 1:N-2
            if p<q
                ligne(cnt) = norm(X(q:q+D)- X(p:p+D)); 
            end
            cnt = cnt + 1; 
        end 
    end 
    A_z = [A_z; ligne]
    b_z = [b_z; 0];
    
    %Sous-probl�me : on cherche z
    fobjZ = zeros(COL+1,1);
    fobjZ(1) = 1; 
    intcon = 2:COL+1; %elles sont toutes enti�res sauf la premi�re
    lb = zeros(COL+1,1);
    ub = zeros(COL+1,1);
    ub(:) = +Inf;
 
    for p=1:N-2
        for q=1:N-2
            if(p<q)
                ub(N*(N-2)+p+q) = 1; 
            end 
        end 
    end

    XZ = intlinprog(fobjZ,intcon,A_z,b_z,A_eqz,b_eqz, lb, ub); %on a Z puis YZ
    LB = XZ(1); 

    k = k + 1;

    if(LB >=UB) 
        stop = true;       
    else 
        YZ = XZ(2:end); 
    end
        
end

%Pour le plot
Longueur = XZ(1); 

end 