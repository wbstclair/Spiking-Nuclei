% This is a script to distribute jobs to the different computers in the
% lab.


addpath('/Users/wbstclair/Dropbox/Research/matlab/sshfrommatlab_13b')

userName = 'wbs';
hostName = 'starbuck.ccnl.ucmerced.edu';

password = input('Enter password for wbstclair: ', 's');

% This will initiate the ssh connection.
matlabChannel = sshfrommatlab(userName, hostName, password);


sshfrommatlabissue(matlabChannel,'screen -dRR matlabSession')

% assume parameterList with rows of 8 for each parameter set to be run.
% create a string form of the code to define the conditions for parallel
% runs.

paramString = 'parameterList = [';
for runNum = 1:size(parameterList,1)
    for paramNum = 1:size(parameterList,2)
        if paramNum < size(parameterList,2) 
            paramString = [paramString num2str(parameterList(runNum,paramNum)) ', '];
        elseif size(parameterList,1) > runNum
            paramString = [paramString num2str(parameterList(runNum,paramNum)) '; '];
        else
            paramString = [paramString num2str(parameterList(runNum,paramNum)) '];'];
        end
    end
end

sshfrommatlabissue(matlabChannel,paramString);
sshfrommatlabissue(matlabChannel,'parNetEval(parameterList, -1, 1 run_on_demand/cluster_analysis');


% Sequence of Commands
% sshfrommatlabissue(matlabChannel,'cd ..');
% sshfrommatlabissue(matlabChannel,'cd ..');
% sshfrommatlabissue(matlabChannel,'cd /usr/local/MATLAB/R2012a/bin');
% sshfrommatlabissue(matlabChannel,'sudo sh matlab');
% sshfrommatlabissue(matlabChannel, password);

% Now at this point, matlab is open on the machine...run commands!



% So what commands do I need?



sshfrommatlabclose(matlabChannel);