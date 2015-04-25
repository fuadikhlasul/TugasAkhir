function I = ImageAcquisition(path)

global w h

I = imread(path);
info = imfinfo(path);
h = info.Height;
w = info.Width;

