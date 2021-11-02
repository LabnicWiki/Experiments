function [gaborimdef, gaborname]=create_gaborim(imsize, lamda, sigma, phase, Ltheta, Gtheta, fdist, xoff, yoff, cutoff, show, gabordir)
% gaborim=gabor_pix(imsize, lamda, sigma, phase, Ltheta, Gtheta, fdist, xoff, yoff, cutoff, show)
% Generate gabor patch with parameters in pixels: gabor(size, freq, sigma, phase, Ltheta, Gtheta, fdist, xoff, yoff, cutoff, [show])
%  imsize;        %image size
%  lamda;          %wavelength in pixels
%  sigma;          %gaussian standard deviation in pixels
%  phase;           %phase 0:1
%  Ltheta;         %local orientation in degrees (clockwise from vertical)
%  Gtheta;          %global orientation in degrees (clockwise from vertical)
%  fdist;           %distance between target and flankes in pixels
%  xoff;            %horizontal offset position of gabor in pixels
%  yof;            %vertical offset position of gabor in pixels
%  cutoff;		  %if positive, applies threshold of gauss>cutoff to produce sharp edges and no smooth fading
%if negative, trims off gauss > abs(cutoff) while preserving fading in remaining regions
%  showme;          %if present, display result
% for demo, call with no arguments

% Demo
if nargin == 0
    imsize = 200;        %image size
    lamda = 10;          %wavelength in pixels
    sigma = 10;          %gaussian standard deviation in pixels
    phase = 0;           %phase 0:1
    Ltheta = 45;         %local orientation in degrees (clockwise from vertical)
    Gtheta = 0;          %global orientation in degrees (clockwise from vertical)
    fdist = 0;           %distance between target and flankes in pixels
    xoff = 0;            %horizontal offset position of gabor in pixels
    yoff = 0;            %vertical offset position of gabor in pixels
    cutoff = 0;		     %if positive, applies threshold of gauss>cutoff to produce sharp edges and no smooth fading
    show = 1;            %if present, display result
    im = gabor_pix(imsize, lamda, sigma, phase, Ltheta, Gtheta, fdist, xoff, yoff, cutoff, show);
else

    % main program
    fdist = min(imsize,fdist*2);
    xoff = max(-imsize,-xoff); yoff=max(-imsize,-yoff);
    freq = 1/(lamda/imsize);
    thL = (Ltheta/360)*2*pi;
    thG = (Gtheta/360)*2*pi;
    st = 1/imsize;
    [X Y] = meshgrid(-.5:st:.5-st,-.5:st:.5-st);
    XGr = (fdist.*sin(thG));
    YGr = (fdist.*cos(thG));
    Xo = X+ ((-XGr+xoff)/imsize); Yo = Y+ ((YGr+yoff)/imsize);
    XLr = X.*cos(thL); YLr = Y.*sin(thL);
    s = sigma/imsize;
    gauss = exp(-(((Xo.^2)+(Yo.^2))./(2*s*s)));

    cthr=[.005 abs(cutoff)];
    if exist('cutoff') && cutoff>0
        gauss = gauss >cutoff;
    else
        gauss = gauss.*(gauss > cthr(1+ (cutoff<0)) );  % apply default cutoff unless otherwise specified
    end

    grating = cos(((2*freq*pi)) .* (XLr + YLr) + ((phase*2*pi)));
    gaborim = gauss .* grating;
    if exist('show') && show==1
        gaborimdef=(gaborim+1)/2;
        cd (gabordir)
        imwrite(gaborimdef, ['gabor_', num2str(round(Ltheta)),'.png']);
        gaborname= ['gabor_', num2str(round(Ltheta)),'.png'];
                imshow(gaborimdef);%imshow((gaborim+1) /2);
        set(gcf,'Color',[.5 .5 .5], 'MenuBar', 'none');
        axis off; axis image; colormap gray; %truesize;
        cd ../../
  
    end
end