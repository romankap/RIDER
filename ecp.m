clc; clear;

%Comments: 
%1) No 0.5 probability of a bit flipping its value
%2) k is the number of writes? If yes, then a new page is generated for
%every write?

if 1
    N=512;          % row width
    M=64;           % number of rows (so that N*M=4KB = page)
    a=1e8;          % average endurance
    s=0.25*a;        % std deviation
    Pages=128;      % Number of pages in the memory
    max_fr_e=6;     % Max ECP recoverable faults per row     
    
    
    RU=250;
    ESurPages=zeros(1,RU+1);
    kk=zeros(1,RU+1);
    L1=0;
    L2=1e8;
    LS=(L2-L1)/RU;

    i=0;
    for k=L1:LS:L2
        i=i+1
        kk(i)=k;

        esupages=Pages;

        for j=1:Pages
            bf = normrnd(a,s,M,N); %
            bf(bf<4)=4; %What's this for?

    %%%% ECP
            [xi, yi, vi]=find(k>bf);
            if ~isempty(xi)
                AA=full(sparse(xi,yi,vi));
                BB=sum(AA'>0);

                if ~isempty(find(BB>max_fr_e, 1)) 
                    esupages=esupages-1;
                end
            end
        end

        ESurPages(i)=esupages;        % Surviving pages - ECP

    end
        
    
    save e58
else

    load e58
    

    ESurPages=100*ESurPages/Pages;              
    
    ESurPages1=sort(ESurPages,'descend');

    figure(54)
    set(gca, 'FontName', 'Helvetica')
    set(gca,'FontSize',16,'FontUnits','points');
    afFigureBackgroundColor = [1, 1, 1];
    set(gcf, 'color', afFigureBackgroundColor);
    set(gcf, 'InvertHardCopy', 'off');    

    % 2 because the probability of a bit to flip is 0.5
%     plot(2*M*kk,RSurRows1,'r')
%     hold
    plot(2*M*kk,ESurPages1,'b')
%     hold

    set(findall(gca, 'Type', 'Line'),'LineWidth',3);

    xlabel('Average writes/page (B), \sigma=25%')
    ylabel('Percentage of surviving pages')
%     legend('Rider_3_4_0', 'ECP_6', 'Location','SW')

end





