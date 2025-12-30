% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.





function [X,Y,Z,Labels] = ParsePositionList(fp)
fh = fopen(fp,'r');
X = [];
Y = [];
Z = [];
Labels = {};

row = nan; col = nan;
x = nan; y = nan; z = nan;
label = nan;
line = fgetl(fh);
while ischar(line)

    if ~isempty(strfind(line, 'GRID_COL'))
        idx = strfind(line, 'GRID_COL');
        col = str2double(line(idx+11:end-1));
        col = round(col) + 1;
    end
    if ~isempty(strfind(line, 'GRID_ROW'))
        idx = strfind(line, 'GRID_ROW');
        row = str2double(line(idx+11:end-1));
        row = round(row) + 1;
    end
    if ~isempty(strfind(line, '"DEVICE": "XYStage"'))
        line = fgetl(fh);
        line = fgetl(fh);
        idx = strfind(line, 'Y');
        y = str2double(line(idx+4:end-1));
        line = fgetl(fh);
        idx = strfind(line, 'X');
        x = str2double(line(idx+4:end-1));
    end
    if ~isempty(strfind(line, '"DEVICE": "Stage"'))
        line = fgetl(fh);
        line = fgetl(fh);
        line = fgetl(fh);
        idx = strfind(line, 'X');
        z = str2double(line(idx+4:end-1));
    end
    if ~isempty(strfind(line, 'LABEL'))
        idx = strfind(line, 'LABEL');
        label = line(idx+9:end-2);
    end

    if ~isnan(x) && ~isnan(y) && ~isnan(z) && ~isnan(row) && ~isnan(col) && ischar(label)
        X(row,col) = x;
        Y(row,col) = y;
        Z(row,col) = z;
        Labels{row,col} = label;

        row = nan; col = nan;
        x = nan; y = nan; z = nan;
        label = nan;
    end

   line = fgetl(fh);
end

fclose(fh);
end
