function krontest(TOL)
%Performs numerous tests of KronProd math operations, comparing the results
%to those from equivalent numerical forms of the kronecker products.
%
%  krontest(TOL)
%
%TOL is a tolerance value on the percent error (default=inf). Execution will pause 
%in debug mode for inspection if any one of the tests exhibits an error greater than TOL

if nargin<1
 TOL=inf; %default tolerance value on discrepancies
end

%%some useful functions
 ncols=@(M) size(M,2);     
 err=@(x,y) DiscrepancyMeasure(x,y,TOL);

%%Some operands
Az=rand(4,3); Ay=rand(3,2); Ax=eye(4)*pi; as=4;
Bz=rand(4,3); By=rand(3,2); Bx=rand(4);   bs=5;
Sz=rand(4,4); Sy=i*eye(3) ; Sx=Sz;        ss=6;

   Az(1,1)=0; %add in some zeros

   
%%Some Kronecker products of the above operands - conventionally computed
Afull=kron(Az,kron(Ay,Ax))*as;  
Bfull=kron(Bz,kron(By,Bx))*bs;
Sfull=kron(Sz,kron(Sy,Sx))*ss;


%%Their sparse forms 
Asparse=sparse(Afull); 
Bsparse=sparse(Bfull); 
Ssparse=sparse(Sfull);


%%Representations of the above as KronProd objects 
A=KronProd({pi,Ay,Az,1},[1,2,3], [ncols(Ax),nan,nan],as);     % =Afull
B=KronProd({Bx,By,Bz,1},[1,2,3], [],bs);                      % =Bfull
S=KronProd({i,Sz,1}, [2 1 2], [nan, ncols(Sy), nan],ss);      % =Sfull
Sa=KronProd({Sx,Sy,Sz,1}, [1,2,3], [],ss);  %=Sfull, alternative construction
                                                 
                                                       


%%%%%%%%%%%%%%%%%%%%%%%%%%%TESTS%%%%%%%%%%%%%%%%%%%%%%%%%%


%%Test of full()
Error(1)=     err( full(A), Afull  );  
Error(end+1)= err( full(B), Bfull  );  
Error(end+1)= err( full(S), Sfull  );  

%%Test of sparse()
Error(end+1)= err( sparse(A), Asparse );
Error(end+1)= err( issparse(sparse(A)), 1 );


   %%No sense in proceding if the tests so far didn't pass - the error
   %%calculations rely on the functionality of full@KronProd(A)
    if max(Error)>TOL,
        Error,
        error 'Something wrong with sparse() and full() methods'; 
    end

 
 
%%Test of transpose, ctranspose
Error(end+1)= err( A.' ,  Afull.'   );
Error(end+1)= err( A'  ,  Afull'   );


%%Test of size()
Error(end+1)= err( size(A) ,  size(Afull) );


%%Test of inv, pinv

Error(end+1)= err( inv(S)  , inv(Sfull) );
Error(end+1)= err( pinv(B)  , pinv(Bfull) );

%%Test of sum

Error(end+1)= err( sum(A,1)  , sum(Afull,1) );
Error(end+1)= err( sum(B,2)  , sum(Bfull,2) );
Error(end+1)= err( sum(S)    , sum(Sfull) );


%%Test of nnz

Error(end+1)= err( nnz(A) , nnz(Afull)  );
Error(end+1)= err( nnz(B) , nnz(Bfull)  );


%%Test of cellfun

    fun= @(A) sum(A(:)); 

Error(end+1)= err( cellfun(fun,A) , fun(Afull) );   


   fun= @(A) diag(diag(A));

Error(end+1)= err( cellfun(fun,S,'ExpandScalars',0) , fun(Sfull) );   
   

%%Test of kron

        Z=rand(2);
Error(end+1)= err( kron(A,B) , kron(Afull,Bfull) );   
Error(end+1)= err( kron(A,Bfull) , kron(Afull,Bfull) );   
Error(end+1)= err( kron(Z,A,2) , kron(Z,kron(Afull,2)) );   

%%Test of mtimes

Error(end+1)= err( A*3 , Afull*3  );  %scalar with KronProd
Error(end+1)= err( 3*A , 3*Afull  );

