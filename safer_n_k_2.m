function term_err=safer_n_k_2(N, M, K, e, numt)

% SAFER
% For a memory row of N bits and k groups
% there are nchoosek (log2N, log2k) possible partitions 
% For N=512 and k=32 for example, there are 126 possible partitions
% Since all partitions need to be examined, this is impractical
% The max number of partitions to consider is definied by a counter
% which is log2(log2k+1) in SAFER
% In k=32 example, it's 3 bit meaning at most 8 partitions are
% considered

% In this program, I will consider all 126 possible partitions?

% N=512;      % memory row 
nb=log2(N); % wordlength
% K=32;       % number of groups
% e=10;        % number of errors

% Matrix of partition indices as per C(N,K) partitions above
if 0
    n=[[9 8 7 6 5];[9 8 7 6 4];[9 8 7 4 3];[9 8 4 3 2];[9 4 3 2 1];[5 4 3 2 1]];
else
    n=nchoosek(log2(N):-1:1,log2(K));
end
[partnum, partbit]=size(n);

term_err=0;


for ii=1:numt
    
    a=sprand(N,M,e/(N*M));
    
% % % % %     ee1= ee(ii);
% % % % %     err = randperm(N,ee1)-1;

    for kk=1:M
        
        err=find(a(kk,:));       
        ee1=length(err);

        erri = zeros(1,ee1);
        err_cnt=0;

        for r=1:partnum
            for j=1:ee1
                su=0;
                for c=1:partbit
                    su=su+bitget(err(j),n(r,c))*2^(nb-c);
                end
                erri(j)=su;
            end
            if length(erri)~=length(unique(erri))
                err_cnt=err_cnt+1;
            end
            if err_cnt>=partnum
                term_err=term_err+1;
            end
        end
               
    end
end

% term_err


