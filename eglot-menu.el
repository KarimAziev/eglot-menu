;;; eglot-menu.el --- Transient menu for Eglot -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Karim Aziiev <karim.aziiev@gmail.com>

;; Author: Karim Aziiev <karim.aziiev@gmail.com>
;; URL: https://github.com/KarimAziev/eglot-menu
;; Version: 0.1.0
;; Keywords: convenience
;; Package-Requires: ((emacs "29.1") (transient "0.7.3") (eglot "1.17"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Transient menu for Eglot

;;; Code:

(require 'transient)
(require 'eglot)

;;;###autoload
(defun eglot-menu-reconnect ()
  "Reconnect to the Eglot server and reopen the buffer at the same position."
  (interactive)
  (let ((file buffer-file-name)
        (buffer (current-buffer))
        (pos (point))
        (server (condition-case nil
                    (eglot--current-server-or-lose)
                  (error nil))))
    (when server
      (ignore-errors (eglot-reconnect server
                                      t)))
    (when (and file
               (or (not (buffer-modified-p
                         buffer))
                   (and (yes-or-no-p
                         "Save buffer?")
                        (progn (save-buffer)
                               t))))
      (kill-buffer buffer)
      (find-file file)
      (goto-char pos))
    (when server
      (eglot-ensure))))


;;;###autoload (autoload 'eglot-menu-transient "eglot-menu" nil t)
(transient-define-prefix eglot-menu-transient ()
  "A command dispatcher for various Eglot actions, find commands, and configurations."
  ["Eglot"
   ["Actions"
    ("c" "All possible code actions" eglot-code-actions)
    ("r" "Rename symbol" eglot-rename)
    ("f" "Format region" eglot-format)
    ("o" "Format buffer" eglot-format-buffer)
    ("." "Show Eldoc documentation at point" eldoc-doc-buffer)
    ("A" "All possible code actions" eglot-code-actions)
    ("O" "Organize imports" eglot-code-action-organize-imports)
    ("E" "Extract" eglot-code-action-extract)
    ("I" "Inline" eglot-code-action-inline)
    ("W" "Rewrite" eglot-code-action-rewrite)
    ("u" "Quickfix" eglot-code-action-quickfix)
    ("M" "Start LSP server" eglot)]
   ["Find"
    ("t" "Type Definition" eglot-find-typeDefinition)
    ("i" "Implementation" eglot-find-implementation)
    ("n" "Declaration" eglot-find-declaration)]
   ["Connection"
    ("l" "list connections" eglot-list-connections)
    ("R" "Reconnect to server" eglot-menu-reconnect)
    ("C" "Clear status" eglot-clear-status)
    ("g" "Forget pending requests" eglot-forget-pending-continuations)
    ("S" "Shutdown all servers" eglot-shutdown-all)
    ("Q" "Quit server" eglot-shutdown)]
   ["Config"
    ("s" "Show configuration" eglot-show-workspace-configuration)
    ("L" "Display events buffer" eglot-events-buffer)
    ("e" "Display stderr buffer" eglot-stderr-buffer)
    ("h" "Send a didChangeConfiguration signal"
     eglot-signal-didChangeConfiguration)]])


(provide 'eglot-menu)
;;; eglot-menu.el ends here