Error(end+1)= err( S*A , Sfull*Afull  ); %prod of 2 KronProds

       x=Afull(end,:).';
       y=Afull(:,end).';

Error(end+1)= err( A*[x,x] , Afull*[x,x]  ); %pre-mult with columnized data
Error(end+1)= err( [y;y]*A , [y;y]*Afull  ); %post-mult with columnized data

   xx=reshape([x,x], [A.domainsizes,2]  );
   Afull_times_xx=reshape(Afull*[x,x], [A.rangesizes,2]  );
   
   yy=reshape([y;y], [2,A.rangesizes]  );
   yy_times_Afull=reshape([y;y]*Afull, [2,A.domainsizes]  );
   
Error(end+1)= err( A*xx , Afull_times_xx ); %pre-mult with data in n-D array form
Error(end+1)= err( yy*A , yy_times_Afull  ); %post-mult with data in n-D array form  


     %repeat above tests with sparse operators
     As=cellfun(@(s) sparse(s), A); 
     
Error(end+1)= err( As*[x,x] , Afull*[x,x]  ); %pre-mult with columnized data
Error(end+1)= err( [y;y]*As , [y;y]*Afull  ); %post-mult with columnized data

   
Error(end+1)= err( As*xx , Afull_times_xx ); %pre-mult with data in n-D array form
Error(end+1)= err( yy*As , yy_times_Afull  ); %post-mult with data in n-D array form       
     



%%Test of mldivide
Error(end+1)= err( 3\B , 3\Bfull  );  %scalar with KronProd

Error(end+1)= err( B\A , Bfull\Afull  ); %prod of 2 KronProds

     y=Bfull(:,end);
     yy=reshape([y,y], [B.rangesizes,2]  );
     Bfull_slash_yy=reshape(Bfull\[y,y], [B.domainsizes,2]  );

Error(end+1)= err( B\[y,y] , Bfull\[y,y]  ); %Backslash with columnized data
   
Error(end+1)= err( B\yy , Bfull_slash_yy  ); %Backslash with data in n-D array form  


%%Test of mrdivide
  
    Bt=B.'; Btfull=Bfull.';

Error(end+1)= err( Bt/3 , Btfull/3  );%scalar with KronProd

Error(end+1)= err( A.'/Bt , Afull.'/Btfull ); %prod of 2 KronProds

     x=Btfull(end,:);
     xx=reshape([x;x], [2,Bt.domainsizes]  );
     xx_slash_Btfull=reshape([x;x]/Btfull, [2,Bt.rangesizes]  );

Error(end+1)= err( [x;x]/Bt , [x;x]/Btfull ); %Slash op with columnized data
   
Error(end+1)= err( xx/Bt  , xx_slash_Btfull ); %Slash op with data in n-D arrax form  


%%Test of times

Error(end+1)= err( A.*3 , Afull.*3  );  %scalar with KronProd
Error(end+1)= err( 3.*A , 3.*Afull  );

Error(end+1)= err( A.*B , Afull.*Bfull  ); %prod of 2 KronProds


%%Test of rdivide

Error(end+1)= err( B./3 , Bfull./3  );  %scalar with KronProd
Error(end+1)= err( 3./B , 3./Bfull  );

Error(end+1)= err( A./B , Afull./Bfull  ); %2 KronProds
Error(end+1)= err( B./A , Bfull./Afull  ); %2 KronProds

%%Test of ldivide

Error(end+1)= err( B.\3 , Bfull.\3  );  %scalar with KronProd
Error(end+1)= err( 3.\B , 3.\Bfull  );

Error(end+1)= err( B.\A , Bfull.\Afull  ); %2 KronProds
Error(end+1)= err( A.\B , Afull.\Bfull  ); %2 KronProds

%%Test of power, mpower
Error(end+1)= err( A.^2 ,  Afull.^2   );
Error(end+1)= err( S^2  ,  Sfull^2   );


%%Test of norm
Error(end+1)= err( norm(A) , norm(Afull) );
Error(end+1)= err( norm(B) , norm(Bfull) );
Error(end+1)= err( norm(S,1) , norm(full(S),1) );
Error(end+1)= err( norm(S,inf) , norm(full(S),inf) );
Error(end+1)= err( norm(S,'fro') , norm(Sfull,'fro') );

