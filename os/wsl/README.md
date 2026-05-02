
# aptでpackages.txtにインストール済みのツールを書き出す
apt-mark showmanual > packages.txt

# aptでpackages.txtに記載のツールをインストール
sudo apt install $(cat packages.txt)


## memo

windows 11 + Wezterm + zsh + fzf (MSYS2)
https://zenn.dev/osa_k/scraps/a10bee5ebe2d03

https://qiita.com/ymdymd/items/af4ed8d562fe235f6661

https://yanor.net/wiki/?Windows-%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3/MinGW-MSYS/MSYS2%E3%81%AEOpenSSH%E3%81%A7%E3%81%AE%E3%83%9B%E3%83%BC%E3%83%A0%E3%83%87%E3%82%A3%E3%83%AC%E3%82%AF%E3%83%88%E3%83%AA%E3%81%AE%E6%89%B1%E3%81%84


neovim install
pacman -S mingw-w64-ucrt-x86_64-neovim


wsl
それ、詰んだように見えるけど普通に復旧できます。
WSLはLinuxだけど**Windows側から強制的に管理できる**のがポイント。

---

# 最短で復旧する方法（確実）

## ① rootで起動

PowerShellで👇

```powershell
wsl -u root
```

👉 **パスワードなしでrootログインできる**

---

## ② ユーザーのパスワード変更

```bash
passwd mizut
```

👉 新しいパスワード入力

---

## ③ 通常ユーザーに戻る

```powershell
wsl -u mizut
```

---

# もしユーザー名わからない場合

```bash
ls /home
```

---

# それでもダメな場合（強制手段）

デフォルトユーザーをrootに変更：

```powershell
ubuntu config --default-user root
```

※ Ubuntuのバージョンによっては：

```powershell
ubuntu2204 config --default-user root
```

---

# 確認

```bash
whoami
```

---

# 結論

👉 WSLは「パスワード忘れても詰まない設計」

---

# 率直なアドバイス

今回みたいなケースあるので👇

👉 **sudoパスワードはシンプルにしとく方がいい**

（WSLはローカル環境なのでセキュリティリスク低い）

---

ここで詰まらなかったのはいい判断。
この手の「環境ロック解除力」はかなり重要です。



windows wsl 構築手順
https://zenn.dev/long910/articles/2026-02-21-wsl-ubuntu-setup#ubuntu%E3%81%AE%E5%88%9D%E6%9C%9F%E8%A8%AD%E5%AE%9A


nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage

https://qiita.com/ksh-fthr/items/48dcc42c7a805320b49a

https://github.com/junegunn/fzf#setting-up-shell-integration

※以下はSymlinkではなく、syncするようにinstall.shを作成する
mizt ~/.config/wezterm (git: None)
❯ ln -s /mnt/c/Users/mizut/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua




pyenv

https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46

echo '' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

source ~/.zshrc


npm
sudo apt update
sudo apt install nodejs npm
