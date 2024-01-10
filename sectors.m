close all
clear all
% [header, BScanHeader, slo, BScans, ThicknessGrid] = open_vol ('abasi_m_285_0.vol');
% figure, imshow(BScans.^.25,[])
% hold on
% plot(BScanHeader.Boundary_1  )

dirData = dir('*.vol');
counter = size(dirData,1);
C = cell(1,11);
%------------------------------
% circle mask
mask = ones(512,512);
for i=1:512
    for j=1:512
        if (i-256).^2+(j-256).^2 > 256.^2
            mask(i,j)= 0;
        end
    end
end
% mask_rep = repmat(mask, 1,1,10);
%------------------------------
% Location = [];
for count = 1:counter
    C{count,1} = dirData(count).name;
    [header, BScanHeader, slo, BScans, ThicknessGrid] = open_vol (dirData(count).name);
    BScans(BScans>1e+38)=0;
    
    %     ww = fieldnames(BScanHeader);
    %     if size(ww,1)== 14
    %         location = 'ONH';
    %     else
    %         location = 'Macula';
    %     end
    % figure, imshow(BScans(:,:,1).^.25,[])
    % hold on
    % plot(BScanHeader.Boundary_1(1,:)  )
    % hold on
    % plot(BScanHeader.Boundary_3(1,:)  )
    % figure, imshow(slo,[])
    if BScanHeader.NumSeg ~= 3  ;
        
        thick_allLayers = zeros(512, 512, 11);
        thick_allLayers(:,:,1) = imresize(BScanHeader.Boundary_2 -BScanHeader.Boundary_1, [512,512]);
        thick_allLayers(:,:,2) = imresize(BScanHeader.Boundary_3 -BScanHeader.Boundary_1, [512,512]);
        thick_allLayers(:,:,3) = imresize(BScanHeader.Boundary_4 -BScanHeader.Boundary_3, [512,512]);
        thick_allLayers(:,:,4) = imresize(BScanHeader.Boundary_5 -BScanHeader.Boundary_4, [512,512]);
        thick_allLayers(:,:,5) = imresize(BScanHeader.Boundary_6 -BScanHeader.Boundary_5, [512,512]);
        thick_allLayers(:,:,6) = imresize(BScanHeader.Boundary_7 -BScanHeader.Boundary_6, [512,512]);
        thick_allLayers(:,:,7) = imresize(BScanHeader.Boundary_9 -BScanHeader.Boundary_7, [512,512]);
        thick_allLayers(:,:,8) = imresize(BScanHeader.Boundary_15 -BScanHeader.Boundary_9, [512,512]);
        thick_allLayers(:,:,9) = imresize(BScanHeader.Boundary_16 -BScanHeader.Boundary_15, [512,512]);
        thick_allLayers(:,:,10) = imresize(BScanHeader.Boundary_17 -BScanHeader.Boundary_16, [512,512]);
        thick_allLayers(:,:,11) = imresize(BScanHeader.Boundary_2 -BScanHeader.Boundary_17, [512,512]);
        %         thick_tot = BScanHeader.Boundary_2 -BScanHeader.Boundary_1;
        %         thick_tot_square = imresize(thick_tot, [512,512]);
        %         figure, imshow(thick_tot_square, [])
        for layer = 1:11
            thickTemp = thick_allLayers(:,:,layer);
            mask2 = ones(512, 512);
            mask2((thickTemp* header.ScaleZ>1)) = 0; % big numbersdue to incorrect segmentation or out of boundary values
            mask2((thickTemp* header.ScaleZ<0)) = 0; %incorrect if negative
            C{count,layer+1} = mean(mean(thickTemp((mask==1) & (mask2==1) )))* header.ScaleZ;
        end
    else
        %         thick_allLayers = zeros(1, 768, 2);
        %         thick_allLayers(:,:,1) = BScanHeader.Boundary_2 -BScanHeader.Boundary_1;
        %         thick_allLayers(:,:,2) = BScanHeader.Boundary_3 -BScanHeader.Boundary_1;
        pRNFL = BScanHeader.Boundary_3 -BScanHeader.Boundary_1;
        C{count,2} = mean([pRNFL(1:96), pRNFL(768-96+1:768)])* header.ScaleZ;
        C{count,3} = mean([pRNFL(97:96+192)])* header.ScaleZ;
        C{count,4} = mean([pRNFL(97+192:96+192+192)])* header.ScaleZ;
        C{count,5} = mean([pRNFL(97+192+192:768-96)])* header.ScaleZ;
        C{count,6} = mean([pRNFL(97:96+96)])* header.ScaleZ;
        C{count,7} = mean([pRNFL(96+97:96+192)])* header.ScaleZ;
        C{count,8} = mean([pRNFL(97+192+192:96+192+192+96)])* header.ScaleZ;
        C{count,9} = mean([pRNFL(97+192+192+96:96+192+192+192)])* header.ScaleZ;
        C{count,10} = mean([ C{count,2},C{count,3},C{count,4},C{count,5}]);
    end
    % thick_tot_square(256,256)* header.S
    % temp = 0;
    % for ii=1:9
    %     temp = temp + ThicknessGrid.Sectors(ii).Thickness;
    % end
    % temp/9
    
end
xlswrite('test.xls',C)
