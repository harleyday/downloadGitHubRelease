function downloadGitHubRelease ( repository, varargin )

p = inputParser;

% repository: The username/repository adress of the code on GitHub.
addRequired ( p, 'repository', @check_repository);
% version: this optional positional parameter defines the tag_name of the
% version we want to download, or simply latest
addOptional ( p, 'version', 'latest', @check_version );

% token: the GitHub API token to allow us to download from a private
% repository
addOptional ( p, 'token', [], @(x) length(x)==40 ); % GitHub API tokens are 40 characters in length

addOptional ( p, 'install', false, @(x) assert(islogical(x), '''install'', must be a logical value.') );

addOptional ( p, 'overwrite', true, @(x) assert(islogical(x), '''overwrite'', must be a logical value.')  );

parse ( p, repository, varargin{:} );

repository = p.Results.repository;
version = p.Results.version;
token = p.Results.token;
install = p.Results.install;
overwrite = p.Results.overwrite;
delete(p); % clear the input parser form memory
GitHubAPI='https://api.github.com';

if isempty ( token )
    headerFields = {'Accept', 'application/vnd.github.v3.raw'};
else
    headerFields = {'Authorization', ['token ', token]; 'Accept', 'application/vnd.github.v3.raw'};
end

if ~isempty(version)
    specVersion = regexp ( version, 'v(\d+\.)(\d)' );
end
if isempty(version) || (~isempty ( specVersion ) && specVersion==1)
    url = [GitHubAPI, '/repos/', repository, '/releases'];
    
    options = weboptions( 'HeaderFields', headerFields, 'ContentType', 'json' );
    data = webread(url,options);
    
    if isempty(version)
        % show the user some information abou the releases available in
        % this repository
        fprintf ( 'There are %d releases on github.\n', length ( data ) );
        dataTable = struct2table ( data );
        dataTable = sortrows ( dataTable, 'tag_name', 'descend' );
        disp ( dataTable(:,{'tag_name', 'name', 'body'}) );
        prompt = sprintf( 'Specify which <strong>tag_name</strong> you wish to download (in ''v#.#'' format, or simply "latest"):\n' );
        version = input ( prompt, 's' );
    end
    
    [ present, index ] = ismember( version, {data.tag_name} );
    if sum(present)==1
        data = data ( index );
    else
        error ( 'There is no record of version %s on GitHub', version );
    end
elseif strcmp ( version, 'latest' )
    disp ( 'We''ll get the latest release' );
    url = [GitHubAPI, '/repos/', repository, '/releases/', version];
    options = weboptions( 'HeaderFields', headerFields, 'ContentType', 'json' );
    data = webread(url,options);
else
    error ( 'You should provide a version number as ''v#.#'', or ''latest''' );
end

if isempty ( token )
    download_url = data.assets.url;
else
    download_url = [data.assets.url, '?access_token=', token];
end
save_name = data.assets.name;

% delete files of the same name if already in this directory if asked to overwrite
directory_contents = dir;
if ismember( save_name, {directory_contents.name} );
    if overwrite
        fprintf ( 'Overwriting %s already in this directory.\n', save_name );
        delete ( save_name );
    else
        error ( 'There is already a file by that name in this directory.' );
    end
end

headerFields = {'Accept', 'application/octet-stream' };
options = weboptions('HeaderFields', headerFields);
fprintf ( 'Downloading version %s.\n', version );
status = websave ( save_name, download_url, options );
if status == false
    error ( 'The download failed' );
end
disp ( 'Completed download.' );
if regexp ( save_name, '.*\.mltbx' )
    if isempty(install)
    response = input ( 'The file you''ve downloaded is a MATLAB toolbox. Would you like to install it? [Y, n]\n', 's' );
    if strcmpi ( response, 'Y' )
        install = true;
    else
        install = false;
        disp ( 'Okay. The toolbox file is still saved, but isn''t installed.' );
    end
    end
    if install
        disp ( 'Installing the toolbox...' );
        installedToolbox = matlab.addons.toolbox.installToolbox ( save_name );
        disp ( installedToolbox );
    end

end
end

function valid = check_repository(x)
if (ischar(x) || isstring(x))
     % the regexp checks that there is a forward slash between two squences of characters/numbers
    regResult = regexp ( x, '.*\/.*' );
    if regResult == 1
        valid = true;
        return;
    else
        valid = false;
        return;
    end
else
    valid = false;
end
end

function valid = check_version(x)
if (ischar(x) || isstring(x))
    regResult = regexp ( x, 'v(\d+\.)(\d)|latest' );
    if regResult == 1
        valid = true;
        return;
    else
        valid = false;
        return;
    end
elseif isempty (x)
    valid = true;
    return;
else
    valid = false;
    return;
end
end