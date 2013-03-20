;;; pomodoro.el -- Time your pomodoros

;; Copyright (C) 2013  Luke Amdor

;; Authors: Luke Amdor <luke.amdor@gmail.com>
;; Keywords: productivity pomodoro
;; Version: 0.1

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary

;; See the README.markdown for information on intallation and usage.

(require 'timer)

(defvar pomodoro-current-timer nil)

(defvar pomodoro-duration-seconds (* 25 60))

(defvar pomodoro-start-hook nil)
(defvar pomodoro-void-hook nil)
(defvar pomodoro-finished-hook nil)

(defvar pomodoro-display-string "")

(defun pomodoro-display-time-left ()
  (interactive)
  (if pomodoro-current-timer
      (message (comcat "Pomodoro: "
                       (pomodoro-format-time-difference
                        (timer-until pomodoro-current-timer (current-time)))))
    (message "No current pomodoro")))

(defun pomodoro-format-time-difference (seconds)
  (let ((absolute-seconds (abs seconds)))
    (format "%s%02d:%02d" (if (< 0 seconds) "+" "-")
            (/ absolute-seconds 60)
            (% absolute-seconds 60))))

(defun pomodoro-set-display-on-mode-line (what)
  (setq pomodoro-display-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (or (memq 'pomodoro-display-string global-mode-string)
      (setq global-mode-string
            (append global-mode-string '(pomodoro-display-string))))
  (setq pomodoro-display-string what))

(defun pomodoro-display-message (msg)
  (let ((pomodoro-buffer (get-buffer-create "*Pomodoro*")))
    (switch-to-buffer pomodoro-buffer)
    (delete-other-windows)
    (toggle-read-only -1)
    (erase-buffer)
    (insert msg)
    (text-scale-increase 0)
    (text-scale-adjust 10)
    (local-set-key "q" 'bury-buffer)
    (toggle-read-only t)))

(defun pomodoro-finished ()
  (cancel-timer pomodoro-current-timer)
  (setq pomodoro-current-timer nil)
  (pomodoro-set-display-on-mode-line "")
  (pomodoro-display-message "Pomodoro Finished")
  (run-hooks 'pomodoro-finished-hook))

;;;###autoload
(defun pomodoro-start ()
  "Start a pomodoro timer"
  (interactive)
  (setq pomodoro-current-timer
        (run-at-time (time-add (current-time) (seconds-to-time pomodoro-duration-seconds))
                     nil
                     'pomodoro-finished))
  (pomodoro-set-display-on-mode-line " Pomodoro")
  (message "Pomodoro started")
  (run-hooks 'pomodoro-start-hook))

(defun pomodoro-void ()
  "Stops the current pomodoro timer"
  (interactive)
  (cancel-timer pomodoro-current-timer)
  (setq pomodoro-current-timer nil)
  (pomodoro-set-display-on-mode-line "")
  (message "Pomodoro voided")
  (run-hooks 'pomodoro-void-hook))

(provide 'pomodoro)