%%Test of cond

Error(end+1)= err( cond(B) , cond(Bfull) );
Error(end+1)= err( cond(S,1) , cond(Sfull,1) );
Error(end+1)= err( cond(S,inf) , cond(Sfull,inf) );
Error(end+1)= err( cond(S,'fro') , cond(Sfull,'fro') );

%%Test of quadform

     w=rand(ncols(A),1);
   
Error(end+1)= err( quadform(A,w) , Afull*diag(w)*Afull.' ); 

Error(end+1)= err( quadform(A,w,B.') , Afull*diag(w)*Bfull.' );   
  

%%Test of svd

   Z=full(svd(A)); Zfull=svd(Afull);

Error(end+1)= err( sort(Z) , sort(Zfull) );

   [U,Z,V]=svd(A); 
   
Error(end+1)= err( U*Z*V', Afull );   

%%Test of eig

    [V,D]=eig(S); 
   
    
Error(end+1)= err(V*D, Sfull*V );   %standard eig value problem - 1 argout

    E=full(eig(S)); Efull=eig(Sfull);

Error(end+1)= err( sort(abs(E)) , sort(abs(Efull)) );%standard eig value problem - all argout

    [V,D]=eig(S,S); 
   
Error(end+1)= err( Sfull*V ,  Sfull*V*D);   %generalized eig value problem - 1 argout

    E=full(eig(S,S)); Efull=eig(Sfull,Sfull);

Error(end+1)= err( sort(abs(E)) , sort(abs(Efull)) );%generalized eig value problem - all argout


    [V,D]=eig(S,Sa); %Repeat the above with an alternative form Sa of S
   
Error(end+1)= err( Sfull*V ,  Sfull*V*D);   

    E=full(eig(S,Sa)); Efull=eig(Sfull,Sfull);

Error(end+1)= err( sort(abs(E)) , sort(abs(Efull)) );

%%Test of orth

    Z=orth(A); Zfull=orth(Afull);
   
Error(end+1)= err( Z'*Z, eye(size(Z'*Z)) );   
Error(end+1)= err( Z*(Z\Afull), Afull );   


%%Test of rank 

Error(end+1)= err( rank(A), rank(Afull) );
Error(end+1)= err( rank(B), rank(Bfull) );
Error(end+1)= err( rank(S), rank(Sfull) );




%%Test of chol 


     Z=S'*S;  Zfull=full(Z);
     
Error(end+1)= err( chol(Z), chol(Zfull) );
Error(end+1)= err( chol(Z,'lower') , chol(Zfull,'lower') );




%%Test of lu 

    [L,U]=lu(S);

Error(end+1)= err( L*U , Sfull );


    [L,U,P]=lu(S); [LL,UU,PP]=lu(Sfull);

    
Error(end+1)= err( P.'*L*U , Sfull );



       %Now some sparse data
       Sopset=S.opset; Sopset{1}=sparse(S.opset{1});     
       Ss=KronProd(Sopset,S.opinds,S.domainsizes,S.scalarcoeff);
  
   
     [L,U,P,Q,R]=lu(Ss); 
     [LL,UU,PP,QQ,RR]=lu(Ssparse);
  
Error(end+1)= err( P*(R\Ssparse)*Q , L*U );
Error(end+1)= err( Ssparse, R*P'*L*U*Q' );


%%Test of qr    - a lot of them, because the I/O combinations are complex

        Z=S'*S;  Zfull=full(Z); Zsparse=sparse(Z);


    [Q,R]=qr(Z); 

Error(end+1)= err( Q*R , Zfull );                        %recomposition
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );             %orthogonality of Q
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) ); %triangularity of R

    [Q,R,E]=qr(Z);

