;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .emacs                                                                    ;;
;; Author: Pavel Penev                                                       ;;
;; Licence: MIT                                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This file describes a basic Emacs setup. Feel free to modify it to
;; your liking.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section I: Generic settings                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following 3 lines disable unnecessary GUI elements, in this case the
;; menu bar, the tool bar and the scroll bar. If you wish, you can comment out
;; the menu-bar and keep it, but eventually I recommend you disable it.

(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Sometimes the mini-buffer becomes multi-line, and it can be a bit annoying as
;; you type in it. This makes it stay one line.

(setq resize-mini-windows nil)

;; We don't need the Emacs splash screen. You can keep it on if you're into
;; that sort of thing

(setq inhibit-splash-screen t)

;;; global-linum-mode adds line numbers to all open windows, In my opinion
;;; there is no reason not to have this enabled.

(global-linum-mode)

;;; Emacs comes with a built-in text based browser. Since I use the browse-url
;;; function most often to browse documentation, I've set it to eww, the Emacs
;;; Web Browser. It works well for that purpose. If you would prefer to use a
;;; graphical browser, you can change this line.

(setq browse-url-browser-function 'eww-browse-url)

;;; I prefer to make the default font slightly smaller.

(set-face-attribute 'default nil :height 90)

;; Show matching parentecies globaly.

(show-paren-mode 1)

;; Use UTF-8 by default
(set-language-environment "UTF-8")

;; Don't ring the bell. It saves some annoyance

(setq ring-bell-function 'ignore)

;; If you're one of the heathens who prefers tabs over spaces, you should
;; remove the following line. It makes indentation use spaces.
(setq-default indent-tabs-mode nil)

;;; A simple backup setup. Makes sure I don't foo~ and #.foo files in
;;; directories with files you edit.

(setq
 backup-by-copying t      ; don't clobber symlinks-
 backup-directory-alist
 '(("." . "~/.saves"))    ; don't litter my fs tree
 auto-save-file-name-transforms
 `((".*" ,temporary-file-directory t))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups


;; Set up emacs server. This allows you to run emacs in the background and
;; connect to it with emacs client. It reduces startup time significantly. If
;; the server is not running, it starts it.

(load "server")

(unless (server-running-p)
  (server-start))

;;; ido-mode, or Interactively DO mode, adds lots of improvements when working
;;; with buffers of files. You can read more about it at:
;;; https://www.emacswiki.org/emacs-test/InteractivelyDoThings
(require 'ido)
(ido-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section II: Packages                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Elpa, the default package repository for emacs is fairly conservative, so
;; we'll add the melpa and marbaraie repositories
(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/"))

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

;; You can install packages by typing M-x package-install <package-name>. I
;; recomend you install the following packages: smex, which adds an improved
;; version of M-x. I highly recomend this. You can read more about smex at:
;; https://github.com/nonsequitur/smex/

;; Another ofthen used mode is magit, which is an interface to git, allowing
;; you to manage your repos through emacs. You can read more about it at:
;; http://magit.vc/ It is one of the most useful modes available for emacs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section III: Global Key Bindings                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; By default C-x o is bound to 'other window, but I find I use it much more
;; ofther than open-line, which is bound to C-o, so I swap their definitions
(global-set-key (kbd "C-o") 'other-window)
(global-set-key (kbd "C-x o") 'open-line)

;; M-0..3 are bound to 'digit-argument. To be used with C-u. I don't use them
;; ofthen, so I prefer to rebind them to the window commands, since M-1 is
;; easyer to type than C-x 1. 
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-2") 'split-window-vertically)
(global-set-key (kbd "M-3") 'split-window-horizontally)
(global-set-key (kbd "M-0") 'delete-window)

;; Set the enter key to newline-and-indent which inserts a new line and then
;; indents according to the major mode. This is very convenient. 
(global-set-key (kbd "<RET>") 'newline-and-indent)

;; If you have installed smex, you can uncomment the following lines. To
;; activate it without restarting Emacs select the lines and type M-x eval-region:

;; (require 'smex)

;; (global-set-key (kbd "M-x") 'smex) 
;; (global-set-key (kbd "M-X") 'smex-major-mode-commands) 
;; (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
