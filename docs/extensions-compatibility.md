<!-- order: 0 -->

# Extensions Compatibility

## Table of Contents

- [Incompatibility](#incompatibility)
- [Replacements](#replacements)
  - [C/C++](#cc)
  - [Python](#python)
  - [Remote](#remote)

## <a id="incompatibility"></a>Incompatibility

RunQL is a Code OSS based product. Some Microsoft-published extensions are licensed or implemented to run only in Microsoft products, and some third-party extensions also explicitly do not support VSCodium or other Code OSS based builds.

Examples that may not work correctly in RunQL include:

- [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
- [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
- [Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
- [Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
- [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

## <a id="replacements"></a>Replacements

The following extensions are commonly used alternatives:

### <a id="cc"></a>C/C++

- [clangd](https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd)
- [Native Debug](https://open-vsx.org/extension/webfreak/debug)

### <a id="python"></a>Python

- [BasedPyright](https://open-vsx.org/extension/detachhead/basedpyright)

### <a id="remote"></a>Remote Development

- [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh)
- [Open Remote - WSL](https://open-vsx.org/extension/jeanp413/open-remote-wsl)
