---
title:  "Mint - Seahorse for GitHub SSH keys"
excerpt: "SSH keys made easy"
tags: "mint seahorse ssh keys github"
---

## 1. In _Cinnamon_

1. Open `Password and Keys` (this app is known as [_Seahorse_](https://wiki.gnome.org/Apps/Seahorse/))
1. Click `+`
1. Select `Secure Shell Key`
1. Enter a description of the key
1. Click `Advanced key options`
    - Set Encryption Type to RSA
    - Set Key Strength to 4096
1. Click `Just Create Key`

## 2. In a CLI (terminal)

1. Install xclip:
    ```bash
    sudo apt install xclip
    ```
1. Copy the key to your clipboard:
    ```bash
    cat ~/.ssh/{keyname}.pub | xclip -i -sel clip
    ```

## 3. In GitHub

1. Open [SSH and GPG keys (https://github.com/settings/keys)](https://github.com/settings/keys)
1. Click `New SSH key`
1. Enter a title
1. Paste the key 