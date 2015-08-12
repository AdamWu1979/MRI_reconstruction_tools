function mp4_writer(x, filename, varargin)
% function mp4_writer(x, filename, varargin)
% varargin: rate (fps)
%			magnify, 100 = regular
%			texts
% wrapper for Matlab's VideoWriter
arg.NI = 5;
arg.rate = 1; % fps
arg.rgb = 0;
arg.magnify = 'fit'; % or can be positive number, 100 = regular size
arg.texts = {};
arg.text_x = 10*ones(1,arg.NI);
arg.text_y = 10 + min(size(x,1), size(x,2))*(0:arg.NI-1);
arg.profile = 'MPEG-4';
if size(x, 1) < size(x, 2)
	tmp = arg.text_y;
	arg.text_y = arg.text_x;
	arg.text_x = tmp;
end
arg = vararg_pair(arg, varargin);

if strcmp(filename, 'tmp')
	if strcmp(arg.profile, 'MPEG-4')
		filename = '~/Downloads/tmp.mp4';
	elseif ~isempty(strfind(lower(arg.profile), 'avi'))
		filename = '~/Downloads/tmp.avi';
	else
		display('unknown file type');
		return;
	end
elseif length(filename) < 4 || ~strcmp(filename(end-3:end), '.mp4')
	if strcmp(arg.profile, 'MPEG-4')
		filename = [filename '.mp4'];
	elseif ~isempty(strfind(lower(arg.profile), 'avi'))
		filename = [filename '.avi'];
	else
		display('unknown file type');
		return;
	end
end


% normalize to satisfy writeVideo
x = x./max(abs(col(x)));

try
	writerObj = VideoWriter(filename, arg.profile);
catch
	display(sprintf('unable to write mp4 %s, this machine probably does not have the specified VideoWriter profile', filename)) 
	return;
end
writerObj.FrameRate = arg.rate;
open(writerObj);

if arg.rgb
	Nf = size(x,4);
else
	Nf = size(x,3);
end
for ii = 1:Nf
	if arg.rgb 
		pic = x(:,:,:,ii);
	else
		pic = x(:,:,ii);
	end
	imshow(squeeze(pic), 'InitialMagnification', arg.magnify);
	if ~isempty(arg.texts)
		for jj = 1:length(arg.texts)
			text(arg.text_x(jj), arg.text_y(jj), arg.texts{jj}, ...
				'color', [1 1 1]);
		end
	end
	frame = getframe;
	writeVideo(writerObj, frame);
end
close(writerObj);