Error(end+1)= err( Q*R*E' , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );

    [Q,R,E]=qr(Z,0);

Error(end+1)= err( Q*R*E' , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );

           %Now some sparse data
           Zopset=Z.opset; Zopset{1}=sparse(Z.opset{1});
           Zs=KronProd(Zopset,Z.opinds,Z.domainsizes,Z.scalarcoeff);
 
           

    [Q,R]=qr(Zs);   [R0]=qr(Zs);

Error(end+1)= err( Q*R , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err(R,R0);



    [Q,R]=qr(Zs,0);  [R0]=qr(Zs,0);

Error(end+1)= err( Q*R , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err(R,R0);


    [Q,R,E]=qr(Zs);

Error(end+1)= err( Q*R*E' , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );

    [Q,R,E]=qr(Zs,0);

Error(end+1)= err( Q*R*E' , Zfull );
Error(end+1)= err( Q'*Q , eye(size(Q'*Q)) );
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );


            bb=rand(size(Zfull,1),1);  
           [CC,RR]=qr(Zsparse,bb); 
           [Q,R]=qr(Zs);              
           
           
    [C,R]=qr(Zs,bb); %full second argument
    
Error(end+1)= err( C , Q'*bb);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( R\C, RR\CC );
Error(end+1)= err( R\C, Zsparse\bb );


           [CC,RR,EE]=qr(Zsparse,bb);  [Q,R,E]=qr(Zs);                        

    [C,R,E]=qr(Zs,bb); %full second argument

Error(end+1)= err( C , Q'*bb);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( E*(R\C), EE*(RR\CC) );
Error(end+1)= err( E*(R\C), Zsparse\bb  );

           [CC,RR,EE]=qr(Zsparse,bb);   [Q,R,E]=qr(Zs,0);          

    [C,R,E]=qr(Zs,bb,0); %full second argument

Error(end+1)= err( C , Q'*bb);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( E*(R\C), EE*(RR\CC) );
Error(end+1)= err( E*(R\C), Zsparse\bb  );

           [CC,RR]=qr(Zsparse,Afull);  [Q,R]=qr(Zs);   

    [C,R]=qr(Zs,A); %KronProd second argument

Error(end+1)= err( C , Q'*Afull);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( R\C, RR\CC );
Error(end+1)= err( R\C, Zsparse\Afull);

       [CC,RR,EE]=qr(Zsparse,Afull);   [Q,R,E]=qr(Zs);  

    [C,R,E]=qr(Zs,A); %KronProd second argument

Error(end+1)= err( C , Q'*Afull);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( E*(R\C),  EE*(RR\CC)  );
Error(end+1)= err( E*(R\C),  Zsparse\Afull  );

       [CC,RR,EE]=qr(Zsparse,Afull);  [Q,R,E]=qr(Zs,0);          

    [C,R,E]=qr(Zs,A,0); %KronProd second argument

Error(end+1)= err( C , Q'*Afull);
Error(end+1)= err( tril(full(R),-1) +1, ones(size(R)) );
Error(end+1)= err( E*(R\C),  EE*(RR\CC)  );
Error(end+1)= err( E*(R\C),  Zsparse\Afull  );


%%Test of opinds default

   K1=rand(3); K2=rand(4); K3=rand(5);
   PPP=kron(K3,kron(K2,K1)); QQQ=KronProd({K1,K2,K3});

Error(end+1)= err(PPP, QQQ);


%%%%%%%%%%%%%%%%%%%%%%%END OF TESTS%%%%%%%%%%%%%%%%%%%%%%%%%%


MAX_ERROR=max(Error);

disp(['Maximum observed error was   ' num2str(MAX_ERROR) ' percent.'])





function errval=DiscrepancyMeasure(X,Y,TOL)

  errval=Discrepancy(X,Y)/Discrepancy(0,Y)*100; %normalize

  if errval>TOL, 
      disp ' '; disp 'Discrepancy detected'
      errval, 
      x=full(X); y=full(Y);
      keyboard;
  end 
  
  
function errval=Discrepancy(X,Y) 
%Primary error measurement function

  fin=@(a) a(isfinite(a));
  nonfin=@(a) a(~isfinite(a)); 

  x=full(X); y=full(Y);

  errval= norm( fin(x-y) , inf)+...   
       ~isequalwithequalnans(nonfin(x),nonfin(y))*...
       ~isempty([nonfin(x);nonfin(y)]); 





