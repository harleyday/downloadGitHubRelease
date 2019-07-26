# downloadGitHubRelease

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/8f178489c803497697f41941752573cb)](https://app.codacy.com/app/harleyday/downloadGitHubRelease?utm_source=github.com&utm_medium=referral&utm_content=harleyday/downloadGitHubRelease&utm_campaign=Badge_Grade_Dashboard)

## A function which allows you to easily download MATLAB toolbox releases from GitHub repositories using the GitHub REST API v3

The function specifically looks for assets with the file extension ".mltbx" to download.

## Installation

Simply copy-paste the [downloadGitHubRelease.m](https://github.com/harleyday/downloadGitHubRelease/blob/master/downloadGitHubRelease.m) into a MATLAB function in your workspace, and you can use this tool.

## Syntax

If you wish to download a toolbox file from a GitHub repository called `REPO` owned by someone with the username `USERNAME`, you can use

```MATLAB
downloadGitHubRelease ( 'USERNAME/REPO' )
downloadGitHubRelease ( 'USERNAME/REPO', 'version_id_OR_latest' )
downloadGitHubRelease ( 'USERNAME/REPO', 'version_id_OR_latest', 'token', PERSONAL_ACESS_TOKEN, 'install', true/false, 'overwrite', true/false )
```

## Description

  - **`'USERNAME/REPO'`:** String specifying the username and repository name you wish to acess. This argument is required.
  - **`'version_id_OR_latest'`:** Optional string specifying the version id (e.g. `'v1.0'`) you wish to download. You can also specify `'latest'`. The `'latest'` release is downloaded by default.

Three name-value pairs exist as optional additional arguments:
  - **`'token'`:** Use this to provide a [personal access token](https://github.com/settings/tokens) as a string if you're downloading from a private repository.
  - **`'install'`:** true/false value (`false` by default) to specify if you wish to immediately install the MATLAB toolbox you download.
  - **`'overwrite'`:** true/false value (`false` by default) to specify if you wish to overwrite files by the same name in the current directory.

## Examples

```MATLAB
downloadGitHubRelease ( 'harleyday/logicleTransform.m' );
```

```HTML
We'll get the latest release
Downloading version latest.
Completed download.
```

---

```MATLAB
downloadGitHubRelease ( 'harleyday/logicleTransform.m', 'v1.0' );
```

```HTML
Overwriting logicleTransform.m.mltbx already in this directory.
Downloading version v1.0.
Completed download.
```
