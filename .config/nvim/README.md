# **Neovim Keybinds Documentation**

This document provides a simple and organized overview of all the custom keybinds defined in my Neovim configuration. The `\<leader\>` key is `Space`.

## **General Keybinds**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>cd | Open file explorer (`netrw`) in the current directory. |
| n | J | Join lines while keeping the cursor in place. |
| n | \<C-d\> | Scroll half-page down and keep the cursor centered. |
| n | \<C-u\> | Scroll half-page up and keep the cursor centered. |
| n | n | Move to next search result and keep it centered. |
| n | N | Move to previous search result and keep it centered. |
| n | \<leader\>nh | **(New)** Clear search highlight. |
| n | Q | Disable Ex mode (noop). |
| i | \<C-c\> | Exit insert mode (acts like `Esc`). |
| n | \<leader\>x | Make current file executable (`chmod \+x`). |
| n | \<leader\>u | Toggle Undotree (visualize undo history). |
| n | \<leader\>rl | Reload the Neovim config. |
| n | \<leader\>\<leader\> | Source (execute) the current file. |

## **Visual Mode & Editing Keybinds**

| Mode | Key | Action |
| :---- | :---- | :---- |
| v | J | Move selected block down. |
| v | K | Move selected block up. |
| x | \<leader\>p | Paste without overwriting the clipboard register. |
| n, v | \<leader\>d | **(New)** Delete without yanking (sends to blackhole register). |
| n, v | \<leader\>y | Yank into system clipboard (works over SSH). |

## **Quickfix List Keybinds**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>co | **(New)** Open the quickfix list. |
| n | \<leader\>cl | **(New)** Close the quickfix list. |
| n | \<C-j\> | Jump to **next** quickfix entry and center the view. |
| n | \<C-k\> | Jump to **previous** quickfix entry and center the view. |
| n | \<leader\>j | Jump to **previous** location list entry. |
| n | \<leader\>k | Jump to **next** location list entry. |

## **Telescope Keybinds (Fuzzy Finder)**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>ff | Find files in the current directory. |
| n | \<leader\>fa | **(New)** Find **all** files (including hidden files like `.gitignore`). |
| n | \<leader\>fg | **(Corrected)** Live Grep for a string you input (uses `ripgrep`). |
| n | \<leader\>fs | Grep for the string under the cursor. |
| n | \<leader\>fc | Grep for instances of the current file's name. |
| n | \<leader\>fo | Open recent files. |
| n | \<leader\>fb | Open buffer list. |
| n | \<leader\>fq | Open quickfix list in Telescope. |
| n | \<leader\>fh | Open help tags. |
| n | \<leader\>fi | Find files in your Neovim config directory. |

## **Harpoon Integration (File Bookmarking)**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>a | Add (append) current file to the Harpoon list. |
| n | \<C-e\> | Toggle the Harpoon quick menu UI. |
| n | \<leader\>fl | Show the Harpoon list in a Telescope window. |
| n | \<C-n\> | Go to the **next** Harpoon mark. |
| n | \<C-p\> | Go to the **previous** Harpoon mark. |

## **LSP (Language Server) Keybinds**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | K | Show hover information. |
| n | gd | Go to definition. |
| n | gD | Go to declaration. |
| n | gi | Go to implementation. |
| n | go | Go to type definition. |
| n | gr | Show references. |
| n | gs | Show signature help. |
| n | gl | Show line diagnostics in a floating window. |
| n | \<F2\> | Rename symbol. |
| n, x | \<F3\> | Format code asynchronously. |
| n | \<F4\> | Show code actions. |
| n | \<leader\>li | **(New)** Show LSP server info for the current buffer (`:LspInfo`). |

## **Floating Terminal**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>ft | **(New)** Toggle a floating terminal window. |

## **Miscellaneous**

| Mode | Key | Action |
| :---- | :---- | :---- |
| n | \<leader\>dg | Generate comment documentation blocks (`DogeGenerate`). |
| n | \<leader\>s | Replace all instances of the word under the cursor on the current line. |
| n | \<leader\>cc | Run `php-cs-fixer` to lint and format the current PHP file. |
| n | \<leader\>qq | **(New)** Reformat comma-separated content inside parentheses into multiple lines. |

# **LSP Servers**

I am migrating my LSP config to `plugin/lsp.lua` because Neovim v0.11+ allows a very minimal, debloated way to set up language server protocols.

Below is a running list of what and how to install the LSPs that are configured in this build. I am avoiding Mason for now to have full control over my system. To use Mason, you can uncomment the `lsp.lua` file in the `plugins` directory.

1. **lua-language-server**:  
   * Install via your distribution's package manager (e.g., `lua-language-server` in Nixpkgs).  
2. **css-language-server, html-language-server**:  
   * `npm install \-g vscode-langservers-extracted  `
3. **intelephense (PHP)**:  
   * `npm install \-g intelephense  `
4. **typescript-language-server**:  
   * `npm install \-g typescript-language-server typescript`
